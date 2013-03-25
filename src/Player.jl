module Player

import GL

type State
	position::GL.Vec3
	pitch::Real
	yaw::Real
	movedir::GL.Vec3
	speed::Real
end
State() = State(GL.Vec3(0, 0, 0), 0, 0, GL.Vec3(0, 0, 0), 100)

function lookdir!(player::State, yaw::Real, pitch::Real)
	pitch *= (pi / 180)
	yaw *= (pi / 180)
	player.pitch += pitch
	pitch_bound = 89 * (pi / 180)
	player.pitch = clamp(player.pitch, -pitch_bound, pitch_bound)
	player.yaw += yaw
end

function movedir!(player::State, dir::GL.Vec3, apply::Bool)
	if apply
		player.movedir += dir
	else
		player.movedir -= dir
	end
end

# update position using eyedir, movedir, and speed
function move!(player::State)
	dist = player.speed / 60
	x = cos(player.yaw)*cos(player.pitch)
	y = sin(player.yaw)*cos(player.pitch)
	z = sin(player.pitch)
	eyedir = GL.Vec3(x, y, z)
	eyedir /= norm(eyedir)
	updir = GL.Vec3(0, 0, 1)
	rightdir = cross(eyedir, updir)
	player.position += dist * player.movedir[1] * eyedir
	player.position += dist * player.movedir[2] * rightdir
	player.position += dist * player.movedir[3] * updir
end

self = State()

export forward, back, moveleft, moveright, moveup, movedown

forward(apply::Bool)   = movedir!(self, GL.Vec3( 1,  0,  0), apply)
back(apply::Bool)      = movedir!(self, GL.Vec3(-1,  0,  0), apply)
moveleft(apply::Bool)  = movedir!(self, GL.Vec3( 0, -1,  0), apply)
moveright(apply::Bool) = movedir!(self, GL.Vec3( 0,  1,  0), apply)
moveup(apply::Bool)    = movedir!(self, GL.Vec3( 0,  0,  1), apply)
movedown(apply::Bool)  = movedir!(self, GL.Vec3( 0,  0, -1), apply)

end
