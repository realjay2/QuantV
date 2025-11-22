local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = workspace.CurrentCamera

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlurFadeGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local image = Instance.new("ImageLabel")
image.Parent = screenGui
image.Size = UDim2.new(0, 400, 0, 400)
image.Position = UDim2.new(0.5, -200, 0.5, -200)
image.BackgroundTransparency = 1
image.Image = "https://raw.githubusercontent.com/realjay2/QuantV/refs/heads/main/Images/QuantV-Transparent.png"
image.ImageTransparency = 1

local blurTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local fadeInInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local holdTime = 2
local fadeOutInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local unblurTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local blurTween = TweenService:Create(blur, blurTweenInfo, { Size = 24 })
local fadeInTween = TweenService:Create(image, fadeInInfo, { ImageTransparency = 0 })
local fadeOutTween = TweenService:Create(image, fadeOutInfo, { ImageTransparency = 1 })
local unblurTween = TweenService:Create(blur, unblurTweenInfo, { Size = 0 })

blurTween:Play()
blurTween.Completed:Connect(function()
    fadeInTween:Play()
    fadeInTween.Completed:Connect(function()
        task.wait(holdTime)
        fadeOutTween:Play()
        fadeOutTween.Completed:Connect(function()
            unblurTween:Play()
            unblurTween.Completed:Connect(function()
                blur:Destroy()
                screenGui:Destroy()
            end)
        end)
    end)
end)
