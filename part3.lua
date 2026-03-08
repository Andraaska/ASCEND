-- Pencarian di Rscripts.net
local function searchRscripts(query)
    local url = "https://api.rscripts.net/scripts?search=" .. game:GetService("HttpService"):UrlEncode(query)
    local response = httpRequest(url)
    if not response then return {} end

    local data = game:GetService("HttpService"):JSONDecode(response)
    local results = {}
    if data and data.scripts then
        for _, script in ipairs(data.scripts) do
            table.insert(results, {
                title = script.title,
                game = script.game or "Unknown",
                creator = script.creator or "Unknown",
                url = script.download_url or script.url,
                source = "Rscripts",
                keyRequired = script.keyRequired or false
            })
        end
    end
    return results
end

-- Pencarian di ScriptBlox.com (menggunakan API tidak resmi)
local function searchScriptBlox(query)
    local url = "https://scriptblox.com/api/script/search?q=" .. game:GetService("HttpService"):UrlEncode(query)
    local response = httpRequest(url)
    if not response then return {} end

    local data = game:GetService("HttpService"):JSONDecode(response)
    local results = {}
    if data and data.result and data.result.scripts then
        for _, script in ipairs(data.result.scripts) do
            table.insert(results, {
                title = script.title,
                game = script.game,
                creator = (script.user and script.user.username) or "Unknown",
                url = "https://scriptblox.com/script/" .. script.slug,
                source = "ScriptBlox",
                keyRequired = script.has_key or false
            })
        end
    end
    return results
end

-- Fungsi utama pencarian (menggabungkan semua sumber)
function Ultimate.ScriptFinder:search(query, callback)
    -- Reset hasil sebelumnya
    local allResults = {}
    local sources = {
        searchRscripts,
        searchScriptBlox
        -- Bisa ditambahkan sumber lain (Pastebin, dll) di sini
    }

    -- Lakukan pencarian paralel (menggunakan coroutine/task)
    local co = {}
    for i, sourceFunc in ipairs(sources) do
        co[i] = coroutine.create(function()
            local results = sourceFunc(query)
            for _, res in ipairs(results) do
                table.insert(allResults, res)
            end
        end)
        coroutine.resume(co[i])
    end

    -- Tunggu semua selesai (sederhana: loop sampai semua mati)
    while true do
        local allDead = true
        for i = 1, #co do
            if coroutine.status(co[i]) ~= "dead" then
                allDead = false
                break
            end
        end
        if allDead then break end
        task.wait(0.1)
    end

    -- Hapus duplikat berdasarkan URL
    local seen = {}
    local uniqueResults = {}
    for _, res in ipairs(allResults) do
        if not seen[res.url] then
            seen[res.url] = true
            table.insert(uniqueResults, res)
        end
    end

    -- Panggil callback dengan hasil
    if callback then
        callback(uniqueResults)
    end
    return uniqueResults
end

-- Fungsi download script dari URL
function Ultimate.ScriptFinder:downloadScript(url)
    -- Coba ambil konten script
    local content = httpRequest(url)
    if content then
        return content
    else
        return nil
    end
end

-- GUI Pencarian
function Ultimate.ScriptFinder:showUI(parent)
    local resultsFrame
    local statusLabel
    -- Hapus konten lama jika ada
    for _, child in ipairs(parent:GetChildren()) do
        child:Destroy()
    end

    local y = 10

    -- Label judul
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, y)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔍 SCRIPT FINDER OTOMATIS"
    titleLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Parent = parent
    y = y + 40

    -- Input pencarian
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -20, 0, 40)
    searchBox.Position = UDim2.new(0, 10, 0, y)
    searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    searchBox.PlaceholderText = "Masukkan nama game (contoh: Blox Fruit)..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 15
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = searchBox
    y = y + 50

    -- Tombol cari
    local searchBtn = Ultimate.UI:CreateButton(parent, "🔎 CARI SCRIPT", function()
        if searchBox.Text == "" then return end
        -- Tampilkan loading
        statusLabel.Text = "⏳ Mencari..."
        -- Hapus hasil sebelumnya
        if resultsFrame then resultsFrame:Destroy() end

        -- Lakukan pencarian
        Ultimate.ScriptFinder:search(searchBox.Text, function(results)
            statusLabel.Text = "✅ Ditemukan " .. #results .. " script"

            -- Buat ScrollingFrame untuk hasil
            resultsFrame = Instance.new("ScrollingFrame")
            resultsFrame.Size = UDim2.new(1, -20, 1, - (y + 40))
            resultsFrame.Position = UDim2.new(0, 10, 0, y + 40)
            resultsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            resultsFrame.BackgroundTransparency = 0.3
            resultsFrame.BorderSizePixel = 0
            resultsFrame.CanvasSize = UDim2.new(0, 0, 5, 0)
            resultsFrame.ScrollBarThickness = 4
            resultsFrame.Parent = parent

            local corner2 = Instance.new("UICorner")
            corner2.CornerRadius = UDim.new(0, 6)
            corner2.Parent = resultsFrame

            local ry = 5
            for i, res in ipairs(results) do
                -- Frame untuk setiap hasil
                local item = Instance.new("Frame")
                item.Size = UDim2.new(1, -10, 0, 80)
                item.Position = UDim2.new(0, 5, 0, ry)
                item.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                item.Parent = resultsFrame

                local itemCorner = Instance.new("UICorner")
                itemCorner.CornerRadius = UDim.new(0, 5)
                itemCorner.Parent = item

                -- Judul
                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, -80, 0, 25)
                title.Position = UDim2.new(0, 5, 0, 5)
                title.BackgroundTransparency = 1
                title.Text = res.title
                title.TextColor3 = Color3.fromRGB(255, 255, 0)
                title.Font = Enum.Font.GothamBold
                title.TextSize = 14
                title.TextXAlignment = Enum.TextXAlignment.Left
