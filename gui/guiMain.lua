--// CONFIG
local TOGGLE_KEY = Enum.KeyCode.P

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

--// VARIABLES
local LocalPlayer = Players.LocalPlayer
local Character = nil
local HRP = nil

local enabled = false

local savedCFrame = nil
local savedVel = nil
local savedAngVel = nil

local desyncActive = false

--// RANDOM
local function safeRandom(min, max)
    return math.random(min, max)
end

--// CHARACTER SETUP
local function setupCharacter(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")

    -- Only reset positional state, NOT the enabled toggle
    savedCFrame = nil
    savedVel = nil
    savedAngVel = nil
    desyncActive = false
    print("Desync: character loaded, enabled =", enabled)
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
        if not enabled then
            desyncActive = false
        end
        print("Desync:", enabled and "ON" or "OFF")
    end
end)

--// HEARTBEAT — send junk to server
RunService.Heartbeat:Connect(function()
    if not enabled or not HRP then
        desyncActive = false
        return
    end

    local cf = HRP.CFrame
    if cf.Position.Magnitude < 50000 then
        savedCFrame = cf
        savedVel = HRP.AssemblyLinearVelocity
        savedAngVel = HRP.AssemblyAngularVelocity
    end

    if savedCFrame == nil then return end

    desyncActive = true

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

--// RENDERSTEP — restore client-side
RunService:BindToRenderStep("DesyncFix", Enum.RenderPriority.First.Value, function()
    if not enabled or not HRP or not desyncActive then return end
    if savedCFrame == nil then return end

    HRP.CFrame = savedCFrame
    HRP.AssemblyLinearVelocity = savedVel
    HRP.AssemblyAngularVelocity = savedAngVel
end)