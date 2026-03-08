                title.Parent = item

                -- Game
                local gameLbl = Instance.new("TextLabel")
                gameLbl.Size = UDim2.new(1, -80, 0, 20)
                gameLbl.Position = UDim2.new(0, 5, 0, 30)
                gameLbl.BackgroundTransparency = 1
                gameLbl.Text = "🎮 " .. res.game .. "  |  👤 " .. res.creator
                gameLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
                gameLbl.Font = Enum.Font.Gotham
                gameLbl.TextSize = 12
                gameLbl.TextXAlignment = Enum.TextXAlignment.Left
                gameLbl.Parent = item

                -- Sumber
                local srcLbl = Instance.new("TextLabel")
                srcLbl.Size = UDim2.new(1, -80, 0, 20)
                srcLbl.Position = UDim2.new(0, 5, 0, 50)
                srcLbl.BackgroundTransparency = 1
                srcLbl.Text = "📌 " .. res.source .. (res.keyRequired and " (🔑 Key)" or "")
                srcLbl.TextColor3 = res.keyRequired and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
                srcLbl.Font = Enum.Font.Gotham
                srcLbl.TextSize = 11
                srcLbl.TextXAlignment = Enum.TextXAlignment.Left
                srcLbl.Parent = item

                -- Tombol Download
                local downloadBtn = Instance.new("TextButton")
                downloadBtn.Size = UDim2.new(0, 70, 0, 30)
                downloadBtn.Position = UDim2.new(1, -75, 0.5, -15)
                downloadBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                downloadBtn.Text = "⬇️"
                downloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                downloadBtn.Font = Enum.Font.GothamBold
                downloadBtn.TextSize = 18
                downloadBtn.Parent = item

                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 5)
                btnCorner.Parent = downloadBtn

                downloadBtn.MouseButton1Click:Connect(function()
                    local content = Ultimate.ScriptFinder:downloadScript(res.url)
                    if content then
                        -- Tampilkan opsi (jalankan / unobfuscate / bypass)
                        local actionWin = Ultimate.UI:CreateWindow("Script: "..res.title, UDim2.new(0, 350, 0, 300), UDim2.new(0.5, -175, 0.5, -150))
                        local ac = actionWin.Container

                        local info = Instance.new("TextLabel")
                        info.Size = UDim2.new(1, -20, 0, 60)
                        info.Position = UDim2.new(0, 10, 0, 10)
                        info.BackgroundTransparency = 1
                        info.Text = "Judul: "..res.title.."\nSumber: "..res.source
                        info.TextColor3 = Color3.fromRGB(255,255,255)
                        info.TextWrapped = true
                        info.TextXAlignment = Enum.TextXAlignment.Left
                        info.Parent = ac

                        Ultimate.UI:CreateButton(ac, "▶ Jalankan Script", function()
                            loadstring(content)()
                            actionWin.Close()
                        end, 80)

                        Ultimate.UI:CreateButton(ac, "🔓 Unobfuscate", function()
                            local deob = Ultimate.Unobfuscator:deob(content)
                            -- Tampilkan hasil
                            local textWin = Ultimate.UI:CreateWindow("Hasil Deobfuscate", UDim2.new(0, 400, 0, 500), UDim2.new(0.5, -200, 0.5, -250))
                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1, -20, 1, -20)
                            txt.Position = UDim2.new(0, 10, 0, 10)
                            txt.BackgroundTransparency = 1
                            txt.Text = deob
                            txt.TextColor3 = Color3.fromRGB(255,255,255)
                            txt.TextWrapped = true
                            txt.TextXAlignment = Enum.TextXAlignment.Left
                            txt.TextYAlignment = Enum.TextYAlignment.Top
                            txt.Parent = textWin.Container
                        end, 140)

                        if res.keyRequired then
                            Ultimate.UI:CreateButton(ac, "🔑 Bypass Key", function()
                                local key = Ultimate.KeyBypasser:bypass(content)
                                if key then
                                    game:StarterGui:SetCore("SendNotification", {Title="Key Bypass", Text="Key ditemukan: "..key, Duration=5})
                                else
                                    game:StarterGui:SetCore("SendNotification", {Title="Key Bypass", Text="Tidak dapat menemukan key", Duration=5})
                                end
                            end, 200)
                        end
                    else
                        game:StarterGui:SetCore("SendNotification", {Title="Error", Text="Gagal download script", Duration=3})
                    end
                end)

                ry = ry + 85
            end
            resultsFrame.CanvasSize = UDim2.new(0, 0, 0, ry)
        end)
    end, y)
    y = y + 50

    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, y)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "💡 Masukkan kata kunci dan tekan Cari"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.Parent = parent
    y = y + 40
end-- Key Bypasser Module
Ultimate.KeyBypasser = {}
do
    -- Coba deteksi fungsi key di script
    function Ultimate.KeyBypasser:bypass(script)
        -- Metode 1: cari pola umum (misal: if key == "xxx" then)
        local patterns = {
            'key%s*==%s*"([^"]+)"',
            'key%s*==%s*%\'([^\']+)\'',
            'checkKey%(([^)]+)%)',
        }
        for _, pattern in ipairs(patterns) do
            local found = script:match(pattern)
            if found then
                return found
            end
        end

        -- Metode 2: coba ekstrak dari string literal
        local allStrings = {}
        for str in script:gmatch('"([^"]+)"') do
            table.insert(allStrings, str)
        end
        for str in script:gmatch("'([^']+)'") do
            table.insert(allStrings, str)
        end
        -- Filter yang mungkin key (panjang 6-20, alfanumerik)
        for _, s in ipairs(allStrings) do
            if #s >= 4 and #s <= 20 and s:match("^[A-Za-z0-9_]+$") then
                -- Coba gunakan sebagai key (simulasi)
                return s
            end
        end

        return nil
    end

    -- Hook loadstring untuk intercept key request
    function Ultimate.KeyBypasser:hook()
        local oldLoad = loadstring
        loadstring = function(s, chunk)
            -- Cek apakah script meminta key, jika ya, coba bypass
            if s:find("key") or s:find("Key") then
                local key = Ultimate.KeyBypasser:bypass(s)
                if key then
                    -- Ganti dengan key yang ditemukan? Tidak mudah.
                end
            end
            return oldLoad(s, chunk)
        end
    end
end-- Unobfuscator Module
Ultimate.Unobfuscator = {}
do
    -- Deteksi jenis obfuscation
    function Ultimate.Unobfuscator:detect(script)
        if script:find("MoonSec") then
            return "MoonSec"
        elseif script:find("IronBrew") then
            return "IronBrew"
        elseif script:find("Oxide") then
            return "Oxide"
        else
            return "Unknown"
        end
    end

    -- Deobfuscate sederhana (hanya untuk demonstrasi)
    function Ultimate.Unobfuscator:deob(script)
        local detected = self:detect(script)
        if detected == "MoonSec" then
            -- MoonSec V3: biasanya berupa rantai gsub dan load
            -- Contoh sederhana: ambil string terakhir yang di-load
            local lastString = script:match("('[^']+')$") or script:match('("[^"]+")$')
            if lastString then
                return "// Deobfuscated (simulated):\n" .. lastString
            else
                return script
            end
        else
            return script
        end
    end

    -- Untuk JavaScript (jika diperlukan)
    function Ultimate.Unobfuscator:deobJS(js)
        -- Bisa panggil layanan eksternal atau gunakan js-beautifier jika tersedia
        -- Karena lokal, kita bisa gunakan pattern sederhana
