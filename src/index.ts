import type {} from "npm:@webgpu/types"

const canvas = document.getElementById("canvas") as HTMLCanvasElement
const ctx = canvas.getContext("2d")

if (!("gpu" in navigator)) {
  alert("WebGPU is not supported.")
  throw 0
}

const gpu = navigator.gpu as GPU
const adapter = await gpu.requestAdapter()
if (!adapter) {
  alert("Failed to get GPU adapter.")
  throw 0
}
const device = await adapter.requestDevice()

const shaderModule = device.createShaderModule({
  code: await fetch("./index.wgsl").then((r) => r.text()),
})

const bindGroupLayout = device.createBindGroupLayout({
  entries: [
    {
      binding: 0,
      visibility: GPUShaderStage.COMPUTE,
      buffer: { type: "read-only-storage" },
    },
    {
      binding: 1,
      visibility: GPUShaderStage.COMPUTE,
      buffer: { type: "storage" },
    },
    {
      binding: 2,
      visibility: GPUShaderStage.COMPUTE,
      buffer: { type: "storage" },
    },
  ],
})

const pipeline = device.createComputePipeline({
  layout: device.createPipelineLayout({
    bindGroupLayouts: [bindGroupLayout],
  }),
  compute: {
    module: shaderModule,
    entryPoint: "main",
  },
})

let width = 0
let height = 0
let bufferSize = 0

const configWrite = device.createBuffer({
  size: 32,
  usage: GPUBufferUsage.MAP_WRITE | GPUBufferUsage.COPY_SRC,
})
const config = device.createBuffer({
  size: 32,
  usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
})
let store!: GPUBuffer
let output!: GPUBuffer
let read!: GPUBuffer
let bindGroup!: GPUBindGroup

renderLoop()

function init(size: number) {
  if (bufferSize >= size) return
  size = Math.ceil(size / 1024) * 1024
  bufferSize = size

  store?.destroy()
  store = device.createBuffer({
    size: size * 4,
    usage: GPUBufferUsage.STORAGE,
  })

  output?.destroy()
  output = device.createBuffer({
    size,
    usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC,
  })

  read?.destroy()
  read = device.createBuffer({
    size,
    usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ,
  })

  bindGroup = device.createBindGroup({
    layout: bindGroupLayout,
    entries: [
      { binding: 0, resource: { buffer: config } },
      { binding: 1, resource: { buffer: store } },
      { binding: 2, resource: { buffer: output } },
    ],
  })
}

function resize() {
  if (width !== window.innerWidth) {
    width = canvas.width = window.innerWidth
  }
  if (height !== window.innerHeight) {
    height = canvas.height = window.innerHeight
  }
}

async function render(time: number, iteration: number) {
  const commandEncoder = device.createCommandEncoder()

  const imageSize = width * height * 4
  init(imageSize)

  await configWrite.mapAsync(GPUMapMode.WRITE)
  const configBuffer = configWrite.getMappedRange()
  new Uint32Array(configBuffer).set([width, height, time, iteration])
  configWrite.unmap()

  commandEncoder.copyBufferToBuffer(configWrite, 0, config, 0, config.size)

  const computePass = commandEncoder.beginComputePass()
  computePass.setPipeline(pipeline)
  computePass.setBindGroup(0, bindGroup)
  computePass.dispatchWorkgroups(Math.ceil(width / 8), Math.ceil(height / 8))
  computePass.end()

  commandEncoder.copyBufferToBuffer(output, 0, read, 0, bufferSize)

  device.queue.submit([commandEncoder.finish()])

  await read.mapAsync(GPUMapMode.READ)
  const out = read.getMappedRange()

  const img = new ImageData(
    new Uint8ClampedArray(out, 0, imageSize),
    width,
    height,
  )
  ctx?.putImageData(img, 0, 0)
  read.unmap()
}

async function renderLoop() {
  const start = Date.now()
  let iteration = 0
  while (true) {
    console.time("frame")
    resize()
    await render(Date.now() - start, iteration)
    console.timeEnd("frame")
    await new Promise((r) => window.requestAnimationFrame(r))
    iteration++
  }
}
