local original = string.char
if string.char ~= original then
    error("Environment tampered")
end

if not game or not game:GetService("Workspace") then
    error("Invalid environment context")
end

local rayfield_parts = {"https://", "sirius", ".menu", "/rayfield"}
local rayfield_url = table.concat(rayfield_parts)

local Rayfield = loadstring(game:HttpGet(rayfield_url))()
getgenv().AshlyRayfield = Rayfield

getgenv().AshlyState = {
    ESPEnabled = false,
    ChamsEnabled = false,
    EnemyOnly = false,
    AimbotEnabled = true,
    FOVEnabled = false,
    AimbotSmoothness = 4
}

local function createMainWindow()
    local Window = Rayfield:CreateWindow({
       Name = "Ashly",
       LoadingTitle = "Ashly Script",
       LoadingSubtitle = "by Ashe",
       ToggleUIKeybind = "K",
       ConfigurationSaving = {Enabled = false},
       KeySystem = false
    })
    getgenv().AshlyWindow = Window
    return Window
end

local Window = createMainWindow()

local savedKeyFile = "Ashly_SavedKey.txt"
local KeyInput = ""

if isfile and isfile(savedKeyFile) then
    local s, res = pcall(function() return readfile(savedKeyFile) end)
    if s and type(res) == "string" then
        KeyInput = res:gsub("^%s*(.-)%s*$", "%1")
    end
end

local function getValidationUrl()
    local p = {"https://", "yourserver", ".com", "/api/validate"}
    return table.concat(p)
end

local function validateKey(keyToTest)
    --[[ Uncomment for real server validation
    local req = (syn and syn.request) or (http and http.request) or request or http_request
    if not req then return false end
    
    local success, response = pcall(function()
        return req({
            Url = getValidationUrl(),
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode({key = keyToTest})
        })
    end)
    
    if success and response and response.Body == "valid" then
        return true
    end
    return false
    ]]--

    if keyToTest == "Newbeginning1" then
        return true
    end
    return false
end

local function loadModules()
    local function loadRemoteModule(moduleName)
        local url_parts = {"https://raw.githubusercontent.com", "/Ashev27", "/Ashev", "/main/", moduleName, ".lua"}
        local module_url = table.concat(url_parts)
        
        local s, res = pcall(function()
            return loadstring(game:HttpGet(module_url))()
        end)
        if not s then
            warn("Failed to load module: " .. moduleName .. " | Error: " .. tostring(res))
        end
    end

    loadRemoteModule("ui_main")
    loadRemoteModule("esp")
    loadRemoteModule("aimbot")
end

if KeyInput ~= "" and validateKey(KeyInput) then
    Rayfield:Notify({Title = "Auto-Login", Content = "Saved key used: '" .. KeyInput .. "'", Duration = 5})
    loadModules()
    Rayfield:Notify({Title = "Loaded", Content = "Modules successfully injected.", Duration = 3})
else
    if isfile and isfile(savedKeyFile) and delfile then
        pcall(function() delfile(savedKeyFile) end)
    end
    KeyInput = ""

    local AuthTab = Window:CreateTab("Authentication", 4483362458)
    
    AuthTab:CreateInput({
        Name = "Enter Secret Key",
        PlaceholderText = "Key...",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
            KeyInput = Text
        end,
    })

    AuthTab:CreateButton({
        Name = "Login",
        Callback = function()
            Rayfield:Notify({Title = "Authenticating", Content = "Checking key...", Duration = 2})
            
            local isValid = validateKey(KeyInput)

            if isValid then
                Rayfield:Notify({Title = "Success", Content = "Key valid! Loading modules...", Duration = 3})
                if writefile then
                    writefile(savedKeyFile, KeyInput)
                end
                
                -- Make authentication disappear by recreating the window without the Auth tab
                pcall(function() Rayfield:Destroy() end)
                Window = createMainWindow()
                loadModules()
                
                Rayfield:Notify({Title = "Loaded", Content = "Modules successfully injected.", Duration = 3})
            else
                Rayfield:Notify({Title = "Denied", Content = "Invalid Key! Please try again.", Duration = 3})
            end
        end
    })
end