if not game:IsLoaded() then game.Loaded:Wait() end

-- ══════════════════════════════════════════
--           NULLHUB LOADER
--   Detecta jogo → Keysystem ou Suggest
-- ══════════════════════════════════════════

-- ══════════════════════════════════════════
--              CONFIG
-- ══════════════════════════════════════════

local SUPPORTED_GAMES = {
    [92783581681786] = "https://raw.githubusercontent.com/Dead0G0D/Main.lua/refs/heads/main/Anime%20Cicker%20(Hunters%202.0).lua",
    [78754030900809] = "https://raw.githubusercontent.com/Dead0G0D/Main.lua/refs/heads/main/Scripts/Anime%20Leveling.lua",
}

-- URL do Keysystem separado (hospede no seu GitHub)
local KEYSYSTEM_URL = "https://raw.githubusercontent.com/Dead0G0D/Main.lua/refs/heads/main/KeySystem.lua"

local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1484255458477740224/UNHgxyTGlFyw84VkH0OYJcniTuL-tFwK6UoKNXOVSz32uo_QLJprWQmZqcKhagCFMIAH"
local DISCORD_INVITE  = "https://discord.gg/yjdxgGTDyy"
local SUGGESTED_FILE  = "NullHub_Suggested.json"

-- ══════════════════════════════════════════
--              DETECÇÃO DE JOGO
-- ══════════════════════════════════════════

local currentGameId = game.PlaceId
local scriptUrl     = SUPPORTED_GAMES[currentGameId]
local IS_SUPPORTED  = scriptUrl ~= nil

-- Jogo suportado: passa o script URL para o Keysystem e encerra este loader
if IS_SUPPORTED then
    -- Injeta as informações que o Keysystem precisa no ambiente global
    getgenv().__NH_SCRIPT_URL  = scriptUrl
    getgenv().__NH_GAME_ID     = currentGameId

    local ok, err = pcall(function()
        loadstring(game:HttpGet(KEYSYSTEM_URL))()
    end)
    if not ok then
        warn("[NullHub Loader] Falha ao carregar o Keysystem:", err)
    end
    return  -- encerra o loader aqui
end

-- ══════════════════════════════════════════
-- Jogo NÃO suportado: exibe janela de Suggest
-- ══════════════════════════════════════════

-- ══════════════════════════════════════════
--              BLOCK RE-EXECUTE
-- ══════════════════════════════════════════

if getgenv().__NULLHUB_LOADER_OPEN then return end
getgenv().__NULLHUB_LOADER_OPEN = true

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
--                 PALETA
-- ══════════════════════════════════════════

local Palette = {
    BG0     = Color3.fromRGB(6,   6,   6),
    BG1     = Color3.fromRGB(11,  11,  11),
    BG2     = Color3.fromRGB(18,  18,  18),
    BG3     = Color3.fromRGB(24,  24,  24),
    BG4     = Color3.fromRGB(30,  30,  30),
    Line    = Color3.fromRGB(36,  36,  36),
    Border  = Color3.fromRGB(50,  50,  50),
    TextHi  = Color3.fromRGB(235, 235, 235),
    TextMid = Color3.fromRGB(150, 150, 150),
    TextLo  = Color3.fromRGB(80,  80,  80),
    Success = Color3.fromRGB(90,  200, 160),
    Error   = Color3.fromRGB(220, 80,  90),
    Warning = Color3.fromRGB(255, 170, 70),
    Discord = Color3.fromRGB(88,  101, 242),
}

-- ══════════════════════════════════════════
--                  ICONS
-- ══════════════════════════════════════════

local Icons = {
    Logo    = "rbxassetid://90421697308928",
    Close   = "rbxassetid://10747384394",
    Submit  = "rbxassetid://10709790644",
    Discord = "rbxassetid://101192191207677",
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

local function SafeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    return ok and result or nil
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

local WINDOW_WIDTH  = 360
local WINDOW_HEIGHT = 340
local HEADER_HEIGHT = 46
local INNER_PAD     = 12

if getgenv().__NULLHUB_GUI then
    pcall(function() getgenv().__NULLHUB_GUI:Destroy() end)
    getgenv().__NULLHUB_GUI = nil
end

local ScreenGui = New("ScreenGui", {
    Name           = "NullHubLoader",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent         = CoreGui,
})

getgenv().__NULLHUB_GUI = ScreenGui

local BlurEffect = New("BlurEffect", {
    Name = "NullHubBlur", Size = 0, Parent = Lighting,
})

local BackgroundOverlay = New("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0, ZIndex = 1, Parent = ScreenGui,
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
    Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Palette.BG0, BorderSizePixel = 0, ZIndex = 10, Parent = Window,
})
local RightDoor = New("Frame", {
    Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0),
    BackgroundColor3 = Palette.BG0, BorderSizePixel = 0, ZIndex = 10, Parent = Window,
})
local DoorLogo = New("ImageLabel", {
    Size = UDim2.new(0, 356, 0, 142), Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
    Image = "rbxassetid://90431150498873", ScaleType = Enum.ScaleType.Fit,
    ImageTransparency = 0, ZIndex = 11, Parent = Window,
})

local DoorState = {
    OPEN_LEFT   = UDim2.new(-0.5, 0, 0, 0), OPEN_RIGHT  = UDim2.new(1, 0, 0, 0),
    CLOSE_LEFT  = UDim2.new(0,    0, 0, 0), CLOSE_RIGHT = UDim2.new(0.5, 0, 0, 0),
}

local function AnimateDoors(direction, callback)
    local isOpen = direction == "open"
    if isOpen then
        Window.Visible = true
        Tween(BackgroundOverlay, { BackgroundTransparency = 0.62 }, 0.7)
        Tween(BlurEffect, { Size = 18 }, 0.7)
        Tween(DoorLogo, { ImageTransparency = 1 }, 0.6)
        task.delay(0.55, function()
            Tween(LeftDoor,  { Position = DoorState.OPEN_LEFT  }, 0.88, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            Tween(RightDoor, { Position = DoorState.OPEN_RIGHT }, 0.88, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            task.delay(0.92, function()
                LeftDoor.Visible = false; RightDoor.Visible = false; DoorLogo.Visible = false
                if callback then callback() end
            end)
        end)
    else
        LeftDoor.Visible = true; RightDoor.Visible = true; DoorLogo.Visible = true
        LeftDoor.Position = DoorState.OPEN_LEFT; RightDoor.Position = DoorState.OPEN_RIGHT
        DoorLogo.ImageTransparency = 1
        Tween(LeftDoor,  { Position = DoorState.CLOSE_LEFT  }, 0.48, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        Tween(RightDoor, { Position = DoorState.CLOSE_RIGHT }, 0.48, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        task.delay(0.38, function() Tween(DoorLogo, { ImageTransparency = 0 }, 0.28) end)
        task.delay(0.10, function() Tween(BackgroundOverlay, { BackgroundTransparency = 1 }, 0.38) end)
        task.delay(0.10, function() Tween(BlurEffect, { Size = 0 }, 0.38) end)
        task.delay(0.82, function() if callback then callback() end end)
    end
end

local function OpenLoader()  AnimateDoors("open") end
local function CloseLoader(cb)
    AnimateDoors("close", function()
        ScreenGui:Destroy()
        if cb then cb() end
    end)
end

-- ══════════════════════════════════════════
--                  HEADER
-- ══════════════════════════════════════════

local Header = New("Frame", {
    Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
    BackgroundColor3 = Palette.BG1, BorderSizePixel = 0, ZIndex = 3, Parent = Window,
})
Round(Header, 6)
New("Frame", {
    Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = Palette.BG1, BorderSizePixel = 0, ZIndex = 3, Parent = Header,
})
New("Frame", {
    Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = Palette.Line, BorderSizePixel = 0, ZIndex = 4, Parent = Header,
})
New("ImageLabel", {
    Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(0, 8, 0.4, -13),
    BackgroundTransparency = 1, Image = Icons.Logo,
    ImageColor3 = Palette.TextHi, ZIndex = 4, Parent = Header,
})
New("TextLabel", {
    Size = UDim2.new(0, 120, 0, 18), Position = UDim2.new(0, 47, 0.5, -9),
    BackgroundTransparency = 1, Text = "NULL HUB",
    TextColor3 = Palette.TextHi, Font = Enum.Font.GothamBlack,
    TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = Header,
})

-- Botão fechar
local CloseBtn = New("TextButton", {
    Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -36, 0.5, -13),
    BackgroundColor3 = Palette.BG3, Text = "",
    AutoButtonColor = false, ZIndex = 5, Parent = Header,
})
Round(CloseBtn, 5)
New("ImageLabel", {
    Size = UDim2.new(0, 11, 0, 11), Position = UDim2.new(0.5, -5, 0.5, -6),
    BackgroundTransparency = 1, Image = Icons.Close,
    ImageColor3 = Palette.TextMid, ZIndex = 6, Parent = CloseBtn,
})
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, { BackgroundColor3 = Palette.Error }, 0.12) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, { BackgroundColor3 = Palette.BG3 }, 0.12) end)
CloseBtn.MouseButton1Click:Connect(function() CloseLoader() end)

-- ══════════════════════════════════════════
--                 DRAGGABLE
-- ══════════════════════════════════════════

do
    local dragging, dragStart, startPos = false, nil, nil
    local function IsClick(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end
    Header.InputBegan:Connect(function(input)
        if not IsClick(input) or dragging then return end
        dragging = true; dragStart = input.Position; startPos = Window.Position
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = input.Position - dragStart
        Window.Position = UDim2.new(0, startPos.X.Offset + d.X, 0, startPos.Y.Offset + d.Y)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if not dragging or not IsClick(input) then return end
        dragging = false
        local vp = workspace.CurrentCamera.ViewportSize
        local pos = Window.Position
        Tween(Window, { Position = UDim2.new(
            0, math.clamp(pos.X.Offset, 0, vp.X - WINDOW_WIDTH),
            0, math.clamp(pos.Y.Offset, 0, vp.Y - WINDOW_HEIGHT)
        )}, 0.2)
    end)
end

-- ══════════════════════════════════════════
--              CONTENT — SUGGEST
-- ══════════════════════════════════════════

local ContentY = HEADER_HEIGHT
local Content  = New("ScrollingFrame", {
    Size                 = UDim2.new(1, 0, 1, -ContentY),
    Position             = UDim2.new(0, 0, 0, ContentY),
    BackgroundTransparency = 1,
    BorderSizePixel      = 0,
    ScrollBarThickness   = 3,
    ScrollBarImageColor3 = Palette.Border,
    CanvasSize           = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize  = Enum.AutomaticSize.Y,
    ZIndex               = 3,
    Parent               = Window,
})
New("UIPadding", {
    PaddingTop = UDim.new(0, INNER_PAD), PaddingBottom = UDim.new(0, INNER_PAD),
    PaddingLeft = UDim.new(0, INNER_PAD), PaddingRight = UDim.new(0, INNER_PAD + 2),
    Parent = Content,
})
New("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = Content,
})

-- Card info do jogo
local GameInfoCard = MakeCard(Content, 60, 1)
local GameThumb = New("ImageLabel", {
    Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 10, 0.5, -20),
    BackgroundColor3 = Palette.BG3, BorderSizePixel = 0, ZIndex = 6, Parent = GameInfoCard,
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

local UnsupBadge = New("Frame", {
    Size = UDim2.new(0, 0, 0, 16), Position = UDim2.new(1, -8, 0, 8),
    AnchorPoint = Vector2.new(1, 0), AutomaticSize = Enum.AutomaticSize.X,
    BackgroundColor3 = Palette.BG4, BorderSizePixel = 0, ZIndex = 6, Parent = GameInfoCard,
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

-- Info card
local InfoCard = MakeCard(Content, 50, 2)
InfoCard.BackgroundColor3 = Palette.BG1
Stroke(InfoCard, Palette.Line, 1, 0)
MakeLabel(InfoCard, "⚠ This game isn't supported yet.", Enum.Font.GothamBold, 11, Palette.TextHi, Enum.TextXAlignment.Left, {
    Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 10, 0, 10),
})
MakeLabel(InfoCard, "Click below to suggest it to our team!", Enum.Font.Gotham, 10, Palette.TextMid, Enum.TextXAlignment.Left, {
    Size = UDim2.new(1, -20, 0, 14), Position = UDim2.new(0, 10, 0, 28),
})

-- Status card
local StatusCard = MakeCard(Content, 34, 3)
StatusCard.BackgroundColor3 = Palette.BG1
Stroke(StatusCard, Palette.Line, 1, 0)
local StatusDot = New("Frame", {
    Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 11, 0.5, -3),
    BackgroundColor3 = Palette.TextLo, BorderSizePixel = 0, ZIndex = 6, Parent = StatusCard,
})
Round(StatusDot, 99)
local StatusLabel = MakeLabel(StatusCard, "Click below to suggest this game", Enum.Font.Gotham, 10, Palette.TextLo, Enum.TextXAlignment.Left, {
    Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 22, 0, 0),
})

-- Divider
New("Frame", {
    Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Palette.Line,
    BorderSizePixel = 0, LayoutOrder = 4, ZIndex = 5, Parent = Content,
})

-- Submit button
local SubmitButton = New("TextButton", {
    Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Palette.BG3,
    Text = "", AutoButtonColor = false, LayoutOrder = 5, ZIndex = 5, Parent = Content,
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
local DiscordCard = MakeCard(Content, 38, 6)
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

-- ══════════════════════════════════════════
--           SUBMIT LOGIC
-- ══════════════════════════════════════════

local submitBgColor = Palette.BG3
local submitted = false

local function SetStatus(message, statusType)
    local colors = {
        success = Palette.Success, error = Palette.Error,
        warning = Palette.Warning, idle  = Palette.TextLo,
    }
    local color = colors[statusType] or Palette.TextLo
    Tween(StatusDot,   { BackgroundColor3 = color }, 0.12)
    Tween(StatusLabel, { TextColor3       = color }, 0.12)
    StatusLabel.Text = message
end

local function SetSubmitState(state)
    if state == "idle" then
        submitted = false; SubmitButton.Active = true
        SubmitLabel.Text = "Suggest This Game  ·  Submit"
        Tween(SubmitLabel, { TextColor3 = Palette.TextMid }, 0.2)
        Tween(SubmitIcon,  { ImageColor3 = Palette.TextMid }, 0.2)
        submitBgColor = Palette.BG3
        Tween(SubmitButton, { BackgroundColor3 = Palette.BG3 }, 0.2)
    elseif state == "loading" then
        SubmitButton.Active = false; SubmitLabel.Text = "Submitting..."
        Tween(SubmitLabel, { TextColor3 = Palette.Warning }, 0.15)
        Tween(SubmitIcon,  { ImageColor3 = Palette.Warning }, 0.15)
    elseif state == "success" then
        submitted = true; SubmitLabel.Text = "Submitted Successfully!"
        Tween(SubmitLabel, { TextColor3 = Palette.Success }, 0.2)
        Tween(SubmitIcon,  { ImageColor3 = Palette.Success }, 0.2)
        submitBgColor = Palette.BG1
        Tween(SubmitButton, { BackgroundColor3 = Palette.BG1 }, 0.2)
    elseif state == "error" then
        submitted = false; SubmitButton.Active = true
        SubmitLabel.Text = "Suggest This Game  ·  Submit"
        Tween(SubmitLabel, { TextColor3 = Palette.TextLo }, 0.2)
        Tween(SubmitIcon,  { ImageColor3 = Palette.TextLo }, 0.2)
        submitBgColor = Palette.BG3
        Tween(SubmitButton, { BackgroundColor3 = Palette.BG3 }, 0.2)
    elseif state == "disabled" then
        submitted = true; SubmitButton.Active = false
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
    SetStatus("You already suggested this game", "warning")
end

SubmitButton.MouseButton1Click:Connect(function()
    if submitted then return end
    submitted = true
    SetSubmitState("loading")
    SetStatus("Sending suggestion to Discord...", "warning")
    pcall(setclipboard, DISCORD_INVITE)

    local payload = HttpService:JSONEncode({
        username = "Null Hub System",
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
    local ok, err = pcall(function()
        if not httpRequest then error("executor sem suporte a request()") end
        httpRequest({ Url = DISCORD_WEBHOOK, Method = "POST",
            Headers = { ["Content-Type"] = "application/json" }, Body = payload })
    end)

    if ok then
        MarkSuggested(currentGameId)
        SetSubmitState("success")
        SetStatus("Submitted! Discord link copied  ✓", "success")
    else
        warn("[NullHub] Webhook error:", err)
        SetSubmitState("error")
        SetStatus("⚠ Failed to send  ·  try again", "error")
    end
end)

-- ══════════════════════════════════════════
--             CLEANUP + OPEN
-- ══════════════════════════════════════════

ScreenGui.Destroying:Connect(function()
    pcall(function() BlurEffect:Destroy() end)
    getgenv().__NULLHUB_LOADER_OPEN = nil
    getgenv().__NULLHUB_GUI = nil
end)

do
    local vp = workspace.CurrentCamera.ViewportSize
    Window.Position = UDim2.new(
        0, math.floor(vp.X / 2 - WINDOW_WIDTH  / 2),
        0, math.floor(vp.Y / 2 - WINDOW_HEIGHT / 2)
    )
end

task.wait(0.1)
OpenLoader()
