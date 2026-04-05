-- ZT HUD - ULTRA FINAL V25 (IMMORTALITY ADDED)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- LIMPIAR UI
if CoreGui:FindFirstChild("ZTHUD") then
    CoreGui.ZTHUD:Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ZTHUD"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,210)
frame.Position = UDim2.new(0.5,-130,0.5,-105)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "ZT HUD"
title.BackgroundColor3 = Color3.fromRGB(25,25,25)
title.TextColor3 = Color3.new(1,1,1)

-- BOTONES
local minimize = Instance.new("TextButton", frame)
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-90,0,0)
minimize.Text = "-"

local expand = Instance.new("TextButton", frame)
expand.Size = UDim2.new(0,30,0,30)
expand.Position = UDim2.new(1,-60,0,0)
expand.Text = "+"

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"

-- FARM
local farmBtn = Instance.new("TextButton", frame)
farmBtn.Size = UDim2.new(1,-20,0,40)
farmBtn.Position = UDim2.new(0,10,0,50)
farmBtn.Text = "FARM: OFF"

-- GOD MODE
local godBtn = Instance.new("TextButton", frame)
godBtn.Size = UDim2.new(1,-20,0,30)
godBtn.Position = UDim2.new(0,10,0,95)
godBtn.Text = "GOD: OFF"

-- SPEED UI
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.new(1,0,0,20)
speedLabel.Position = UDim2.new(0,0,0,130)
speedLabel.Text = "Speed: 500000"
speedLabel.BackgroundTransparency = 1

local minus = Instance.new("TextButton", frame)
minus.Size = UDim2.new(0,50,0,30)
minus.Position = UDim2.new(0,20,0,155)
minus.Text = "-"

local plus = Instance.new("TextButton", frame)
plus.Size = UDim2.new(0,50,0,30)
plus.Position = UDim2.new(0,100,0,155)
plus.Text = "+"

-- DRAG
local dragging, dragStart, startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- VARIABLES
local farming = false
local godMode = false
local force
local gyro
local currentSpeed = 0
local maxSpeed = 500000
local speedControl = maxSpeed

-- CONTROL VELOCIDAD
plus.MouseButton1Click:Connect(function()
    speedControl = math.min(speedControl + 2000, maxSpeed)
    speedLabel.Text = "Speed: "..speedControl
end)

minus.MouseButton1Click:Connect(function()
    speedControl = math.max(0, speedControl - 2000)
    speedLabel.Text = "Speed: "..speedControl
end)

-- GOD MODE
godBtn.MouseButton1Click:Connect(function()
    godMode = not godMode
    godBtn.Text = godMode and "GOD: ON" or "GOD: OFF"
end)

-- MANTENER VIDA
RunService.RenderStepped:Connect(function()
    if godMode then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
            end
        end
    end
end)

-- MINIMIZAR
minimize.MouseButton1Click:Connect(function()
    frame.Size = UDim2.new(0,260,0,30)
    farmBtn.Visible = false
    godBtn.Visible = false
    speedLabel.Visible = false
    plus.Visible = false
    minus.Visible = false
end)

-- RESTAURAR
expand.MouseButton1Click:Connect(function()
    frame.Size = UDim2.new(0,260,0,210)
    farmBtn.Visible = true
    godBtn.Visible = true
    speedLabel.Visible = true
    plus.Visible = true
    minus.Visible = true
end)

-- CERRAR
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- VEHÍCULO
local function getSeat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then return hum.SeatPart end
end

-- ALTURA
local function getGroundY(pos)
    local origin = pos + Vector3.new(0, 50, 0)
    local direction = Vector3.new(0, -200, 0)
    local result = workspace:Raycast(origin, direction)
    return result and result.Position.Y or pos.Y
end

-- AUTOFARM (SIN CAMBIOS)
local function startFarm()
    local seat = getSeat()
    if not seat then return end

    if force then force:Destroy() end
    if gyro then gyro:Destroy() end

    force = Instance.new("BodyVelocity")
    force.MaxForce = Vector3.new(1e7, 1e7, 1e7)
    force.Parent = seat

    gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    gyro.P = 100000
    gyro.D = 5000
    gyro.Parent = seat

    RunService.RenderStepped:Connect(function()
        if farming and seat then
            
            local forward = seat.CFrame.LookVector
            currentSpeed = math.min(currentSpeed + 500, speedControl)

            local groundY = getGroundY(seat.Position)
            local targetY = groundY + 35
            local lift = (targetY - seat.Position.Y) * 2

            seat.AssemblyLinearVelocity = Vector3.new(0,0,0)
            seat.AssemblyAngularVelocity = Vector3.new(0,0,0)

            local forwardVel = forward * currentSpeed

            force.Velocity = Vector3.new(
                forwardVel.X,
                lift,
                forwardVel.Z
            )

            local pos = seat.Position
            local flatForward = Vector3.new(forward.X, 0, forward.Z).Unit

            seat.CFrame = CFrame.lookAt(
                pos,
                pos + flatForward,
                Vector3.new(0,1,0)
            )
        end
    end)
end

-- FARM
farmBtn.MouseButton1Click:Connect(function()
    farming = not farming
    
    if farming then
        farmBtn.Text = "FARM: ON"
        currentSpeed = 0
        startFarm()
    else
        farmBtn.Text = "FARM: OFF"
        if force then force:Destroy() end
        if gyro then gyro:Destroy() end
    end
end)

-- ANTI AFK
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
