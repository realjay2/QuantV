local url = "https://raw.githubusercontent.com/realjay2/QuantV/refs/heads/main/Images/QuantV-Transparent.png"
local savePath = "QuantV/Images/QuantV.png"

if not isfolder("QuantV") then makefolder("QuantV") end
if not isfolder("QuantV/Images") then makefolder("QuantV/Images") end

writefile(savePath, game:HttpGet(url))

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = workspace.CurrentCamera

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local image = Instance.new("ImageLabel")
image.Parent = screenGui
image.Size = UDim2.new(0, 400, 0, 400)
image.Position = UDim2.new(0.5, -200, 0.5, -200)
image.BackgroundTransparency = 1
image.Image = getcustomasset(savePath)
image.ImageTransparency = 1

local blurIn = TweenService:Create(blur, TweenInfo.new(1), {Size = 24})
local fadeIn = TweenService:Create(image, TweenInfo.new(1), {ImageTransparency = 0})
local fadeOut = TweenService:Create(image, TweenInfo.new(1), {ImageTransparency = 1})
local blurOut = TweenService:Create(blur, TweenInfo.new(1), {Size = 0})

blurIn:Play()
blurIn.Completed:Connect(function()
    fadeIn:Play()
    fadeIn.Completed:Connect(function()
        task.wait(2)
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            blurOut:Play()
            blurOut.Completed:Connect(function()
                blur:Destroy()
                screenGui:Destroy()
            end)
        end)
    end)
end)
