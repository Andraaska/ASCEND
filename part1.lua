-- GOJO-V8 Ultimate - Core Engine
local Ultimate = {}
Ultimate.Version = "1.0.0"

-- Deteksi lingkungan
do
    local success, executor = pcall(identifyexecutor)
    Ultimate.Env = {
        Executor = success and executor or "Unknown",
        GameId = game.PlaceId,
        GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown",
        Platform = game:GetService("UserInputService").TouchEnabled and "Mobile" or "PC",
        Memory = (collectgarbage("count") or 0) -- perkiraan memori
    }
end

-- Optimasi berdasarkan spesifikasi (deteksi RAM via performa)
do
    -- Simulasi deteksi dengan mengukur waktu eksekusi loop
    local start = os.clock()
    for i=1,10000 do end
    local elapsed = os.clock() - start
    Ultimate.Optimization = {
        LowMemory = (Ultimate.Env.Memory < 50000), -- 50MB sisa?
        SlowDevice = (elapsed > 0.1),
        PerformanceMode = false
    }
    if Ultimate.Optimization.LowMemory or Ultimate.Optimization.SlowDevice then
        Ultimate.Optimization.PerformanceMode = true
    end
end

-- Enkripsi data user (sederhana, gunakan base64 atau hashing)
do
    local http = game:GetService("HttpService")
    function Ultimate.Encrypt(data)
        -- Enkripsi sederhana: encode JSON + XOR dengan kunci
        local json = http:JSONEncode(data)
        local key = "GOJOV8SECRET"
        local encrypted = ""
        for i=1, #json do
            encrypted = encrypted .. string.char(json:byte(i) ~ key:byte((i-1)%#key+1))
        end
        return http:Base64Encode(encrypted)
    end

    function Ultimate.Decrypt(encrypted)
        local decoded = http:Base64Decode(encrypted)
        local key = "GOJOV8SECRET"
        local json = ""
        for i=1, #decoded do
            json = json .. string.char(decoded:byte(i) ~ key:byte((i-1)%#key+1))
        end
        return http:JSONDecode(json)
    end
end

-- Error handler global
function Ultimate.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[GOJO-V8] Error: " .. tostring(result))
        -- Bisa kirim ke log internal
    end
    return result
end-- GUI Engine - GOJO-V8 Ultimate
do
    local gui = Instance.new("ScreenGui")
    gui.Name = "GOJO-V8_UI"
    gui.Parent = game.CoreGui
    gui.ResetOnSpawn = false

    -- Utility: membuat elemen bisa digeser
    local function makeDraggable(frame)
        local dragging = false
        local dragStart, startPos
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        frame.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- Fungsi membuat window dengan efek glassmorphism
    function Ultimate.UI:CreateWindow(title, size, position)
        local main = Instance.new("Frame")
        main.Size = size
        main.Position = position
        main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        main.BackgroundTransparency = 0.2
        main.BorderSizePixel = 0
        main.Parent = gui
        main.ZIndex = 10

        -- Sudut melengkung
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = main

        -- Stroke (garis tepi) neon
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 200, 255)
        stroke.Thickness = 1.5
        stroke.Transparency = 0.5
        stroke.Parent = main

        -- Shadow (efek glow)
        local shadow = Instance.new("ImageLabel")
        shadow.Size = UDim2.new(1, 20, 1, 20)
        shadow.Position = UDim2.new(0, -10, 0, -10)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://6015897843" -- glow texture
        shadow.ImageColor3 = Color3.fromRGB(0, 200, 255)
        shadow.ImageTransparency = 0.7
        shadow.Parent = main
        shadow.ZIndex = 5

        -- Title bar
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 35)
        titleBar.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        titleBar.BackgroundTransparency = 0.8
        titleBar.BorderSizePixel = 0
        titleBar.Parent = main

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -40, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 16
        titleLabel.Parent = titleBar

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 30, 1, 0)
        closeBtn.Position = UDim2.new(1, -30, 0, 0)
        closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        closeBtn.BackgroundTransparency = 0.5
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 18
        closeBtn.Parent = titleBar
        closeBtn.MouseButton1Click:Connect(function() main:Destroy() end)

        makeDraggable(titleBar)

        -- Container untuk konten
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -20, 1, -45)
        container.Position = UDim2.new(0, 10, 0, 40)
        container.BackgroundTransparency = 1
        container.Parent = main

        -- Animasi fade in
        main.BackgroundTransparency = 1
        stroke.Transparency = 1
        titleBar.BackgroundTransparency = 1
        for i=1,10 do
            main.BackgroundTransparency = 1 - i/10
            stroke.Transparency = 1 - i/10
            titleBar.BackgroundTransparency = 1 - i/10
            task.wait(0.02)
        end

        return {
            Main = main,
            Container = container,
            Close = function() main:Destroy() end
        }
    end

    -- Komponen: Tombol
    function Ultimate.UI:CreateButton(parent, text, callback, y)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, y or 10)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 15
        btn.Parent = parent

