import type { TextureEntry } from '../types';
import type { GLContext } from './GLContext';

const MAX_QUADS = 1024;
const FLOATS_PER_VERTEX = 8; // x, y, u, v, r, g, b, a
const VERTS_PER_QUAD = 6;

export class QuadBatcher {
  private buf = new Float32Array(MAX_QUADS * VERTS_PER_QUAD * FLOATS_PER_VERTEX);
  private count = 0;
  batchTex: WebGLTexture | null = null;

  private vao!: WebGLVertexArrayObject;
  private vbo!: WebGLBuffer;
  private ctx!: GLContext;

  init(ctx: GLContext) {
    this.ctx = ctx;
    const gl = ctx.gl;

    this.vao = gl.createVertexArray()!;
    this.vbo = gl.createBuffer()!;
    gl.bindVertexArray(this.vao);
    gl.bindBuffer(gl.ARRAY_BUFFER, this.vbo);
    gl.bufferData(gl.ARRAY_BUFFER, this.buf.byteLength, gl.DYNAMIC_DRAW);
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(0, 2, gl.FLOAT, false, FLOATS_PER_VERTEX * 4, 0);
    gl.enableVertexAttribArray(1);
    gl.vertexAttribPointer(1, 2, gl.FLOAT, false, FLOATS_PER_VERTEX * 4, 8);
    gl.enableVertexAttribArray(2);
    gl.vertexAttribPointer(2, 4, gl.FLOAT, false, FLOATS_PER_VERTEX * 4, 16);
    gl.bindVertexArray(null);
  }

  flush() {
    if (this.count === 0) return;
    const gl = this.ctx.gl;
    gl.bindVertexArray(this.vao);
    gl.bindBuffer(gl.ARRAY_BUFFER, this.vbo);
    gl.bufferSubData(gl.ARRAY_BUFFER, 0, this.buf.subarray(0, this.count * VERTS_PER_QUAD * FLOATS_PER_VERTEX));
    gl.drawArrays(gl.TRIANGLES, 0, this.count * VERTS_PER_QUAD);
    gl.bindVertexArray(null);
    this.count = 0;
  }

  private pushRaw(x: number, y: number, w: number, h: number,
    u0: number, v0: number, u1: number, v1: number,
    r: number, g: number, b: number, a: number) {
    if (this.count >= MAX_QUADS) this.flush();
    const i = this.count * VERTS_PER_QUAD * FLOATS_PER_VERTEX;
    const x2 = x + w, y2 = y + h;
    const buf = this.buf;
    buf[i]    = x;  buf[i+1]  = y;  buf[i+2]  = u0; buf[i+3]  = v0;
    buf[i+4]  = r;  buf[i+5]  = g;  buf[i+6]  = b;  buf[i+7]  = a;
    buf[i+8]  = x2; buf[i+9]  = y;  buf[i+10] = u1; buf[i+11] = v0;
    buf[i+12] = r;  buf[i+13] = g;  buf[i+14] = b;  buf[i+15] = a;
    buf[i+16] = x;  buf[i+17] = y2; buf[i+18] = u0; buf[i+19] = v1;
    buf[i+20] = r;  buf[i+21] = g;  buf[i+22] = b;  buf[i+23] = a;
    buf[i+24] = x2; buf[i+25] = y;  buf[i+26] = u1; buf[i+27] = v0;
    buf[i+28] = r;  buf[i+29] = g;  buf[i+30] = b;  buf[i+31] = a;
    buf[i+32] = x2; buf[i+33] = y2; buf[i+34] = u1; buf[i+35] = v1;
    buf[i+36] = r;  buf[i+37] = g;  buf[i+38] = b;  buf[i+39] = a;
    buf[i+40] = x;  buf[i+41] = y2; buf[i+42] = u0; buf[i+43] = v1;
    buf[i+44] = r;  buf[i+45] = g;  buf[i+46] = b;  buf[i+47] = a;
    this.count++;
  }

  drawQuad(x: number, y: number, w: number, h: number,
    texEntry: TextureEntry | null,
    u0: number, v0: number, u1: number, v1: number,
    r = 1, g = 1, b = 1, a = 1) {
    const gl = this.ctx.gl;
    const whiteTex = (this.ctx as any)._texManager?.whiteTex;
    const t = texEntry ? texEntry.tex : (whiteTex || null);
    if (t !== this.batchTex) {
      this.flush();
      this.batchTex = t;
      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, t);
    }
    const dpr = this.ctx.dpr;
    this.pushRaw(x * dpr, y * dpr, w * dpr, h * dpr, u0, v0, u1, v1, r, g, b, a);
  }

  drawQuadRotated(x: number, y: number, w: number, h: number,
    texEntry: TextureEntry | null,
    u0: number, v0: number, u1: number, v1: number) {
    const gl = this.ctx.gl;
    const whiteTex = (this.ctx as any)._texManager?.whiteTex;
    const t = texEntry ? texEntry.tex : (whiteTex || null);
    if (t !== this.batchTex) {
      this.flush();
      this.batchTex = t;
      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, t);
    }
    if (this.count >= MAX_QUADS) this.flush();
    const dpr = this.ctx.dpr;
    const px = x * dpr, py = y * dpr, pw = w * dpr, ph = h * dpr;
    const x2 = px + pw, y2 = py + ph;
    const i = this.count * VERTS_PER_QUAD * FLOATS_PER_VERTEX;
    const r = 1, g = 1, b = 1, a = 1;
    const buf = this.buf;
    buf[i]    = px; buf[i+1]  = py; buf[i+2]  = u0; buf[i+3]  = v1;
    buf[i+4]  = r;  buf[i+5]  = g;  buf[i+6]  = b;  buf[i+7]  = a;
    buf[i+8]  = x2; buf[i+9]  = py; buf[i+10] = u0; buf[i+11] = v0;
    buf[i+12] = r;  buf[i+13] = g;  buf[i+14] = b;  buf[i+15] = a;
    buf[i+16] = px; buf[i+17] = y2; buf[i+18] = u1; buf[i+19] = v1;
    buf[i+20] = r;  buf[i+21] = g;  buf[i+22] = b;  buf[i+23] = a;
    buf[i+24] = x2; buf[i+25] = py; buf[i+26] = u0; buf[i+27] = v0;
    buf[i+28] = r;  buf[i+29] = g;  buf[i+30] = b;  buf[i+31] = a;
    buf[i+32] = x2; buf[i+33] = y2; buf[i+34] = u1; buf[i+35] = v0;
    buf[i+36] = r;  buf[i+37] = g;  buf[i+38] = b;  buf[i+39] = a;
    buf[i+40] = px; buf[i+41] = y2; buf[i+42] = u1; buf[i+43] = v1;
    buf[i+44] = r;  buf[i+45] = g;  buf[i+46] = b;  buf[i+47] = a;
    this.count++;
  }
}
