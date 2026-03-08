        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        -- Hover effect
        btn.MouseEnter:Connect(function()
            btn:TweenSize(UDim2.new(1, -20, 0, 44), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        end)
        btn.MouseLeave:Connect(function()
            btn:TweenSize(UDim2.new(1, -20, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        end)

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Komponen: Toggle dengan animasi
    function Ultimate.UI:CreateToggle(parent, text, default, callback, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 40)
        frame.Position = UDim2.new(0, 10, 0, y or 10)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 15
        label.Parent = frame

        local toggleBg = Instance.new("Frame")
        toggleBg.Size = UDim2.new(0, 50, 0, 24)
        toggleBg.Position = UDim2.new(1, -55, 0.5, -12)
        toggleBg.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(100, 100, 100)
        toggleBg.Parent = frame

        local cornerToggle = Instance.new("UICorner")
        cornerToggle.CornerRadius = UDim.new(1, 0)
        cornerToggle.Parent = toggleBg

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 20, 0, 20)
        circle.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.Parent = toggleBg

        local cornerCircle = Instance.new("UICorner")
        cornerCircle.CornerRadius = UDim.new(1, 0)
        cornerCircle.Parent = circle

        local enabled = default
        local function update()
            toggleBg.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(100, 100, 100)
            circle:TweenPosition(enabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        end

        toggleBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                enabled = not enabled
                update()
                callback(enabled)
            end
        end)

        return function() return enabled end
    end

    -- Komponen: InputBox
    function Ultimate.UI:CreateInput(parent, placeholder, y, callback)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -20, 0, 40)
        box.Position = UDim2.new(0, 10, 0, y or 10)
        box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        box.PlaceholderText = placeholder
        box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.Font = Enum.Font.Gotham
        box.TextSize = 15
        box.ClearTextOnFocus = false
        box.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = box

        box.FocusLost:Connect(function(enter)
            if enter then
                callback(box.Text)
            end
        end)

        return box
    end

    -- Komponen: List/ScrollingFrame
    function Ultimate.UI:CreateScrollingFrame(parent, size, position)
        local sf = Instance.new("ScrollingFrame")
        sf.Size = size or UDim2.new(1, -20, 1, -20)
        sf.Position = position or UDim2.new(0, 10, 0, 10)
        sf.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        sf.BackgroundTransparency = 0.3
        sf.BorderSizePixel = 0
        sf.CanvasSize = UDim2.new(0, 0, 5, 0)
        sf.ScrollBarThickness = 4
        sf.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = sf

        return sf
    end
end-- Key System untuk melindungi script
Ultimate.KeySystem = {}
do
    local function generateHWID()
        local userId = tostring(game.Players.LocalPlayer.UserId)
        local sum = 0
        for i = 1, #userId do
            sum = sum + string.byte(userId, i)
        end
        return tostring(sum)
    end

    local function checkLicense(key)
        -- Validasi dengan server (jika online) atau lokal
        -- Untuk offline, kita bisa menggunakan daftar key yang di-hash
        local validKeys = {
            ["GOJO-TRIAL"] = { expiry = os.time() + 86400, hwid = nil },
            ["GOJO-PREMIUM"] = { expiry = os.time() + 31536000, hwid = nil },
        }
        local data = validKeys[key]
        if data and (data.hwid == nil or data.hwid == generateHWID()) and data.expiry > os.time() then
            return true
        end
        return false
    end

    -- Tampilkan GUI key prompt
    function Ultimate.KeySystem:prompt()
        local win = Ultimate.UI:CreateWindow("GOJO-V8 Ultimate - Key Required", UDim2.new(0, 300, 0, 200), UDim2.new(0.5, -150, 0.5, -100))
        local container = win.Container

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 40)
        label.Position = UDim2.new(0, 10, 0, 10)
        label.BackgroundTransparency = 1
        label.Text = "Masukkan Key Anda:"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 16
        label.Parent = container

        local keyBox = Ultimate.UI:CreateInput(container, "Key...", 60, function() end)
        keyBox.Size = UDim2.new(1, -20, 0, 40)
        keyBox.Position = UDim2.new(0, 10, 0, 60)

        local btn = Ultimate.UI:CreateButton(container, "Aktifkan", function()
            if checkLicense(keyBox.Text) then
                label.Text = "Key valid! Memuat..."
                task.wait(1)
                win.Close()
                Ultimate.MainMenu()
            else
                label.Text = "Key tidak valid!"
            end
        end, 110)
    end
end-- Modules/ScriptFinder.lua
-- Script Finder OTOMATIS dengan pencarian real-time

Ultimate.ScriptFinder = Ultimate.ScriptFinder or {}

-- Fungsi HTTP request yang kompatibel dengan berbagai executor
local function httpRequest(url)
    -- Coba syn.request (Delta, Hydrogen, dll)
    if syn and syn.request then
        local response = syn.request({
            Url = url,
            Method = "GET",
            Headers = {["User-Agent"] = "GOJO-V8-Ultimate"}
        })
        if response.StatusCode == 200 then
            return response.Body
        end
    end

    -- Fallback ke game:HttpGet (terbatas untuk GET saja)
    local success, result = pcall(game.HttpGet, game, url)
    if success then
        return result
    end

    return nil
end

