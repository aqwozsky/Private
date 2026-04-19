local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local sharedEnv = (type(getgenv) == "function" and getgenv()) or _G
local bannerAssetId = "110544367095949"

local existingGui = PlayerGui:FindFirstChild("CheatwozLoader")
if existingGui then
	existingGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatwozLoader"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

sharedEnv.CheatwozUI = sharedEnv.CheatwozUI or {}

local function corner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = obj
	return c
end

local function stroke(obj, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.Parent = obj
	return s
end

local function gradient(obj, c1, c2, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1),
		ColorSequenceKeypoint.new(1, c2),
	})
	g.Rotation = rot or 0
	g.Parent = obj
	return g
end

local function tween(obj, time, props, style, dir)
	local tw = TweenService:Create(
		obj,
		TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

local MainHolder = Instance.new("Frame")
MainHolder.AnchorPoint = Vector2.new(0.5, 0.5)
MainHolder.Position = UDim2.fromScale(0.5, 0.2)
MainHolder.Size = UDim2.new(0, 820, 0, 320)
MainHolder.BackgroundTransparency = 1
MainHolder.Parent = ScreenGui

local Banner = Instance.new("ImageLabel")
Banner.AnchorPoint = Vector2.new(0.5, 0)
Banner.Position = UDim2.fromScale(0.5, 0)
Banner.Size = UDim2.new(0, 320, 0, 78)
Banner.BackgroundTransparency = 1
Banner.Image = ""
Banner.ImageTransparency = 0
Banner.ImageColor3 = Color3.fromRGB(255, 255, 255)
Banner.ScaleType = Enum.ScaleType.Fit
Banner.ZIndex = 8
Banner.Parent = MainHolder

local BannerFallback = Instance.new("TextLabel")
BannerFallback.AnchorPoint = Vector2.new(0.5, 0)
BannerFallback.Position = UDim2.fromScale(0.5, 0.12)
BannerFallback.Size = UDim2.new(0, 360, 0, 42)
BannerFallback.BackgroundTransparency = 1
BannerFallback.Text = "CHEATWOZ"
BannerFallback.Font = Enum.Font.GothamBlack
BannerFallback.TextScaled = true
BannerFallback.TextColor3 = Color3.fromRGB(218, 116, 255)
BannerFallback.TextTransparency = 1
BannerFallback.ZIndex = 7
BannerFallback.Parent = MainHolder

local BannerGlow = Instance.new("UIStroke")
BannerGlow.Color = Color3.fromRGB(184, 88, 255)
BannerGlow.Thickness = 2
BannerGlow.Transparency = 0.35
BannerGlow.Parent = Banner

local function applyBannerImage(imageLabel, assetId)
	local imageSources = {
		("rbxassetid://%s"):format(assetId),
		("http://www.roblox.com/asset/?id=%s"):format(assetId),
		("rbxthumb://type=Asset&id=%s&w=420&h=120"):format(assetId),
		("rbxthumb://type=Asset&id=%s&w=840&h=240"):format(assetId),
		("rbxthumb://type=Image&id=%s&w=420&h=120"):format(assetId),
		("rbxthumb://type=Image&id=%s&w=840&h=240"):format(assetId),
		("rbxthumb://type=Decal&id=%s&w=420&h=120"):format(assetId),
		("rbxthumb://type=Decal&id=%s&w=840&h=240"):format(assetId),
	}

	for _, source in ipairs(imageSources) do
		imageLabel.Image = source

		local ok = pcall(function()
			ContentProvider:PreloadAsync({ imageLabel })
		end)

		if ok and imageLabel.IsLoaded then
			sharedEnv.CheatwozBannerImage = source
			return true
		end
	end

	sharedEnv.CheatwozBannerImage = nil
	return false
end

applyBannerImage(Banner, bannerAssetId)

if sharedEnv.CheatwozBannerImage then
	BannerFallback.Visible = false
else
	BannerFallback.TextTransparency = 0
end

local LoadingCard = Instance.new("Frame")
LoadingCard.AnchorPoint = Vector2.new(0.5, 0)
LoadingCard.Position = UDim2.fromOffset(410, 84)
LoadingCard.Size = UDim2.new(0, 760, 0, 140)
LoadingCard.BackgroundColor3 = Color3.fromRGB(9, 3, 18)
LoadingCard.BackgroundTransparency = 0.18
LoadingCard.BorderSizePixel = 0
LoadingCard.ZIndex = 5
LoadingCard.Parent = MainHolder
corner(LoadingCard, 28)
stroke(LoadingCard, Color3.fromRGB(200, 95, 255), 2, 0.1)

local LoadingGlow = Instance.new("UIStroke")
LoadingGlow.Color = Color3.fromRGB(155, 45, 255)
LoadingGlow.Thickness = 5
LoadingGlow.Transparency = 0.75
LoadingGlow.Parent = LoadingCard

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.AnchorPoint = Vector2.new(0.5, 0)
LoadingTitle.Position = UDim2.fromScale(0.5, 0.34)
LoadingTitle.Size = UDim2.new(0.9, 0, 0, 42)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = "Loading up Cheatwoz's Script..."
LoadingTitle.Font = Enum.Font.GothamBold
LoadingTitle.TextScaled = true
LoadingTitle.TextColor3 = Color3.fromRGB(203, 88, 255)
LoadingTitle.ZIndex = 6
LoadingTitle.Parent = LoadingCard

local LoadingBarBack = Instance.new("Frame")
LoadingBarBack.AnchorPoint = Vector2.new(0.5, 0)
LoadingBarBack.Position = UDim2.fromScale(0.5, 0.72)
LoadingBarBack.Size = UDim2.new(0, 520, 0, 16)
LoadingBarBack.BackgroundColor3 = Color3.fromRGB(75, 42, 100)
LoadingBarBack.BackgroundTransparency = 0.2
LoadingBarBack.BorderSizePixel = 0
LoadingBarBack.ZIndex = 6
LoadingBarBack.Parent = LoadingCard
corner(LoadingBarBack, 999)

local LoadingBarFill = Instance.new("Frame")
LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
LoadingBarFill.BackgroundColor3 = Color3.fromRGB(170, 35, 255)
LoadingBarFill.BorderSizePixel = 0
LoadingBarFill.ZIndex = 7
LoadingBarFill.Parent = LoadingBarBack
corner(LoadingBarFill, 999)
gradient(LoadingBarFill, Color3.fromRGB(220, 100, 255), Color3.fromRGB(120, 20, 255), 0)

local BarFillGlow = Instance.new("UIStroke")
BarFillGlow.Color = Color3.fromRGB(200, 80, 255)
BarFillGlow.Thickness = 4
BarFillGlow.Transparency = 0.7
BarFillGlow.Parent = LoadingBarFill

local LoadingPercent = Instance.new("TextLabel")
LoadingPercent.AnchorPoint = Vector2.new(0.5, 0)
LoadingPercent.Position = UDim2.fromScale(0.5, 0.84)
LoadingPercent.Size = UDim2.new(0, 100, 0, 18)
LoadingPercent.BackgroundTransparency = 1
LoadingPercent.Text = "0%"
LoadingPercent.Font = Enum.Font.Gotham
LoadingPercent.TextSize = 14
LoadingPercent.TextColor3 = Color3.fromRGB(150, 110, 185)
LoadingPercent.ZIndex = 6
LoadingPercent.Parent = LoadingCard

local InfoCard = Instance.new("Frame")
InfoCard.AnchorPoint = Vector2.new(0.5, 0)
InfoCard.Position = UDim2.fromOffset(410, 134)
InfoCard.Size = UDim2.new(0, 760, 0, 108)
InfoCard.BackgroundColor3 = Color3.fromRGB(9, 3, 18)
InfoCard.BackgroundTransparency = 0.18
InfoCard.BorderSizePixel = 0
InfoCard.ZIndex = 5
InfoCard.Visible = false
InfoCard.Parent = MainHolder
corner(InfoCard, 28)
stroke(InfoCard, Color3.fromRGB(200, 95, 255), 2, 0.1)

local InfoGlow = Instance.new("UIStroke")
InfoGlow.Color = Color3.fromRGB(155, 45, 255)
InfoGlow.Thickness = 5
InfoGlow.Transparency = 0.78
InfoGlow.Parent = InfoCard

local Divider = Instance.new("Frame")
Divider.AnchorPoint = Vector2.new(0.5, 0.5)
Divider.Position = UDim2.fromScale(0.5, 0.5)
Divider.Size = UDim2.new(0, 2, 0, 58)
Divider.BackgroundColor3 = Color3.fromRGB(168, 70, 255)
Divider.BackgroundTransparency = 0.15
Divider.BorderSizePixel = 0
Divider.ZIndex = 6
Divider.Parent = InfoCard
corner(Divider, 999)

local function makeKeyCap(parent, xScale, isRight, label)
	local key = Instance.new("Frame")
	key.AnchorPoint = Vector2.new(isRight and 1 or 0, 0.5)
	key.Position = UDim2.new(xScale, 0, 0.52, 0)
	key.Size = UDim2.new(0, isRight and 78 or 52, 0, 34)
	key.BackgroundColor3 = Color3.fromRGB(32, 18, 52)
	key.BackgroundTransparency = 0.02
	key.BorderSizePixel = 0
	key.ZIndex = 7
	key.Parent = parent
	corner(key, 8)

	local keyStroke = Instance.new("UIStroke")
	keyStroke.Color = Color3.fromRGB(182, 90, 255)
	keyStroke.Thickness = 1
	keyStroke.Transparency = 0.15
	keyStroke.Parent = key

	local keyLabel = Instance.new("TextLabel")
	keyLabel.Size = UDim2.fromScale(1, 1)
	keyLabel.BackgroundTransparency = 1
	keyLabel.Text = label
	keyLabel.Font = Enum.Font.GothamBold
	keyLabel.TextSize = isRight and 15 or 18
	keyLabel.TextColor3 = Color3.fromRGB(244, 236, 255)
	keyLabel.ZIndex = 8
	keyLabel.Parent = key

	return key
end

local LeftTitle = Instance.new("TextLabel")
LeftTitle.Position = UDim2.new(0, 36, 0, 20)
LeftTitle.Size = UDim2.new(0, 300, 0, 20)
LeftTitle.BackgroundTransparency = 1
LeftTitle.Text = "Random Voidspam Teleport"
LeftTitle.TextXAlignment = Enum.TextXAlignment.Left
LeftTitle.Font = Enum.Font.GothamBold
LeftTitle.TextSize = 17
LeftTitle.TextColor3 = Color3.fromRGB(155, 155, 155)
LeftTitle.ZIndex = 7
LeftTitle.Parent = InfoCard

makeKeyCap(InfoCard, 0.05, false, "P")

local LeftKey = Instance.new("TextLabel")
LeftKey.Position = UDim2.new(0, 104, 0, 50)
LeftKey.Size = UDim2.new(0, 80, 0, 30)
LeftKey.BackgroundTransparency = 1
LeftKey.Text = "P"
LeftKey.TextXAlignment = Enum.TextXAlignment.Left
LeftKey.Font = Enum.Font.GothamBold
LeftKey.TextSize = 27
LeftKey.TextColor3 = Color3.fromRGB(190, 72, 255)
LeftKey.ZIndex = 7
LeftKey.Parent = InfoCard

local LeftStatus = Instance.new("TextLabel")
LeftStatus.Position = UDim2.new(0, 36, 0, 76)
LeftStatus.Size = UDim2.new(0, 220, 0, 16)
LeftStatus.BackgroundTransparency = 1
LeftStatus.Text = "Status: OFF"
LeftStatus.TextXAlignment = Enum.TextXAlignment.Left
LeftStatus.Font = Enum.Font.GothamSemibold
LeftStatus.TextSize = 13
LeftStatus.TextColor3 = Color3.fromRGB(140, 120, 160)
LeftStatus.ZIndex = 7
LeftStatus.Parent = InfoCard

local RightTitle = Instance.new("TextLabel")
RightTitle.AnchorPoint = Vector2.new(1, 0)
RightTitle.Position = UDim2.new(1, -36, 0, 20)
RightTitle.Size = UDim2.new(0, 220, 0, 20)
RightTitle.BackgroundTransparency = 1
RightTitle.Text = "Hide The Gui"
RightTitle.TextXAlignment = Enum.TextXAlignment.Right
RightTitle.Font = Enum.Font.GothamBold
RightTitle.TextSize = 17
RightTitle.TextColor3 = Color3.fromRGB(155, 155, 155)
RightTitle.ZIndex = 7
RightTitle.Parent = InfoCard

makeKeyCap(InfoCard, 0.95, true, "RCTRL")

local RightKey = Instance.new("TextLabel")
RightKey.AnchorPoint = Vector2.new(1, 0)
RightKey.Position = UDim2.new(1, -126, 0, 50)
RightKey.Size = UDim2.new(0, 220, 0, 30)
RightKey.BackgroundTransparency = 1
RightKey.Text = "RightControl"
RightKey.TextXAlignment = Enum.TextXAlignment.Right
RightKey.Font = Enum.Font.GothamBold
RightKey.TextSize = 24
RightKey.TextColor3 = Color3.fromRGB(190, 72, 255)
RightKey.ZIndex = 7
RightKey.Parent = InfoCard

local function setVoidSpamEnabled(isEnabled)
	LeftStatus.Text = "Status: " .. (isEnabled and "ON" or "OFF")
	LeftStatus.TextColor3 = isEnabled and Color3.fromRGB(205, 95, 255) or Color3.fromRGB(140, 120, 160)
	LeftKey.TextColor3 = isEnabled and Color3.fromRGB(233, 132, 255) or Color3.fromRGB(190, 72, 255)
end

setVoidSpamEnabled(false)
sharedEnv.CheatwozUI.SetVoidSpamEnabled = setVoidSpamEnabled

task.spawn(function()
	local duration = 2.8
	local startTime = tick()

	tween(LoadingBarFill, duration, {
		Size = UDim2.new(1, 0, 1, 0),
	})

	while true do
		local alpha = math.clamp((tick() - startTime) / duration, 0, 1)
		LoadingPercent.Text = tostring(math.floor(alpha * 100)) .. "%"

		if alpha >= 1 then
			break
		end

		task.wait()
	end

	LoadingPercent.Text = "100%"
	task.wait(0.2)

	tween(LoadingCard, 0.35, {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, -0.05),
	})

	tween(LoadingTitle, 0.35, {TextTransparency = 1})
	tween(LoadingBarBack, 0.35, {BackgroundTransparency = 1})
	tween(LoadingBarFill, 0.35, {BackgroundTransparency = 1})
	tween(LoadingPercent, 0.35, {TextTransparency = 1})

	task.wait(0.4)

	LoadingCard.Visible = false
	InfoCard.Visible = true
	InfoCard.BackgroundTransparency = 1
	InfoCard.Position = UDim2.fromOffset(410, 96)

	tween(InfoCard, 0.35, {
		BackgroundTransparency = 0.18,
		Position = UDim2.fromOffset(410, 134),
	})
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightControl then
		InfoCard.Visible = not InfoCard.Visible
	end
end)
