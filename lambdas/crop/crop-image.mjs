import sharp from "sharp";

export const SIZE = 40;

const CIRCLE_MASK = Buffer.from(
    `<svg width="${SIZE}" height="${SIZE}" xmlns="http://www.w3.org/2000/svg">` +
    `<circle cx="${SIZE / 2}" cy="${SIZE / 2}" r="${SIZE / 2}" fill="#fff"/></svg>`
);


export async function circularPng(inputBuffer) {
    return sharp(inputBuffer)
        .rotate() // respeta orientacion EXIF
        .resize(SIZE, SIZE, { fit: "cover" })
        .ensureAlpha()
        .composite([{ input: CIRCLE_MASK, blend: "dest-in" }])
        .png()
        .toBuffer();
}