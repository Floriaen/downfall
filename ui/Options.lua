local Options = Class:extend("Options")
local resources = require 'assets/data/resources'

function Options:new()

	local music = {"determined", "iceScream", "anou", "bigfoot", "ricano", "hante"}

	local frame = loveframes.Create("frame")
	frame:SetName("Options")
	frame:SetState("options")
	frame:SetPos(0, 0)
--[[
	local grid = loveframes.Create("grid", frame)
	--grid:SetPos(5, 5)
	grid:SetRows(1)
	grid:SetColumns(#music)
	grid:SetCellWidth(60)
	grid:SetCellHeight(30)
	grid:SetCellPadding(5)
	grid:SetItemAutoSize(true)
]]--

	local label = loveframes.Create("text", frame)
	label:SetPos(5, 36)
	label:SetFont(love.graphics.newFont(10))
	label:SetText("Music")

	local multiChoice = loveframes.Create('multichoice', frame)
	multiChoice:SetPos(60, 30)
	multiChoice:SetChoice("determined")
	for k, v in pairs(music) do
		multiChoice:AddChoice(v)
	end
	multiChoice.OnChoiceSelected = function(object, choice)
		State.current:changeBackgroundMusic(choice)
	end
--[[
	for k, v in pairs(music) do
		local button = loveframes.Create("button", frame)
		--button:SetParent(frame)
		button:SetText(v)
		button:SetSize(50, 20)
		grid:AddItem(button, 1, k)
		--button:SetPos(10 + (k - 1) * 60, 10)
		button.OnClick = function(object, x, y)
			State.current:changeBackgroundMusic(v)
		end
	end

	grid.OnSizeChanged = function(object)
		frame:SetSize(object:GetWidth() + 10, object:GetHeight() + 35)
		--frame:CenterWithinArea(unpack(demo.centerarea))
	end
]]
end

return Options