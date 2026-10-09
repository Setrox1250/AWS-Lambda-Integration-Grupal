import { S3Client, GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import { circularPng } from "./crop-image.mjs";

const s3 = new S3Client({});
const PROCESSED_PREFIX = process.env.PROCESSED_PREFIX || "processed/";
const UPLOAD_PREFIX = "uploads/";

async function streamToBuffer(stream) {
    const chunks = [];
    for await (const chunk of stream) chunks.push(chunk);
    return Buffer.concat(chunks);
}


export function outputKeyFor(key) {
    const file = key.slice(UPLOAD_PREFIX.length);
    const dot = file.lastIndexOf(".");
    const base = dot > 0 ? file.slice(0, dot) : file;
    return `${PROCESSED_PREFIX}${base}_circular.png`;
}

async function processS3Record(s3Record) {
    const bucket = s3Record.s3.bucket.name;

    const key = decodeURIComponent(s3Record.s3.object.key.replace(/\+/g, " "));

    if (!key.startsWith(UPLOAD_PREFIX)) {
        console.log(JSON.stringify({ msg: "Clave ignorada (no es uploads/)", key }));
        return;
    }

    const obj = await s3.send(new GetObjectCommand({ Bucket: bucket, Key: key }));
    const input = await streamToBuffer(obj.Body);
    const output = await circularPng(input);
    const outKey = outputKeyFor(key);

    await s3.send(
        new PutObjectCommand({
            Bucket: bucket,
            Key: outKey,
            Body: output,
            ContentType: "image/png",
        })
    );
    console.log(JSON.stringify({ msg: "Imagen procesada", from: key, to: outKey, bytes: output.length }));
}

export const handler = async (event) => {
    const batchItemFailures = [];

    for (const record of event.Records ?? []) {
        try {
            const body = JSON.parse(record.body);

            if (body.Event === "s3:TestEvent") continue;

            for (const s3Record of body.Records ?? []) {
                await processS3Record(s3Record);
            }
        } catch (err) {
            console.error(JSON.stringify({ msg: "Error procesando mensaje", messageId: record.messageId, error: err.message }));
            batchItemFailures.push({ itemIdentifier: record.messageId });
        }
    }

    return { batchItemFailures };
};