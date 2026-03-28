import type { TextureEntry } from '../types';
import type { GLContext } from './GLContext';
import type { QuadBatcher } from './QuadBatcher';
import type { BlendManager } from './BlendManager';

export function drawNineSlice(
  ctx: GLContext,
  batcher: QuadBatcher,
  blend: BlendManager,
  x: number, y: number, w: number, h: number,
  borderEntry: TextureEntry | null,
  cornerSize: number,
  tiledBgEntry: TextureEntry | null,
  tileSize: number,
  inset?: number
) {
  if (!borderEntry || !borderEntry.loaded) return;
  const gl = ctx.gl;
  const atlasW = borderEntry.width;
  const cellW = atlasW / 8;
  const cs = cornerSize;
  const ins = inset || 0;

  function cellUV(idx: number): [number, number, number, number] {
    const u0 = (idx * cellW) / atlasW;
    const u1 = ((idx + 1) * cellW) / atlasW;
    return [u0, 0, u1, 1];
  }

  // Tiled background
  if (tiledBgEntry && tiledBgEntry.loaded) {
    batcher.flush();
    blend.useProgram(ctx.tiledProg);
    gl.uniform2f(ctx.tiledLocs.resolution, ctx.canvasW * ctx.dpr, ctx.canvasH * ctx.dpr);
    gl.uniform1i(ctx.tiledLocs.tex, 0);
    gl.uniform2f(ctx.tiledLocs.quadSize, w - ins * 2, h - ins * 2);
    gl.uniform2f(ctx.tiledLocs.tileSize, tileSize, tileSize);
    gl.uniform1i(ctx.tiledLocs.alphaMode, 0);
    blend.setBlend('BLEND');
    batcher.batchTex = null;
    batcher.drawQuad(x + ins, y + ins, w - ins * 2, h - ins * 2, tiledBgEntry, 0, 0, 1, 1);
    batcher.flush();
    blend.useProgram(ctx.quadProg);
    gl.uniform2f(ctx.quadLocs.resolution, ctx.canvasW * ctx.dpr, ctx.canvasH * ctx.dpr);
    gl.uniform1i(ctx.quadLocs.tex, 0);
    gl.uniform1i(ctx.quadLocs.alphaMode, 0);
    batcher.batchTex = null;
  }

  blend.setBlend('BLEND');

  // Corners
  const [u4a, v4a, u4b, v4b] = cellUV(4);
  batcher.drawQuad(x, y, cs, cs, borderEntry, u4a, v4a, u4b, v4b);
  const [u5a, v5a, u5b, v5b] = cellUV(5);
  batcher.drawQuad(x + w - cs, y, cs, cs, borderEntry, u5a, v5a, u5b, v5b);
  const [u6a, v6a, u6b, v6b] = cellUV(6);
  batcher.drawQuad(x, y + h - cs, cs, cs, borderEntry, u6a, v6a, u6b, v6b);
  const [u7a, v7a, u7b, v7b] = cellUV(7);
  batcher.drawQuad(x + w - cs, y + h - cs, cs, cs, borderEntry, u7a, v7a, u7b, v7b);

  // Vertical edges
  const edgeH = h - cs * 2;
  if (edgeH > 0) {
    const [u0a, v0a, u0b, v0b] = cellUV(0);
    batcher.drawQuad(x, y + cs, cs, edgeH, borderEntry, u0a, v0a, u0b, v0b);
    const [u1a, v1a, u1b, v1b] = cellUV(1);
    batcher.drawQuad(x + w - cs, y + cs, cs, edgeH, borderEntry, u1a, v1a, u1b, v1b);
  }

  // Horizontal edges (rotated)
  const edgeW = w - cs * 2;
  if (edgeW > 0) {
    const [u2a, v2a, u2b, v2b] = cellUV(2);
    batcher.drawQuadRotated(x + cs, y, edgeW, cs, borderEntry, u2a, v2a, u2b, v2b);
    const [u3a, v3a, u3b, v3b] = cellUV(3);
    batcher.drawQuadRotated(x + cs, y + h - cs, edgeW, cs, borderEntry, u3a, v3a, u3b, v3b);
  }
}
