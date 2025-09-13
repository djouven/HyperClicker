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
modeChoice := myGui.Add("DropDownList", "x80 y" yPos " w120 vModeChoice", ["AutoClicker", "AutoTyper", "Both"])
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
btnStart := myGui.Add("Button", "x10 y" yPos " w60 h25 BackgroundGreen cWhite", "▶ Start")
btnStop  := myGui.Add("Button", "x80 y" yPos " w60 h25 BackgroundRed cWhite", "■ Stop")
btnGear  := myGui.Add("Button", "x150 y" yPos " w40 h25 BackgroundBlue cWhite", "⚙️")
btnTheme := myGui.Add("Button", "x200 y" yPos " w90 h25 BackgroundGray cWhite", "🌙 Theme")

btnStart.OnEvent("Click", (*) => Start())
btnStop.OnEvent("Click", (*) => Stop())
btnGear.OnEvent("Click", (*) => OpenSettings())
btnTheme.OnEvent("Click", (*) => OpenColorPicker())

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
toggleHotkey := "\" ; default toggle key = backslash
Hotkey(toggleHotkey, (*) => ToggleStartStop(), "On") ; bind default hotkey

themeDark := true

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

    delayClick := (cps > 0) ? 1000 / cps : 99999
    delayType  := (wps > 0) ? 1000 / wps : 99999

    if (A_TickCount - lastClick >= Min(delayClick, delayType)) {
        lastClick := A_TickCount

        if (mode = "AutoClicker" || mode = "Both") {
            clickCount := (mb = "Double") ? 2 : 1
            Loop clickCount {
                Click(clickBtn)
            }
        }

        if (mode = "AutoTyper" || mode = "Both") {
            if (txt != "") {
                if (idx <= StrLen(txt)) {
                    Send(SubStr(txt, idx, 1))
                    idx++
                } else {
                    idx := 1
                }
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
        if (mode = "Both") {
            statusDot.SetFont("cPurple")
        } else if (mode = "AutoClicker") {
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
    hotkeyChoice := settingsGui.Add("DropDownList", "w100", ["\\", "F7", "F8", "F9"])

    ; pre-select current hotkey
    if (toggleHotkey="\") hotkeyChoice.Value:=1
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

OpenColorPicker() {
    global myGui, statusLabel, statusDot
    colorGui := Gui("+AlwaysOnTop", "🎨 Pick Theme")
    colorGui.SetFont("s9", "Segoe UI")

    colors := Map("Black","Blue"
                , "White","Black"
                , "Blue","White"
                , "Red","White"
                , "0xFFA500","Black"   ; fixed orange with hex
                , "Green","White"
                , "Purple","White")

    for clr, txtClr in colors {
        label := (clr="0xFFA500") ? "Orange" : clr
        btn := colorGui.Add("Button", "w80 h25", label)
        btn.OnEvent("Click", makeHandler(clr, txtClr, colorGui))
    }

    colorGui.Show("AutoSize")
}

makeHandler(clr, txtClr, colorGui) {
    return (*) => (
        myGui.BackColor := clr,
        statusLabel.SetFont("c" txtClr),
        statusDot.SetFont("c" txtClr),
        colorGui.Destroy()
    )
}

ToggleStartStop() {
    global running
    if running
        Stop()
    else
        Start()
}
