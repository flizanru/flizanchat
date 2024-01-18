flizan = flizan or {}
flizan.theme = flizan.theme or {}

flizan.theme.loadDefault = function()
    flizan.theme.rem = 16
    flizan.theme.round = 10 -- более скругленные углы
    flizan.theme.bg = Color(18, 21, 23, 255) -- более темный фон
    flizan.theme.bgAlternative = Color(24, 28, 31, 120) -- альтернативный фон
    flizan.theme.txt = Color(235, 235, 235) -- светлый текст
    flizan.theme.txtAlternative = Color(235, 235, 235, 100) -- менее яркий текст
    flizan.theme.red = Color(220, 50, 47) -- насыщенный красный
    flizan.theme.green = Color(95, 174, 87) -- зеленый
    flizan.theme.blue = Color(60, 145, 230) -- яркий синий
    flizan.theme.yellow = Color(203, 144, 34) -- яркий желтый
end

flizan.theme.loadDefault()
local fileName = "flizan/theme.txt"
if file.Exists(fileName, "DATA") then
    table.Merge(flizan.theme, util.JSONToTable(file.Read(fileName, "DATA")))
end

function flizan.theme:Transparency(colour, opacity)
    return Color(colour.r, colour.g, colour.b, opacity * 255)
end

--TDLib()

if CLIENT then
    surface.CreateFont("ChatFontPassive", {
        font = "Open Sans",
        size = 1.2 * flizan.theme.rem,
        weight = 1000,
        extended = true,
        antialias = true,
    })

    surface.CreateFont("ChatFont", {
        font = "Montserrat SemiBold",
        size = 1.4 * flizan.theme.rem,
        weight = 700,
        extended = true,
        antialias = true,
    })

    surface.CreateFont("ChatFontEntry", {
        font = "Montserrat SemiBold",
        size = flizan.theme.rem,
        weight = 700,
        extended = true,
        antialias = true,
    })
end

local messageHistory = {}
local currentHistoryIndex = 0

local function addMessageToHistory(message)
    table.insert(messageHistory, message)
    if #messageHistory > 10 then
        table.remove(messageHistory, 1) 
    end
    currentHistoryIndex = #messageHistory + 1 
end


local function getPreviousMessage()
    if currentHistoryIndex > 1 then
        currentHistoryIndex = currentHistoryIndex - 1
    end
    return messageHistory[currentHistoryIndex] or ""
end

local function getNextMessage()
    if currentHistoryIndex < #messageHistory then
        currentHistoryIndex = currentHistoryIndex + 1
    end
    return messageHistory[currentHistoryIndex] or ""
end

local function createFrame(classname, parent, x, y, w, h)
    frame = vgui.Create(classname, parent)
    frame:SetPos(x, y)
    frame:SetSize(w, h)

    if classname == "DFrame" then
        frame:SetTitle("")
        frame:ShowCloseButton(false)
        frame:SetDraggable(false)
    else
        frame:SetAllowNonAsciiCharacters(true)
    end

    return frame
end

local function rem(multiply)
    if multiply == nil then
        multiply = 1
    end

    return multiply * flizan.theme.rem
end

local function init()
    local sustain = 10
    local length = 2.5

    hook.Add("HUDPaint", "chatPaint", function()
        local w = rem(50)
        local h = rem(18)
        local x = rem(-2)
        local y = ScrH() - rem(40)

        if flizan.BottomLeftHeight then
            y = ScrH() - h - flizan.BottomLeftHeight - rem()
        end

        customChat.window:SetPos(x + 45, y)
        customChat.window:SetSize(w, h)
        customChat.window2:SetPos(x - 15, y)
        customChat.window2:SetSize(customChat.window:GetWide() - rem() + 170, h + 50)
        customChat.passive:SetSize(customChat.window:GetWide() - rem(), h - rem(3.5))
        customChat.passive:SetPos(rem(.5), rem(.5))
        customChat.container:StretchToParent(0, 0, 0, 0)
        customChat.container2:StretchToParent(0, 0, 0, 0)
        customChat.active:SetSize(customChat.window:GetWide() - rem(), h - rem(3.5))
        customChat.active:SetPos(rem(.5), rem(.5))
        customChat.textbox:SetPos(rem(.5), h - rem(2))
        customChat.textbox:SetSize(w - rem(), rem(1.5))
    end)

    if customChat then
        customChat.window:Remove()
    end

    customChat = {}
    customChat.window = createFrame("DFrame")
    customChat.window.Paint = nil
    customChat.window2 = createFrame("DFrame")
    customChat.window2.Paint = nil
    customChat.passive = createFrame("RichText", customChat.window)
    customChat.passive:SetVerticalScrollbarEnabled(false)

    customChat.passive.Paint = function(self, w, h)
        self:DrawTextEntryText(flizan.theme.txt, flizan.theme.txtAlternative, flizan.theme.txt)
        self:SetFontInternal("ChatFontPassive")
        self:SetVerticalScrollbarEnabled(false)
    end

    customChat.container = createFrame("DPanel", customChat.window)
    customChat.container:SetAlpha(0)

    customChat.container.Paint = function(self, w, h)
        draw.RoundedBox(flizan.theme.round, 0, 0, w, h, flizan.theme.bg)
        draw.RoundedBox(flizan.theme.round, 0, h - rem(2.5), w, rem(2.5), flizan.theme.bgAlternative)
    end

    customChat.textbox = createFrame("DTextEntry", customChat.container)

customChat.textbox.Paint = function(self, w, h)
    surface.SetMaterial(Material("cp2077/chat/textentry.png"))
    surface.SetDrawColor(Color(255, 255, 255, 215))
    surface.DrawTexturedRect(0, 0, w, h)
    
    local borderColor = Color(18, 21, 23, 255) 
    draw.RoundedBox(8, 0, 0, w, h, borderColor) 
    
    self:DrawTextEntryText(flizan.theme.txt, flizan.theme.txtAlternative, flizan.theme.txt)
    self:SetFontInternal("ChatFontEntry")
    self:SetDrawLanguageID(false)

    if self:GetValue() == "" then
        draw.SimpleText("Введите текст. . .", "ChatFontEntry", 3, rem(.75), flizan.theme.txtAlternative, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    else
        sentence = nil
    end
end


    customChat.container2 = createFrame("DPanel", customChat.window2)
    customChat.container2:SetAlpha(0)
    customChat.container2.Paint = function(self, w, h) end
    customChat.active = createFrame("RichText", customChat.container)

    customChat.active.Paint = function(self, w, h)
        self:DrawTextEntryText(flizan.theme.txt, flizan.theme.txtAlternative, flizan.theme.txt)
        self:SetFontInternal("ChatFontPassive")
    end

    customChat.sendButton = createFrame("DButton", customChat.container2)
 --   customChat.sendButton:SetText("")
 --   customChat.sendButton:SetSize(41, 34)
 --   customChat.sendButton:SetPos(customChat.textbox:GetWide() + 620, 250)

    customChat.sendButton.Paint = function(self, w, h)
       -- surface.SetMaterial(Material("cp2077/chat/textsend.png"))
     --   surface.SetDrawColor(255, 255, 255)
     --   surface.DrawTexturedRect(0, 0, w, h)
    end

    local activeButtons = {
        ["DOButton"] = false,
        ["ICButton"] = false,
        ["OOCButton"] = false,
        ["LOOCButton"] = false,
    }

    local function setActiveButton(buttonName)
        for name, active in pairs(activeButtons) do
            activeButtons[name] = (name == buttonName) and true or false
            local button = customChat[name]
            local x, y = button:GetPos()
            button:SetPos(x, y)
        end
    end

    customChat.sendButton.DoClick = function()
        local message = string.Trim(customChat.textbox:GetText())

        if message ~= "" then
            if activeButtons["DOButton"] then
                LocalPlayer():ConCommand([[say "/do ]] .. message .. [["]])
            elseif activeButtons["ICButton"] then
                LocalPlayer():ConCommand([[say "]] .. message .. [["]])
            elseif activeButtons["OOCButton"] then
                LocalPlayer():ConCommand([[say "/ooc ]] .. message .. [["]])
            elseif activeButtons["LOOCButton"] then
                LocalPlayer():ConCommand([[say "/looc ]] .. message .. [["]])
            else
                LocalPlayer():ConCommand([[say "]] .. message .. [["]])
            end
        end

        customChat.openChatbox(false)
    end

    hook.Add("PlayerBindPress", "overrideChatbind", function(ply, bind, pressed)
        if bind == "messagemode" then
            local bTeam = false
        elseif bind == "messagemode2" then
            bTeam = true
        else
            return
        end

        customChat.openChatbox(true)

        return true
    end)

    hook.Add("ChatText", "serverNotifications", function(index, name, text, type)
        if type == "joinleave" or type == "none" then
            appendToChat("\n" .. text)
        end
    end)

    hook.Add("HUDShouldDraw", "noMoreDefault", function(name)
        if name == "CHudChat" then return false end
    end)

    function appendToChat(obj)
        if type(obj) == "table" then
            customChat.active:InsertColorChange(obj.r, obj.g, obj.b, 255)
            customChat.passive:InsertColorChange(obj.r, obj.g, obj.b, 255)
        elseif type(obj) == "string" then
            customChat.active:AppendText(obj)
            customChat.passive:AppendText(obj)
            customChat.passive:InsertFade(sustain, length)
        end
    end

    if not preventDoubleUpdateSpam then
        preventDoubleUpdateSpam = true
        oldAddText = chat.AddText
    end

    function chat.AddText(...)
        local args = {...}

        appendToChat("\n")
        local col = Color(28, 33, 34)

        for _, obj in pairs(args) do
            if type(obj) == "table" or type(obj) == "string" then
                appendToChat(obj, col)
            elseif obj:IsPlayer() then
                appendToChat(col)
                appendToChat(obj:Nick(), col)
            end
        end

        oldAddText(...)
    end

customChat.textbox.OnKeyCodeTyped = function(self, code)
    if code == KEY_ESCAPE then
        customChat.openChatbox(false)
        gui.HideGameUI()
    elseif code == KEY_ENTER then
        local message = string.Trim(customChat.textbox:GetText())

        if message ~= "" then
            if activeButtons["DOButton"] then
                LocalPlayer():ConCommand([[say "/do ]] .. message .. [["]])
            elseif activeButtons["ICButton"] then
                LocalPlayer():ConCommand([[say "]] .. message .. [["]])
            elseif activeButtons["OOCButton"] then
                LocalPlayer():ConCommand([[say "/ooc ]] .. message .. [["]])
            elseif activeButtons["LOOCButton"] then
                LocalPlayer():ConCommand([[say "/looc ]] .. message .. [["]])
            else
                LocalPlayer():ConCommand([[say "]] .. message .. [["]])
            end
            addMessageToHistory(message) -- Добавление сообщения в историю
        end

        customChat.openChatbox(false)
    elseif code == KEY_UP then
        self:SetText(getPreviousMessage())
        self:SetCaretPos(string.len(self:GetText()))
    elseif code == KEY_DOWN then
        self:SetText(getNextMessage())
        self:SetCaretPos(string.len(self:GetText()))
    end
end


    customChat.textbox.OnTextChanged = function(self)
        if self and self.GetText then
            gamemode.Call("ChatTextChanged", self:GetText() or "")
        end
    end

    function customChat.openChatbox(shouldOpen)
        customChat.window:SetMouseInputEnabled(shouldOpen)
        customChat.window:SetKeyboardInputEnabled(shouldOpen)
        gui.EnableScreenClicker(shouldOpen)
        customChat.active:SetVerticalScrollbarEnabled(shouldOpen)

        if shouldOpen then
            customChat.window:MakePopup()
            customChat.textbox:RequestFocus()
            gamemode.Call("StartChat")
            customChat.container:AlphaTo(255, .2)
            customChat.textbox:SetAlpha(255)
            customChat.container2:AlphaTo(255, .2)
        else
            gamemode.Call("FinishChat")
            gamemode.Call("ChatTextChanged", "")
            customChat.textbox:SetText("")
            customChat.active:GotoTextEnd()
            customChat.container:AlphaTo(0, .2)
            customChat.textbox:SetAlpha(0)
            customChat.container2:AlphaTo(0, .2)
            sentence = nil
        end
    end
end

hook.Add("Initialize", "chatInit", init)

if GAMEMODE then
    init()
end

function ChatTags(ply, Text, Team, PlayerIsDead)
    if Team and not ply:IsAdmin() then
        local nickteamcolor = Color(58, 163, 164)
        local nickteam = team.GetName(ply:Team())

        if ply:Alive() then
            chat.AddText(nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), Text)
        else
            chat.AddText(nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), Text)
        end

        return true
    elseif Team and ply:IsAdmin() then
        local nickteamcolor = Color(255, 53, 53)
        local nickteam = team.GetName(ply:Team())

        if ply:Alive() then
            chat.AddText(nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), Text)
        else
            chat.AddText(nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), Text)
        end

        return true
    end

    if ply:IsPlayer() and ply:IsAdmin() then
        if ply:Alive() then
            local nickteamcolor = Color(255, 53, 53)
            local nickteam = team.GetName(ply:Team())
            chat.AddText(nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), Text)

            return true
        elseif not ply:Alive() then
            local nickteamcolor = Color(255, 53, 53)
            local nickteam = team.GetName(ply:Team())
            chat.AddText(nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), Text)

            return true
        end
    elseif ply:IsPlayer() and not ply:IsAdmin() then
        if ply:Alive() then
            local nickteamcolor = Color(58, 163, 164)
            local nickteam = team.GetName(ply:Team())
            chat.AddText(nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), Text)

            return true
        elseif not ply:Alive() then
            local nickteamcolor = Color(58, 163, 164)
            local nickteam = team.GetName(ply:Team())
            chat.AddText(nickteamcolor, ply:Nick(), color_white, ": ", Color(255, 255, 255, 255), Text)

            return true
        end
    end
end

hook.Add("OnPlayerChat", "Tags", ChatTags)