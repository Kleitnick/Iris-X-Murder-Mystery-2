-- MM2
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Kleitnick/Iris-X/refs/heads/main/loader.lua"))()

local IrisX = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kleitnick/Iris-X/refs/heads/main/loader.lua"))()
local win = IrisX:CreateWindow({Title = "MM2", Size = Vector2.new(420, 560), Theme = "light"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    ESP_Enabled = false,
    ESP_Box = true,
    ESP_Name = true,
    ESP_Role = true,
    ESP_Distance = true,
    ESP_MaxDistance = 500,

    Fly_Enabled = false,
    Fly_Speed = 50,

    Speed_Value = 16,
    Jump_Value = 50,
    Noclip_Enabled = false,
    InfJump_Enabled = false,
}

local espSection = win:Section("ESP")
win:Toggle("Enabled", false, function(v) Config.ESP_Enabled = v end, espSection)
win:Toggle("Box", true, function(v) Config.ESP_Box = v end, espSection)
win:Toggle("Name", true, function(v) Config.ESP_Name = v end, espSection)
win:Toggle("Role", true, function(v) Config.ESP_Role = v end, espSection)
win:Toggle("Distance", true, function(v) Config.ESP_Distance = v end, espSection)
win:Slider("Max Distance", 50, 1000, 500, function(v) Config.ESP_MaxDistance = v end, espSection)

local flySection = win:Section("FLY")
win:Toggle("Enabled", false, function(v) Config.Fly_Enabled = v end, flySection)
win:Slider("Speed", 10, 500, 50, function(v) Config.Fly_Speed = v end, flySection)

local miscSection = win:Section("MISC")
win:Slider("WalkSpeed", 16, 200, 16, function(v)
    Config.Speed_Value = v
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end, miscSection)
win:Slider("JumpPower", 50, 300, 50, function(v)
    Config.Jump_Value = v
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v end
end, miscSection)
win:Toggle("Noclip", false, function(v) Config.Noclip_Enabled = v end, miscSection)
win:Toggle("Infinite Jump", false, function(v) Config.InfJump_Enabled = v end, miscSection)

win:AddUnloadButton()

local function getRole(player)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name == "Knife" then return "Murderer" end
            if item.Name == "Gun" then return "Sheriff" end
        end
    end
    return "Innocent"
end

local function getRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(220, 60, 60) end
    if role == "Sheriff" then return Color3.fromRGB(60, 130, 220) end
    return Color3.fromRGB(60, 180, 90)
end

local ESPObjects = {}

local function createESP(player)
    if ESPObjects[player] then return end
    ESPObjects[player] = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        role = Drawing.new("Text"),
        dist = Drawing.new("Text"),
    }
    local e = ESPObjects[player]
    e.box.Thickness = 1
    e.box.Filled = false
    e.name.Size = 13
    e.name.Center = true
    e.name.Outline = true
    e.name.Color = Color3.fromRGB(230, 230, 230)
    e.role.Size = 12
    e.role.Center = true
    e.role.Outline = true
    e.dist.Size = 12
    e.dist.Center = true
    e.dist.Outline = true
    e.dist.Color = Color3.fromRGB(200, 200, 200)
end

local function removeESP(player)
    local e = ESPObjects[player]
    if e then
        for _, o in pairs(e) do o:Remove() end
        ESPObjects[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    for player, e in pairs(ESPObjects) do
        local show = false
        local char = player.Character
        if Config.ESP_Enabled and char and player ~= LocalPlayer then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if hum and root and head and hum.Health > 0 then
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                if dist <= Config.ESP_MaxDistance then
                    local v, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        show = true
                        local hp = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
                        local bp = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        local h = math.abs(hp.Y - bp.Y)
                        local w = h * 0.6
                        local x, y = v.X - w / 2, v.Y - h / 2
                        local role = getRole(player)
                        local roleColor = getRoleColor(role)

                        if Config.ESP_Box then
                            e.box.Size = Vector2.new(w, h)
                            e.box.Position = Vector2.new(x, y)
                            e.box.Color = roleColor
                            e.box.Visible = true
                        else e.box.Visible = false end

                        if Config.ESP_Name then
                            e.name.Text = player.Name
                            e.name.Position = Vector2.new(v.X, y - 32)
                            e.name.Visible = true
                        else e.name.Visible = false end

                        if Config.ESP_Role then
                            e.role.Text = "[" .. role .. "]"
                            e.role.Position = Vector2.new(v.X, y - 16)
                            e.role.Color = roleColor
                            e.role.Visible = true
                        else e.role.Visible = false end

                        if Config.ESP_Distance then
                            e.dist.Text = string.format("[%d]", math.floor(dist))
                            e.dist.Position = Vector2.new(v.X, y + h + 3)
                            e.dist.Visible = true
                        else e.dist.Visible = false end
                    end
                end
            end
        end
        if not show then
            for _, o in pairs(e) do o.Visible = false end
        end
    end
end)

local flyConn
local bodyVel
local bodyGyro

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.PlatformStand = true

    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 10000
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    flyConn = RunService.RenderStepped:Connect(function()
        if not Config.Fly_Enabled then return end
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0 then move = move.Unit * Config.Fly_Speed end
        bodyVel.Velocity = move
        bodyGyro.CFrame = Camera.CFrame
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bodyVel then bodyVel:Destroy() bodyVel = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local lastFlyState = false
RunService.RenderStepped:Connect(function()
    if Config.Fly_Enabled and not lastFlyState then
        lastFlyState = true
        startFly()
    elseif not Config.Fly_Enabled and lastFlyState then
        lastFlyState = false
        stopFly()
    end
end)

RunService.Stepped:Connect(function()
    if not Config.Noclip_Enabled then return end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Config.Speed_Value ~= hum.WalkSpeed then hum.WalkSpeed = Config.Speed_Value end
    if Config.Jump_Value ~= hum.JumpPower then hum.JumpPower = Config.Jump_Value end
    if Config.InfJump_Enabled and hum:GetState() == Enum.HumanoidStateType.Freefall then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
