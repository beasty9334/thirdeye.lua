local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local CurrentCamera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ThirdEye = {
    esp = {
        CharacterSize = Vector2.new(5, 6),
        RenderDistance = 1000, -- Default render distance (in meters)
        Box = {
            TeamCheck = false,
            Box = true,
            Name = true,
            Distance = true,
            BoxTransparency = 0.8,
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
        },
        Tracer = {
            TeamCheck = false,
            Tracer = true,
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
        },
        Highlights = {
            TeamCheck = false,
            Highlights = true,
            AlwaysVisible = true,
            OutlineTransparency = 0.5,
            FillTransparency = 0.5,
            OutlineColor = Color3.fromRGB(255, 0, 0),
            FillColor = Color3.fromRGB(255, 255, 255),
        },
    }
}

local oldZoom = CurrentCamera.FieldOfView
local Settings = {
    ZoomTime = 0.2,
    ZoomedAmount = 10
}

local function createZoom(time, amount)
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(CurrentCamera, tweenInfo, { FieldOfView = amount })
    return tween
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.C then
        createZoom(Settings.ZoomTime, Settings.ZoomedAmount):Play()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.C then
        createZoom(Settings.ZoomTime, oldZoom):Play()
    end
end)

local ESPHolder = Instance.new("Folder", CoreGui)
ESPHolder.Name = "ESPHolder"

local function IsAlive(player)
    local character = player and player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    return humanoidRootPart ~= nil
end

local function GetTeam(player)
    return player and player.Team
end

local function LoadESP(player)
    local PlayerESP = Instance.new("Folder", ESPHolder)
    PlayerESP.Name = player.Name .. "ESP"

    local BoxHolder = Instance.new("ScreenGui", PlayerESP)
    BoxHolder.Name = "Box"
    BoxHolder.DisplayOrder = 2
    BoxHolder.ResetOnSpawn = false

    local TracerHolder = Instance.new("ScreenGui", PlayerESP)
    TracerHolder.Name = "Tracer"
    TracerHolder.DisplayOrder = 3
    TracerHolder.ResetOnSpawn = false

    local HilightHolder = Instance.new("Folder", PlayerESP)
    HilightHolder.Name = "Hilight"

    local LeftOutline = Instance.new("Frame", BoxHolder)
    LeftOutline.BackgroundColor3 = ThirdEye.esp.Box.OutlineColor
    LeftOutline.Visible = false
    LeftOutline.BorderSizePixel = 0

    local RightOutline = Instance.new("Frame", BoxHolder)
    RightOutline.BackgroundColor3 = ThirdEye.esp.Box.OutlineColor
    RightOutline.Visible = false
    RightOutline.BorderSizePixel = 0

    local TopOutline = Instance.new("Frame", BoxHolder)
    TopOutline.BackgroundColor3 = ThirdEye.esp.Box.OutlineColor
    TopOutline.Visible = false
    TopOutline.BorderSizePixel = 0

    local BottomOutline = Instance.new("Frame", BoxHolder)
    BottomOutline.BackgroundColor3 = ThirdEye.esp.Box.OutlineColor
    BottomOutline.Visible = false
    BottomOutline.BorderSizePixel = 0

    local Left = Instance.new("Frame", BoxHolder)
    Left.BackgroundColor3 = ThirdEye.esp.Box.Color
    Left.Visible = false
    Left.BorderSizePixel = 0

    local Right = Instance.new("Frame", BoxHolder)
    Right.BackgroundColor3 = ThirdEye.esp.Box.Color
    Right.Visible = false
    Right.BorderSizePixel = 0

    local Top = Instance.new("Frame", BoxHolder)
    Top.BackgroundColor3 = ThirdEye.esp.Box.Color
    Top.Visible = false
    Top.BorderSizePixel = 0

    local Bottom = Instance.new("Frame", BoxHolder)
    Bottom.BackgroundColor3 = ThirdEye.esp.Box.Color
    Bottom.Visible = false
    Bottom.BorderSizePixel = 0

    local Name = Instance.new("TextLabel", BoxHolder)
    Name.BackgroundTransparency = 1
    Name.Text = player.Name
    Name.Visible = false
    Name.AnchorPoint = Vector2.new(0.5, 0.5)
    Name.TextSize = 12
    Name.Font = Enum.Font.SourceSansBold
    Name.TextColor3 = Color3.fromRGB(255, 255, 255)
    Name.TextStrokeTransparency = 0

    local Distance = Instance.new("TextLabel", BoxHolder)
    Distance.BackgroundTransparency = 1
    Distance.Text = ""
    Distance.Visible = false
    Distance.AnchorPoint = Vector2.new(0.5, 0.5)
    Distance.TextSize = 12
    Distance.Font = Enum.Font.SourceSansBold
    Distance.TextColor3 = Color3.fromRGB(255, 255, 255)
    Distance.TextStrokeTransparency = 0

    local Hilight = Instance.new("Highlight", HilightHolder)
    Hilight.Enabled = false

    local Tracer = Instance.new("Frame", TracerHolder)
    Tracer.BackgroundColor3 = ThirdEye.esp.Tracer.Color
    Tracer.Visible = false
    Tracer.BorderSizePixel = 0

    local TracerOutline = Instance.new("Frame", TracerHolder)
    TracerOutline.BackgroundColor3 = ThirdEye.esp.Tracer.OutlineColor
    TracerOutline.Visible = false
    TracerOutline.BorderSizePixel = 0

    local co = coroutine.create(function()
        RunService.Heartbeat:Connect(function()
            if IsAlive(player) then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local screen, onScreen = CurrentCamera:WorldToScreenPoint(humanoidRootPart.Position)
                    local distance = (CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude

                    if distance <= ThirdEye.esp.RenderDistance then
                        local frustumHeight = math.tan(math.rad(CurrentCamera.FieldOfView * 0.5)) * 2 * screen.Z
                        local size = CurrentCamera.ViewportSize.Y / frustumHeight * ThirdEye.esp.CharacterSize
                        local position = Vector2.new(screen.X, screen.Y) - (size / 2 - Vector2.new(0, size.Y) / 20)

                        if onScreen then
                            if ThirdEye.esp.Box.TeamCheck ~= true or GetTeam(player) ~= GetTeam(Players.LocalPlayer) then
                                LeftOutline.Visible = ThirdEye.esp.Box.Box and ThirdEye.esp.Box.Outline
                                RightOutline.Visible = ThirdEye.esp.Box.Box and ThirdEye.esp.Box.Outline
                                TopOutline.Visible = ThirdEye.esp.Box.Box and ThirdEye.esp.Box.Outline
                                BottomOutline.Visible = ThirdEye.esp.Box.Box and ThirdEye.esp.Box.Outline

                                Left.Visible = ThirdEye.esp.Box.Box
                                Right.Visible = ThirdEye.esp.Box.Box
                                Top.Visible = ThirdEye.esp.Box.Box
                                Bottom.Visible = ThirdEye.esp.Box.Box
                                Name.Visible = ThirdEye.esp.Box.Name
                                Distance.Visible = ThirdEye.esp.Box.Distance

                                Left.Size = UDim2.fromOffset(size.X, 1)
                                Right.Size = UDim2.fromOffset(size.X, 1)
                                Top.Size = UDim2.fromOffset(1, size.Y)
                                Bottom.Size = UDim2.fromOffset(1, size.Y)

                                LeftOutline.Size = Left.Size
                                RightOutline.Size = Right.Size
                                TopOutline.Size = Top.Size
                                BottomOutline.Size = Bottom.Size

                                Left.Position = UDim2.fromOffset(position.X, position.Y)
                                Right.Position = UDim2.fromOffset(position.X, position.Y + size.Y - 1)
                                Top.Position = UDim2.fromOffset(position.X, position.Y)
                                Bottom.Position = UDim2.fromOffset(position.X + size.X - 1, position.Y)
                                Name.Position = UDim2.fromOffset(screen.X, screen.Y - (size.Y + Name.TextBounds.Y + 14) / 2)
                                Distance.Position = UDim2.fromOffset(screen.X, screen.Y - (size.Y + Name.TextBounds.Y + 19) / 2)

                                LeftOutline.Position = Left.Position
                                RightOutline.Position = Right.Position
                                TopOutline.Position = Top.Position
                                BottomOutline.Position = Bottom.Position

                                LeftOutline.BackgroundColor3 = ThirdEye.esp.Box.OutlineColor
                                RightOutline.BackgroundColor3 = ThirdEye.esp.Box.OutlineColor
                                TopOutline.BackgroundColor3 = ThirdEye.esp.Box.OutlineColor
                                BottomOutline.BackgroundColor3 = ThirdEye.esp.Box.OutlineColor

                                Left.BackgroundColor3 = ThirdEye.esp.Box.Color
                                Right.BackgroundColor3 = ThirdEye.esp.Box.Color
                                Top.BackgroundColor3 = ThirdEye.esp.Box.Color
                                Bottom.BackgroundColor3 = ThirdEye.esp.Box.Color

                                Distance.Text = math.floor(distance)
                                Name.Text = player.Name
                            else
                                LeftOutline.Visible = false
                                RightOutline.Visible = false
                                TopOutline.Visible = false
                                BottomOutline.Visible = false
                                Left.Visible = false
                                Right.Visible = false
                                Top.Visible = false
                                Bottom.Visible = false
                                Name.Visible = false
                                Distance.Visible = false
                            end

                            if ThirdEye.esp.Tracer.TeamCheck ~= true or GetTeam(player) ~= GetTeam(Players.LocalPlayer) then
                                local Origin = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y)
                                local TracerPosition = Vector2.new(screen.X, screen.Y)

                                TracerOutline.Visible = ThirdEye.esp.Tracer.Outline and ThirdEye.esp.Tracer.Tracer
                                Tracer.Visible = ThirdEye.esp.Tracer.Tracer

                                Tracer.Position = UDim2.new(0, TracerPosition.X, 0, TracerPosition.Y)
                                Tracer.Size = UDim2.new(0, (Origin - TracerPosition).magnitude, 0, 1)
                                Tracer.Rotation = math.deg(math.atan2(TracerPosition.Y - Origin.Y, TracerPosition.X - Origin.X))

                                TracerOutline.Position = Tracer.Position
                                TracerOutline.Size = Tracer.Size
                                TracerOutline.Rotation = Tracer.Rotation

                                Tracer.BackgroundColor3 = ThirdEye.esp.Tracer.Color
                                TracerOutline.BackgroundColor3 = ThirdEye.esp.Tracer.OutlineColor
                            else
                                TracerOutline.Visible = false
                                Tracer.Visible = false
                            end

                            if ThirdEye.esp.Highlights.TeamCheck ~= true or GetTeam(player) ~= GetTeam(Players.LocalPlayer) then
                                Hilight.Enabled = ThirdEye.esp.Highlights.Highlights
                                Hilight.Adornee = player.Character

                                Hilight.OutlineColor = ThirdEye.esp.Highlights.OutlineColor
                                Hilight.FillColor = ThirdEye.esp.Highlights.FillColor

                                Hilight.FillTransparency = ThirdEye.esp.Highlights.FillTransparency
                                Hilight.OutlineTransparency = ThirdEye.esp.Highlights.OutlineTransparency

                                Hilight.DepthMode = ThirdEye.esp.Highlights.AlwaysVisible and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                            else
                                Hilight.Enabled = false
                                Hilight.Adornee = nil
                            end
                        else
                            LeftOutline.Visible = false
                            RightOutline.Visible = false
                            TopOutline.Visible = false
                            BottomOutline.Visible = false
                            Left.Visible = false
                            Right.Visible = false
                            Top.Visible = false
                            Bottom.Visible = false
                            TracerOutline.Visible = false
                            Tracer.Visible = false
                            Name.Visible = false
                            Distance.Visible = false
                        end
                    else
                        LeftOutline.Visible = false
                        RightOutline.Visible = false
                        TopOutline.Visible = false
                        BottomOutline.Visible = false
                        Left.Visible = false
                        Right.Visible = false
                        Top.Visible = false
                        Bottom.Visible = false
                        TracerOutline.Visible = false
                        Tracer.Visible = false
                        Name.Visible = false
                        Distance.Visible = false
                        Hilight.Adornee = nil
                    end
                end
            else
                LeftOutline.Visible = false
                RightOutline.Visible = false
                TopOutline.Visible = false
                BottomOutline.Visible = false
                Left.Visible = false
                Right.Visible = false
                Top.Visible = false
                Bottom.Visible = false
                TracerOutline.Visible = false
                Tracer.Visible = false
                Name.Visible = false
                Distance.Visible = false
                Hilight.Adornee = nil
            end
        end)

        if not Players:FindFirstChild(player.Name) then
            PlayerESP:Destroy()
            coroutine.yield()
        end
    end)
    coroutine.resume(co)
end

for _, plr in pairs(Players:GetChildren()) do
    if plr ~= Players.LocalPlayer then
        LoadESP(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= Players.LocalPlayer then
        LoadESP(plr)
    end
end)

-- Disable all ESP features when the cheat is unloaded
local function UnloadThirdEye()
    for _, gui in pairs(ESPHolder:GetChildren()) do
        gui:Destroy()
    end
    Library:Unload()
end

-- Library Initialization
local repo = 'https://raw.githubusercontent.com/DaniHRE/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter += 1

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end

    Library:SetWatermark(('ThirdEye V1 | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    UnloadThirdEye()  -- Disable all ESP features
    Library.Unloaded = true
end)

local Window = Library:CreateWindow({
    Title = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name) .. "| ThirdEye V1",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local BoxGB = Tabs.Main:AddLeftGroupbox('Box')
local EnemyGB = Tabs.Main:AddLeftGroupbox('Enemy')
local TracerGB = Tabs.Main:AddRightGroupbox("Tracer")
local HighlightGB = Tabs.Main:AddRightGroupbox("Highlight")
local SettingsGB = Tabs['UI Settings']:AddRightGroupbox("Menu")

SettingsGB:AddButton('Unload', function()
    Library:Unload()
end)

BoxGB:AddToggle('BoxEnabled', {
    Text = 'Enabled',
    Default = ThirdEye.esp.Box.Box,
    Tooltip = 'Enable or disable Box ESP',
    Callback = function(Value)
        ThirdEye.esp.Box.Box = Value
    end
})

BoxGB:AddSlider('BoxTransparency', {
    Text = 'Transparency',
    Default = ThirdEye.esp.Box.BoxTransparency,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        ThirdEye.esp.Box.BoxTransparency = Value
    end
})

BoxGB:AddLabel('Color'):AddColorPicker('BoxColor', {
    Default = ThirdEye.esp.Box.Color,
    Title = 'Color',
    Transparency = 0,
    Callback = function(Value)
        ThirdEye.esp.Box.Color = Value
    end
})

BoxGB:AddDivider()

BoxGB:AddToggle('BoxOutlineEnabled', {
    Text = 'Outline',
    Default = ThirdEye.esp.Box.Outline,
    Tooltip = 'Enable or disable Box Outline',
    Callback = function(Value)
        ThirdEye.esp.Box.Outline = Value
    end
})

BoxGB:AddLabel('Outline Color'):AddColorPicker('BoxOutlineColor', {
    Default = ThirdEye.esp.Box.OutlineColor,
    Title = 'Outline Color',
    Transparency = 0,
    Callback = function(Value)
        ThirdEye.esp.Box.OutlineColor = Value
    end
})

BoxGB:AddSlider('RenderDistance', {
    Text = 'Render Distance (m)',
    Default = ThirdEye.esp.RenderDistance,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Compact = false,
    Tooltip = 'Adjust the maximum render distance for ESP',
    Callback = function(Value)
        ThirdEye.esp.RenderDistance = Value
    end
})

EnemyGB:AddToggle('NameEnabled', {
    Text = 'Name',
    Default = ThirdEye.esp.Box.Name,
    Tooltip = 'Enable or disable Name',
    Callback = function(Value)
        ThirdEye.esp.Box.Name = Value
    end
})

EnemyGB:AddToggle('DistanceEnabled', {
    Text = 'Distance',
    Default = ThirdEye.esp.Box.Distance,
    Tooltip = 'Enable or disable Distance',
    Callback = function(Value)
        ThirdEye.esp.Box.Distance = Value
    end
})

TracerGB:AddToggle('TracerEnabled', {
    Text = 'Enabled',
    Default = ThirdEye.esp.Tracer.Tracer,
    Tooltip = 'Enable or disable Tracer',
    Callback = function(Value)
        ThirdEye.esp.Tracer.Tracer = Value
    end
})

TracerGB:AddLabel('Color'):AddColorPicker('TracerColor', {
    Default = ThirdEye.esp.Tracer.Color,
    Title = 'Color',
    Transparency = 0,
    Callback = function(Value)
        ThirdEye.esp.Tracer.Color = Value
    end
})

TracerGB:AddToggle('TracerOutline', {
    Text = 'Outline',
    Default = ThirdEye.esp.Tracer.Outline,
    Tooltip = 'Enable or disable Tracer Outline',
    Callback = function(Value)
        ThirdEye.esp.Tracer.Outline = Value
    end
})

TracerGB:AddLabel('Outline Color'):AddColorPicker('TracerOutlineColor', {
    Default = ThirdEye.esp.Tracer.OutlineColor,
    Title = 'Outline Color',
    Transparency = 0,
    Callback = function(Value)
        ThirdEye.esp.Tracer.OutlineColor = Value
    end
})

HighlightGB:AddToggle('HighlightEnabled', {
    Text = 'Enabled',
    Default = ThirdEye.esp.Highlights.Highlights,
    Tooltip = 'Enable or disable Highlights',
    Callback = function(Value)
        ThirdEye.esp.Highlights.Highlights = Value
    end
})

HighlightGB:AddSlider('HighlightOutlineTransparency', {
    Text = 'Outline Transparency',
    Default = ThirdEye.esp.Highlights.OutlineTransparency,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        ThirdEye.esp.Highlights.OutlineTransparency = Value
    end
})

HighlightGB:AddLabel('Outline Color'):AddColorPicker('HighlightOutlineColor', {
    Default = ThirdEye.esp.Highlights.OutlineColor,
    Title = 'Outline Color',
    Transparency = 0,
    Callback = function(Value)
        ThirdEye.esp.Highlights.OutlineColor = Value
    end
})

HighlightGB:AddSlider('HighlightFillTransparency', {
    Text = 'Fill Transparency',
    Default = ThirdEye.esp.Highlights.FillTransparency,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        ThirdEye.esp.Highlights.FillTransparency = Value
    end
})

HighlightGB:AddLabel('Fill Color'):AddColorPicker('HighlightFillColor', {
    Default = ThirdEye.esp.Highlights.FillColor,
    Title = 'Fill Color',
    Transparency = 0,
    Callback = function(Value)
        ThirdEye.esp.Highlights.FillColor = Value
    end
})

HighlightGB:AddSlider('RenderDistance', {
    Text = 'Render Distance (m)',
    Default = ThirdEye.esp.RenderDistance,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Compact = false,
    Tooltip = 'Adjust the maximum render distance for Highlights',
    Callback = function(Value)
        ThirdEye.esp.RenderDistance = Value
    end
})

HighlightGB:AddToggle('HighlightAlwaysVisible', {
    Text = 'Always Visible',
    Default = ThirdEye.esp.Highlights.AlwaysVisible,
    Tooltip = 'Enable or disable Always Visible for Highlights',
    Callback = function(Value)
        ThirdEye.esp.Highlights.AlwaysVisible = Value
    end
})

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('ThirdEye')
ThemeManager:ApplyToTab(Tabs['UI Settings'])
ThemeManager:ApplyTheme("BBot")

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
SaveManager:SetFolder('ThirdEye')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
