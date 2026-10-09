import { test } from "node:test";
import assert from "node:assert/strict";
import sharp from "sharp";
import { circularPng } from "../crop-image.mjs";

async function sampleImage(format = "jpeg") {
    return sharp({
        create: { width: 200, height: 120, channels: 3, background: { r: 220, g: 40, b: 40 } },
    })[format]().toBuffer();
}

test("genera PNG 40x40 con canal alfa", async () => {
    const out = await circularPng(await sampleImage("jpeg"));
    const meta = await sharp(out).metadata();
    assert.equal(meta.format, "png");
    assert.equal(meta.width, 40);
    assert.equal(meta.height, 40);
    assert.equal(meta.channels, 4);
});

test("esquinas transparentes y centro opaco", async () => {
    const out = await circularPng(await sampleImage("png"));
    const { data, info } = await sharp(out).raw().toBuffer({ resolveWithObject: true });
    const alphaAt = (x, y) => data[(y * info.width + x) * 4 + 3];
    assert.equal(alphaAt(0, 0), 0);
    assert.equal(alphaAt(39, 39), 0);
    assert.equal(alphaAt(20, 20), 255);
});

test("es idempotente: misma entrada, misma salida", async () => {
    const input = await sampleImage("png");
    const a = await circularPng(input);
    const b = await circularPng(input);
    assert.deepEqual(a, b);
});