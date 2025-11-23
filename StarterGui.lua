local url = "https://raw.githubusercontent.com/realjay2/QuantV/refs/heads/main/Images/QuantV-Transparent.png"
local savePath = "QuantV/Images/QuantV.png"
local SeedVersion = "e274eeff768c6396088ec6eb091f4bf4d47ab1e0"
local soundURL = "https://raw.githubusercontent.com/realjay2/QuantV/refs/heads/main/Images/Sounds/Win11-Startup.ogg"
local soundPath = "QuantV/Sounds/Win11-Startup.ogg"

if not isfolder("QuantV") then makefolder("QuantV") end
if not isfolder("QuantV/Images") then makefolder("QuantV/Images") end
if not isfolder("QuantV/Sounds") then makefolder("QuantV/Sounds") end

writefile(savePath, game:HttpGet(url))
writefile(soundPath, game:HttpGet(soundURL))

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = workspace.CurrentCamera

local gui = Instance.new("ScreenGui")
gui.Parent = playerGui
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

local snd = Instance.new("Sound")
snd.SoundId = getcustomasset(soundPath)
snd.Volume = 3
snd.Parent = gui

local logo = Instance.new("ImageLabel")
logo.Parent = gui
logo.Size = UDim2.new(0, 400, 0, 400)
logo.Position = UDim2.fromScale(0.5, 0.5)
logo.AnchorPoint = Vector2.new(.5, .5)
logo.BackgroundTransparency = 1
logo.Image = getcustomasset(savePath)
logo.ImageTransparency = 1

local line1 = Instance.new("Frame")
line1.Parent = gui
line1.Size = UDim2.new(1.5, 0, 0, 6)
line1.Position = UDim2.new(-1.5, 0, 0.35, 0)
line1.BackgroundColor3 = Color3.fromRGB(255,255,255)
line1.BackgroundTransparency = 0.2

local line2 = Instance.new("Frame")
line2.Parent = gui
line2.Size = UDim2.new(1.3, 0, 0, 3)
line2.Position = UDim2.new(-1.3, 0, 0.6, 0)
line2.BackgroundColor3 = Color3.fromRGB(255,255,0)
line2.BackgroundTransparency = 0.1

local blurIn = TweenService:Create(blur, TweenInfo.new(.8), {Size = 24})
local logoIn = TweenService:Create(logo, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0})
local logoOut = TweenService:Create(logo, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1})
local blurOut = TweenService:Create(blur, TweenInfo.new(.8), {Size = 0})

local line1In = TweenService:Create(line1, TweenInfo.new(.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Position = UDim2.new(1.5, 0, 0.35, 0),
    BackgroundTransparency = 1
})

local line2In = TweenService:Create(line2, TweenInfo.new(.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Position = UDim2.new(1.3, 0, 0.6, 0),
    BackgroundTransparency = 1
})

snd:Play()
task.wait(.75)
blurIn:Play()
line1In:Play()
task.wait(.15)
line2In:Play()

task.wait(.2)
logoIn:Play()

logoIn.Completed:Connect(function()
    task.wait(1.5)
    logoOut:Play()
    logoOut.Completed:Connect(function()
        blurOut:Play()
        blurOut.Completed:Connect(function()
            gui:Destroy()
            blur:Destroy()
        end)
    end)
end)

warn('Spoofed Bypassed Seed: ' .. SeedVersion )
