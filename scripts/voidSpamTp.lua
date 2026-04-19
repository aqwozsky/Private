

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

--// VARIABLES
local LocalPlayer = Players.LocalPlayer
local Character = nil
local HRP = nil

local enabled = false

local savedCFrame
local savedVel
local savedAngVel

--// RANDOM (daha hafif)
local function safeRandom(min, max)
    return math.random(min, max)
end

--// CHARACTER SETUP
local function setupCharacter(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
end

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)

--// TOGGLE
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TOGGLE_KEY then
        enabled = not enabled
        print("Desync:", enabled and "ON" or "OFF")
    end
end)

--// HEARTBEAT (server'a çöp veri gönder)
RunService.Heartbeat:Connect(function()
    if not enabled or not HRP then return end

    -- eski değerleri kaydet
    savedCFrame = HRP.CFrame
    savedVel = HRP.AssemblyLinearVelocity
    savedAngVel = HRP.AssemblyAngularVelocity

    -- aşırı uç değil, daha stabil değerler
    HRP.CFrame = CFrame.new(
        safeRandom(-10000, 10000),
        safeRandom(-10000, 10000),
        safeRandom(-10000, 10000)
    ) * CFrame.Angles(math.pi, math.pi, math.pi)

    HRP.AssemblyLinearVelocity = Vector3.new(
        safeRandom(-500, 500),
        safeRandom(-500, 500),
        safeRandom(-500, 500)
    )

    HRP.AssemblyAngularVelocity = Vector3.new(
        safeRandom(-50, 50),
        safeRandom(-50, 50),
        safeRandom(-50, 50)
    )
end)

--// RENDERSTEP (clientte eski haline dön)
RunService:BindToRenderStep("DesyncFix", Enum.RenderPriority.First.Value, function()
    if not enabled or not HRP then return end

    HRP.CFrame = savedCFrame
    HRP.AssemblyLinearVelocity = savedVel
    HRP.AssemblyAngularVelocity = savedAngVel
end)