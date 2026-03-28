import { QUAD_VS, QUAD_FS, TILED_FS, ELLIPSE_FS } from './shaders';

function compileShader(gl: WebGL2RenderingContext, type: number, src: string): WebGLShader | null {
  const s = gl.createShader(type)!;
  gl.shaderSource(s, src);
  gl.compileShader(s);
  if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) {
    console.error('Shader:', gl.getShaderInfoLog(s));
    gl.deleteShader(s);
    return null;
  }
  return s;
}

function createProgram(gl: WebGL2RenderingContext, vsSrc: string, fsSrc: string): WebGLProgram | null {
  const vs = compileShader(gl, gl.VERTEX_SHADER, vsSrc);
  const fs = compileShader(gl, gl.FRAGMENT_SHADER, fsSrc);
  if (!vs || !fs) return null;
  const p = gl.createProgram()!;
  gl.attachShader(p, vs);
  gl.attachShader(p, fs);
  gl.linkProgram(p);
  if (!gl.getProgramParameter(p, gl.LINK_STATUS)) {
    console.error('Program:', gl.getProgramInfoLog(p));
    return null;
  }
  return p;
}

export interface ProgramLocs {
  resolution: WebGLUniformLocation | null;
  tex: WebGLUniformLocation | null;
  alphaMode: WebGLUniformLocation | null;
}

export interface TiledLocs extends ProgramLocs {
  quadSize: WebGLUniformLocation | null;
  tileSize: WebGLUniformLocation | null;
}

export interface EllipseLocs {
  resolution: WebGLUniformLocation | null;
  tex: WebGLUniformLocation | null;
  ellipseCenter: WebGLUniformLocation | null;
  ellipseRadius: WebGLUniformLocation | null;
  uvOffset: WebGLUniformLocation | null;
}

export class GLContext {
  gl!: WebGL2RenderingContext;
  canvas!: HTMLCanvasElement;
  canvasW = 0;
  canvasH = 0;
  dpr = 1;

  quadProg!: WebGLProgram;
  tiledProg!: WebGLProgram;
  ellipseProg!: WebGLProgram;

  quadLocs!: ProgramLocs;
  tiledLocs!: TiledLocs;
  ellipseLocs!: EllipseLocs;

  private resizeHandler = () => this.resize();

  init(canvas: HTMLCanvasElement) {
    this.canvas = canvas;
    this.gl = canvas.getContext('webgl2', {
      alpha: true,
      premultipliedAlpha: false,
      antialias: false,
      depth: false,
      stencil: true,
    })!;

    const gl = this.gl;

    this.quadProg = createProgram(gl, QUAD_VS, QUAD_FS)!;
    this.tiledProg = createProgram(gl, QUAD_VS, TILED_FS)!;
    this.ellipseProg = createProgram(gl, QUAD_VS, ELLIPSE_FS)!;

    this.quadLocs = {
      resolution: gl.getUniformLocation(this.quadProg, 'u_resolution'),
      tex: gl.getUniformLocation(this.quadProg, 'u_tex'),
      alphaMode: gl.getUniformLocation(this.quadProg, 'u_alphaMode'),
    };
    this.tiledLocs = {
      resolution: gl.getUniformLocation(this.tiledProg, 'u_resolution'),
      tex: gl.getUniformLocation(this.tiledProg, 'u_tex'),
      quadSize: gl.getUniformLocation(this.tiledProg, 'u_quadSize'),
      tileSize: gl.getUniformLocation(this.tiledProg, 'u_tileSize'),
      alphaMode: gl.getUniformLocation(this.tiledProg, 'u_alphaMode'),
    };
    this.ellipseLocs = {
      resolution: gl.getUniformLocation(this.ellipseProg, 'u_resolution'),
      tex: gl.getUniformLocation(this.ellipseProg, 'u_tex'),
      ellipseCenter: gl.getUniformLocation(this.ellipseProg, 'u_ellipseCenter'),
      ellipseRadius: gl.getUniformLocation(this.ellipseProg, 'u_ellipseRadius'),
      uvOffset: gl.getUniformLocation(this.ellipseProg, 'u_uvOffset'),
    };

    this.resize();
    window.addEventListener('resize', this.resizeHandler);
  }

  resize() {
    this.dpr = window.devicePixelRatio || 1;
    this.canvasW = window.innerWidth;
    this.canvasH = window.innerHeight;
    this.canvas.width = this.canvasW * this.dpr;
    this.canvas.height = this.canvasH * this.dpr;
    this.canvas.style.width = this.canvasW + 'px';
    this.canvas.style.height = this.canvasH + 'px';
    this.gl.viewport(0, 0, this.canvas.width, this.canvas.height);
  }

  destroy() {
    window.removeEventListener('resize', this.resizeHandler);
  }
}
