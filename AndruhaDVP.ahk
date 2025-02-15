#SingleInstance, forse
#IfWinActive ahk_class L2UnrealWWindowsViewportWindow

global ShoutMessage := " "

SkillPanelHandler := new SkillPanelHandler()
BotHandler := new BotHandler()
ControlHandler := new ControlHandler()
ShoutHandler := new ShoutHandler()

F1::
    SkillPanelHandler.ShortcutAction(1)
return

F2::
    SkillPanelHandler.ShortcutAction(2)
return

F3::
    SkillPanelHandler.ShortcutAction(3)
return

#MaxThreadsPerHotkey 1
F4::
    SkillPanelHandler.PickUpAction()
return

F5::
    SkillPanelHandler.ShortcutAction(5)
return

F9::
    BotHandler.DoSingleAssist()
Return

F11::
	ControlHandler.MoveCoursor(ControlHandler.AxisX, ControlHandler.AxisY)
	BotHander.BotOn()
return

F12::
    BotHander.BotOff()
return

Up::
    ControlHandler.PreviousPosition()
return

Down::
    ControlHandler.NextPosition()
return

Numpad0::
    ShoutHandler.IsShoutEnabled := false
return

Numpad1::
    ShoutHandler.IsShoutEnabled := true
    ShoutHandler.InvokeShout()
return

Numpad2::
    ShoutHandler.Shout()
return

Numpad5::
    ShoutHandler.GetMessageFromUser()
return

M::
    SkillPanelHandler.ShortcutAction(0)
return

class BotHandler {
    Name := "AndruhaDVP"
    IsOn := true
    MinTimeout := 200 ; Min timeout per assist
    MaxTimeout := 2000 ; Max timeout per assist
    TimeoutPerClick := 100 ; timeout per click

    BotOn() {
        this.ShowNotification(this.Name, "Bot on")
	    this.IsOn := true

	    While (this.IsOn && !ControlHandler.IsManual()) {
            Random, rand, this.MinTimeout, this.MaxTimeout
		    Sleep, rand
		    Send, {Click Right}
		    Sleep, this.TimeoutPerClick
    	    Send, {Click Right}
        }

        this.ShowNotification(this.Name, "Bot off")
	    return
    }

    DoSingleAssist(){
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
        return ((currentPos + saveZone) > mousePos && (currentPos - saveZone) < mousePos)
    }
}

class SkillPanelHandler {
    LoopIterationTimeout := 50
    PickUpHotkey := "4"
    FistPanel := "!1"
    SecondPanel := "!2"

    PickUpAction() {
        Send, % this.SecondPanel
        while GetKeyState("F4", "P") {
            Send, % this.PickUpHotkey
            Sleep, % this.LoopIterationTimeout
        }
        Send, % this.FistPanel
    }

    ShortcutAction(shortcut) {
        Send, % this.SecondPanel
        Send, %shortcut%
        Send, % this.FistPanel
    }
}

class ShoutHandler {
    IsShoutEnabled := false
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

        Gui, +AlwaysOnTop -Caption +ToolWindow
        Gui, Color, % this.GuiBackgroundColor
        Gui, Font, % this.FontSize, % this.Font
        Gui, Add, Edit, vShoutMessage w%InputControlWidth% h%InputControlHeight%
        Gui, Add, Button, w%ButtonWidth% h%ButtonHeight% gSubmit x%SubmitButtonX% y%SubmitButtonY% +Center, Submit
        Gui, Add, Button, w%ButtonWidth% h%ButtonHeight% gCancel x%CancelButtonX% y%CancelButtonY% +Center, Cancel
    }

    GetMessageFromUser() {
        GuiWidth := 300
        GuiHeight := 100

        Gui, Show, w%GuiWidth% h%GuiHeight%, Shout Window
    }
    
    InvokeShout(){
        while (this.IsShoutEnabled) {
            this.Shout()
            this.ShoutTimeoutAction()
        }
    }

    ShoutTimeoutAction(){
        SubTimeoutTick := 100

        Loop, % this.ShoutTimeout / SubTimeoutTick {
            Sleep, SubTimeoutTick
            if (!this.IsShoutEnabled) {
                break
            }
        }
    }

    Shout(){
        GuiControlGet, ShoutMessage,, ShoutMessage
        Send, {Enter}
        SendRaw, % ShoutMessage
        Send, {Enter}
    }
}

Submit:
    Gui, Submit, Hide
return

Cancel:
    Gui, Submit, Hide
Return
