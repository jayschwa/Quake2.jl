import GL
import GLFW

const vertex_shader_src = "
#version 420

uniform mat4 ModelMatrix;

in vec3 VertexPosition;
in vec3 VertexColor;

out vec3 Color;

void main()
{
	Color = VertexColor;
	gl_Position = ModelMatrix * vec4(VertexPosition, 1.0);
}
"

const fragment_shader_src = "
#version 420

in vec3 Color;

out vec4 FragColor;

void main()
{
	FragColor = vec4(Color, 1.0);
}
"

const positionData = Float32[
	-0.5, -0.5, -0.5,
	-0.5, -0.5, 0.5,
	-0.5, 0.5, -0.5,
	-0.5, 0.5, 0.5,
	0.5, -0.5, -0.5,
	0.5, -0.5, 0.5,
	0.5, 0.5, -0.5,
	0.5, 0.5, 0.5,
]

const colorData = Float32[
	0, 0, 0,
	0, 0, 1,
	0, 1, 0,
	0, 1, 1,
	1, 0, 0,
	1, 0, 1,
	1, 1, 0,
	1, 1, 1,
]

const indices = Uint8[
	0, 2, 1,
	2, 3, 1,
	0, 1, 5,
	4, 0, 5,
	4, 5, 6,
	5, 7, 6,
	2, 6, 3,
	6, 7, 3,
	0, 6, 2,
	0, 4, 6,
	1, 3, 7,
	1, 7, 5,
]

const modelMatrix = float32(eye(4))

GLFW.Init()
GLFW.OpenWindowHint(GLFW.OPENGL_VERSION_MAJOR, 4)
GLFW.OpenWindowHint(GLFW.OPENGL_VERSION_MINOR, 2)
GLFW.OpenWindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)
GLFW.OpenWindowHint(GLFW.OPENGL_FORWARD_COMPAT, 1)
GLFW.OpenWindow(0, 0, 0, 0, 0, 0, 0, 0, GLFW.WINDOW)
GLFW.SetWindowTitle("GL for Julia")

println("Vendor:   ", GL.GetString(GL.VENDOR))
println("Renderer: ", GL.GetString(GL.RENDERER))
println("Version:  ", GL.GetString(GL.VERSION))
println("GLSL:     ", GL.GetString(GL.SHADING_LANGUAGE_VERSION))

vertex_shader = GL.CreateShader(GL.VERTEX_SHADER)
GL.ShaderSource(vertex_shader, vertex_shader_src)
GL.CompileShader(vertex_shader)

fragment_shader = GL.CreateShader(GL.FRAGMENT_SHADER)
GL.ShaderSource(fragment_shader, fragment_shader_src)
GL.CompileShader(fragment_shader)

prog = GL.CreateProgram()
GL.AttachShader(prog, vertex_shader)
GL.AttachShader(prog, fragment_shader)
GL.LinkProgram(prog)

uModel = GL.GetUniformLocation(prog, "ModelMatrix")
aPosition = GL.GetAttribLocation(prog, "VertexPosition")
aColor = GL.GetAttribLocation(prog, "VertexColor")

vao = GL.GenVertexArray()
GL.BindVertexArray(vao)

positionBuf = GL.GenBuffer()
GL.BindBuffer(GL.ARRAY_BUFFER, positionBuf)
GL.BufferData(GL.ARRAY_BUFFER, positionData, GL.STATIC_DRAW)
GL.EnableVertexAttribArray(aPosition)
GL.VertexAttribPointer(aPosition, 3, GL.FLOAT, false, 0, 0)
GL.BindBuffer(GL.ARRAY_BUFFER, 0)

colorBuf = GL.GenBuffer()
GL.BindBuffer(GL.ARRAY_BUFFER, colorBuf)
GL.BufferData(GL.ARRAY_BUFFER, colorData, GL.STATIC_DRAW)
GL.EnableVertexAttribArray(aColor)
GL.VertexAttribPointer(aColor, 3, GL.FLOAT, false, 0, 0)
GL.BindBuffer(GL.ARRAY_BUFFER, 0)

GL.BindVertexArray(0)

frames = 0
tic()

while GLFW.GetWindowParam(GLFW.OPENED)
	GL.UseProgram(prog)
	GL.UniformMatrix4fv(uModel, modelMatrix)
	GL.BindVertexArray(vao)
	GL.DrawElements(GL.TRIANGLE_STRIP, indices)
	GL.BindVertexArray(0)

	GLFW.SwapBuffers()
	frames += 1
end

seconds = toq()
println(frames / seconds, " FPS")

GLFW.Terminate()
