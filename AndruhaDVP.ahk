#SingleInstance, forse
#IfWinActive ahk_class L2UnrealWWindowsViewportWindow

; ========================
; Region: Global variables and some shit from kondr-sugoi
; ========================

global ShoutMessage
global MainAssist
global Overlay
global BotStatus

SkillPanelHandler := new SkillPanelHandler()
BotHandler := new BotHandler()
ControlHandler := new ControlHandler()
ChatHandler := new ChatHandler()
OverlayHandler := new OverlayHandler()

;This shit provided by kondr-sugoi
WinTitle := "Lineage II"
PreviousWinState := WinActive(WinTitle)
CheckWinStateIsRunning := 0

CheckWindowStatePeriod := 50
UpdateOverLayPeriod := 1000

; ========================
; Region: Timers
; ========================

SetTimer, CheckWindowState, %CheckWindowStatePeriod%
SetTimer, UpdateOverLay, %UpdateOverLayPeriod%
return

; ========================
; Region: Labels
; ========================

BotAssist:
    BotHandler.Assist()
return

CheckWindowState:
    if (CheckWinStateIsRunning)
        return
    CheckWinStateIsRunning := 1

    if WinExist(WinTitle) {
        CurrentState := WinActive(WinTitle)

        if (CurrentState && !PreviousWinState) {
            Gui, OverlayGui: Show, NoActivate
            PreviousWinState := 1
            Send, {Home}
            Send, //
            Send, {Enter}
            Send, {Ctrl}
        }
        else if (!CurrentState) {
            Gui, OverlayGui: Hide
            PreviousWinState := 0
        }
    }

    CheckWinStateIsRunning := 0
return

UpdateOverLay:
    if (BotHandler.IsOn) {
        OverlayHandler.SetCurrentBotTime()
    }
    OverlayHandler.UpdateOverLay()
return

Submit:
    Gui, Submit, Hide
return

Cancel:
    Gui, Submit, Hide
Return

; ========================
; Region: Hotkeys
; ========================

#MaxThreadsPerHotkey 1
1::
2::
3::
4::
5::
6::
    SkillPanelHandler.FirstPanelShortcut(A_ThisHotkey)
return

#MaxThreadsPerHotkey 1
F1::
F2::
F3::
F4::
F5::
F6::
F7::
    SkillPanelHandler.SecondPanelShortcut(A_ThisHotkey)
return

F8::
    SkillPanelHandler.SecondPanelShortcutSingle(A_ThisHotkey)
return

F9::
    ChatHandler.Shout()
return

F10::
    ChatHandler.GetMessageFromUser()
return

F11::
    BotHandler.Toogle()
return

+F11::
    ChatHandler.GetMainAssistFromUser()
return

F12::
    SkillPanelHandler.ToogleFuryMode()
    OverlayHandler.UpdateOverLay()
Return

~SC029::
    if (ChatHandler.ChatIsInactive()) {
        command := "/targetnext"
        ChatHandler.SendChatCommand(command)
    }
return

+SC029::
    ChatHandler.GetMainAssistFromUser()
return

^SC029::
    ChatHandler.SingleAssist()
return

+F12::
    SkillPanelHandler.ToogleSoulshotMode()
    OverlayHandler.UpdateOverLay()
Return

Up::
    if (ChatHandler.ChatIsInactive()) {
        ControlHandler.PreviousPosition()
        OverlayHandler.UpdateOverLay()
    }
    else {
        Send, {Up}
    }
return

Down::
    if (ChatHandler.ChatIsInactive()) {
        ControlHandler.NextPosition()
        OverlayHandler.UpdateOverLay()
    }
    else {
        Send, {Down}
    }
return

; ========================
; Region: Classes
; ========================

class BotHandler {
    Name := "AndruhaDVP"
    IsOn := false
    MinTimeout := 200 ; Min timeout per assist
    MaxTimeout := 2000 ; Max timeout per assist
    TotalElapsedTime := 0
    BotStartedAt := 0

    Toogle() {
	if (this.IsOn) {
	    this.Stop()
	}
	else {
	    this.Start()
	}
    }

    Start() {
	this.IsOn := true
	this.BotStartedAt := A_TickCount
	OverlayHandler.UpdateOverLay()
	SetTimer, BotAssist, 1
    }

    Assist() {
        ChatHandler.AssistAttack()
	Random, nextAssist, this.MinTimeout, this.MaxTimeout
	SetTimer, BotAssist, %nextAssist%
    }

    Stop() {
	SetTimer, BotAssist, Off
	this.IsOn := false
	this.TotalElapsedTime += A_TickCount - this.BotStartedAt
	OverlayHandler.UpdateOverLay()
    }

    GetTotalTime() {
	return this.TotalElapsedTime + this.GetCurrentSessionTime()
    }

    GetCurrentSessionTime() {
	if (!this.IsOn) {
	    return 0
	}
	sessionTime := A_TickCount - this.BotStartedAt
        return sessionTime
    }
}

class ControlHandler {
    AxisX := 50  ; first member position x
    AxisY := 360  ; first member position y
    SafeZoneX := 40
    SafeZoneY := 15
    MemberDistance := 34

    NextPosition() {
        this.AxisY := (this.AxisY > 564) ? 598 : this.AxisY += this.MemberDistance
        this.MoveCoursor(this.AxisX, this.AxisY)
        return
    }

    PreviousPosition() {
        this.AxisY := (this.AxisY < 394) ? 360 : this.AxisY -= this.MemberDistance
        this.MoveCoursor(this.AxisX, this.AxisY)
        return
    }
    
    MoveCoursor(x, y) {
        MouseMove, x, y, 0
        return
    }
    
    IsManual() {
        MouseGetPos, xpos, ypos
        return (!this.IsSaveZone(this.AxisX, xpos, "x") || !this.IsSaveZone(this.AxisY, ypos, "y"))
    }

    IsSaveZone(currentPos, mousePos, axis) {
        safeZone := axis == "x" ? this.SafeZoneX : this.SafeZoneY       
        return ((currentPos + safeZone) > mousePos && (currentPos - safeZone) < mousePos)
    }
}

class SkillPanelHandler {
    LoopIterationTimeout := 50
    FistPanel := "!1"
    SecondPanel := "!2"
    SoulshotModeEnabled := false
    SoulshotShortcut := 8
    AttackShortcut := 2
    FuryModeEnabled := true
    FuryShortcut := 0
    Panel1FuryShortcuts := Array(1, 2, 3, 4, 5)
    Panel2FuryShortcuts := Array(1, 2, 3, 5, 6, 7, 8)
    
    SecondPanelShortcutSingle(key) {
        Send, % this.SecondPanel
        shortcut := SubStr(key, 2)
        Send, %shortcut%
        Send, % this.FistPanel
    }

    FirstPanelShortcut(key) {
        if (ChatHandler.ChatIsInactive()) {
    	    this.PanelShortcut(key, key, this.Panel1FuryShortcuts)
        }
        else {
            SendInput, %key%
        }
    }

    SecondPanelShortcut(key) {
    	shortcut := SubStr(key, 2)
        Send, % this.SecondPanel
        this.PanelShortcut(shortcut, key, this.Panel2FuryShortcuts)
        Send, % this.FistPanel
    }

    PanelShortcut(shortcut, key, furyShortcuts) {
    	this.UseFury(shortcut, furyShortcuts)
        while GetKeyState(key, "P") {
            this.UseSoulshot(key)
            Send, %shortcut%
            Sleep, % this.LoopIterationTimeout
        }
    	this.UseFury(shortcut, furyShortcuts)
    }

    SecondPanelSingleShortcut(shortcut) {
        Send, % this.SecondPanel
        Send, %shortcut%
        Send, % this.FistPanel
    }

    UseFury(shortcut, furyShortcuts) {
    	if (this.FuryEnabled(shortcut, furyShortcuts)) {
    	    Send, % this.FuryShortcut
	}
    }

    UseSoulshot(shortcut) {
    	if (this.SoulshotEnabled(shortcut)) {
    	    Send, % this.SoulshotShortcut
	}
    }

    FuryEnabled(shortcut, furyShortcuts) {
	if (!this.FuryModeEnabled) {
	    return false
        }
        for index, value in furyShortcuts {
            if (value = shortcut) {
                return true
            }
        }
        return false
    }

    SoulshotEnabled(shortcut) {
	return this.SoulshotModeEnabled && this.AttackShortcut = shortcut
    }

    ToogleFuryMode() {
        this.FuryModeEnabled := !this.FuryModeEnabled
    }

    ToogleSoulshotMode() {
        this.SoulshotModeEnabled := !this.SoulshotModeEnabled
    }
}

class ChatHandler {
    GuiBackgroundColor := "242729"
    FontSize := "s12"
    Font := "Arial"

    __New() {
        InputControlWidth := 270
        InputControlHeight := 30
        ButtonWidth := 80
        ButtonHeight := 23
        SubmitButtonX := 50
        SubmitButtonY := 90
        CancelButtonX := 170
        CancelButtonY := 90

        Gui, ShoutGui: New, +AlwaysOnTop -Caption +ToolWindow
        Gui, ShoutGui: Color, % this.GuiBackgroundColor
        Gui, ShoutGui: Font, % this.FontSize, % this.Font
        Gui, ShoutGui: Add, Text, w%InputControlWidth% h%InputControlHeight% cFFFFFF, Shout Message:
        Gui, ShoutGui: Add, Edit, vShoutMessage w%InputControlWidth% h%InputControlHeight%
        Gui, ShoutGui: Add, Button, w%ButtonWidth% h%ButtonHeight% gSubmit x%SubmitButtonX% y%SubmitButtonY% +Center, Submit
        Gui, ShoutGui: Add, Button, w%ButtonWidth% h%ButtonHeight% gCancel x%CancelButtonX% y%CancelButtonY% +Center, Cancel

        Gui, MaGui: New, +AlwaysOnTop -Caption +ToolWindow
        Gui, MaGui: Color, % this.GuiBackgroundColor
        Gui, MaGui: Font, % this.FontSize, % this.Font
        Gui, MaGui: Add, Text, w%InputControlWidth% h%InputControlHeight% cFFFFFF, Main Assist Nickname:
        Gui, MaGui: Add, Edit, vMainAssist w%InputControlWidth% h%InputControlHeight%
        Gui, MaGui: Add, Button, w%ButtonWidth% h%ButtonHeight% gSubmit x%SubmitButtonX% y%SubmitButtonY% +Center, Submit
        Gui, MaGui: Add, Button, w%ButtonWidth% h%ButtonHeight% gCancel x%CancelButtonX% y%CancelButtonY% +Center, Cancel
    }

    GetMessageFromUser() {
        GuiWidth := 300
        GuiHeight := 130

        Gui, ShoutGui: Show, w%GuiWidth% h%GuiHeight%, Shout Window
    }

    GetMainAssistFromUser() {
        GuiWidth := 300
        GuiHeight := 130

        Gui, MaGui: Show, w%GuiWidth% h%GuiHeight%, Main Assist Window
    }

    Shout() {
        GuiControlGet, ShoutMessage,, ShoutMessage
        Send, {Enter}
        SendInput, % ShoutMessage
        Send, {Enter}
    }

    SingleAssist() {
        targetCommand := "/target " . MainAssist
        ChatHandler.SendChatCommand(targetCommand)
        Sleep, 50
        ChatHandler.SendChatCommand("/assist")
    }

    AssistAttack() {
        targetCommand := "/target " . MainAssist
        ChatHandler.SendChatCommand(targetCommand)
        Sleep, 50
        ChatHandler.SendChatCommand("/assist")
        Sleep, 100
        ChatHandler.SendChatCommand("/attack")
    }

    SendChatCommand(command) {
        Send, {Enter}
        SendInput, %command%
        Send, {Enter}
    }

    ChatIsInactive() {
        PixelGetColor, color, 46, 1426
        return color = 0x1E1D1E
    }
}

class OverlayHandler {

    __New() {     
        FontSize := 17
        WidthMargin := 500
        FontWidth := 1000
        TextWidth := 700
        BotStatusTextHeight := 22
        OverlayTextHeight := 200
        HeightPos := 10
        Font := "Consolas"
        CustomColor := "282829"

        SysGet, ScreenWidth, 0
        SysGet, ScreenHeight, 1
        WidthPos := ScreenWidth - WidthMargin   
        Gui, OverlayGui: New, +AlwaysOnTop +ToolWindow -Caption
        Gui, OverlayGui: Color, CustomColor
        Gui, OverlayGui: Font, s%FontSize% w%FontWidth%, % Font
        Gui, OverlayGui: Add, Text, w%TextWidth% h%BotStatusTextHeight% vBotStatus
        Gui, OverlayGui: Add, Text, w%TextWidth% h%OverlayTextHeight% vOverlay cLime
        Gui, OverlayGui: Show, x%WidthPos% y%HeightPos% NoActivate, OverlayWindow
        WinSet, TransColor, CustomColor, OverlayWindow
        this.UpdateOverLay()
    }

    GetCurrentTime(){
        FormatTime, currentTime, , HH:mm
        return currentTime
    }

    GetTimeInFormat(timeInMs) {
        seconds := Floor(timeInMs // 1000)
        minutes := seconds // 60
        hours := minutes // 60
        remainingSeconds := Mod(seconds, 60)
        remainingMinutes := Mod(minutes, 60)
    
        FormattedSeconds := Format("{:02}", remainingSeconds)
        FormattedMinutes := Format("{:02}", remainingMinutes)
        FormattedHours := Format("{:02}", hours)
    
        return FormattedHours . ":" . FormattedMinutes . ":" . FormattedSeconds
    }

    UpdateOverLay() {
        this.UpdateOverlayInfo(BotHandler.IsOn, SkillPanelHandler.FuryModeEnabled, SkillPanelHandler.SoulshotModeEnabled, this.GetTimeInFormat(BotHandler.GetTotalTime()), this.GetCurrentTime())
    }

    UpdateOverlayInfo(isBotOn, furyMode, soulshotMode, elapsedTime, currentTime) {
        botStatus := (isBotOn ? "ON" : "OFF") 
        botStatusText := BotHandler.Name . " " . A_Tab . botStatus
        botStatusColor := (isBotOn ? "Lime" : "Red")

	elapsedTimeText := "Elapsed time: " . A_Tab . elapsedTime
        currentTimeText := "Current time: " . A_Tab . currentTime
        separatingLine := "---------------------"

        furyModeText := "Fury Mode:" . A_Tab . (furyMode ? "ON" : "OFF")
        soulshotModeText := "Soulshot Mode:" . A_Tab . (soulshotMode ? "ON" : "OFF")

        overlayText := elapsedTimeText  . "`n" . furyModeText . "`n" . soulshotModeText . "`n" .  separatingLine . "`n" . currentTimeText

        Gui, OverlayGui:Font, c%botStatusColor% ; Set the new font color
        GuiControl, OverlayGui:Font, BotStatus ; Apply the new font color to the control
        GuiControl, OverlayGui:, BotStatus, %botStatusText% ; Update bot status text
        GuiControl, OverlayGui:, Overlay, %overlayText% ; Update other overlay text
        return
    }
}
