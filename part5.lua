        return js:gsub("function%((.-)%)", "function(%1)") -- contoh
    end
end-- Infinite Yield Loader
Ultimate.InfiniteYield = {}
do
    function Ultimate.InfiniteYield:load()
        local url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
        local script = game:HttpGet(url)
        loadstring(script)()
    end
end-- AI Assistant Module
Ultimate.AI = {}
do
    -- Basis pengetahuan lokal
    local knowledge = {
        { pattern = "fitur", response = "Script ini memiliki fitur: Script Finder, Key Bypasser, Unobfuscator, Infinite Yield, AI Assistant, dan GUI futuristik." },
        { pattern = "cara pakai", response = "Buka menu utama dengan menjalankan script. Pilih tab yang diinginkan. Untuk pencarian script, gunakan Script Finder." },
        { pattern = "script finder", response = "Script Finder memungkinkan Anda mencari ribuan script dari database lokal. Ketik kata kunci, lalu pilih script untuk dijalankan atau dianalisis." },
        { pattern = "key bypass", response = "Key Bypasser mencoba menemukan key dalam script dengan menganalisis pola umum. Hasil tidak selalu akurat." },
        { pattern = "unobfuscate", response = "Unobfuscator dapat mendeteksi jenis obfuscation dan mencoba mengembalikan kode ke bentuk yang lebih mudah dibaca." },
    }

    -- Fungsi AI sederhana
    function Ultimate.AI:ask(question)
        question = question:lower()
        for _, item in ipairs(knowledge) do
            if question:find(item.pattern) then
                return item.response
            end
        end
        return "Maaf, saya belum mengerti pertanyaan itu. Coba tanya tentang fitur, cara pakai, script finder, key bypass, atau unobfuscate."
    end

    -- Opsi OLLAMA (jika user menjalankan server lokal)
    function Ultimate.AI:askOllama(question)
        local url = "http://localhost:11434/api/generate"
        local data = {
            model = "llama2",
            prompt = question,
            stream = false
        }
        local jsonData = game:GetService("HttpService"):JSONEncode(data)
        local success, response = pcall(function()
            return syn.request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        end)
        if success and response.StatusCode == 200 then
            local result = game:GetService("HttpService"):JSONDecode(response.Body)
            return result.response
        else
            return "OLLAMA tidak merespon. Gunakan mode lokal."
        end
    end

    -- Tampilkan GUI AI
    function Ultimate.AI:showUI()
        local win = Ultimate.UI:CreateWindow("AI Assistant", UDim2.new(0, 350, 0, 300), UDim2.new(0.5, -175, 0.5, -150))
        local container = win.Container

        local chatLog = Ultimate.UI:CreateScrollingFrame(container, UDim2.new(1, -20, 1, -100), UDim2.new(0, 10, 0, 10))
        local input = Ultimate.UI:CreateInput(container, "Tanya sesuatu...", 210, function(text)
            local response = Ultimate.AI:ask(text)
            -- Tambahkan ke chat log
            local msgFrame = Instance.new("Frame")
            msgFrame.Size = UDim2.new(1, -10, 0, 40)
            msgFrame.BackgroundTransparency = 1
            msgFrame.Parent = chatLog

            local userLabel = Instance.new("TextLabel")
            userLabel.Size = UDim2.new(1, 0, 0, 20)
            userLabel.BackgroundTransparency = 1
            userLabel.Text = "Anda: " .. text
            userLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
            userLabel.TextXAlignment = Enum.TextXAlignment.Left
            userLabel.Font = Enum.Font.Gotham
            userLabel.TextSize = 14
            userLabel.Parent = msgFrame

            local aiLabel = Instance.new("TextLabel")
            aiLabel.Size = UDim2.new(1, 0, 0, 20)
            aiLabel.Position = UDim2.new(0, 0, 0, 20)
            aiLabel.BackgroundTransparency = 1
            aiLabel.Text = "AI: " .. response
            aiLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            aiLabel.TextXAlignment = Enum.TextXAlignment.Left
            aiLabel.TextWrapped = true
            aiLabel.Font = Enum.Font.Gotham
            aiLabel.TextSize = 14
            aiLabel.Parent = msgFrame

            -- Update canvas size
            chatLog.CanvasSize = UDim2.new(0, 0, 0, chatLog.CanvasSize.Y.Offset + 50)
        end)
    end
end-- Main Menu
function Ultimate.MainMenu()
    local win = Ultimate.UI:CreateWindow("GOJO-V8 ULTIMATE", UDim2.new(0, 450, 0, 550), UDim2.new(0.5, -225, 0.5, -275))
    local container = win.Container

    -- Tab bar (sederhana dengan tombol di atas)
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -20, 0, 40)
    tabBar.Position = UDim2.new(0, 10, 0, 10)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = container

    local tabs = {"Script Finder", "Tools", "AI", "Settings"}
    local currentTab = 1
    local tabButtons = {}
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = container

    local function switchTab(idx)
        for i, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = (i == idx) and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(50, 50, 50)
        end
        -- Hapus konten lama
        for _, child in ipairs(contentFrame:GetChildren()) do
            child:Destroy()
        end
        if idx == 1 then
            -- Script Finder
            Ultimate.ScriptFinder:showUI(contentFrame)
        elseif idx == 2 then
            -- Tools: Infinite Yield, Unobfuscator, dll
            local y = 10
            Ultimate.UI:CreateButton(contentFrame, "Load Infinite Yield", function() Ultimate.InfiniteYield:load() end, y)
            y = y + 50
            Ultimate.UI:CreateButton(contentFrame, "Unobfuscate Script", function()
                local inputWin = Ultimate.UI:CreateWindow("Unobfuscate", UDim2.new(0, 400, 0, 300), UDim2.new(0.5, -200, 0.5, -150))
                local ic = inputWin.Container
                local textBox = Instance.new("TextBox")
                textBox.Size = UDim2.new(1, -20, 1, -80)
                textBox.Position = UDim2.new(0, 10, 0, 10)
                textBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
                textBox.TextColor3 = Color3.fromRGB(255,255,255)
                textBox.TextWrapped = true
                textBox.MultiLine = true
                textBox.PlaceholderText = "Tempel script di sini..."
                textBox.Parent = ic

                local btn = Ultimate.UI:CreateButton(ic, "Deobfuscate", function()
                    local deob = Ultimate.Unobfuscator:deob(textBox.Text)
                    local resultWin = Ultimate.UI:CreateWindow("Hasil", UDim2.new(0, 400, 0, 400), UDim2.new(0.5, -200, 0.5, -200))
                    local rc = resultWin.Container
                    local resLabel = Instance.new("TextLabel")
                    resLabel.Size = UDim2.new(1, -20, 1, -20)
                    resLabel.Position = UDim2.new(0, 10, 0, 10)
                    resLabel.BackgroundTransparency = 1
                    resLabel.Text = deob
                    resLabel.TextColor3 = Color3.fromRGB(255,255,255)
                    resLabel.TextWrapped = true
                    resLabel.TextXAlignment = Enum.TextXAlignment.Left
                    resLabel.TextYAlignment = Enum.TextYAlignment.Top
                    resLabel.Parent = rc
                end, 250)
            end, y)
        elseif idx == 3 then
            -- AI
            Ultimate.AI:showUI(contentFrame)
        elseif idx == 4 then
            -- Settings
            local y = 10
            local perfToggle = Ultimate.UI:CreateToggle(contentFrame, "Mode Performa", Ultimate.Optimization.PerformanceMode, function(state)
                Ultimate.Optimization.PerformanceMode = state
            end, y)
            y = y + 50
            local encryptToggle = Ultimate.UI:CreateToggle(contentFrame, "Enkripsi Data User", true, function(state)
                -- Implementasi enkripsi on/off
            end, y)
            y = y + 50
            Ultimate.UI:CreateButton(contentFrame, "Destroy GUI", function() win.Close() end, y)
        end
    end

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 1, 0)
        btn.Position = UDim2.new(0, (i-1)*85, 0, 0)
        btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(50, 50, 50)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = tabBar

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            currentTab = i
            switchTab(i)
        end)
        tabButtons[i] = btn
    end

    switchTab(1)
end
-- Mulai script
Ultimate.KeySystem:prompt()
