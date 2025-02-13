#SingleInstance, forse

global AxisX := 50  ; first member position x
global AxisY := 360  ; first member position y
global Name := "AndruhaDVP"
global IsOn := true
global MinTimeout := 200 ; Min timeout per assist
global MaxTimeout := 2000 ; Max timeout per assist
global TimeoutPerClick := 100 ; timeout per click

SkillPanelHandler := new SkillPanelHandler()

#IfWinActive ahk_class L2UnrealWWindowsViewportWindow

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
    MouseGetPos, xpos, ypos
    ControlHandler.MoveCoursor(global AxisX, global AxisY)
    Send, {Click Right}
    Sleep, 50
    Send, {Click Right}
    ControlHandler.MoveCoursor(xpos, ypos)
Return

F11::
	ControlHandler.MoveCoursor(global AxisX, global AxisY)
	Bot.BotOn()
return

F12::
    Bot.BotOff() ;
return

Up::
    ControlHandler.PreviousPosition()
return

Down::
    ControlHandler.NextPosition()
return

class Bot{

    BotOn() {
	      this.ShowNotification(global Name, "Bot on")
	      global IsOn := true
	      While (global IsOn && !ControlHandler.IsManual()) {
		        Random, rand, global MinTimeout, global MaxTimeout
		        Sleep, rand
		        Send, {Click Right}
		        Sleep, global TimeoutPerClick
    	      Send, {Click Right}
	      }
	      this.ShowNotification(global Name, "Bot off")
	      return
    }

    BotOff() {
	global IsOn := false
	return
    }
    
    ShowNotification(title, text) {
        TrayTip, %title%, %text%, 2, 2
    }
}

class ControlHandler {

    NextPosition() {
        global AxisY := (global AxisY > 564) ? 598 : global AxisY += 34
        this.MoveCoursor(global AxisX, global AxisY)
        return
    }

    PreviousPosition() {
        global AxisY := (global AxisY < 394) ? 360 : global AxisY -= 34
        this.MoveCoursor(global AxisX, global AxisY)
        return
    }
    
    MoveCoursor(x, y) {
        MouseMove, x, y, 0
        return
    }
    
    IsManual() {
	MouseGetPos, xpos, ypos
        return (!this.IsSaveZone(global AxisX, xpos, "x") || !this.IsSaveZone(global AxisY, ypos, "y"))
    }

    IsSaveZone(currentPos, mousePos, axis) {
	; 40 - save zone for x
        ; 16 - save zone for y  
        saveZone := 40
	if(axis == "y") {
		saveZone := 16
	}
	return ((currentPos + saveZone) > mousePos && (currentPos - saveZone) < mousePos)
    }
}

class SkillPanelHandler{

    PickUpAction() {
        Send, !2
        while GetKeyState("F4", "P") {
            Send, 4
            Sleep, 50
        }
        Send, !1
        Sleep, 100
    }

    ShortcutAction(shortcut) {
        Send, !2
        Send, %shortcut%
        Send, !1
    }
}