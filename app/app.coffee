`import WebGLDebugUtils from "webgl-debug"`

createGLContext = (canvas) ->
  names = [
    "webgl"
    "experimental-webgl"
  ]
  context = null
  i = 0

  while i < names.length
    try
      context = canvas.getContext(names[i])
    break  if context
    i++
  if context
    context.viewportWidth = canvas.width
    context.viewportHeight = canvas.height
  else
    alert "Failed to create WebGL context!"
  context

loadShader = (shaderName, type) ->
  Qajax(shaderName).then (shaderXhr) ->
    if type is "fragment"
      shader = gl.createShader(gl.FRAGMENT_SHADER)
    else if type is "vertex"
      shader = gl.createShader(gl.VERTEX_SHADER)
    else
      return null
    gl.shaderSource shader, shaderXhr.responseText
    gl.compileShader shader
    unless gl.getShaderParameter(shader, gl.COMPILE_STATUS)
      alert gl.getShaderInfoLog(shader)
      return null
    shader

setupShaders = (vertexShader, fragmentShader) ->
  shaderProgram = gl.createProgram()
  gl.attachShader shaderProgram, vertexShader
  gl.attachShader shaderProgram, fragmentShader
  gl.linkProgram shaderProgram
  alert "Failed to setup shaders"  unless gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)
  gl.useProgram shaderProgram
  shaderProgram.vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "aVertexPosition")
  shaderProgram

setupBuffers = ->
  vertexBuffer = gl.createBuffer()
  gl.bindBuffer gl.ARRAY_BUFFER, vertexBuffer
  triangleVertices = [
    0.0
    0.5
    0.0
    -0.5
    -0.5
    0.0
    0.5
    -0.5
    0.0
  ]
  gl.bufferData gl.ARRAY_BUFFER, new Float32Array(triangleVertices), gl.STATIC_DRAW
  vertexBuffer.itemSize = 3
  vertexBuffer.numberOfItems = 3
  vertexBuffer

draw = (shaderProgram, vertexBuffer) ->
  gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
  gl.clear gl.COLOR_BUFFER_BIT
  gl.vertexAttribPointer shaderProgram.vertexPositionAttribute, vertexBuffer.itemSize, gl.FLOAT, false, 0, 0
  gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute
  gl.drawArrays gl.TRIANGLES, 0, vertexBuffer.numberOfItems

gl = undefined
canvas = undefined
startup = ->
  canvas = document.getElementById 'myGLCanvas'
  gl = WebGLDebugUtils.makeDebugContext createGLContext canvas
  loadShader('vertex.glsl', 'vertex').then (v) ->
    loadShader('fragment.glsl', 'fragment').then (f) ->
      shader = setupShaders v, f
      buffer = setupBuffers()
      gl.clearColor 0.0, 0.0, 0.0, 1.0
      draw shader, buffer

`export default startup`
