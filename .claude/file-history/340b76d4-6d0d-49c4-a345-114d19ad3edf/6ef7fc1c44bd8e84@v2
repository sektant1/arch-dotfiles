import type { GLContext } from './GLContext';
import type { QuadBatcher } from './QuadBatcher';

export type BlendMode = 'BLEND' | 'ADD' | 'NONE';

export class BlendManager {
  private current: BlendMode | '' = '';
  private ctx!: GLContext;
  private batcher!: QuadBatcher;
  currentProg: WebGLProgram | null = null;

  init(ctx: GLContext, batcher: QuadBatcher) {
    this.ctx = ctx;
    this.batcher = batcher;
  }

  setBlend(mode: BlendMode) {
    if (mode === this.current) return;
    this.batcher.flush();
    this.current = mode;
    const gl = this.ctx.gl;
    switch (mode) {
      case 'BLEND':
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
        break;
      case 'ADD':
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
        break;
      case 'NONE':
        gl.disable(gl.BLEND);
        break;
    }
  }

  useProgram(prog: WebGLProgram) {
    if (prog !== this.currentProg) {
      this.batcher.flush();
      this.currentProg = prog;
      this.ctx.gl.useProgram(prog);
    }
  }
}
