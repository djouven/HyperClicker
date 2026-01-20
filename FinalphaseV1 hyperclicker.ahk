#Requires AutoHotkey v2.0
#SingleInstance Force

; =====================================
; HyperClicker Ultra – v2.0 COMPACT
; Professional AutoClicker + AutoTyper
; =====================================

; --- Globals ---
global running := false
global lastClick := 0
global idx := 1
global toggleHotkey := "\"
global soundHotkey := "F10"
global soundOn := true
global totalClicks := 0
global totalKeys := 0
global sessionStart := 0

; --- Compact GUI Setup ---
myGui := Gui("+Resize -DPIScale", "HyperClicker Ultra ⚡")
myGui.BackColor := "0x1a1a1a"
myGui.SetFont("s9 cE0E0E0", "Segoe UI")

; === HEADER & STATUS ===
myGui.SetFont("s9 cFFFFFF Bold", "Segoe UI")
statusLabel := myGui.Add("Text", "x10 y8 w200 h15 BackgroundTrans", "Status: Stopped")
myGui.SetFont("s12 cFF5252", "Segoe UI")
statusDot := myGui.Add("Text", "x220 y8 w15 h15 BackgroundTrans Center", "●")
myGui.SetFont("s8 c90CAF9", "Segoe UI")
cpsLabel := myGui.Add("Text", "x10 y25 w380 h15 BackgroundTrans", "CPS: -- | WPS: -- | Clicks: 0 | Keys: 0")

y := 50

; === MODE ===
myGui.SetFont("s9 cBDBDBD", "Segoe UI")
myGui.Add("Text", "x10 y" y " w60 h20 BackgroundTrans", "Mode:")
modeChoice := myGui.Add("DropDownList", "x75 y" (y-2) " w120 Background0x2a2a2a cE0E0E0 Choose1", ["AutoClicker", "AutoTyper", "Both"])
chkRamp := myGui.Add("CheckBox", "x205 y" y " cBDBDBD", "Ramp")
y += 28

; === SPEED ===
myGui.Add("Text", "x10 y" y " w60 h20 BackgroundTrans", "CPS:")
cpsInput := myGui.Add("Edit", "x75 y" (y-2) " w60 Number Background0x2a2a2a cE0E0E0 Center", "10")
myGui.Add("UpDown", "Range1-999", 10)
myGui.Add("Text", "x145 y" y " w60 h20 BackgroundTrans", "WPS:")
wpsInput := myGui.Add("Edit", "x210 y" (y-2) " w60 Number Background0x2a2a2a cE0E0E0 Center", "5")
myGui.Add("UpDown", "Range1-100", 5)
y += 28

; === DELAYS ===
myGui.Add("Text", "x10 y" y " w60 h20 BackgroundTrans", "Click ms:")
clickDelayInput := myGui.Add("Edit", "x75 y" (y-2) " w60 Number Background0x2a2a2a cE0E0E0 Center", "0")
myGui.Add("Text", "x145 y" y " w60 h20 BackgroundTrans", "Type ms:")
typeDelayInput := myGui.Add("Edit", "x210 y" (y-2) " w60 Number Background0x2a2a2a cE0E0E0 Center", "0")
y += 28

; === RANDOMIZE ===
chkRandom := myGui.Add("CheckBox", "x10 y" y " cBDBDBD", "Randomize ±")
randRangeInput := myGui.Add("Edit", "x100 y" (y-2) " w40 Number Background0x2a2a2a cE0E0E0 Center", "10")
myGui.Add("Text", "x145 y" y " w20 h20 BackgroundTrans", "%")
y += 28

; === CLICK SETTINGS ===
myGui.Add("Text", "x10 y" y " w60 h20 BackgroundTrans", "Click:")
clickType := myGui.Add("DropDownList", "x75 y" (y-2) " w100 Background0x2a2a2a cE0E0E0 Choose1", ["Left", "Right", "Middle", "Scroll"])
mouseButton := myGui.Add("DropDownList", "x185 y" (y-2) " w85 Background0x2a2a2a cE0E0E0 Choose1", ["Single", "Double", "Triple"])
y += 28

; === TEXT INPUT ===
myGui.Add("Text", "x10 y" y " w60 h20 BackgroundTrans", "Text:")
txtInput := myGui.Add("Edit", "x75 y" (y-2) " w315 Background0x2a2a2a cE0E0E0", "Hello from HyperClicker!")
y += 28

; === AUTO-STOP ===
myGui.SetFont("s8 c757575", "Segoe UI")
myGui.Add("Text", "x10 y" y " w100 h15 BackgroundTrans", "Auto-Stop (0=off):")
y += 18
myGui.SetFont("s9 cBDBDBD", "Segoe UI")
myGui.Add("Text", "x10 y" y " w50 h20 BackgroundTrans", "Clicks:")
stopClicksInput := myGui.Add("Edit", "x65 y" (y-2) " w50 Number Background0x2a2a2a cE0E0E0 Center", "0")
myGui.Add("Text", "x125 y" y " w50 h20 BackgroundTrans", "Keys:")
stopKeysInput := myGui.Add("Edit", "x180 y" (y-2) " w50 Number Background0x2a2a2a cE0E0E0 Center", "0")
myGui.Add("Text", "x240 y" y " w60 h20 BackgroundTrans", "Seconds:")
stopTimeInput := myGui.Add("Edit", "x305 y" (y-2) " w50 Number Background0x2a2a2a cE0E0E0 Center", "0")
y += 32

; === CONTROL BUTTONS ===
myGui.SetFont("s10 cFFFFFF Bold", "Segoe UI")
btnStart := myGui.Add("Button", "x10 y" y " w75 h35 Background43A047", "▶ START")
btnStop := myGui.Add("Button", "x95 y" y " w75 h35 BackgroundE53935", "■ STOP")
myGui.SetFont("s9 cFFFFFF", "Segoe UI")
btnSound := myGui.Add("Button", "x180 y" y " w70 h35 Background757575", "🔊 SND")
btnTheme := myGui.Add("Button", "x260 y" y " w65 h35 Background757575", "🎨 THM")
btnHotkeys := myGui.Add("Button", "x335 y" y " w65 h35 Background757575", "⌨️ KEY")

; Event Handlers
btnStart.OnEvent("Click", (*) => Start())
btnStop.OnEvent("Click", (*) => Stop())
btnSound.OnEvent("Click", (*) => ToggleSound())
btnTheme.OnEvent("Click", (*) => OpenColorPicker())
btnHotkeys.OnEvent("Click", (*) => OpenHotkeyEditor())

myGui.Show("w410 AutoSize")

; --- Tray ---
A_IconTip := "HyperClicker Ultra v2.0"
TraySetIcon("shell32.dll", 44)
A_TrayMenu.Delete()
A_TrayMenu.Add("Show/Hide", (*) => ToggleGui())
A_TrayMenu.Add()
A_TrayMenu.Add("Exit", (*) => ExitApp())

; --- Hotkeys ---
Hotkey(toggleHotkey, (*) => ToggleStartStop(), "On")
Hotkey(soundHotkey, (*) => ToggleSound(), "On")
Hotkey("Esc", (*) => Stop(), "On")

; =====================================
; FUNCTIONS
; =====================================

Start() {
    global running, txt, idx, cps, wps, clickBtn, mb, mode, rampMode, clickDelay, typeDelay
    global totalClicks, totalKeys, sessionStart
    
    running := true
    idx := 1
    totalClicks := 0
    totalKeys := 0
    sessionStart := A_TickCount

    mode := modeChoice.Text
    cps := (cpsInput.Text != "") ? Integer(cpsInput.Text) : 10
    wps := (wpsInput.Text != "") ? Integer(wpsInput.Text) : 5
    txt := txtInput.Text
    clickBtn := clickType.Text
    mb := mouseButton.Text
    rampMode := chkRamp.Value
    clickDelay := (clickDelayInput.Text != "") ? Integer(clickDelayInput.Text) : 0
    typeDelay := (typeDelayInput.Text != "") ? Integer(typeDelayInput.Text) : 0

    UpdateStatus()
    SetTimer(DoWork, 1)
}

Stop() {
    global running
    running := false
    UpdateStatus()
    SetTimer(DoWork, 0)
    cpsLabel.Text := "CPS: -- | WPS: -- | Clicks: 0 | Keys: 0"
}

DoWork() {
    global running, txt, idx, cps, wps, clickBtn, mb, mode, lastClick, soundOn, rampMode
    global clickDelay, typeDelay, totalClicks, totalKeys, sessionStart
    global chkRandom, randRangeInput
    global stopClicksInput, stopKeysInput, stopTimeInput

    if !running
        return

    ; Ramp logic
    curCPS := (rampMode) ? Min(cps, 1 + (A_TickCount - sessionStart)/100) : cps
    curWPS := wps

    ; Delay calculation
    curClickDelay := (clickDelay > 0) ? clickDelay : ((curCPS > 0) ? 1000/curCPS : 99999)
    curTypeDelay := (typeDelay > 0) ? typeDelay : ((curWPS > 0) ? 1000/curWPS : 99999)

    ; Randomization
    if chkRandom.Value {
        range := (randRangeInput.Text != "") ? Integer(randRangeInput.Text) : 10
        curClickDelay := curClickDelay * (1 + Random(-range, range)/100.0)
        curTypeDelay := curTypeDelay * (1 + Random(-range, range)/100.0)
    }

    delayUse := Min(curClickDelay, curTypeDelay)

    if (A_TickCount - lastClick >= delayUse) {
        lastClick := A_TickCount

        ; Clicking
        if (mode = "AutoClicker" || mode = "Both") {
            count := (mb = "Double") ? 2 : ((mb = "Triple") ? 3 : 1)
            Loop count {
                try {
                    Click(clickBtn)
                    totalClicks++
                    if soundOn
                        SoundBeep(1200, 8)
                }
            }
        }

        ; Typing
        if (mode = "AutoTyper" || mode = "Both") && (txt != "") {
            if (idx <= StrLen(txt)) {
                try {
                    Send(SubStr(txt, idx, 1))
                    idx++
                    totalKeys++
                }
            } else {
                idx := 1
            }
        }

        ; Update stats
        elapsed := Max(1, (A_TickCount - sessionStart)/1000)
        displayCPS := Round(totalClicks/elapsed, 1)
        displayWPS := Round(totalKeys/elapsed, 1)
        cpsLabel.Text := "CPS: " displayCPS " | WPS: " displayWPS " | Clicks: " totalClicks " | Keys: " totalKeys

        ; Auto-stop
        checkClicks := (stopClicksInput.Text != "") ? Integer(stopClicksInput.Text) : 0
        checkKeys := (stopKeysInput.Text != "") ? Integer(stopKeysInput.Text) : 0
        checkTime := (stopTimeInput.Text != "") ? Integer(stopTimeInput.Text) : 0
        
        if (checkClicks > 0 && totalClicks >= checkClicks) ||
           (checkKeys > 0 && totalKeys >= checkKeys) ||
           (checkTime > 0 && elapsed >= checkTime) {
            Stop()
        }
    }
}

ToggleSound() {
    global soundOn, btnSound
    soundOn := !soundOn
    btnSound.Text := soundOn ? "🔊 SND" : "🔇 OFF"
    btnSound.Opt("Background" (soundOn ? "757575" : "E53935"))
}

UpdateStatus() {
    global running, mode, statusLabel, statusDot
    if !running {
        statusLabel.Text := "Status: Stopped"
        statusDot.SetFont("cFF5252")
        statusDot.Text := "●"
    } else {
        statusLabel.Text := "Running: " mode
        statusDot.SetFont("c66BB6A")
        statusDot.Text := "●"
    }
}

ToggleGui() {
    if WinExist("HyperClicker Ultra ⚡") {
        if WinActive()
            WinHide()
        else
            WinShow()
    }
}

OpenColorPicker() {
    global myGui
    colorGui := Gui("+AlwaysOnTop -DPIScale", "🎨 Theme Selector")
    colorGui.BackColor := "0x2a2a2a"
    colorGui.SetFont("s9 cE0E0E0", "Segoe UI")

    colorGui.SetFont("s11 c64B5F6 Bold", "Segoe UI")
    colorGui.Add("Text", "x20 y15 w200 Center", "Choose Your Theme")
    
    ; DARK MODES
    colorGui.SetFont("s9 cFFD700", "Segoe UI")
    colorGui.Add("Text", "x20 y45", "🌙 DARK MODES")
    
    darkThemes := Map(
        "Dark Blue", {bg: "0x0a1929", btn: "0x1565c0"},
        "Dark Red", {bg: "0x1a0a0a", btn: "0xc62828"},
        "Dark Green", {bg: "0x0a1a0a", btn: "0x2e7d32"},
        "Dark Purple", {bg: "0x1a0a1a", btn: "0x6a1b9a"},
        "Dark Orange", {bg: "0x1a0f0a", btn: "0xe65100"},
        "Dark Pink", {bg: "0x1a0a14", btn: "0xc2185b"},
        "Dark Cyan", {bg: "0x0a1a1a", btn: "0x00838f"},
        "Dark Yellow", {bg: "0x1a1a0a", btn: "0xf9a825"},
        "Dark Teal", {bg: "0x0a1a14", btn: "0x00897b"},
        "Dark Indigo", {bg: "0x0f0a1a", btn: "0x3949ab"},
        "Pure Black", {bg: "0x000000", btn: "0x424242"}
    )

    colorGui.SetFont("s9 cFFFFFF", "Segoe UI")
    yy := 70
    for name, colors in darkThemes {
        btn := colorGui.Add("Button", "x20 y" yy " w200 h28 Background" SubStr(colors.btn, 3), name)
        btn.OnEvent("Click", makeThemeHandler(colors.bg, colorGui))
        yy += 32
    }

    ; LIGHT MODES
    yy += 10
    colorGui.SetFont("s9 cFFD700", "Segoe UI")
    colorGui.Add("Text", "x20 y" yy, "☀️ LIGHT MODES")
    yy += 25
    
    lightThemes := Map(
        "Light Blue", {bg: "0xe3f2fd", btn: "0x2196f3"},
        "Light Red", {bg: "0xffebee", btn: "0xf44336"},
        "Light Green", {bg: "0xe8f5e9", btn: "0x4caf50"},
        "Light Purple", {bg: "0xf3e5f5", btn: "0x9c27b0"},
        "Light Orange", {bg: "0xfff3e0", btn: "0xff9800"},
        "Light Pink", {bg: "0xfce4ec", btn: "0xe91e63"},
        "Light Cyan", {bg: "0xe0f7fa", btn: "0x00bcd4"},
        "Light Yellow", {bg: "0xfffde7", btn: "0xffeb3b"},
        "Light Teal", {bg: "0xe0f2f1", btn: "0x009688"},
        "Light Indigo", {bg: "0xe8eaf6", btn: "0x3f51b5"},
        "Pure White", {bg: "0xffffff", btn: "0x9e9e9e"}
    )

    colorGui.SetFont("s9 c000000", "Segoe UI")
    for name, colors in lightThemes {
        btn := colorGui.Add("Button", "x20 y" yy " w200 h28 Background" SubStr(colors.btn, 3), name)
        btn.OnEvent("Click", makeThemeHandler(colors.bg, colorGui))
        yy += 32
    }

    colorGui.Show("w240 h" (yy + 20))
}

makeThemeHandler(bgColor, colorGui) {
    return (*) => (
        myGui.BackColor := bgColor,
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

OpenHotkeyEditor() {
    global toggleHotkey, soundHotkey
    hotkeyGui := Gui("+AlwaysOnTop -DPIScale", "⌨️ Hotkey Settings")
    hotkeyGui.BackColor := "0x2a2a2a"
    hotkeyGui.SetFont("s9 cE0E0E0", "Segoe UI")
    
    hotkeyGui.SetFont("s10 c64B5F6 Bold", "Segoe UI")
    hotkeyGui.Add("Text", "x20 y15", "Configure Hotkeys")
    
    hotkeyGui.SetFont("s9 cBDBDBD", "Segoe UI")
    hotkeyGui.Add("Text", "x20 y50", "Start/Stop:")
    editStart := hotkeyGui.Add("Edit", "x120 y47 w100 Background0x1a1a1a cE0E0E0 Center", toggleHotkey)
    
    hotkeyGui.Add("Text", "x20 y80", "Sound Toggle:")
    editSound := hotkeyGui.Add("Edit", "x120 y77 w100 Background0x1a1a1a cE0E0E0 Center", soundHotkey)
    
    hotkeyGui.SetFont("s9 cFFFFFF Bold", "Segoe UI")
    saveBtn := hotkeyGui.Add("Button", "x20 y110 w200 h30 Background43A047", "✓ SAVE")
    saveBtn.OnEvent("Click", (*) => SaveHotkeys(editStart, editSound, hotkeyGui))
    
    hotkeyGui.Show("w240 h160 Center")
}

SaveHotkeys(editStart, editSound, guiRef) {
    global toggleHotkey, soundHotkey
    try {
        Hotkey(toggleHotkey, "Off")
        Hotkey(soundHotkey, "Off")
    }
    toggleHotkey := editStart.Text
    soundHotkey := editSound.Text
    Hotkey(toggleHotkey, (*) => ToggleStartStop(), "On")
    Hotkey(soundHotkey, (*) => ToggleSound(), "On")
    guiRef.Destroy()
    MsgBox("Hotkeys saved!", "Success", "Iconi 64")
}