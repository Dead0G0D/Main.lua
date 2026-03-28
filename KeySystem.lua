if not game:IsLoaded() then game.Loaded:Wait() end

-- ══════════════════════════════════════════
--           NULLHUB UNIFIED SCRIPT
--         Loader + Keysystem + Suggest
-- ══════════════════════════════════════════

-- ══════════════════════════════════════════
--              LOADER CONFIG
-- ══════════════════════════════════════════

local SUPPORTED_GAMES = {
    [92783581681786] = "https://raw.githubusercontent.com/Dead0G0D/Main.lua/refs/heads/main/Anime%20Cicker%20(Hunters%202.0).lua",
    [78754030900809] = "https://raw.githubusercontent.com/Dead0G0D/Main.lua/refs/heads/main/Scripts/Anime%20Leveling.lua",
}

local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1484255458477740224/UNHgxyTGlFyw84VkH0OYJcniTuL-tFwK6UoKNXOVSz32uo_QLJprWQmZqcKhagCFMIAH"
local DISCORD_INVITE  = "https://discord.gg/yjdxgGTDyy"
local SUGGESTED_FILE  = "NullHub_Suggested.json"

-- ══════════════════════════════════════════
--           KEYSYSTEM CONFIG
-- ══════════════════════════════════════════

local Options = {
    Draggable       = true,
    Background      = true,
    BlurBackground  = true,
    AutoClose       = true,
    PlayAnimations  = true,
    BlockReExecute  = true,
    AutoLoad        = true,
    UUIDCheck       = false,
}

local Links = {
    Discord = DISCORD_INVITE,
    BuyText = "buy button text",
}

local LaunchJunkie = {
    Provider   = "Nullhub",
    Service    = "NullHub",
    Identifier = "1041912",
}

-- ══════════════════════════════════════════
--              CONSTANTS
-- ══════════════════════════════════════════

local KEY_FILE   = "NullHub_Key.txt"
local KEY_LENGTH = 36
local UUID_PAT   = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"

local WINDOW_WIDTH  = 360
local WINDOW_HEIGHT = 388
local HEADER_HEIGHT = 46
local TABBAR_HEIGHT = 36
local CONTENT_Y     = HEADER_HEIGHT + TABBAR_HEIGHT
local CONTENT_H     = WINDOW_HEIGHT - CONTENT_Y
local INNER_PAD     = 12
local TAB_COUNT     = 3

-- ══════════════════════════════════════════
--                  PALETA
--
-- Tudo em preto / cinza / branco.
-- Sem cores de destaque espalhadas.
-- Feedbacks de estado (success/error/warning)
-- continuam coloridos porque são funcionais.
-- ══════════════════════════════════════════

local Palette = {
    -- Fundos (do mais escuro ao mais claro)
    BG0   = Color3.fromRGB(6,   6,   6),    -- fundo da janela
    BG1   = Color3.fromRGB(11,  11,  11),   -- header / tabbar
    BG2   = Color3.fromRGB(18,  18,  18),   -- card padrão
    BG3   = Color3.fromRGB(24,  24,  24),   -- card secundário / pending
    BG4   = Color3.fromRGB(30,  30,  30),   -- hover de botão

    -- Bordas / divisórias
    Line  = Color3.fromRGB(36,  36,  36),   -- divisória sutil
    Border= Color3.fromRGB(50,  50,  50),   -- stroke de card / input

    -- Textos
    TextHi  = Color3.fromRGB(235, 235, 235), -- texto principal (quase branco)
    TextMid = Color3.fromRGB(150, 150, 150), -- texto secundário (cinza médio)
    TextLo  = Color3.fromRGB(80,  80,  80),  -- texto desativado / placeholder

    -- Estados funcionais (mantidos coloridos — são semânticos)
    Success = Color3.fromRGB(90,  200, 160),
    Error   = Color3.fromRGB(220, 80,  90),
    Warning = Color3.fromRGB(255, 170, 70),
    Discord = Color3.fromRGB(88,  101, 242),
}

-- ══════════════════════════════════════════
--           DETECÇÃO DE JOGO
-- ══════════════════════════════════════════

local currentGameId = game.PlaceId
local IS_SUPPORTED  = SUPPORTED_GAMES[currentGameId] ~= nil

-- ══════════════════════════════════════════
--              BLOCK RE-EXECUTE
-- ══════════════════════════════════════════

if Options.BlockReExecute then
    if getgenv().__NULLHUB_KS_OPEN then return end
    getgenv().__NULLHUB_KS_OPEN = true
end

-- ══════════════════════════════════════════
--              SERVICES
-- ══════════════════════════════════════════

cloneref = cloneref or function(...) return ... end

local function GetService(name)
    return cloneref(game:GetService(name))
end

local Players            = GetService("Players")
local TweenService       = GetService("TweenService")
local UserInputService   = GetService("UserInputService")
local HttpService        = GetService("HttpService")
local CoreGui            = GetService("CoreGui")
local Lighting           = GetService("Lighting")
local ContentProvider    = GetService("ContentProvider")
local MarketplaceService = GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local IS_MOBILE   = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- ══════════════════════════════════════════
--                   ICONS
-- ══════════════════════════════════════════

local Icons = {
    Logo      = "rbxassetid://90421697308928",
    Key       = "rbxassetid://10871266112",
    Redeem    = "rbxassetid://10709790644",
    Close     = "rbxassetid://10747384394",
    Copy      = "rbxassetid://10734940376",
    Clock     = "rbxassetid://10723415903",
    UserInfo  = "rbxassetid://9405926389",
    Changelog = "rbxassetid://96498567035505",
    Discord   = "rbxassetid://101192191207677",
    KeyInput  = "rbxassetid://10747373176",
    Submit    = "rbxassetid://10709790644",
}

-- ══════════════════════════════════════════
--         ANTI SPAM / PERSIST (Suggest)
-- ══════════════════════════════════════════

getgenv().__NH_SUGGESTED = getgenv().__NH_SUGGESTED or {}

local function LoadSuggestedFile()
    if not (isfile and isfile(SUGGESTED_FILE)) then return {} end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(SUGGESTED_FILE))
    return (ok and type(data) == "table") and data or {}
end

local function AlreadySuggested(placeId)
    local key = tostring(placeId)
    if getgenv().__NH_SUGGESTED[key] then return true end
    return LoadSuggestedFile()[key] == true
end

local function MarkSuggested(placeId)
    local key = tostring(placeId)
    getgenv().__NH_SUGGESTED[key] = true
    if not writefile then return end
    local existing = LoadSuggestedFile()
    existing[key] = true
    pcall(writefile, SUGGESTED_FILE, HttpService:JSONEncode(existing))
end

-- ══════════════════════════════════════════
--            UTILITY FUNCTIONS
-- ══════════════════════════════════════════

local function Tween(object, properties, duration, style, direction)
    return TweenService:Create(
        object,
        TweenInfo.new(
            duration  or 0.2,
            style     or Enum.EasingStyle.Quint,
            direction or Enum.EasingDirection.Out
        ),
        properties
    ):Play()
end

local function Spring(object, properties, duration)
    return TweenService:Create(
        object,
        TweenInfo.new(duration or 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        properties
    ):Play()
end

local function New(className, properties)
    local object = Instance.new(className)
    for key, value in pairs(properties) do
        if key ~= "Parent" then object[key] = value end
    end
    if properties.Parent then object.Parent = properties.Parent end
    return object
end

local function Round(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = object
    return corner
end

local function Stroke(object, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color        = color        or Palette.Border
    stroke.Thickness    = thickness    or 1
    stroke.Transparency = transparency or 0
    stroke.Parent       = object
    return stroke
end

local function TouchCooldown(flag, seconds)
    if not getgenv then return false end
    if getgenv()[flag] then return true end
    getgenv()[flag] = true
    task.delay(seconds or 0.5, function()
        if getgenv then getgenv()[flag] = nil end
    end)
    return false
end

local function SafeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    return ok and result or nil
end

-- ══════════════════════════════════════════
--           KEY FILE HELPERS
-- ══════════════════════════════════════════

local function SaveKey(key)
    pcall(function()
        if writefile then
            writefile(KEY_FILE, HttpService:JSONEncode({ key = key }))
        end
    end)
end

local function LoadKey()
    local ok, result = pcall(function()
        if not (isfile and readfile) then return nil end
        if not isfile(KEY_FILE) then return nil end
        local raw = readfile(KEY_FILE)
        if not raw or #raw == 0 then return nil end
        local data = HttpService:JSONDecode(raw)
        return data and data.key or nil
    end)
    return ok and result or nil
end

local function ClearKey()
    pcall(function()
        if delfile and isfile and isfile(KEY_FILE) then delfile(KEY_FILE) end
    end)
end

-- ══════════════════════════════════════════
--               HWID HELPER
-- ══════════════════════════════════════════

local function GetHWID()
    if gethwid then
        local ok, value = pcall(gethwid)
        if ok and value then return tostring(value) end
    end
    local ok, clientId = pcall(function()
        return tostring(cloneref(game:GetService("RbxAnalyticsService")):GetClientId())
    end)
    return ok and clientId or ""
end

-- ══════════════════════════════════════════
--         SCRIPT_KEY PRE-SAVE CHECK
-- ══════════════════════════════════════════

do
    local existing = getgenv().SCRIPT_KEY
    if type(existing) == "string" and #existing > 0 then
        SaveKey(existing)
    end
end

-- ══════════════════════════════════════════
--             JUNKIE SDK LOADER
-- ══════════════════════════════════════════

local Junkie = nil
task.spawn(function()
    local ok, sdk = pcall(loadstring, game:HttpGet("https://jnkie.com/sdk/library.lua"))
    if not (ok and sdk) then return end
    local ok2, lib = pcall(sdk)
    if not (ok2 and lib) then return end
    lib.service    = LaunchJunkie.Service
    lib.identifier = LaunchJunkie.Identifier
    lib.provider   = LaunchJunkie.Provider
    Junkie = lib
end)

-- ══════════════════════════════════════════
--           GAME INFO (async)
-- ══════════════════════════════════════════

local gameInfo = { Name = "Unknown", IconId = nil }

task.spawn(function()
    local info = SafeCall(function()
        return MarketplaceService:GetProductInfo(currentGameId)
    end)
    if info then
        gameInfo.Name   = info.Name or "Unknown"
        gameInfo.IconId = (info.IconImageAssetId and info.IconImageAssetId ~= 0)
                          and info.IconImageAssetId or nil
    end
end)

-- ══════════════════════════════════════════
--              GUI SETUP
-- ══════════════════════════════════════════

if getgenv().__NULLHUB_GUI then
    pcall(function() getgenv().__NULLHUB_GUI:Destroy() end)
    getgenv().__NULLHUB_GUI = nil
end

local ScreenGui = New("ScreenGui", {
    Name           = "NullHubKey",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent         = CoreGui,
})

getgenv().__NULLHUB_GUI = ScreenGui

local BlurEffect = nil
if Options.BlurBackground then
    BlurEffect = New("BlurEffect", {
        Name   = "NullHubBlur",
        Size   = 0,
        Parent = Lighting,
    })
end

local BackgroundOverlay = New("Frame", {
    Size                   = UDim2.new(1, 0, 1, 0),
    BackgroundColor3       = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel        = 0,
    ZIndex                 = 1,
    Parent                 = ScreenGui,
})

local Window = New("Frame", {
    Size             = UDim2.new(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT),
    Position         = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Palette.BG0,
    BorderSizePixel  = 0,
    ClipsDescendants = true,
    Visible          = false,
    ZIndex           = 2,
    Parent           = ScreenGui,
})
Round(Window, 6)
Stroke(Window, Palette.Line, 1, 0)

-- ══════════════════════════════════════════
--          DOOR ANIMATION SYSTEM
-- ══════════════════════════════════════════

local LeftDoor = New("Frame", {
    Size             = UDim2.new(0.5, 0, 1, 0),
    Position         = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Palette.BG0,
    BorderSizePixel  = 0,
    ZIndex           = 10,
    Parent           = Window,
})

local RightDoor = New("Frame", {
    Size             = UDim2.new(0.5, 0, 1, 0),
    Position         = UDim2.new(0.5, 0, 0, 0),
    BackgroundColor3 = Palette.BG0,
    BorderSizePixel  = 0,
    ZIndex           = 10,
    Parent           = Window,
})

local DoorLogo = New("ImageLabel", {
    Size                   = UDim2.new(0, 356, 0, 142),
    Position               = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint            = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Image                  = "rbxassetid://105433751946385",--90431150498873
    ScaleType              = Enum.ScaleType.Fit,
    ImageTransparency      = 0,
    ZIndex                 = 11,
    Parent                 = Window,
})

local DoorState = {
    OPEN_LEFT_POS   = UDim2.new(-0.5, 0, 0, 0),
    OPEN_RIGHT_POS  = UDim2.new(1,    0, 0, 0),
    CLOSE_LEFT_POS  = UDim2.new(0,    0, 0, 0),
    CLOSE_RIGHT_POS = UDim2.new(0.5,  0, 0, 0),
}

local function AnimateDoors(direction, callback)
    local isOpen = direction == "open"

    if not Options.PlayAnimations then
        if isOpen then
            Window.Visible    = true
            LeftDoor.Visible  = false
            RightDoor.Visible = false
            DoorLogo.Visible  = false
            if Options.Background then BackgroundOverlay.BackgroundTransparency = 0.62 end
            if BlurEffect then BlurEffect.Size = 18 end
        else
            if Options.Background then BackgroundOverlay.BackgroundTransparency = 1 end
            if BlurEffect then BlurEffect.Size = 0 end
        end
        if callback then callback() end
        return
    end

    if isOpen then
        Window.Visible = true
        if Options.Background then Tween(BackgroundOverlay, { BackgroundTransparency = 0.62 }, 0.7) end
        if BlurEffect then Tween(BlurEffect, { Size = 18 }, 0.7) end
        Tween(DoorLogo, { ImageTransparency = 1 }, 0.6)
        task.delay(0.55, function()
            Tween(LeftDoor,  { Position = DoorState.OPEN_LEFT_POS  }, 0.88, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            Tween(RightDoor, { Position = DoorState.OPEN_RIGHT_POS }, 0.88, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            task.delay(0.92, function()
                LeftDoor.Visible  = false
                RightDoor.Visible = false
                DoorLogo.Visible  = false
                if callback then callback() end
            end)
        end)
    else
        LeftDoor.Visible   = true
        RightDoor.Visible  = true
        DoorLogo.Visible   = true
        LeftDoor.Position  = DoorState.OPEN_LEFT_POS
        RightDoor.Position = DoorState.OPEN_RIGHT_POS
        DoorLogo.ImageTransparency = 1

        Tween(LeftDoor,  { Position = DoorState.CLOSE_LEFT_POS  }, 0.48, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        Tween(RightDoor, { Position = DoorState.CLOSE_RIGHT_POS }, 0.48, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        task.delay(0.38, function() Tween(DoorLogo, { ImageTransparency = 0 }, 0.28) end)
        if Options.Background then
            task.delay(0.10, function() Tween(BackgroundOverlay, { BackgroundTransparency = 1 }, 0.38) end)
        end
        if BlurEffect then
            task.delay(0.10, function() Tween(BlurEffect, { Size = 0 }, 0.38) end)
        end
        task.delay(0.82, function()
            if callback then callback() end
        end)
    end
end

local function OpenDoorAnimation(callback)  AnimateDoors("open", callback) end
local function CloseDoorAnimation(callback)
    AnimateDoors("close", function()
        ScreenGui:Destroy()
        if callback then callback() end
    end)
end
local function HideAnimation(callback)
    AnimateDoors("close", function()
        Window.Visible = false
        if callback then callback() end
    end)
end
local function ShowAnimation(callback)
    LeftDoor.Position  = DoorState.CLOSE_LEFT_POS
    RightDoor.Position = DoorState.CLOSE_RIGHT_POS
    DoorLogo.ImageTransparency = 0
    AnimateDoors("open", callback)
end

-- ══════════════════════════════════════════
--                  HEADER
-- ══════════════════════════════════════════

local Header = New("Frame", {
    Size             = UDim2.new(1, 0, 0, HEADER_HEIGHT),
    BackgroundColor3 = Palette.BG1,
    BorderSizePixel  = 0,
    ZIndex           = 3,
    Parent           = Window,
})
Round(Header, 6)

-- Cobre arredondamento inferior
New("Frame", {
    Size             = UDim2.new(1, 0, 0, 10),
    Position         = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = Palette.BG1,
    BorderSizePixel  = 0,
    ZIndex           = 3,
    Parent           = Header,
})

-- Linha divisória simples (cinza, sem gradiente colorido)
New("Frame", {
    Size             = UDim2.new(1, 0, 0, 1),
    Position         = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = Palette.Line,
    BorderSizePixel  = 0,
    ZIndex           = 4,
    Parent           = Header,
})

-- Logo
New("ImageLabel", {
    Size                   = UDim2.new(0, 36, 0, 36),
    Position               = UDim2.new(0, 8, 0.4, -13),
    BackgroundTransparency = 1,
    Image                  = Icons.Logo,
    ImageColor3            = Palette.TextHi,
    ZIndex                 = 4,
    Parent                 = Header,
})

-- Nome
New("TextLabel", {
    Size                   = UDim2.new(0, 120, 0, 18),
    Position               = UDim2.new(0, 47, 0.5, -9),
    BackgroundTransparency = 1,
    Text                   = "NULL HUB",
    TextColor3             = Palette.TextHi,
    Font                   = Enum.Font.GothamBlack,
    TextSize               = 15,
    TextXAlignment         = Enum.TextXAlignment.Left,
    ZIndex                 = 4,
    Parent                 = Header,
})

-- Botão fechar
local HEADER_BTN_BG = Palette.BG3

local function MakeHeaderIconButton(xOffset, bgColor, imageId, imageSize, imageColor, onEnter, onLeave, onClick)
    local btn = New("TextButton", {
        Size             = UDim2.new(0, 26, 0, 26),
        Position         = UDim2.new(1, xOffset, 0.5, -13),
        BackgroundColor3 = bgColor,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 5,
        Parent           = Header,
    })
    Round(btn, 5)
    local img = New("ImageLabel", {
        Size                   = UDim2.new(0, imageSize, 0, imageSize),
        Position               = UDim2.new(0.5, -math.floor(imageSize / 2), 0.5, -math.ceil(imageSize / 2)),
        BackgroundTransparency = 1,
        Image                  = imageId,
        ImageColor3            = imageColor,
        ZIndex                 = 6,
        Parent                 = btn,
    })
    btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = onEnter }, 0.12) end)
    btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = onLeave }, 0.12) end)
    btn.MouseButton1Click:Connect(onClick)
    return btn, img
end

MakeHeaderIconButton(
    -36, HEADER_BTN_BG, Icons.Close, 11, Palette.TextMid,
    Palette.Error, HEADER_BTN_BG,
    function() CloseDoorAnimation() end
)

-- ══════════════════════════════════════════
--                 DRAGGABLE
-- ══════════════════════════════════════════

if Options.Draggable then
    local uiDragging      = false
    local activeDragInput = nil
    local dragStart       = nil
    local startPos        = nil

    local function IsClickInput(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end

    local function ClampWindow()
        local vp  = workspace.CurrentCamera.ViewportSize
        local pos = Window.Position
        return UDim2.new(
            0, math.clamp(pos.X.Offset, 0, vp.X - WINDOW_WIDTH),
            0, math.clamp(pos.Y.Offset, 0, vp.Y - WINDOW_HEIGHT)
        )
    end

    local function StartDrag(input)
        if not IsClickInput(input) or uiDragging then return end
        uiDragging      = true
        activeDragInput = input
        dragStart       = input.Position
        startPos        = Window.Position
    end

    Header.InputBegan:Connect(StartDrag)
    Window.InputBegan:Connect(StartDrag)

    UserInputService.InputChanged:Connect(function(input)
        if not uiDragging then return end
        local isMoveInput = IS_MOBILE
            and (activeDragInput == input and input.UserInputType == Enum.UserInputType.Touch)
            or (input.UserInputType == Enum.UserInputType.MouseMovement)
        if not isMoveInput then return end
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(
            0, startPos.X.Offset + delta.X,
            0, startPos.Y.Offset + delta.Y
        )
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not uiDragging then return end
        local isEndInput = IS_MOBILE
            and (activeDragInput == input and input.UserInputType == Enum.UserInputType.Touch)
            or (input.UserInputType == Enum.UserInputType.MouseButton1)
        if not isEndInput then return end
        uiDragging      = false
        activeDragInput = nil
        Tween(Window, { Position = ClampWindow() }, 0.2, Enum.EasingStyle.Quint)
    end)
end

-- ══════════════════════════════════════════
--                  TAB BAR
-- ══════════════════════════════════════════

local TabBar = New("Frame", {
    Size             = UDim2.new(1, 0, 0, TABBAR_HEIGHT),
    Position         = UDim2.new(0, 0, 0, HEADER_HEIGHT),
    BackgroundColor3 = Palette.BG1,
    BorderSizePixel  = 0,
    ZIndex           = 3,
    Parent           = Window,
})
New("Frame", {
    Size             = UDim2.new(1, 0, 0, 1),
    Position         = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = Palette.Line,
    BorderSizePixel  = 0,
    ZIndex           = 4,
    Parent           = TabBar,
})

local TAB_WIDTH = math.floor(WINDOW_WIDTH / TAB_COUNT)

-- Pill cinza escuro — sem cor
local TabPill = New("Frame", {
    Size             = UDim2.new(0, TAB_WIDTH - 14, 0, 24),
    Position         = UDim2.new(0, 7, 0.5, -12),
    BackgroundColor3 = Palette.BG3,
    BorderSizePixel  = 0,
    ZIndex           = 4,
    Parent           = TabBar,
})
Round(TabPill, 5)
Stroke(TabPill, Palette.Border, 1, 0)

local TabDefinitions = {
    { label = IS_SUPPORTED and "Key" or "Suggest", icon = IS_SUPPORTED and Icons.Key or Icons.Submit },
    { label = "User Info", icon = Icons.UserInfo   },
    { label = "Changelog", icon = Icons.Changelog  },
}

local TabButtons = {}
local TabPages   = {}
local ActiveTab  = 0

local function ActivateTab(index)
    if index == ActiveTab then return end
    local previous = ActiveTab
    ActiveTab = index
    Spring(TabPill, { Position = UDim2.new(0, (index - 1) * TAB_WIDTH + 7, 0.5, -12) }, 0.28)
    for i, tabData in ipairs(TabButtons) do
        local active = i == index
        -- Ativo = branco, inativo = cinza médio
        Tween(tabData.Label, { TextColor3  = active and Palette.TextHi  or Palette.TextMid }, 0.16)
        Tween(tabData.Icon,  { ImageColor3 = active and Palette.TextHi  or Palette.TextMid }, 0.16)
    end
    if previous > 0 then TabPages[previous].Visible = false end
    TabPages[index].Visible = true
end

for i, definition in ipairs(TabDefinitions) do
    local button = New("TextButton", {
        Size                   = UDim2.new(0, TAB_WIDTH, 1, 0),
        Position               = UDim2.new(0, (i - 1) * TAB_WIDTH, 0, 0),
        BackgroundTransparency = 1,
        Text                   = "",
        AutoButtonColor        = false,
        ZIndex                 = 5,
        Parent                 = TabBar,
    })
    local tabInner = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 6, Parent = button,
    })
    New("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        Padding             = UDim.new(0, 5),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = tabInner,
    })
    local icon = New("ImageLabel", {
        Size = UDim2.new(0, 13, 0, 13), BackgroundTransparency = 1,
        Image = definition.icon, ImageColor3 = Palette.TextMid,
        LayoutOrder = 1, ZIndex = 6, Parent = tabInner,
    })
    local labelObj = New("TextLabel", {
        Size = UDim2.new(0, 0, 0, 13), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, Text = definition.label,
        TextColor3 = Palette.TextMid, Font = Enum.Font.GothamSemibold,
        TextSize = 11, LayoutOrder = 2, ZIndex = 6, Parent = tabInner,
    })
    TabButtons[i] = { Button = button, Label = labelObj, Icon = icon }
    local page = New("Frame", {
        Size = UDim2.new(1, 0, 0, CONTENT_H), Position = UDim2.new(0, 0, 0, CONTENT_Y),
        BackgroundTransparency = 1, Visible = false,
        ClipsDescendants = true, ZIndex = 3, Parent = Window,
    })
    TabPages[i] = page
    button.MouseButton1Click:Connect(function() ActivateTab(i) end)
end

local FirstPage     = TabPages[1]
local UserInfoPage  = TabPages[2]
local ChangelogPage = TabPages[3]

-- ══════════════════════════════════════════
--              UI HELPERS
-- ══════════════════════════════════════════

local function MakeScrollFrame(parent)
    local scroll = New("ScrollingFrame", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = Palette.Border,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ZIndex                 = 4,
        Parent                 = parent,
    })
    New("UIPadding", {
        PaddingTop    = UDim.new(0, INNER_PAD),
        PaddingBottom = UDim.new(0, INNER_PAD),
        PaddingLeft   = UDim.new(0, INNER_PAD),
        PaddingRight  = UDim.new(0, INNER_PAD + 2),
        Parent        = scroll,
    })
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 8),
        Parent    = scroll,
    })
    return scroll
end

local function MakeCard(parent, height, layoutOrder)
    local card = New("Frame", {
        Size             = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Palette.BG2,
        BorderSizePixel  = 0,
        LayoutOrder      = layoutOrder or 0,
        ZIndex           = 5,
        Parent           = parent,
    })
    Round(card, 6)
    return card
end

local function MakeDivider(parent, layoutOrder)
    return New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Palette.Line,
        BorderSizePixel  = 0,
        LayoutOrder      = layoutOrder or 0,
        ZIndex           = 5,
        Parent           = parent,
    })
end

local function MakeLabel(parent, text, font, size, color, alignX, extraProps)
    local props = {
        BackgroundTransparency = 1,
        Text           = text,
        TextColor3     = color  or Palette.TextHi,
        Font           = font   or Enum.Font.Gotham,
        TextSize       = size   or 12,
        TextXAlignment = alignX or Enum.TextXAlignment.Left,
        ZIndex         = 6,
        Parent         = parent,
    }
    if extraProps then
        for k, v in pairs(extraProps) do props[k] = v end
    end
    return New("TextLabel", props)
end

-- ══════════════════════════════════════════
--     PAGE 1A — KEY PAGE (jogo suportado)
-- ══════════════════════════════════════════

local KeyScroll, StatusDot, StatusLabel
local InputCard, InputStroke, KeyBox
local GetKeyButton, GetKeyLabel, RedeemButton, RedeemLabel

if IS_SUPPORTED then
    KeyScroll   = MakeScrollFrame(FirstPage)
    InputCard   = MakeCard(KeyScroll, 44, 1)
    InputStroke = Stroke(InputCard, Palette.Border, 1, 0)

    New("ImageLabel", {
        Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new(0, 11, 0.5, -7),
        BackgroundTransparency = 1, Image = Icons.KeyInput,
        ImageColor3 = Palette.TextLo, ZIndex = 7, Parent = InputCard,
    })

    KeyBox = New("TextBox", {
        Size = UDim2.new(1, -34, 1, -2), Position = UDim2.new(0, 32, 0, 1),
        BackgroundTransparency = 1, Text = "",
        PlaceholderText = "Paste your key here...",
        TextColor3 = Palette.TextHi, PlaceholderColor3 = Palette.TextLo,
        Font = Enum.Font.GothamMedium, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false, ZIndex = 7, Parent = InputCard,
    })

    KeyBox.Focused:Connect(function()
        Tween(InputStroke, { Color = Palette.TextMid, Transparency = 0 }, 0.15)
    end)
    KeyBox.FocusLost:Connect(function(enterPressed)
        if not enterPressed then
            Tween(InputStroke, { Color = Palette.Border, Transparency = 0 }, 0.15)
        end
    end)
    KeyBox:GetPropertyChangedSignal("Text"):Connect(function()
        local len = #KeyBox.Text
        if len == 0 then
            Tween(InputStroke, { Color = Palette.Border, Transparency = 0 }, 0.1)
        elseif len < KEY_LENGTH then
            Tween(InputStroke, { Color = Palette.Warning, Transparency = 0.4 }, 0.12)
        elseif len == KEY_LENGTH then
            Tween(InputStroke, { Color = Palette.Success, Transparency = 0.3 }, 0.15)
        else
            Tween(InputStroke, { Color = Palette.Error, Transparency = 0.4 }, 0.12)
        end
    end)

    -- Status card
    local StatusCard = MakeCard(KeyScroll, 34, 2)
    StatusCard.BackgroundColor3 = Palette.BG1
    Stroke(StatusCard, Palette.Line, 1, 0)

    StatusDot = New("Frame", {
        Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 11, 0.5, -3),
        BackgroundColor3 = Palette.TextLo, BorderSizePixel = 0,
        ZIndex = 6, Parent = StatusCard,
    })
    Round(StatusDot, 99)

    StatusLabel = MakeLabel(StatusCard, "Get a key, paste it below", Enum.Font.Gotham, 10, Palette.TextLo, Enum.TextXAlignment.Left, {
        Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 22, 0, 0),
    })

    MakeDivider(KeyScroll, 3)

    -- Get Key button
    GetKeyButton = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Palette.BG3,
        Text = "", AutoButtonColor = false, LayoutOrder = 4, ZIndex = 5, Parent = KeyScroll,
    })
    Round(GetKeyButton, 8)
    Stroke(GetKeyButton, Palette.Border, 1, 0)
    New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0.5, -52, 0.5, -8),
        BackgroundTransparency = 1, Image = Icons.Key,
        ImageColor3 = Palette.TextMid, ZIndex = 6, Parent = GetKeyButton,
    })
    GetKeyLabel = MakeLabel(GetKeyButton, "Get Key", Enum.Font.GothamBold, 13, Palette.TextMid, Enum.TextXAlignment.Left, {
        Size = UDim2.new(0, 58, 0, 16), Position = UDim2.new(0.5, -28, 0.5, -8),
    })

    -- Redeem button
    RedeemButton = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Palette.BG3,
        Text = "", AutoButtonColor = false, LayoutOrder = 5, ZIndex = 5, Parent = KeyScroll,
    })
    Round(RedeemButton, 8)
    Stroke(RedeemButton, Palette.Border, 1, 0)
    New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0.5, -60, 0.5, -8),
        BackgroundTransparency = 1, Image = Icons.Redeem,
        ImageColor3 = Palette.TextMid, ZIndex = 6, Parent = RedeemButton,
    })
    RedeemLabel = MakeLabel(RedeemButton, "Redeem Key", Enum.Font.GothamBold, 13, Palette.TextMid, Enum.TextXAlignment.Left, {
        Size = UDim2.new(0, 82, 0, 16), Position = UDim2.new(0.5, -36, 0.5, -8),
    })

    MakeDivider(KeyScroll, 6)

    -- Shop banner
    local ShopBanner = New("Frame", {
        Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Palette.BG3,
        BorderSizePixel = 0, LayoutOrder = 7, ZIndex = 5, Parent = KeyScroll,
    })
    Round(ShopBanner, 8)
    local ShopLogoBg = New("Frame", {
        Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 8, 0.5, -16),
        BackgroundColor3 = Palette.BG2, BorderSizePixel = 0, ZIndex = 6, Parent = ShopBanner,
    })
    Round(ShopLogoBg, 6)
    New("ImageLabel", {
        Size = UDim2.new(0, 17, 0, 17), Position = UDim2.new(0.5, -8, 0.5, -9),
        BackgroundTransparency = 1, Image = Icons.Logo,
        ImageColor3 = Palette.TextHi, ZIndex = 7, Parent = ShopLogoBg,
    })
    MakeLabel(ShopBanner, "Get Lifetime-Key NOW!!", Enum.Font.GothamBold, 11, Palette.TextHi, Enum.TextXAlignment.Left, {
        Size = UDim2.new(1, -100, 0, 16), Position = UDim2.new(0, 50, 0, 8),
    })
    MakeLabel(ShopBanner, "Fast Delivery｜24/7 Support", Enum.Font.Gotham, 10, Palette.TextMid, Enum.TextXAlignment.Left, {
        Size = UDim2.new(1, -100, 0, 14), Position = UDim2.new(0, 50, 0, 26),
    })
    local BuyButton = New("TextButton", {
        Size = UDim2.new(0, 44, 0, 26), Position = UDim2.new(1, -52, 0.5, -13),
        BackgroundColor3 = Palette.BG2, Text = "BUY",
        TextColor3 = Palette.TextMid, Font = Enum.Font.GothamBold,
        TextSize = 10, AutoButtonColor = false, ZIndex = 7, Parent = ShopBanner,
    })
    Round(BuyButton, 5)
    Stroke(BuyButton, Palette.Border, 1, 0)
    BuyButton.MouseEnter:Connect(function() Tween(BuyButton, { BackgroundColor3 = Palette.BG4 }, 0.1) end)
    BuyButton.MouseLeave:Connect(function() Tween(BuyButton, { BackgroundColor3 = Palette.BG2 }, 0.1) end)
    BuyButton.MouseButton1Click:Connect(function()
        pcall(setclipboard, Links.BuyText)
        BuyButton.Text = "Copied!"
        BuyButton.TextColor3 = Palette.Success
        task.delay(1.4, function()
            BuyButton.Text = "BUY"
            BuyButton.TextColor3 = Palette.TextMid
        end)
    end)

    for _, btn in ipairs({ GetKeyButton, RedeemButton }) do
        btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = Palette.BG4 }, 0.1) end)
        btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = Palette.BG3 }, 0.1) end)
    end
end

-- ══════════════════════════════════════════
--   PAGE 1B — SUGGEST PAGE (não suportado)
-- ══════════════════════════════════════════

if not IS_SUPPORTED then
    local SuggestScroll = MakeScrollFrame(FirstPage)

    -- Card info do jogo
    local GameInfoCard = MakeCard(SuggestScroll, 60, 1)
    local GameThumb = New("ImageLabel", {
        Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 10, 0.5, -20),
        BackgroundColor3 = Palette.BG3, BorderSizePixel = 0,
        ZIndex = 6, Parent = GameInfoCard,
    })
    Round(GameThumb, 6)
    Stroke(GameThumb, Palette.Border, 1, 0)

    task.spawn(function()
        task.wait(1.5)
        if gameInfo.IconId then
            GameThumb.Image = "rbxassetid://" .. tostring(gameInfo.IconId)
        end
    end)

    local GameNameDisplay = MakeLabel(GameInfoCard, "Loading...", Enum.Font.GothamBold, 12, Palette.TextHi, Enum.TextXAlignment.Left, {
        Size = UDim2.new(1, -62, 0, 16), Position = UDim2.new(0, 60, 0, 12),
    })
    MakeLabel(GameInfoCard, "Place ID: " .. tostring(currentGameId), Enum.Font.Gotham, 10, Palette.TextLo, Enum.TextXAlignment.Left, {
        Size = UDim2.new(1, -62, 0, 14), Position = UDim2.new(0, 60, 0, 32),
    })

    -- Badge "NOT SUPPORTED" em cinza escuro — sem cor
    local UnsupBadge = New("Frame", {
        Size = UDim2.new(0, 0, 0, 16), Position = UDim2.new(1, -8, 0, 8),
        AnchorPoint = Vector2.new(1, 0), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Palette.BG4, BackgroundTransparency = 0,
        BorderSizePixel = 0, ZIndex = 6, Parent = GameInfoCard,
    })
    Round(UnsupBadge, 3)
    Stroke(UnsupBadge, Palette.Border, 1, 0)
    New("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = UnsupBadge })
    New("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, Text = "⚠ NOT SUPPORTED",
        TextColor3 = Palette.TextHi, Font = Enum.Font.GothamBold,
        TextSize = 8, ZIndex = 7, Parent = UnsupBadge,
    })

    task.spawn(function()
        task.wait(1.5)
        GameNameDisplay.Text = gameInfo.Name ~= "Unknown" and gameInfo.Name or "Unknown Game"
    end)

    -- Info card — cinza neutro
    local InfoCard = MakeCard(SuggestScroll, 50, 2)
    InfoCard.BackgroundColor3 = Palette.BG1
    Stroke(InfoCard, Palette.Line, 1, 0)
    MakeLabel(InfoCard, "⚠ This game isn't supported yet.", Enum.Font.GothamBold, 11, Palette.TextHi, Enum.TextXAlignment.Left, {
        Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 10, 0, 10),
    })
    MakeLabel(InfoCard, "Click below to suggest it to our team!", Enum.Font.Gotham, 10, Palette.TextMid, Enum.TextXAlignment.Left, {
        Size = UDim2.new(1, -20, 0, 14), Position = UDim2.new(0, 10, 0, 28),
    })

    -- Status card
    local SuggestStatusCard = MakeCard(SuggestScroll, 34, 3)
    SuggestStatusCard.BackgroundColor3 = Palette.BG1
    Stroke(SuggestStatusCard, Palette.Line, 1, 0)

    local SuggestStatusDot = New("Frame", {
        Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 11, 0.5, -3),
        BackgroundColor3 = Palette.TextLo, BorderSizePixel = 0,
        ZIndex = 6, Parent = SuggestStatusCard,
    })
    Round(SuggestStatusDot, 99)

    local SuggestStatusLabel = MakeLabel(SuggestStatusCard, "Click below to suggest this game", Enum.Font.Gotham, 10, Palette.TextLo, Enum.TextXAlignment.Left, {
        Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 22, 0, 0),
    })

    MakeDivider(SuggestScroll, 4)

    -- Submit button — cinza escuro, sem cor de destaque
    local SubmitButton = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Palette.BG3,
        Text = "", AutoButtonColor = false, LayoutOrder = 5, ZIndex = 5, Parent = SuggestScroll,
    })
    Round(SubmitButton, 8)
    Stroke(SubmitButton, Palette.Border, 1, 0)

    local SubmitInner = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 6, Parent = SubmitButton,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = SubmitInner,
    })
    local SubmitIcon = New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16), BackgroundTransparency = 1,
        Image = Icons.Submit, ImageColor3 = Palette.TextMid,
        LayoutOrder = 1, ZIndex = 6, Parent = SubmitInner,
    })
    local SubmitLabel = New("TextLabel", {
        Size = UDim2.new(0, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, Text = "Suggest This Game  ·  Submit",
        TextColor3 = Palette.TextMid, Font = Enum.Font.GothamBold,
        TextSize = 13, LayoutOrder = 2, ZIndex = 6, Parent = SubmitInner,
    })

    -- Discord card
    local DiscordCard = MakeCard(SuggestScroll, 38, 6)
    DiscordCard.BackgroundColor3 = Palette.BG1
    Stroke(DiscordCard, Palette.Line, 1, 0)
    New("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 10, 0.5, -7),
        BackgroundTransparency = 1, Image = Icons.Discord,
        ImageColor3 = Palette.Discord, ZIndex = 6, Parent = DiscordCard,
    })
    MakeLabel(DiscordCard, "Join our Discord for updates & support", Enum.Font.Gotham, 10, Palette.TextMid, Enum.TextXAlignment.Left, {
        Size = UDim2.new(1, -90, 0, 14), Position = UDim2.new(0, 32, 0, 12),
    })
    local CopyDiscordBtn = New("TextButton", {
        Size = UDim2.new(0, 50, 0, 22), Position = UDim2.new(1, -58, 0.5, -11),
        BackgroundColor3 = Palette.BG3, Text = "Copy",
        TextColor3 = Palette.TextMid, Font = Enum.Font.GothamBold,
        TextSize = 9, AutoButtonColor = false, ZIndex = 6, Parent = DiscordCard,
    })
    Round(CopyDiscordBtn, 4)
    Stroke(CopyDiscordBtn, Palette.Border, 1, 0)
    CopyDiscordBtn.MouseButton1Click:Connect(function()
        pcall(setclipboard, DISCORD_INVITE)
        CopyDiscordBtn.Text = "Copied!"
        CopyDiscordBtn.TextColor3 = Palette.Success
        task.delay(1.5, function()
            CopyDiscordBtn.Text = "Copy"
            CopyDiscordBtn.TextColor3 = Palette.TextMid
        end)
    end)

    local submitBgColor = Palette.BG3
    local submitted = false

    local function SetSuggestStatus(message, statusType)
        local colors = {
            success = Palette.Success,
            error   = Palette.Error,
            warning = Palette.Warning,
            idle    = Palette.TextLo,
        }
        local color = colors[statusType] or Palette.TextLo
        Tween(SuggestStatusDot,   { BackgroundColor3 = color }, 0.12)
        Tween(SuggestStatusLabel, { TextColor3       = color }, 0.12)
        SuggestStatusLabel.Text = message
    end

    local function SetSubmitState(state)
        if state == "idle" then
            submitted = false
            SubmitButton.Active = true
            SubmitLabel.Text = "Suggest This Game  ·  Submit"
            Tween(SubmitLabel, { TextColor3 = Palette.TextMid }, 0.2)
            Tween(SubmitIcon,  { ImageColor3 = Palette.TextMid }, 0.2)
            submitBgColor = Palette.BG3
            Tween(SubmitButton, { BackgroundColor3 = Palette.BG3 }, 0.2)
        elseif state == "loading" then
            SubmitButton.Active = false
            SubmitLabel.Text = "Submitting..."
            Tween(SubmitLabel, { TextColor3 = Palette.Warning }, 0.15)
            Tween(SubmitIcon,  { ImageColor3 = Palette.Warning }, 0.15)
        elseif state == "success" then
            submitted = true
            SubmitLabel.Text = "Submitted Successfully!"
            Tween(SubmitLabel, { TextColor3 = Palette.Success }, 0.2)
            Tween(SubmitIcon,  { ImageColor3 = Palette.Success }, 0.2)
            submitBgColor = Palette.BG1
            Tween(SubmitButton, { BackgroundColor3 = Palette.BG1 }, 0.2)
        elseif state == "error" then
            submitted = false
            SubmitButton.Active = true
            SubmitLabel.Text = "Suggest This Game  ·  Submit"
            Tween(SubmitLabel, { TextColor3 = Palette.TextLo }, 0.2)
            Tween(SubmitIcon,  { ImageColor3 = Palette.TextLo }, 0.2)
            submitBgColor = Palette.BG3
            Tween(SubmitButton, { BackgroundColor3 = Palette.BG3 }, 0.2)
        elseif state == "disabled" then
            submitted = true
            SubmitButton.Active = false
            SubmitLabel.Text = "Already Suggested"
            SubmitLabel.TextColor3 = Palette.TextLo
            SubmitIcon.ImageColor3 = Palette.TextLo
            submitBgColor = Palette.BG1
            Tween(SubmitButton, { BackgroundColor3 = Palette.BG1 }, 0)
        end
    end

    SubmitButton.MouseEnter:Connect(function()
        if not submitted then Tween(SubmitButton, { BackgroundColor3 = Palette.BG4 }, 0.1) end
    end)
    SubmitButton.MouseLeave:Connect(function()
        Tween(SubmitButton, { BackgroundColor3 = submitBgColor }, 0.1)
    end)

    if AlreadySuggested(currentGameId) then
        SetSubmitState("disabled")
        SetSuggestStatus("You already suggested this game ⚠ ", "warning")
    end

    SubmitButton.MouseButton1Click:Connect(function()
        if submitted then return end
        submitted = true
        SetSubmitState("loading")
        SetSuggestStatus("Sending suggestion to Discord...", "warning")
        pcall(setclipboard, DISCORD_INVITE)

        local webhookPayload = HttpService:JSONEncode({
            username   = "Null Hub System",
            avatar_url = "https://i.imgur.com/39mPqpk.jpeg",
            embeds = {{
                title       = "🎮 New Game Suggestion",
                description = "A user has submitted a new game suggestion for review.",
                color       = 0x5012c4,
                fields = {
                    { name = "Game Name",    value = "```" .. tostring(gameInfo.Name) .. "```", inline = false },
                    { name = "Place ID",     value = "`" .. tostring(currentGameId) .. "`",     inline = true  },
                    { name = "Game Link",    value = "[Click to open](https://www.roblox.com/games/" .. tostring(currentGameId) .. ")", inline = true },
                    { name = "Suggested By", value = "`" .. LocalPlayer.Name .. "`\nID: `" .. tostring(LocalPlayer.UserId) .. "`", inline = false },
                },
                thumbnail = { url = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. tostring(currentGameId) .. "&width=420&height=420&format=png" },
                footer    = { text = "Null Hub System • Game Suggestion", icon_url = "https://i.imgur.com/39mPqpk.jpeg" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        })

        local httpRequest = request or http_request or (syn and syn.request) or nil

        local success, err = pcall(function()
            if not httpRequest then error("executor sem suporte a request()") end
            httpRequest({
                Url     = DISCORD_WEBHOOK,
                Method  = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body    = webhookPayload,
            })
        end)

        if success then
            MarkSuggested(currentGameId)
            SetSubmitState("success")
            SetSuggestStatus("Submitted! Discord link copied  ✓", "success")
        else
            warn("[NullHub] Webhook error:", err)
            SetSubmitState("error")
            SetSuggestStatus("⚠ Failed to send  ·  try again", "error")
        end
    end)
end

-- ══════════════════════════════════════════
--             USER INFO PAGE
-- ══════════════════════════════════════════

local UserInfoScroll = MakeScrollFrame(UserInfoPage)

local AvatarCard = MakeCard(UserInfoScroll, 70, 1)
local AvatarImage = New("ImageLabel", {
    Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(0, 12, 0.5, -22),
    BackgroundColor3 = Palette.BG3, BackgroundTransparency = 0,
    BorderSizePixel = 0, Image = "", ZIndex = 6, Parent = AvatarCard,
})
Round(AvatarImage, 6)
Stroke(AvatarImage, Palette.Border, 1.5, 0)

task.spawn(function()
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.AvatarBust,
            Enum.ThumbnailSize.Size150x150
        )
    end)
    if ok and url then AvatarImage.Image = url end
end)

MakeLabel(AvatarCard, "Welcome back,", Enum.Font.Gotham, 10, Palette.TextLo, Enum.TextXAlignment.Left, {
    Size = UDim2.new(1, -68, 0, 14), Position = UDim2.new(0, 66, 0, 16),
})
MakeLabel(AvatarCard, LocalPlayer.DisplayName, Enum.Font.GothamBold, 14, Palette.TextHi, Enum.TextXAlignment.Left, {
    Size = UDim2.new(1, -68, 0, 18), Position = UDim2.new(0, 66, 0, 32),
    TextTruncate = Enum.TextTruncate.AtEnd,
})

local function InfoRow(labelText, valueText, layoutOrder)
    local card = MakeCard(UserInfoScroll, 34, layoutOrder)
    MakeLabel(card, labelText, Enum.Font.Gotham, 10, Palette.TextLo, Enum.TextXAlignment.Left, {
        Size = UDim2.new(0, 88, 1, 0), Position = UDim2.new(0, 12, 0, 0),
    })
    return MakeLabel(card, valueText, Enum.Font.GothamSemibold, 11, Palette.TextHi, Enum.TextXAlignment.Right, {
        Size = UDim2.new(1, -104, 1, 0), Position = UDim2.new(0, 92, 0, 0),
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local executorName = "Unknown"
if identifyexecutor then
    local ok, name = pcall(identifyexecutor)
    if ok and name then executorName = tostring(name) end
end
InfoRow("Executor", executorName,                                      2)
InfoRow("Device",   IS_MOBILE and "Mobile" or "PC",                    3)
InfoRow("Username", LocalPlayer.Name,                                  4)
InfoRow("User ID",  tostring(LocalPlayer.UserId),                      5)

local HWIDCard = MakeCard(UserInfoScroll, 34, 7)
MakeLabel(HWIDCard, "HWID", Enum.Font.Gotham, 10, Palette.TextLo, Enum.TextXAlignment.Left, {
    Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(0, 12, 0, 0),
})
local hwidValue = GetHWID()
local HWIDDots = MakeLabel(HWIDCard, string.rep("•", 18), Enum.Font.Gotham, 10, Palette.TextMid, Enum.TextXAlignment.Left, {
    Size = UDim2.new(1, -84, 1, 0), Position = UDim2.new(0, 60, 0, 0),
})
local CopyHWIDButton = New("TextButton", {
    Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -28, 0.5, -11),
    BackgroundColor3 = Palette.BG3, Text = "",
    AutoButtonColor = false, ZIndex = 6, Parent = HWIDCard,
})
Round(CopyHWIDButton, 4)
New("ImageLabel", {
    Size = UDim2.new(0, 11, 0, 11), Position = UDim2.new(0.5, -5, 0.5, -6),
    BackgroundTransparency = 1, Image = Icons.Copy,
    ImageColor3 = Palette.TextMid, ZIndex = 7, Parent = CopyHWIDButton,
})

local alreadyCopied = false
CopyHWIDButton.MouseButton1Click:Connect(function()
    if alreadyCopied then return end
    alreadyCopied = true
    pcall(setclipboard, hwidValue)
    HWIDDots.Text       = "Copied!"
    HWIDDots.TextColor3 = Palette.Success
    task.delay(1.5, function()
        alreadyCopied = false
        HWIDDots.Text       = string.rep("•", 18)
        HWIDDots.TextColor3 = Palette.TextMid
    end)
end)

MakeDivider(UserInfoScroll, 8)

local ClockCard = MakeCard(UserInfoScroll, 46, 9)
ClockCard.BackgroundColor3 = Palette.BG1
local ClockTime = MakeLabel(ClockCard, "", Enum.Font.GothamBold, 17, Palette.TextHi, Enum.TextXAlignment.Center, {
    Size = UDim2.new(1, 0, 0, 22), Position = UDim2.new(0, 0, 0, 6),
})
local ClockDate = MakeLabel(ClockCard, "", Enum.Font.Gotham, 10, Palette.TextLo, Enum.TextXAlignment.Center, {
    Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 30),
})

local MONTHS = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
local clockRunning = true

local function UpdateClock()
    if not clockRunning then return end
    local t    = os.date("*t")
    local hour = t.hour % 12
    if hour == 0 then hour = 12 end
    ClockTime.Text = string.format("%d:%02d:%02d %s", hour, t.min, t.sec, t.hour >= 12 and "PM" or "AM")
    ClockDate.Text = MONTHS[t.month] .. " " .. string.format("%02d", t.day) .. ", " .. t.year
    task.delay(1, UpdateClock)
end
UpdateClock()

-- ══════════════════════════════════════════
--             CHANGELOG PAGE
-- ══════════════════════════════════════════

local ChangelogScroll = MakeScrollFrame(ChangelogPage)

local ChangelogEntries = {
    { Version = "v0.1.1", Date = "Mar 25, 2026", Changes = { "Improved Keysystem UI x2", "Updated all functions" } },
    { Version = "v0.1", Date = "Mar 01, 2026", Changes = { "Improved Keysystem UI", "Unified Loader + Keysystem" } },
}

local CHANGE_ROW_H = 26

for index, entry in ipairs(ChangelogEntries) do
    local cardHeight = 40 + #entry.Changes * CHANGE_ROW_H + 8
    local card = MakeCard(ChangelogScroll, cardHeight, index)
    local badge = New("Frame", {
        Size = UDim2.new(0, 0, 0, 20), Position = UDim2.new(0, 10, 0, 10),
        AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Palette.BG3,
        BorderSizePixel = 0, ZIndex = 6, Parent = card,
    })
    Round(badge, 4)
    New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = badge })
    New("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, Text = entry.Version,
        -- Versão mais recente em branco, demais em cinza
        TextColor3 = index == 1 and Palette.TextHi or Palette.TextMid,
        Font = Enum.Font.GothamBold, TextSize = 11, ZIndex = 7, Parent = badge,
    })
    if index == 1 then Stroke(badge, Palette.Border, 1, 0) end
    MakeLabel(card, entry.Date, Enum.Font.Gotham, 10, Palette.TextLo, Enum.TextXAlignment.Right, {
        Size = UDim2.new(1, -12, 0, 20), Position = UDim2.new(0, 0, 0, 10),
    })
    for i, changeText in ipairs(entry.Changes) do
        local dotY = 40 + (i - 1) * CHANGE_ROW_H + 10
        local dot = New("Frame", {
            Size = UDim2.new(0, 3, 0, 3), Position = UDim2.new(0, 13, 0, dotY),
            BackgroundColor3 = Palette.TextLo, BorderSizePixel = 0, ZIndex = 6, Parent = card,
        })
        Round(dot, 2)
        New("TextLabel", {
            Size = UDim2.new(1, -26, 0, CHANGE_ROW_H),
            Position = UDim2.new(0, 24, 0, 40 + (i - 1) * CHANGE_ROW_H),
            BackgroundTransparency = 1, Text = changeText,
            TextColor3 = Palette.TextHi, Font = Enum.Font.Gotham,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, ZIndex = 6, Parent = card,
        })
    end
end

-- ══════════════════════════════════════════
--     STATUS + VALIDATE LOGIC (Key Page)
-- ══════════════════════════════════════════

local STATUS_COLORS = {
    success = Palette.Success,
    error   = Palette.Error,
    warning = Palette.Warning,
    idle    = Palette.TextLo,
}

local function SetStatus(message, statusType)
    if not StatusDot or not StatusLabel then return end
    local color = STATUS_COLORS[statusType] or Palette.TextLo
    Tween(StatusDot,   { BackgroundColor3 = color }, 0.12)
    Tween(StatusLabel, { TextColor3       = color }, 0.12)
    StatusLabel.Text = message
end

local function ShakeInput()
    if not InputCard then return end
    local orig = InputCard.Position
    local ox   = orig.X.Offset
    for _, offset in ipairs({ 5, -5, 3, -3, 1, -1, 0 }) do
        InputCard.Position = UDim2.new(orig.X.Scale, ox + offset, orig.Y.Scale, orig.Y.Offset)
        task.wait(0.025)
    end
    InputCard.Position = orig
end

local function ResetRedeem()
    if not RedeemLabel then return end
    RedeemLabel.Text       = "Redeem Key"
    RedeemLabel.TextColor3 = Palette.TextMid
    RedeemButton.Active    = true
    Tween(RedeemButton, { BackgroundColor3 = Palette.BG3 }, 0.15)
    if getgenv then getgenv()._NULLHUB_KS_LOCK = nil end
end

local processing = false

local function TryValidate(key)
    if not IS_SUPPORTED then return end
    if not key or #key == 0 then
        SetStatus("Enter a key first", "warning")
        ShakeInput()
        return
    end
    if processing then return end
    if TouchCooldown("_NULLHUB_KS_LOCK", 0.8) then return end

    processing = true
    RedeemLabel.Text    = "Checking..."
    RedeemButton.Active = false
    Tween(RedeemButton, { BackgroundColor3 = Palette.BG1 }, 0.15)
    Tween(InputStroke,  { Color = Palette.Border, Transparency = 0 }, 0.15)

    local lenDiff = #key - KEY_LENGTH
    if lenDiff ~= 0 then
        local msg = lenDiff < 0
            and ("Too short (" .. -lenDiff .. " chars missing)")
            or  ("Too long ("  ..  lenDiff .. " extra chars)")
        SetStatus(msg, "error")
        Tween(InputStroke, { Color = Palette.Error, Transparency = 0 }, 0.15)
        ShakeInput()
        task.delay(0.5, function() Tween(InputStroke, { Color = Palette.Border, Transparency = 0 }, 0.3) end)
        processing = false
        ResetRedeem()
        return
    end

    SaveKey(key)
    getgenv().SCRIPT_KEY = key

    SetStatus("Key Accepted  ·  Loading script...", "success")
    Tween(InputCard,    { BackgroundColor3 = Color3.fromRGB(10, 28, 18) }, 0.2)
    Tween(InputStroke,  { Color = Palette.Success, Transparency = 0 }, 0.2)
    Tween(RedeemButton, { BackgroundColor3 = Color3.fromRGB(16, 46, 28) }, 0.2)
    RedeemLabel.Text       = "Redeemed ✓"
    RedeemLabel.TextColor3 = Palette.Success

    if getgenv then getgenv()._NULLHUB_KS_LOCK = nil end
    processing = false

    if Options.AutoClose then
        task.delay(1.25, function()
            CloseDoorAnimation(function()
                local scriptUrl = SUPPORTED_GAMES[currentGameId]
                if scriptUrl then
                    task.spawn(function()
                        local ok, result = pcall(loadstring, game:HttpGet(scriptUrl))
                        if ok and result then pcall(result) end
                    end)
                end
            end)
        end)
    end
end

-- ══════════════════════════════════════════
--              BUTTON EVENTS (Key)
-- ══════════════════════════════════════════

if IS_SUPPORTED then
    GetKeyButton.MouseButton1Click:Connect(function()
        if processing then return end
        if TouchCooldown("_NULLHUB_GETCD", 0.6) then return end
        GetKeyButton.Active = false
        if not Junkie then
            SetStatus("Loading SDK... try again", "warning")
            task.delay(1.5, function() GetKeyButton.Active = true end)
            return
        end
        SetStatus("Opening link...", "warning")
        local ok, link = pcall(function() return Junkie.get_key_link() end)
        if ok and link and #link > 0 then
            pcall(setclipboard, link)
            SetStatus("Link copied  ·  complete steps & paste key", "success")
        else
            SetStatus("Rate limited  ·  try again soon", "error")
        end
        task.delay(0.7, function() GetKeyButton.Active = true end)
    end)

    RedeemButton.MouseButton1Click:Connect(function()
        if TouchCooldown("_NULLHUB_RDMCD", 0.5) then return end
        TryValidate(KeyBox.Text)
    end)

    KeyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then TryValidate(KeyBox.Text) end
    end)

    local savedKey = LoadKey()
    if savedKey and #savedKey > 0 then
        KeyBox.Text = savedKey
        if Options.AutoLoad then
            SetStatus("Checking saved key...", "warning")
            task.delay(0.6, function() TryValidate(savedKey) end)
        else
            SetStatus("Saved key loaded — press Redeem", "warning")
        end
    end
end

-- ══════════════════════════════════════════
--            DESTROYING CLEANUP
-- ══════════════════════════════════════════

ScreenGui.Destroying:Connect(function()
    clockRunning = false
    if BlurEffect then pcall(function() BlurEffect:Destroy() end) end
    if Options.BlockReExecute then getgenv().__NULLHUB_KS_OPEN = nil end
    getgenv().__NULLHUB_GUI = nil
end)

-- ══════════════════════════════════════════
--          ICON PRELOAD (async)
-- ══════════════════════════════════════════

task.spawn(function()
    local preloadInstances = {}
    for _, icon in pairs(Icons) do
        local img = Instance.new("ImageLabel")
        img.Image = icon
        table.insert(preloadInstances, img)
    end
    pcall(function() ContentProvider:PreloadAsync(preloadInstances) end)
    for _, img in ipairs(preloadInstances) do img:Destroy() end
end)

-- ══════════════════════════════════════════
--         TOGGLE JANELA - LEFT SHIFT
-- ══════════════════════════════════════════

do
    local windowOpen = true
    local toggling   = false

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode ~= Enum.KeyCode.LeftShift then return end
        if toggling then return end
        toggling = true
        if windowOpen then
            windowOpen = false
            HideAnimation(function() toggling = false end)
        else
            windowOpen = true
            ShowAnimation(function() toggling = false end)
        end
    end)
end

-- ══════════════════════════════════════════
--            CENTER + OPEN
-- ══════════════════════════════════════════

do
    local vp = workspace.CurrentCamera.ViewportSize
    Window.Position = UDim2.new(
        0, math.floor(vp.X / 2 - WINDOW_WIDTH  / 2),
        0, math.floor(vp.Y / 2 - WINDOW_HEIGHT / 2)
    )
end

ActivateTab(1)

task.wait(0.1)
OpenDoorAnimation()

if IS_SUPPORTED then
    repeat task.wait(0.1) until getgenv().SCRIPT_KEY ~= nil
end

if Options.BlockReExecute then
    getgenv().__NULLHUB_KS_OPEN = nil
end
