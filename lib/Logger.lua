local Logger = Class:extend('Logger')

function Logger:new(directoryName, fileName)
	love.filesystem.setIdentity(directoryName)
	self.file = love.filesystem.newFile(fileName)
	self.file:open("w")
	self.file:write(os.date("\n-- %c --\n"))
	self.file:flush()
end

function Logger:write(data, eof)
	if eof ~= false then
		eof = true
	end

	if eof then
		data = data .. "\n"
	end
	self.file:write(data)
	self.file:flush()
end

function Logger:close()
	self.file:close()
end

return Logger