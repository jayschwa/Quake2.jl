import GL
import GLFW

const vertex_shader_src = "
#version 420

uniform mat4 ModelMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjMatrix;

in vec3 VertexPosition;
in vec3 VertexColor;

out vec3 Color;

void main()
{
	Color = VertexColor;
	gl_Position = ProjMatrix * ViewMatrix * ModelMatrix * vec4(VertexPosition, 1.0);
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

const near = 1
const far = 1000
projMatrix = float32(eye(4))
fov = 90.0

function translationMatrix(x::Number, y::Number, z::Number)
	T = float32(eye(4))
	T[13] = float32(x)
	T[14] = float32(y)
	T[15] = float32(z)
	return T
end

modelMatrix = translationMatrix(0, 0, 0)

function updateProjMatrix(width::Cint, height::Cint)
	GL.Viewport(width, height)

	fov_w = fov
	fov_h = fov
	if width > height
		fov_h *= height / width
	else
		fov_w *= width / height
	end
	w = 1 / tan(fov_w * pi / 360)
	h = 1 / tan(fov_h * pi / 360)
	Q = far / (far - near)

	projMatrix[1] = w
	projMatrix[6] = h
	projMatrix[11] = Q
	projMatrix[12] = -Q * near
	projMatrix[15] = 1
	projMatrix[16] = 0

	return
end

GLFW.Init()
GLFW.OpenWindowHint(GLFW.OPENGL_VERSION_MAJOR, 4)
GLFW.OpenWindowHint(GLFW.OPENGL_VERSION_MINOR, 2)
GLFW.OpenWindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)
GLFW.OpenWindowHint(GLFW.OPENGL_FORWARD_COMPAT, 1)
GLFW.OpenWindow(0, 0, 8, 8, 8, 8, 16, 0, GLFW.WINDOW)
GLFW.SetWindowTitle("GL for Julia")
GLFW.SetWindowSizeCallback(updateProjMatrix)
GLFW.SwapInterval(0)

GL.Enable(GL.CULL_FACE)
GL.Enable(GL.DEPTH_TEST)

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
uView = GL.GetUniformLocation(prog, "ViewMatrix")
uProj = GL.GetUniformLocation(prog, "ProjMatrix")
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
tic()

cam_speed = 0.5 # unit/sec
cam_pos = float32([-3, 0, 0])

m_captured = false
function m_capture(capture::Bool)
	if capture
		GLFW.Disable(GLFW.MOUSE_CURSOR)
		#GLFW.SetMousePos(0, 0)
		global m_captured = true
	else
		GLFW.Enable(GLFW.MOUSE_CURSOR)
		global m_captured = false
	end
end
m_capture() = m_captured

const m_pitch = 0.05
const m_yaw = 0.05

function sphereToCartesian(yaw::Number, pitch::Number)
	# apply scalar and convert to radians
	yaw = m_yaw * yaw * (pi / 180)
	pitch = m_pitch * pitch * (pi / 180)

	x = cos(yaw)*cos(pitch)
	y = sin(yaw)*cos(pitch)
	z = sin(pitch)
	return Float32[x, y, z]
end

function rotationMatrix(eyeDir::Vector, upDir::Vector)
	rightDir = cross(eyeDir, upDir)
	rightDir /= norm(rightDir)
	upDir = cross(rightDir, eyeDir)

	rotMat = float32(eye(4))

	rotMat[1] = rightDir[1]
	rotMat[5] = rightDir[2]
	rotMat[9] = rightDir[3]

	rotMat[2] = upDir[1]
	rotMat[6] = upDir[2]
	rotMat[10] = upDir[3]

	rotMat[3] = -eyeDir[1]
	rotMat[7] = -eyeDir[2]
	rotMat[11] = -eyeDir[3]

	return rotMat
end

while GLFW.GetWindowParam(GLFW.OPENED)
	if m_capture()
		m_pos = GLFW.GetMousePos()
		m_pos = (-m_pos[1], -m_pos[2])
		eyeDir = sphereToCartesian(m_pos...)
	else
		eyeDir = sphereToCartesian(0, 0)
	end
	rightDir = cross(eyeDir, Float32[0, 0, 1])
	rightDir /= norm(rightDir)
	rotMat = rotationMatrix(eyeDir, float32([0, 0, 1]))
	dist = cam_speed * toq()
	if m_capture()
		if GLFW.GetKey(',')
			cam_pos += dist * eyeDir
		end
		if GLFW.GetKey('A')
			cam_pos -= dist * rightDir
		end
		if GLFW.GetKey('O')
			cam_pos -= dist * eyeDir
		end
		if GLFW.GetKey('E')
			cam_pos += dist * rightDir
		end
		if GLFW.GetKey(' ')
			cam_pos[3] += dist
		end
		if GLFW.GetKey(GLFW.KEY_LCTRL)
			cam_pos[3] -= dist
		end
		#GLFW.SetMousePos(0, 0)
	end
	if GLFW.GetMouseButton(GLFW.MOUSE_BUTTON_LEFT)
		m_capture(true)
	end
	if GLFW.GetKey(GLFW.KEY_ESC)
		m_capture(false)
	end
	tic()

	GL.Clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT)
	GL.UseProgram(prog)
	GL.UniformMatrix4fv(uModel, modelMatrix)
	transMat = translationMatrix(-cam_pos[1], -cam_pos[2], -cam_pos[3])
	viewMat = rotMat * transMat
	GL.UniformMatrix4fv(uView, viewMat)
	GL.UniformMatrix4fv(uProj, projMatrix)
	GL.BindVertexArray(vao)
	GL.DrawElements(GL.TRIANGLES, indices)
	GL.BindVertexArray(0)

	GLFW.SwapBuffers()
	frames += 1
end

toq()
seconds = toc()
println(frames / seconds, " FPS")

GLFW.Terminate()
