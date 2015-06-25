table.indexOf = function(items, item)
	for k, v in pairs(items) do
		if v == item then
			return k
		end
	end
	return 0
end

table.getSet = function(list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

table.copy = function(t1)
	local out = {}
	for k, v in pairs(t1) do out[k] = v end
	return out
end

table.toString = function(t)
	local str = "{"
	for k, v in pairs(t) do
		if type(k) ~= "number" then str = str .. k .. " = " end
		if type(v) == "number" or type(v) == "boolean" then str = str .. tostring(v) .. ", "
		elseif type(v) == "string" then str = str .. "'" .. v .. "'" .. ", "
		elseif type(v) == "table" then str = str .. table.toString(v) .. ", "
		end
	end
	if #table > 0 then
		str = string.sub(str, 1, -3)
	end
	str = str .. "}"
	return str
end

table.random = function(t)
	return t[math.random(1, #t)]
end

table.shuffle = function(t)
	local n = #t
	while n > 2 do
		local k = math.random(n)
		t[n], t[k] = t[k], t[n]
		n = n - 1
	end
	return t
end

