#Requires AutoHotkey v2.0
#SingleInstance Force

; --- GUI ---
myGui := Gui("+Resize", "HyperClickerReborn ⚡")
myGui.BackColor := "Black"
myGui.SetFont("s9 cBlue", "Segoe UI")

; Status label + indicator
statusLabel := myGui.Add("Text", "x10 y8 w160 h15 cBlue", "Status: Stopped")
statusDot   := myGui.Add("Text", "x175 y8 w15 h15 Center cRed", "●")
cpsLabel    := myGui.Add("Text", "x10 y25 w250 cBlue", "CPS: -- | WPS: --") ; Visual counter

yPos := 50

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
yPos += 25

; Ramp CPS toggle
chkRamp := myGui.Add("CheckBox", "x10 y" yPos, "Ramp CPS Mode")
chkRamp.Value := false
yPos += 30

; Buttons
btnStart := myGui.Add("Button", "x10 y" yPos " w60 h25 BackgroundGreen cWhite", "▶ Start")
btnStop  := myGui.Add("Button", "x80 y" yPos " w60 h25 BackgroundRed cWhite", "■ Stop")
btnSound := myGui.Add("Button", "x150 y" yPos " w60 h25 BackgroundGray cWhite", "🔊 Sound")
btnTheme := myGui.Add("Button", "x220 y" yPos " w90 h25 BackgroundGray cWhite", "🌙 Theme")
btnHotkeys := myGui.Add("Button", "x320 y" yPos " w90 h25 BackgroundGray cWhite", "🎹 Hotkeys")
yPos += 30

btnStart.OnEvent("Click", (*) => Start())
btnStop.OnEvent("Click", (*) => Stop())
btnSound.OnEvent("Click", (*) => ToggleSound())
btnTheme.OnEvent("Click", (*) => OpenColorPicker())
btnHotkeys.OnEvent("Click", (*) => OpenHotkeyEditor())

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
toggleHotkey := "\" ; default toggle key
soundHotkey := "F10"  ; default sound toggle
soundOn := true

; Hotkeys
Hotkey(toggleHotkey, (*) => ToggleStartStop(), "On")
Hotkey(soundHotkey, (*) => ToggleSound(), "On")

; --- Functions ---
Start() {
    global running, txt, idx, cps, wps, clickBtn, mb, mode, rampMode
    running := true
    idx := 1

    mode := modeChoice.Text
    cps  := Integer(cpsInput.Text)
    wps  := Integer(wpsInput.Text)
    txt  := txtInput.Text
    clickBtn := clickType.Text
    mb := mouseButton.Text
    rampMode := chkRamp.Value

    UpdateStatus()
    SetTimer(DoWork, 1)
}

Stop() {
    global running
    running := false
    UpdateStatus()
    SetTimer(DoWork, 0)
    cpsLabel.Value := "CPS: -- | WPS: --"
}

DoWork() {
    global running, txt, idx, cps, wps, clickBtn, mb, mode, lastClick, soundOn, rampMode

    if !running
        return

    ; ramp CPS logic
    curCPS := (rampMode) ? Min(cps, 1 + (A_TickCount - lastClick)/100) : cps
    curWPS := wps

    delayClick := (curCPS > 0) ? 1000 / curCPS : 99999
    delayType  := (curWPS > 0) ? 1000 / curWPS : 99999

    if (A_TickCount - lastClick >= Min(delayClick, delayType)) {
        lastClick := A_TickCount

        ; Clicking
        if (mode = "AutoClicker" || mode = "Both") {
            count := (mb = "Double") ? 2 : 1
            Loop count {
                Click(clickBtn)
                if soundOn
                    SoundBeep 1000,10
            }
        }

        ; Typing
        if (mode = "AutoTyper" || mode = "Both") {
            if txt != "" {
                if idx <= StrLen(txt) {
                    Send(SubStr(txt, idx, 1))
                    idx++
                } else
                    idx := 1
            }
        }

        ; Update visual CPS/WPS
        cpsLabel.Value := "CPS: " Round(curCPS,1) " | WPS: " Round(curWPS,1)
    }
}

ToggleSound() {
    global soundOn
    soundOn := !soundOn
}

UpdateStatus() {
    global running, mode, statusLabel, statusDot
    if !running {
        statusLabel.Value := "Status: Stopped"
        statusDot.SetFont("cRed"), statusDot.Value := "●"
    } else {
        statusLabel.Value := "Running: " mode
        statusDot.SetFont("cGreen"), statusDot.Value := "●"
    }
}

ToggleGui() {
    if WinExist("HyperClickerReborn ⚡") {
        if WinActive("HyperClickerReborn ⚡")
            WinHide()
        else
            WinShow()
    }
}

OpenColorPicker() {
    global myGui, statusLabel, statusDot
    colorGui := Gui("+AlwaysOnTop", "🎨 Pick Theme")
    colorGui.SetFont("s9", "Segoe UI")

    colors := Map("Black","Blue"
                , "White","Black"
                , "Blue","White"
                , "Red","White"
                , "0xFFA500","Black"
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

; --- Hotkey Editor (Fixed for AHK v2) ---
OpenHotkeyEditor() {
    global toggleHotkey, soundHotkey

    hotkeyGui := Gui("+AlwaysOnTop", "🎹 Hotkey Settings")
    hotkeyGui.SetFont("s9", "Segoe UI")

    hotkeyGui.Add("Text", "x10 y10", "Start/Stop Hotkey:")
    editStart := hotkeyGui.Add("Edit", "x150 y10 w80", toggleHotkey)

    hotkeyGui.Add("Text", "x10 y40", "Sound Toggle Hotkey:")
    editSound := hotkeyGui.Add("Edit", "x150 y40 w80", soundHotkey)

    saveBtn := hotkeyGui.Add("Button", "x10 y80 w80 h25 BackgroundBlue cWhite", "Save")
    saveBtn.OnEvent("Click", (*) => SaveHotkeys(editStart, editSound, hotkeyGui))

    hotkeyGui.Show("AutoSize Center")
}

SaveHotkeys(editStart, editSound, guiRef) {
    global toggleHotkey, soundHotkey

    ; Turn off old hotkeys
    Hotkey(toggleHotkey, "Off")
    Hotkey(soundHotkey, "Off")

    ; Save new values
    toggleHotkey := editStart.Value
    soundHotkey := editSound.Value

    ; Rebind hotkeys
    Hotkey(toggleHotkey, (*) => ToggleStartStop(), "On")
    Hotkey(soundHotkey, (*) => ToggleSound(), "On")

    guiRef.Destroy()
}
