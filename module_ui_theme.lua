-- module_ui_theme.lua
-- Simple theme pass for the classic UI.
-- Waits until UPF.UI exists, then applies a cleaner look.

task.spawn(function()
	_G.UPF = _G.UPF or {}
	local UPF = _G.UPF

	local tries = 0
	while (not UPF.UI or not UPF.UI.Main) and tries < 100 do
		task.wait(0.1)
		tries += 1
	end

	if not UPF.UI or not UPF.UI.Main then
		warn("module_ui_theme: UPF.UI is not ready after timeout")
		return
	end

	local Main = UPF.UI.Main
	local Header = UPF.UI.Header or Main:FindFirstChild("Header")
	local Content = UPF.UI.Content or Main:FindFirstChild("Content")

	if Main then
		Main.BackgroundColor3 = Color3.fromRGB(16, 16, 24)

		local stroke = Main:FindFirstChildOfClass("UIStroke")
		if not stroke then
			stroke = Instance.new("UIStroke")
			stroke.Parent = Main
		end
		stroke.Color = Color3.fromRGB(95, 75, 215)
		stroke.Transparency = 0.45

		local gradient = Main:FindFirstChildOfClass("UIGradient")
		if not gradient then
			gradient = Instance.new("UIGradient")
			gradient.Parent = Main
		end
		gradient.Rotation = 90
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 28)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 20))
		})
	end

	if Header then
		Header.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
		local headerStroke = Header:FindFirstChildOfClass("UIStroke")
		if not headerStroke then
			headerStroke = Instance.new("UIStroke")
			headerStroke.Parent = Header
		end
		headerStroke.Color = Color3.fromRGB(80, 65, 180)
		headerStroke.Transparency = 0.75
	end

	if Content then
		local list = Content:FindFirstChildOfClass("UIListLayout")
		if list then
			list.Padding = UDim.new(0, 10)
		end

		for _, obj in ipairs(Content:GetChildren()) do
			if obj:IsA("TextButton") then
				obj.AutoButtonColor = true
				obj.BorderSizePixel = 0
				local corner = obj:FindFirstChildOfClass("UICorner")
				if not corner then
					corner = Instance.new("UICorner")
					corner.Parent = obj
				end
				corner.CornerRadius = UDim.new(0, 10)

				local btnStroke = obj:FindFirstChildOfClass("UIStroke")
				if not btnStroke then
					btnStroke = Instance.new("UIStroke")
					btnStroke.Parent = obj
				end
				btnStroke.Transparency = 0.8
				btnStroke.Color = Color3.fromRGB(255, 255, 255)
			end
		end
	end

	if UPF.UI.Update then
		pcall(function() UPF.UI.Update() end)
	end

	print("✅ module_ui_theme loaded")
end)