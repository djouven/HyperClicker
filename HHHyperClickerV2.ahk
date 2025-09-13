#Requires AutoHotkey v2.0
#SingleInstance Force

; --- GUI ---
myGui := Gui("+Resize", "HyperClickerV2 ⚡")
myGui.BackColor := "Black"
myGui.SetFont("s9 cBlue", "Segoe UI")

; Status label + indicator
statusLabel := myGui.Add("Text", "x10 y8 w160 h15 cBlue", "Status: Stopped")
statusDot   := myGui.Add("Text", "x175 y8 w15 h15 Center cRed", "●")

yPos := 30

; Mode
myGui.Add("Text", "x10 y" yPos " cBlue", "Mode:")
modeChoice := myGui.Add("DropDownList", "x80 y" yPos " w120 vModeChoice", ["AutoClicker", "AutoTyper"])
modeChoice.Value := 1
yPos += 25

; CPS
myGui.Add("Text", "x10 y" yPos " cBlue", "CPS:")
cpsInput := myGui.Add("Edit", "x80 y" yPos " w80 vCPS", "10")
yPos += 25

; WPS
myGui.Add("Text", "x10 y" yPos " cBlue", "WPS:")
wpsInput := myGui.Add("Edit", "x80 y" yPos " w80 vWPS", "5")
yPos += 25

; Text to type
myGui.Add("Text", "x10 y" yPos " cBlue", "Text:")
txtInput := myGui.Add("Edit", "x80 y" yPos " w180 vText", "Hello from HHHyper!")
yPos += 25

; Click Type
myGui.Add("Text", "x10 y" yPos " cBlue", "Click Type:")
clickType := myGui.Add("DropDownList", "x80 y" yPos " w120 vClickType", ["Left", "Right", "Middle"])
clickType.Value := 1
yPos += 25

; Mouse Button
myGui.Add("Text", "x10 y" yPos " cBlue", "Mouse Btn:")
mouseButton := myGui.Add("DropDownList", "x80 y" yPos " w120 vMouseButton", ["Single", "Double"])
mouseButton.Value := 1
yPos += 30

; Buttons
btnStart := myGui.Add("Button", "x10 y" yPos " w60 h25 BackgroundBlue cWhite", "▶")
btnStop  := myGui.Add("Button", "x80 y" yPos " w60 h25 BackgroundBlue cWhite", "■")
btnGear  := myGui.Add("Button", "x150 y" yPos " w40 h25 BackgroundBlue cWhite", "⚙️")

btnStart.OnEvent("Click", (*) => Start())
btnStop.OnEvent("Click", (*) => Stop())
btnGear.OnEvent("Click", (*) => OpenSettings())

myGui.Show("AutoSize")

; --- Tray setup ---
A_IconTip := "AutoClicker + AutoTyper"
TraySetIcon("shell32.dll", 44)
A_TrayMenu.Delete()
A_TrayMenu.Add("Show/Hide", (*) => ToggleGui())
A_TrayMenu.Add("Exit", (*) => ExitApp())

; --- Globals ---
running := false
lastClick := 0
idx := 1
toggleHotkey := "F6" ; default toggle key
Hotkey(toggleHotkey, (*) => ToggleStartStop(), "On") ; bind default hotkey

; --- Functions ---
Start() {
    global running, txt, idx, cps, wps, clickBtn, mb, mode
    running := true
    idx := 1

    mode := modeChoice.Text
    cps  := Integer(cpsInput.Text)
    wps  := Integer(wpsInput.Text)
    txt  := txtInput.Text
    clickBtn := clickType.Text
    mb := mouseButton.Text

    UpdateStatus()
    SetTimer(DoWork, 10)
}

Stop() {
    global running
    running := false
    UpdateStatus()
    SetTimer(DoWork, 0)
}

DoWork() {
    global running, txt, idx, cps, wps, clickBtn, mb, mode, lastClick
    if (!running)
        return

    if (mode = "AutoClicker") {
        if (cps <= 0)
            return
        delay := 1000 / cps
        if (A_TickCount - lastClick >= delay) {
            lastClick := A_TickCount
            clickCount := (mb = "Double") ? 2 : 1
            Loop clickCount {
                Click(clickBtn)
            }
        }
    } else if (mode = "AutoTyper") {
        if (wps <= 0 || txt = "")
            return
        delay := 1000 / wps
        if (A_TickCount - lastClick >= delay) {
            lastClick := A_TickCount
            if (idx <= StrLen(txt)) {
                Send(SubStr(txt, idx, 1))
                idx++
            } else {
                idx := 1
            }
        }
    }
}

UpdateStatus() {
    global running, mode, cps, wps, statusLabel, statusDot
    if !running {
        statusLabel.Value := "Status: Stopped"
        statusDot.SetFont("cRed"), statusDot.Value := "●"
    } else {
        statusLabel.Value := "Running: " mode
        if (mode = "AutoClicker") {
            statusDot.SetFont((cps < 10) ? "cYellow" : "cGreen")
        } else {
            statusDot.SetFont((wps < 10) ? "cYellow" : "cGreen")
        }
        statusDot.Value := "●"
    }
}

ToggleGui() {
    if WinExist("HyperClickerV2 ⚡") {
        if WinActive("HyperClickerV2 ⚡")
            WinHide("HyperClickerV2 ⚡")
        else
            WinShow("HyperClickerV2 ⚡")
    }
}

OpenSettings() {
    global toggleHotkey

    settingsGui := Gui("+AlwaysOnTop", "⭐ Settings")
    settingsGui.BackColor := "Black"
    settingsGui.SetFont("s9 cBlue", "Segoe UI")

    settingsGui.Add("Text", "cBlue", "Pick Toggle Hotkey:")
    hotkeyChoice := settingsGui.Add("DropDownList", "w100", ["F6", "F7", "F8", "F9"])

    ; pre-select current hotkey
    if (toggleHotkey="F6") hotkeyChoice.Value:=1
    if (toggleHotkey="F7") hotkeyChoice.Value:=2
    if (toggleHotkey="F8") hotkeyChoice.Value:=3
    if (toggleHotkey="F9") hotkeyChoice.Value:=4

    saveBtn := settingsGui.Add("Button", "w60 h25 BackgroundBlue cWhite", "Save")
    saveBtn.OnEvent("Click", (*) => (
        Hotkey(toggleHotkey, "Off"), ; disable old hotkey
        toggleHotkey := hotkeyChoice.Text,
        Hotkey(toggleHotkey, (*) => ToggleStartStop(), "On"), ; enable new hotkey
        settingsGui.Destroy()
    ))

    settingsGui.Show("AutoSize")
}

ToggleStartStop() {
    global running
    if running
        Stop()
    else
        Start()
}
