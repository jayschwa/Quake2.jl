module Input

export in_grab, in_release
export bind, bindlist, unbind

import GLFW
import Player

in_grabbed = false
function in_grab()
	GLFW.Disable(GLFW.MOUSE_CURSOR)
	GLFW.SetMousePos(0, 0)
	global in_grabbed = true
end
function in_release()
	global in_grabbed = false
	GLFW.Enable(GLFW.MOUSE_CURSOR)
end

const MOUSE_WHEEL_DOWN = (GLFW.KEY_LAST+1)
const MOUSE_WHEEL_UP   = (GLFW.KEY_LAST+2)

bindlist = Dict{Int,Function}()
bind(key::Integer) = get(bindlist, int(key), None)
bind(key::Integer, action::Function) = setindex!(bindlist, action, int(key))
unbind(key::Integer) = delete!(bindlist, int(key))

function event(key::Int, press::Bool)
	action = bind(key)
	if action != None && (in_grabbed || action == in_grab)
		if applicable(action, press)
			action(press)
		elseif press
			action()
		end
	end
end

# GLFW key and mouse button callback
function event(key::Cint, press::Cint)
	event(int(key), press == 1)
	return
end

# GLFW mouse wheel callback
function wheel_event(val::Cint)
	if val < 0
		event(MOUSE_WHEEL_DOWN, true)
	elseif val > 0
		event(MOUSE_WHEEL_UP, true)
	end
	GLFW.SetMouseWheel(0)
	return
end

m_pitch = 0.05
m_yaw = 0.05

function look_event(x, y)
	if in_grabbed && (x != 0 || y != 0)
		Player.lookdir!(Player.self, m_pitch * -y, m_yaw * -x)
		GLFW.SetMousePos(0, 0)
	end
end

end
