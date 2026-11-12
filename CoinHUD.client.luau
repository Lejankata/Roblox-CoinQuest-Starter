--!strict
-- CoinQuest Starter: mobile-friendly coin counter.
-- Put this LocalScript in StarterPlayer > StarterPlayerScripts.
-- MIT License. See LICENSE in the repository.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "CoinQuestHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Counter"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -18, 0, 18)
panel.Size = UDim2.fromOffset(176, 65)
panel.BackgroundColor3 = Color3.fromRGB(20, 25, 37)
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 81, 104)
stroke.Thickness = 1
stroke.Transparency = 0.25
stroke.Parent = panel

local icon = Instance.new("TextLabel")
icon.BackgroundTransparency = 1
icon.Position = UDim2.fromOffset(12, 6)
icon.Size = UDim2.fromOffset(36, 53)
icon.Font = Enum.Font.GothamBold
icon.Text = "●"
icon.TextSize = 32
icon.TextColor3 = Color3.fromRGB(255, 205, 70)
icon.Parent = panel

local heading = Instance.new("TextLabel")
heading.BackgroundTransparency = 1
heading.Position = UDim2.fromOffset(54, 9)
heading.Size = UDim2.fromOffset(108, 18)
heading.Font = Enum.Font.GothamMedium
heading.Text = "YOUR COINS"
heading.TextSize = 11
heading.TextXAlignment = Enum.TextXAlignment.Left
heading.TextColor3 = Color3.fromRGB(161, 175, 195)
heading.Parent = panel

local balance = Instance.new("TextLabel")
balance.BackgroundTransparency = 1
balance.Position = UDim2.fromOffset(54, 26)
balance.Size = UDim2.fromOffset(108, 29)
balance.Font = Enum.Font.GothamBold
balance.Text = "0"
balance.TextSize = 24
balance.TextXAlignment = Enum.TextXAlignment.Left
balance.TextColor3 = Color3.fromRGB(255, 255, 255)
balance.Parent = panel

local leaderstats = player:WaitForChild("leaderstats")
local coins = leaderstats:WaitForChild("Coins") :: IntValue

local function update()
    balance.Text = tostring(coins.Value)
    TweenService:Create(panel, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
        BackgroundColor3 = Color3.fromRGB(42, 52, 65),
    }):Play()
    task.delay(0.15, function()
        if panel.Parent then
            TweenService:Create(panel, TweenInfo.new(0.23), {
                BackgroundColor3 = Color3.fromRGB(20, 25, 37),
            }):Play()
        end
    end)
end

update()
coins:GetPropertyChangedSignal("Value"):Connect(update)
