#SingleInstance, forse
;#IfWinActive ahk_class L2UnrealWWindowsViewportWindow

SkillPanelHandler := new SkillPanelHandler()
BotHandler := new BotHandler()
ControlHandler := new ControlHandler()

F1::
    SkillPanelHandler.ShortcutAction(1)
return

F2::
    SkillPanelHandler.ShortcutAction(2)
return

F3::
    SkillPanelHandler.ShortcutAction(3)
return

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
    ActionTimeout := 100
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
        Sleep, % this.ActionTimeout
    }

    ShortcutAction(shortcut) {
        Send, % this.SecondPanel
        Send, %shortcut%
        Send, % this.FistPanel
    }
}
