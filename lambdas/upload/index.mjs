import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import busboy from 'busboy';
import { v4 as uuidv4 } from 'uuid';
import { Readable } from 'stream';

const s3Client = new S3Client({});

const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
const EXTENSION_MAP = {
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/gif': 'gif',
    'image/webp': 'webp'
};

const MAX_FILE_SIZE = 4 * 1024 * 1024; // 4 MiB (safe limit for API Gateway 6MB sync limit + base64 overhead)

export const handler = async (event) => {
    console.log("Event:", JSON.stringify(event));
    const environment = process.env.ENVIRONMENT || 'unknown';
    
    try {
        const contentType = event.headers['content-type'] || event.headers['Content-Type'];
        if (!contentType) {
            return formatResponse(400, { message: 'Missing Content-Type header', environment });
        }

        let bodyBuffer;
        if (event.isBase64Encoded) {
            bodyBuffer = Buffer.from(event.body, 'base64');
        } else {
            bodyBuffer = Buffer.from(event.body || '');
        }

        if (bodyBuffer.length > MAX_FILE_SIZE) {
            return formatResponse(413, { message: 'Payload too large. Max size is 4 MiB.', environment });
        }

        // Support both JSON with base64 embedded or multipart/form-data
        if (contentType.includes('application/json')) {
            return await handleJsonPayload(bodyBuffer, environment);
        } else if (contentType.includes('multipart/form-data')) {
            return await handleMultipartPayload(bodyBuffer, contentType, environment);
        } else {
            return formatResponse(400, { message: 'Unsupported Content-Type. Use multipart/form-data or application/json', environment });
        }

    } catch (error) {
        console.error("Error processing upload:", error);
        return formatResponse(500, { message: 'Internal server error', error: error.message, environment });
    }
};

async function handleJsonPayload(bodyBuffer, environment) {
    try {
        const bodyStr = bodyBuffer.toString('utf8');
        const parsedBody = JSON.parse(bodyStr);
        
        const { fileBase64, mimeType } = parsedBody;
        if (!fileBase64 || !mimeType) {
            return formatResponse(400, { message: 'Missing fileBase64 or mimeType in JSON', environment });
        }

        if (!ALLOWED_MIME_TYPES.includes(mimeType)) {
            return formatResponse(400, { message: `Unsupported MIME type: ${mimeType}`, environment });
        }

        const fileBuffer = Buffer.from(fileBase64, 'base64');
        return await uploadToS3(fileBuffer, mimeType, environment);
    } catch (e) {
        return formatResponse(400, { message: 'Invalid JSON payload', environment });
    }
}

function handleMultipartPayload(bodyBuffer, contentType, environment) {
    return new Promise((resolve, reject) => {
        const bb = busboy({ headers: { 'content-type': contentType }, limits: { fileSize: MAX_FILE_SIZE } });
        let fileProcessed = false;
        
        bb.on('file', (name, file, info) => {
            const { mimeType } = info;
            
            if (!ALLOWED_MIME_TYPES.includes(mimeType)) {
                file.resume(); // discard
                return resolve(formatResponse(400, { message: `Unsupported MIME type: ${mimeType}`, environment }));
            }

            const chunks = [];
            file.on('data', (data) => {
                chunks.push(data);
            });

            file.on('end', async () => {
                fileProcessed = true;
                const fileBuffer = Buffer.concat(chunks);
                try {
                    const response = await uploadToS3(fileBuffer, mimeType, environment);
                    resolve(response);
                } catch (err) {
                    resolve(formatResponse(500, { message: 'Failed to upload S3', error: err.message, environment }));
                }
            });
            
            file.on('limit', () => {
                resolve(formatResponse(413, { message: 'File too large', environment }));
            });
        });

        bb.on('finish', () => {
            if (!fileProcessed) {
                resolve(formatResponse(400, { message: 'No file found in payload', environment }));
            }
        });

        bb.on('error', (err) => {
            resolve(formatResponse(500, { message: 'Error parsing multipart', environment }));
        });

        const readable = new Readable();
        readable.push(bodyBuffer);
        readable.push(null);
        readable.pipe(bb);
    });
}

async function uploadToS3(fileBuffer, mimeType, environment) {
    const bucket = process.env.S3_BUCKET;
    const prefix = process.env.UPLOAD_PREFIX || 'uploads';
    const extension = EXTENSION_MAP[mimeType];
    const key = `${prefix}/${uuidv4()}.${extension}`;

    const command = new PutObjectCommand({
        Bucket: bucket,
        Key: key,
        Body: fileBuffer,
        ContentType: mimeType,
    });

    await s3Client.send(command);

    return formatResponse(200, {
        message: 'Upload successful',
        key: key,
        environment
    });
}

function formatResponse(statusCode, body) {
    return {
        statusCode,
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
    };
}
