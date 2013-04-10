module Player

import GL

type State
	position::GL.Vec3
	orientation::GL.Vec3   # pitch, yaw, and roll in degrees
	look_velocity::GL.Vec3
	move_velocity::GL.Vec3
	speed::Real
	last_think::Real
end
State() = State(GL.Vec3(0,0,0), GL.Vec3(0,0,0), GL.Vec3(0,0,0), GL.Vec3(0,0,0), 100, 0)

function lookdir!(player::State, delta::GL.Vec3, apply::Bool)
	if apply
		player.look_velocity += delta
	else
		player.look_velocity -= delta
	end
end

function lookdir!(player::State, pitch::Real, yaw::Real)
	pitch = player.orientation[1] + pitch
	pitch = clamp(pitch, -89, 89)
	yaw = (player.orientation[2] + yaw) % 360
	player.orientation = GL.Vec3(pitch, yaw, 0)
end

export sphere2cartesian # TODO: put this in a better spot
function sphere2cartesian(orientation::GL.Vec3)
	orientation = degrees2radians(orientation)
	x = cos(orientation[1]) * cos(orientation[2])
	y = cos(orientation[1]) * sin(orientation[2])
	z = sin(orientation[1])
	eyedir = GL.Vec3(x, y, z)
	eyedir /= norm(eyedir)
	updir = GL.Vec3(0, 0, 1)
	rightdir = cross(eyedir, updir)
	rightdir /= norm(rightdir)
	return eyedir, updir, rightdir
end

function movedir!(player::State, delta::GL.Vec3, apply::Bool)
	if apply
		player.move_velocity += delta
	else
		player.move_velocity -= delta
	end
end

# update position using eyedir, move_velocity, and speed
function move!(player::State)
	now = time_ns()
	time = (now - player.last_think) / 1000000000
	dist = player.speed * time
	lookdir!(player, player.look_velocity[1] * time, player.look_velocity[2] * time)
	eyedir, updir, rightdir = sphere2cartesian(player.orientation)
	player.position += dist * player.move_velocity[1] * eyedir
	player.position += dist * player.move_velocity[2] * rightdir
	player.position += dist * player.move_velocity[3] * updir
	player.last_think = now
end

self = State()

export forward, back, moveleft, moveright, moveup, movedown, speed, left, right, lookup, lookdown

forward(apply::Bool)   = movedir!(self, GL.Vec3( 1,  0,  0), apply)
back(apply::Bool)      = movedir!(self, GL.Vec3(-1,  0,  0), apply)
moveleft(apply::Bool)  = movedir!(self, GL.Vec3( 0, -1,  0), apply)
moveright(apply::Bool) = movedir!(self, GL.Vec3( 0,  1,  0), apply)
moveup(apply::Bool)    = movedir!(self, GL.Vec3( 0,  0,  1), apply)
movedown(apply::Bool)  = movedir!(self, GL.Vec3( 0,  0, -1), apply)

function speed(apply::Bool)
	if apply
		self.speed *= 5
	else
		self.speed /= 5
	end
end

left(apply::Bool)     = lookdir!(self, GL.Vec3(  0,  60,  0), apply)
right(apply::Bool)    = lookdir!(self, GL.Vec3(  0, -60,  0), apply)
lookup(apply::Bool)   = lookdir!(self, GL.Vec3( 60,   0,  0), apply)
lookdown(apply::Bool) = lookdir!(self, GL.Vec3(-60,   0,  0), apply)

end
