module Input

export in_grab, in_release
export bind, bindlist, unbind

import GLFW
import Player

in_grabbed = false
function in_grab(window::GLFW.Window)
	f() = begin
		GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_DISABLED)
		global in_grabbed = true
	end
end
function in_release(window::GLFW.Window)
	f() = begin
		global in_grabbed = false
		GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_NORMAL)
	end
end

const MOUSE_WHEEL_DOWN = (GLFW.KEY_LAST+1)
const MOUSE_WHEEL_UP   = (GLFW.KEY_LAST+2)

bindlist = Dict{Int,Function}()
bind(key) = get(bindlist, Int(key), None)
bind(key, action::Function) = bindlist[Int(key)] = action
unbind(key) = delete!(bindlist, Int(key))

function event(key, press::Bool)
	action = bind(key)
	if action != None && (in_grabbed || action == in_grab)
		if applicable(action, press)
			action(press)
		elseif press
			action()
		end
	end
end

# GLFW key callback
function event(window::GLFW.Window, key::Cint, scancode::Cint, action::Cint, mods::Cint)
	event(key, action == 1)
	return
end

# GLFW cursor button callback
function event(window::GLFW.Window, button::Cint, action::Cint, mods::Cint)
	event(button, action == 1)
	return
end

# GLFW scroll callback
last_wheel_offset = 0.0
function wheel_event(window::GLFW.Window, xoffset::Cdouble, yoffset::Cdouble)
	if yoffset < last_wheel_offset
		event(MOUSE_WHEEL_DOWN, true)
	elseif yoffset > last_wheel_offset
		event(MOUSE_WHEEL_UP, true)
	end
	global last_wheel_offset = yoffset
	return
end

m_pitch = 0.05
m_yaw = 0.05

function look_event(window::GLFW.Window, x::Cdouble, y::Cdouble)
	if in_grabbed && (x != 0 || y != 0)
		Player.lookdir!(Player.self, m_pitch * -y, m_yaw * -x)
		GLFW.SetCursorPos(window, 0, 0)
	end
	return
end

end
