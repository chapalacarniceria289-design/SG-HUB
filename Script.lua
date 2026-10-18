local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local ENDPOINT = "https://scriptkeeper-hub.lovable.app/api/public/validate"
local SAVE_FILE = "sghub_key.txt"
local req = (syn and syn.request) or http_request or request

local NEON1 = Color3.fromRGB(255, 30, 90)
local NEON2 = Color3.fromRGB(255, 0, 190)
local BG = Color3.fromRGB(10, 4, 9)
local PANEL = Color3.fromRGB(22, 8, 16)
local OK = Color3.fromRGB(60, 255, 150)
local WARN = Color3.fromRGB(255, 190, 80)

pcall(function() playerGui:FindFirstChild("SGKeyWindow"):Destroy() end)
pcall(function() game:GetService("CoreGui"):FindFirstChild("SGKeyWindow"):Destroy() end)

local function call(key, heartbeat)
    if not req then return nil, "Tu executor no soporta requests" end
    local ok, r = pcall(req, {
        Url = ENDPOINT,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({
            key = key,
            hwid = game:GetService("RbxAnalyticsService"):GetClientId(),
            heartbeat = heartbeat or nil,
        }),
    })
    if not ok or not r then return nil, "No se pudo conectar al servidor" end
    if r.StatusCode ~= 200 then return nil, "Servidor no disponible (" .. tostring(r.StatusCode) .. ")" end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, r.Body)
    if not ok2 or type(data) ~= "table" then return nil, "Respuesta inválida del servidor" end
    return data
end

local function launch(data, key)
    pcall(function() if writefile then writefile(SAVE_FILE, key) end end)
    if data.permanent then
        getgenv().KeyRemaining = -1
    else
        getgenv().KeyExpireAt = tick() + (data.remaining or 0)
    end
    task.spawn(function()
        while task.wait(120) do
            local hb = call(key, true)
            if hb and not hb.ok then
                LocalPlayer:Kick("[SG HUB] " .. tostring(hb.msg))
                break
            end
        end
    end)
    local fn = loadstring(data.script or "")
    if fn then
        task.spawn(fn)
        return true
    end
    return false
end

local function neonGradient(parent, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, NEON1),
        ColorSequenceKeypoint.new(0.5, NEON2),
        ColorSequenceKeypoint.new(1, NEON1),
    })
    g.Rotation = rotation or 0
    g.Parent = parent
    return g
end
local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = o
    return c
end

local function showWindow(prefill)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SGKeyWindow"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local parented = pcall(function()
        local h = gethui and gethui()
        gui.Parent = h or game:GetService("CoreGui")
    end)
    if not parented or not gui.Parent then gui.Parent = playerGui end

    local dim = Instance.new("Frame")
    dim.Size = UDim2.new(1, 0, 1, 0)
    dim.BackgroundColor3 = Color3.new(0, 0, 0)
    dim.BackgroundTransparency = 1
    dim.BorderSizePixel = 0
    dim.Parent = gui
    TweenService:Create(dim, TweenInfo.new(0.3), { BackgroundTransparency = 0.45 }):Play()

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = UDim2.new(0, 340, 0, 262)
    frame.BackgroundColor3 = BG
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    corner(frame, 16)

    local st = Instance.new("UIStroke")
    st.Thickness = 2
    st.Color = Color3.new(1, 1, 1)
    st.Parent = frame
    local stGrad = neonGradient(st, 0)

    local glow = Instance.new("Frame")
    glow.Position = UDim2.new(0, -7, 0, -7)
    glow.Size = UDim2.new(1, 14, 1, 14)
    glow.BackgroundTransparency = 1
    glow.Parent = frame
    corner(glow, 22)
    local glowSt = Instance.new("UIStroke")
    glowSt.Thickness = 7
    glowSt.Color = NEON1
    glowSt.Transparency = 0.75
    glowSt.Parent = glow

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 42, 0, 42)
    badge.Position = UDim2.new(0, 20, 0, 18)
    badge.BackgroundColor3 = Color3.new(1, 1, 1)
    badge.Text = "SG"
    badge.TextColor3 = Color3.new(1, 1, 1)
    badge.TextSize = 17
    badge.Font = Enum.Font.GothamBlack
    badge.Parent = frame
    corner(badge, 12)
    neonGradient(badge, 45)

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0, 74, 0, 16)
    title.Size = UDim2.new(1, -120, 0, 26)
    title.BackgroundTransparency = 1
    title.Text = "SG HUB"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 21
    title.Font = Enum.Font.GothamBlack
    title.TextStrokeColor3 = NEON1
    title.TextStrokeTransparency = 0.55
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local sub = Instance.new("TextLabel")
    sub.Position = UDim2.new(0, 74, 0, 42)
    sub.Size = UDim2.new(1, -120, 0, 18)
    sub.BackgroundTransparency = 1
    sub.Text = "Verificación de licencia"
    sub.TextColor3 = Color3.fromRGB(190, 140, 165)
    sub.TextSize = 12
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = frame

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 28, 0, 28)
    close.Position = UDim2.new(1, -42, 0, 16)
    close.BackgroundColor3 = PANEL
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(210, 160, 185)
    close.TextSize = 13
    close.Font = Enum.Font.GothamBold
    close.Parent = frame
    corner(close, 8)

    local line = Instance.new("Frame")
    line.Position = UDim2.new(0, 20, 0, 74)
    line.Size = UDim2.new(1, -40, 0, 2)
    line.BackgroundColor3 = Color3.new(1, 1, 1)
    line.BorderSizePixel = 0
    line.Parent = frame
    neonGradient(line, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.new(0, 22, 0, 86)
    lbl.Size = UDim2.new(1, -44, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Text = "TU KEY"
    lbl.TextColor3 = NEON1
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local box = Instance.new("TextBox")
    box.Position = UDim2.new(0, 20, 0, 106)
    box.Size = UDim2.new(1, -40, 0, 44)
    box.BackgroundColor3 = PANEL
    box.Text = prefill or ""
    box.PlaceholderText = "SG-PREMIUM-XXXXXXX-XXXXXXX"
    box.PlaceholderColor3 = Color3.fromRGB(110, 70, 90)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.TextSize = 14
    box.Font = Enum.Font.Code
    box.ClearTextOnFocus = false
    box.Parent = frame
    corner(box, 10)
    local bst = Instance.new("UIStroke")
    bst.Color = Color3.fromRGB(80, 30, 55)
    bst.Thickness = 1.5
    bst.Parent = box
    box.Focused:Connect(function()
        TweenService:Create(bst, TweenInfo.new(0.2), { Color = NEON1, Thickness = 2 }):Play()
    end)
    box.FocusLost:Connect(function()
        TweenService:Create(bst, TweenInfo.new(0.2), { Color = Color3.fromRGB(80, 30, 55), Thickness = 1.5 }):Play()
    end)

    local status = Instance.new("TextLabel")
    status.Position = UDim2.new(0, 22, 0, 156)
    status.Size = UDim2.new(1, -44, 0, 32)
    status.BackgroundTransparency = 1
    status.Text = "Introduce tu key para continuar"
    status.TextColor3 = Color3.fromRGB(150, 110, 130)
    status.TextSize = 12
    status.TextWrapped = true
    status.Font = Enum.Font.Gotham
    status.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Position = UDim2.new(0, 20, 0, 194)
    btn.Size = UDim2.new(1, -40, 0, 46)
    btn.BackgroundColor3 = Color3.new(1, 1, 1)
    btn.Text = "ENTRAR"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBlack
    btn.AutoButtonColor = false
    btn.Parent = frame
    corner(btn, 12)
    local btnGrad = neonGradient(btn, 0)
    local btnSt = Instance.new("UIStroke")
    btnSt.Color = NEON2
    btnSt.Thickness = 1
    btnSt.Transparency = 0.4
    btnSt.Parent = btn
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { TextSize = 17 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { TextSize = 15 }):Play()
    end)

    local foot = Instance.new("TextLabel")
    foot.Position = UDim2.new(0, 0, 1, -18)
    foot.Size = UDim2.new(1, 0, 0, 14)
    foot.BackgroundTransparency = 1
    foot.Text = "SG HUB · licencia protegida"
    foot.TextColor3 = Color3.fromRGB(100, 60, 80)
    foot.TextSize = 10
    foot.Font = Enum.Font.Gotham
    foot.Parent = frame

    do
        local dragging, dragStart, startPos
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if input.Position.Y - frame.AbsolutePosition.Y < 74 then
                    dragging, dragStart, startPos = true, input.Position, frame.Position
                end
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    task.spawn(function()
        local t = 0
        while gui.Parent do
            t = t + 0.03
            stGrad.Rotation = (stGrad.Rotation + 3) % 360
            btnGrad.Rotation = (btnGrad.Rotation + 1.5) % 360
            glowSt.Transparency = 0.7 + math.sin(t * 2) * 0.12
            task.wait(0.03)
        end
    end)

    frame.Size = UDim2.new(0, 340, 0, 0)
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 340, 0, 262),
    }):Play()

    local busy, fails, lockedUntil = false, 0, 0
    local function setStatus(text, color)
        status.Text = text
        status.TextColor3 = color or NEON1
    end
    local function shake()
        local base = frame.Position
        for i = 1, 6 do
            frame.Position = base + UDim2.new(0, (i % 2 == 0) and 9 or -9, 0, 0)
            task.wait(0.04)
        end
        frame.Position = base
    end

    local function submit()
        if busy then return end
        if tick() < lockedUntil then
            setStatus("Demasiados intentos. Espera " .. math.ceil(lockedUntil - tick()) .. "s", WARN)
            task.spawn(shake)
            return
        end
        local key = box.Text:gsub("%s+", ""):upper()
        if key == "" then
            setStatus("Escribe tu key", WARN)
            task.spawn(shake)
            return
        end

        busy = true
        setStatus("Conectando con el servidor...", Color3.fromRGB(190, 140, 165))
        task.spawn(function()
            local n = 0
            while busy do
                n = n % 3 + 1
                btn.Text = "VERIFICANDO" .. string.rep(".", n)
                task.wait(0.3)
            end
        end)

        local data, err = call(key, false)
        if not data then
            setStatus(err or "Error de conexión")
            task.spawn(shake)
        elseif not data.ok then
            fails = fails + 1
            setStatus("✕  " .. tostring(data.msg or "Key inválida"))
            task.spawn(shake)
            if fails >= 5 then
                lockedUntil = tick() + 30
                fails = 0
            end
        else
            busy = false
            btn.Text = "ACCESO CONCEDIDO"
            setStatus("✓  Licencia válida", OK)
            glowSt.Color = OK
            stGrad.Color = ColorSequence.new(OK)
            task.wait(0.7)
            TweenService:Create(frame, TweenInfo.new(0.25), { Size = UDim2.new(0, 340, 0, 0) }):Play()
            TweenService:Create(dim, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
            task.wait(0.28)
            gui:Destroy()
            if not launch(data, key) then
                LocalPlayer:Kick("[SG HUB] Error al cargar el script")
            end
            return
        end
        busy = false
        task.wait(0.35)
        btn.Text = "ENTRAR"
    end

    btn.Activated:Connect(submit)
    box.FocusLost:Connect(function(enter) if enter then submit() end end)
    close.Activated:Connect(function() gui:Destroy() end)
end

local preset = getgenv().Key or script_key
if preset and preset ~= "" then
    local key = tostring(preset):gsub("%s+", ""):upper()
    local data = call(key, false)
    if data and data.ok then
        if not launch(data, key) then LocalPlayer:Kick("[SG HUB] Error al cargar el script") end
        return
    end
end

local saved = ""
pcall(function()
    if isfile and readfile and isfile(SAVE_FILE) then saved = readfile(SAVE_FILE) end
end)
showWindow(saved)
