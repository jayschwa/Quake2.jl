module Input

export bind, bindlist, unbind

import GLFW

const MOUSE_WHEEL_DOWN = (GLFW.KEY_LAST+1)
const MOUSE_WHEEL_UP   = (GLFW.KEY_LAST+2)

bindlist = Dict{Int,Function}()
bind(key::Integer) = get(bindlist, int(key), None)
bind(key::Integer, action::Function) = setindex!(bindlist, action, int(key))
unbind(key::Integer) = delete!(bindlist, int(key))

function event(key::Int, press::Bool)
	action = bind(key)
	if action != None
		if applicable(action, press)
			action(press)
		elseif press
			action()
		end
	end
end

function event(key::Cint, press::Cint)
	event(int(key), press == 1)
	return
end

function wheel_event(val::Cint)
	if val < 0
		event(MOUSE_WHEEL_DOWN, true)
	elseif val > 0
		event(MOUSE_WHEEL_UP, true)
	end
	GLFW.SetMouseWheel(0)
	return
end

# Aliases for common commands
quit() = exit()

end
