#SingleInstance, forse
#IfWinActive ahk_class L2UnrealWWindowsViewportWindow

; ========================
; Region: Global variables and some shit from kondr-sugoi
; ========================

global ShoutMessage
global Overlay
global BotStatus

SkillPanelHandler := new SkillPanelHandler()
BotHandler := new BotHandler()
ControlHandler := new ControlHandler()
ShoutHandler := new ShoutHandler()
ActiveChanHandler := new ActiveChanHandler()
OverlayHandler := new OverlayHandler()

;This shit provided by kondr-sugoi
WinTitle := "Lineage II"
PreviousWinState := WinActive(WinTitle)
CheckWinStateIsRunning := 0
SkillHotKey := 3

CheckWindowStatePeriod := 100
UseSkillPeriod := 10*1000
UpdateOverLayPeriod := 1000

; ========================
; Region: Timers
; ========================

SetTimer, CheckWindowState, %CheckWindowStatePeriod%
SetTimer, UpdateOverLay, %UpdateOverLayPeriod%
SetTimer, UseSkill, %UseSkillPeriod%
SetTimer, UseSkill, Off
return

; ========================
; Region: Labels
; ========================

CheckWindowState:
    if (CheckWinStateIsRunning)
        return
    CheckWinStateIsRunning := 1

    if WinExist(WinTitle) {
        CurrentState := WinActive(WinTitle)

        if (CurrentState && !PreviousWinState) {
            PreviousWinState := 1
            Send, {Home}
            Send, //
            Send, {Enter}
            Send, {Ctrl}
        }
        else if (!CurrentState) {
            PreviousWinState := 0
        }
    }

    CheckWinStateIsRunning := 0
return

UseSkill:
    if(BotHandler.IsOn) {
        Send, {%SkillHotKey%}
    }
return

UpdateOverLay:
    if(BotHandler.IsOn) {
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
F1::
    SkillPanelHandler.ShortcutAction(1)
return

#MaxThreadsPerHotkey 1
F2::
    SkillPanelHandler.ShortcutAction(2)
return

#MaxThreadsPerHotkey 1
F3::
    SkillPanelHandler.ShortcutAction(3)
return

#MaxThreadsPerHotkey 1
F4::
    SkillPanelHandler.ShortcutAction(4)
return

#MaxThreadsPerHotkey 1
F5::
    SkillPanelHandler.ShortcutAction(5)
return

#MaxThreadsPerHotkey 1
F6::
    SkillPanelHandler.ShortcutAction(6)
return

#MaxThreadsPerHotkey 1
F7::
    SkillPanelHandler.ShortcutAction(7)
return

#MaxThreadsPerHotkey 1
F8::
    SkillPanelHandler.ShortcutAction(8)
return

F9::
    ShoutHandler.Shout()
return

F10::
    ShoutHandler.GetMessageFromUser()
return

F11::
    ControlHandler.MoveCoursor(ControlHandler.AxisX, ControlHandler.AxisY)
    BotHandler.BotOn()
    OverlayHandler.UpdateOverLay()
return

F12::
    BotHandler.DoSingleAssist()  // Currently redundant functionality
Return

Up::
    ControlHandler.PreviousPosition()
    OverlayHandler.UpdateOverLay()
return

Down::
    ControlHandler.NextPosition()
    OverlayHandler.UpdateOverLay()
return

; ========================
; Region: Classes
; ========================

class BotHandler {
    Name := "AndruhaDVP"
    IsOn := false
    MinTimeout := 200 ; Min timeout per assist
    MaxTimeout := 2000 ; Max timeout per assist
    TimeoutPerClick := 100 ; timeout per click

    BotOn() {
        this.ShowNotification(this.Name, "Bot on")
	this.IsOn := true
        SetTimer, UseSkill, On
        OverlayHandler.ResetBotTime()
        OverlayHandler.SetBeginBotTime()
        
	while (!ControlHandler.IsManual()) {
	    Random, rand, this.MinTimeout, this.MaxTimeout
	    Sleep, rand

	    if (!ControlHandler.IsManual()) {
	        Send, {Click Right}
	        Sleep, this.TimeoutPerClick
	        Send, {Click Right}
	    }
        }

        this.BotOff()
        SetTimer, UseSkill, Off
        this.ShowNotification(this.Name, "Bot off")
	return
    }

    DoSingleAssist() {
        MouseGetPos, xpos, ypos
        ControlHandler.MoveCoursor(ControlHandler.AxisX, ControlHandler.AxisY)
        Send, {Click Right}
        Sleep, this.TimeoutPerClick
        Send, {Click Right}
        ControlHandler.MoveCoursor(xpos, ypos)
    }

    BotOff() {
        this.IsOn := false
        return
    }
    
    ShowNotification(title, text) {
        TrayTip, %title%, %text%, 2, 2
    }
}

class ControlHandler {
    AxisX := 50  ; first member position x
    AxisY := 360  ; first member position y
    SafeZoneX := 40
    SafeZoneY := 15
    MemberDistance := 34
    MaPosition := 1

    NextPosition() {
        this.AxisY := (this.AxisY > 564) ? 598 : this.AxisY += this.MemberDistance
        this.MoveCoursor(this.AxisX, this.AxisY)

        if !(this.MaPosition >= 8) {
            this.MaPosition += 1
        }        
        
        return
    }

    PreviousPosition() {
        this.AxisY := (this.AxisY < 394) ? 360 : this.AxisY -= this.MemberDistance
        this.MoveCoursor(this.AxisX, this.AxisY)

        if !(this.MaPosition <= 1) {
            this.MaPosition -= 1
        }

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

    ShortcutAction(shortcut) {
    	key := "F" . shortcut
        Send, % this.SecondPanel
        while GetKeyState(key, "P") {
            Send, %shortcut%
            Sleep, % this.LoopIterationTimeout
        }
        Send, % this.FistPanel
    }
}

class ShoutHandler {
    ShoutTimeout := 2*60*1000
    GuiBackgroundColor := "242729"
    FontSize := "s12"
    Font := "Arial"

    __New() {
        InputControlWidth := 270
        InputControlHeight := 30
        ButtonWidth := 80
        ButtonHeight := 23
        SubmitButtonX := 50
        SubmitButtonY := 50
        CancelButtonX := 170
        CancelButtonY := 50

        Gui, ShoutGui: New, +AlwaysOnTop -Caption +ToolWindow
        Gui, ShoutGui: Color, % this.GuiBackgroundColor
        Gui, ShoutGui: Font, % this.FontSize, % this.Font
        Gui, ShoutGui: Add, Edit, vShoutMessage w%InputControlWidth% h%InputControlHeight%
        Gui, ShoutGui: Add, Button, w%ButtonWidth% h%ButtonHeight% gSubmit x%SubmitButtonX% y%SubmitButtonY% +Center, Submit
        Gui, ShoutGui: Add, Button, w%ButtonWidth% h%ButtonHeight% gCancel x%CancelButtonX% y%CancelButtonY% +Center, Cancel
    }

    GetMessageFromUser() {
        GuiWidth := 300
        GuiHeight := 100

        Gui, ShoutGui: Show, w%GuiWidth% h%GuiHeight%, Shout Window
    }

    Shout(){
        GuiControlGet, ShoutMessage,, ShoutMessage
        Send, {Enter}
        SendRaw, % ShoutMessage
        Send, {Enter}
    }
}

class OverlayHandler {
    BeginBotTime := 0
    CurrentBotTime := 0

    __New() {     
        FontSize := 15
        WidthMargin := 500
        FontWidth := 1000
        TextWidth := 700
        BotStatusTextHeight := 20
        OverlayTextHeight := 100
        HeightPos := 10
        Font := "Tahoma"
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

    SetBeginBotTime() {
        this.BeginBotTime := A_TickCount
    }

    SetCurrentBotTime() {
        if(BotHandler.IsOn){
            this.CurrentBotTime := A_TickCount
            result := this.CurrentBotTime - this.BeginBotTime
        }
    }

    GetCurrentTime(){
        FormatTime, currentTime, , HH:mm
        return currentTime
    }

    GetTimeInFormat(timeInMs) {
        seconds := Floor(timeInMs // 1000)
        minutes := seconds // 60   
        FormattedMinutes := Format("{:02}", minutes)
        FormattedSeconds := Format("{:02}", seconds)    
        return FormattedMinutes . " : " . FormattedSeconds
    }

    UpdateOverLay() {
        this.UpdateOverlayInfo(BotHandler.IsOn, this.GetTimeInFormat(this.CurrentBotTime - this.BeginBotTime), this.GetCurrentTime(), ControlHandler.MaPosition)
    }

    UpdateOverlayInfo(isBotOn, elapsedTime, currentTime, maPosition){
        botStatus := (isBotOn ? "ON" : "OFF") 
        botStatusText := BotHandler.Name . " " . A_Tab . botStatus
        botStatusColor := (isBotOn ? "Lime" : "Red")

        elapsedTimeText := "Elapsed time: " . A_Tab . elapsedTime
        currentTimeText := "Current time: " . A_Tab . currentTime
        MaText := "MA position: " . A_Tab . maPosition
        overlayText := elapsedTimeText . "`n" . currentTimeText . "`n" . MaText

        Gui, OverlayGui:Font, c%botStatusColor% ; Set the new font color
        GuiControl, OverlayGui:Font, BotStatus ; Apply the new font color to the control
        GuiControl, OverlayGui:, BotStatus, %botStatusText% ; Update bot status text
        GuiControl, OverlayGui:, Overlay, %overlayText% ; Update other overlay text
        return
    }

    ResetBotTime(){
        this.CurrentBotTime := 0
        this.BeginBotTime := 0
    }
}
