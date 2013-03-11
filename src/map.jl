import GL
import GLFW

include("bsp.jl")

const vertex_shader_src = "
#version 420

uniform mat4 ModelMatrix;
uniform mat4 ViewMatrix;
uniform mat4 ProjMatrix;

in vec3 VertexPosition;

out vec3 Color;

void main()
{
	const float cs = 500.0;
	Color = mod(abs(VertexPosition), cs) / cs;
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

const near = 4
const far = 16384
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

	aspect = width / height
	ymax = near * tan(fov * pi / 360)
	ymin = -ymax
	xmin = ymin * aspect
	xmax = ymax * aspect

	x = (2*near) / (xmax-xmin)
	y = (2*near) / (ymax-ymin)
	a = (xmax+xmin) / (xmax-xmin)
	b = (ymax+ymin) / (ymax-ymin)
	c = -(far+near) / (far-near)
	d = -(2*far*near) / (far-near)

	projMatrix[1,1] = x
	projMatrix[1,3] = a
	projMatrix[2,2] = y
	projMatrix[2,3] = b
	projMatrix[3,3] = c
	projMatrix[3,4] = d
	projMatrix[4,3] = -1
	projMatrix[4,4] = 0

	return
end

bspFile = open(ARGS[1])
bsp = bspRead(bspFile)
close(bspFile)

GLFW.Init()
GLFW.OpenWindowHint(GLFW.OPENGL_VERSION_MAJOR, 4)
GLFW.OpenWindowHint(GLFW.OPENGL_VERSION_MINOR, 2)
GLFW.OpenWindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)
GLFW.OpenWindowHint(GLFW.OPENGL_FORWARD_COMPAT, 1)
GLFW.OpenWindow(0, 0, 0, 0, 0, 0, 0, 0, GLFW.WINDOW)
GLFW.SetWindowTitle("Quake 2.jl")
GLFW.SetWindowSizeCallback(updateProjMatrix)
GLFW.SwapInterval(0)

println("Red bits:     ", GLFW.GetWindowParam(GLFW.RED_BITS))
println("Green bits:   ", GLFW.GetWindowParam(GLFW.GREEN_BITS))
println("Blue bits:    ", GLFW.GetWindowParam(GLFW.BLUE_BITS))
println("Alpha bits:   ", GLFW.GetWindowParam(GLFW.ALPHA_BITS))
println("Depth bits:   ", GLFW.GetWindowParam(GLFW.DEPTH_BITS))
println("Stencil bits: ", GLFW.GetWindowParam(GLFW.STENCIL_BITS))

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

vao = GL.GenVertexArray()
GL.BindVertexArray(vao)

positionBuf = GL.GenBuffer()
GL.BindBuffer(GL.ARRAY_BUFFER, positionBuf)
GL.BufferData(GL.ARRAY_BUFFER, bsp.vertices, GL.STATIC_DRAW)
GL.EnableVertexAttribArray(aPosition)
GL.VertexAttribPointer(aPosition, 3, GL.FLOAT, false, 0, 0)
GL.BindBuffer(GL.ARRAY_BUFFER, 0)

GL.BindVertexArray(0)

frames = 0
tic()
tic()

cam_speed = 200 # unit/sec
cam_pos = float32([-3, 0, 0])

m_captured = false
function m_capture(capture::Bool)
	if capture
		GLFW.Disable(GLFW.MOUSE_CURSOR)
		GLFW.SetMousePos(0, 0)
		global m_captured = true
	else
		GLFW.Enable(GLFW.MOUSE_CURSOR)
		global m_captured = false
	end
end
m_capture() = m_captured

# cursor xy to degree ratio
const m_pitch = 0.05
const m_yaw = 0.05

cam_yaw = 0
cam_pitch = 0

function mouseToSphere(xdelta::Real, ydelta::Real)
	global cam_yaw -= m_yaw * xdelta
	global cam_pitch -= m_pitch * ydelta
	global cam_pitch = clamp(cam_pitch, -89, 89)
	return (cam_yaw, cam_pitch)
end

function sphereToCartesian(yaw::Real, pitch::Real)
	# convert to radians
	yaw *= (pi / 180)
	pitch *= (pi / 180)

	x = cos(yaw)*cos(pitch)
	y = sin(yaw)*cos(pitch)
	z = sin(pitch)
	return Float32[x, y, z]
end

function rotationMatrix{T<:Real}(eyeDir::Vector{T}, upDir::Vector{T})
	rightDir = cross(eyeDir, upDir)
	rightDir /= norm(rightDir)
	upDir = cross(rightDir, eyeDir)

	rotMat = eye(T, 4)
	rotMat[1,1:3] = rightDir
	rotMat[2,1:3] = upDir
	rotMat[3,1:3] = -eyeDir

	return rotMat
end

while GLFW.GetWindowParam(GLFW.OPENED)
	if m_capture()
		mouseToSphere(GLFW.GetMousePos()...)
		GLFW.SetMousePos(0, 0)
	end
	eyeDir = sphereToCartesian(cam_yaw, cam_pitch)
	rightDir = cross(eyeDir, Float32[0, 0, 1])
	rightDir /= norm(rightDir)
	rotMat = rotationMatrix(eyeDir, float32([0, 0, 1]))
	dist = cam_speed * toq()
	if m_capture()
		if GLFW.GetKey(GLFW.KEY_LSHIFT)
			dist *= 3
		end
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
	for face = bsp.faces
		GL.DrawElements(GL.TRIANGLES, face)
	end
	GL.BindVertexArray(0)

	GLFW.SwapBuffers()
	frames += 1
end

toq()
seconds = toc()
println(frames / seconds, " FPS")

GLFW.Terminate()
