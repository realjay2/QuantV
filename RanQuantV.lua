local DevTesting = false

if not DevTesting and _G.RanQuantV then
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")

    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false

    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = workspace.CurrentCamera

    local flash = Instance.new("Frame", gui)
    flash.Size = UDim2.new(1,0,1,0)
    flash.BackgroundColor3 = Color3.fromRGB(255,0,0)
    flash.BackgroundTransparency = 1

    local msg = Instance.new("TextLabel", gui)
    msg.Size = UDim2.new(1,0,1,0)
    msg.BackgroundTransparency = 1
    msg.Text = "You have already ran QuantV"
    msg.TextScaled = true
    msg.TextColor3 = Color3.new(1,1,1)
    msg.TextTransparency = 1
    msg.Font = Enum.Font.GothamBold

    local sound = Instance.new("Sound", gui)
    sound.SoundId = "rbxassetid://107294127858629"
    sound.Volume = 1
    sound:Play()

    TweenService:Create(blur, TweenInfo.new(0.7), {Size = 24}):Play()
    TweenService:Create(msg, TweenInfo.new(0.7), {TextTransparency = 0}):Play()
    TweenService:Create(flash, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
    task.wait(0.1)
    TweenService:Create(flash, TweenInfo.new(0.7), {BackgroundTransparency = 1}):Play()

    task.wait(2)

    TweenService:Create(msg, TweenInfo.new(0.7), {TextTransparency = 1}):Play()
    TweenService:Create(blur, TweenInfo.new(0.7), {Size = 0}):Play()

    task.wait(0.8)

    gui:Destroy()
    blur:Destroy()

    return
end

_G.RanQuantV = true
