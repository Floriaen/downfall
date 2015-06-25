-- http://stackoverflow.com/questions/20101454/lua-callback-from-c
-- Move to addons
createClosure = function(obj, fun)
	return function(...)
		return obj[fun](obj, ...)
	end
end