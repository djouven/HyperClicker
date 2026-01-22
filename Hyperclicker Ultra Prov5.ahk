#Requires AutoHotkey v2.0
#SingleInstance Force

; ═══════════════════════════════════════════════════════════════════════════
; ║                    HYPERCLICKER ULTRA PRO 4                          ║
; ║              Supreme Edition - Revolutionary Interface                   ║
; ═══════════════════════════════════════════════════════════════════════════

; ══════════════════════════════════════════════════════════════════════════
; CORE STATE MANAGEMENT
; ══════════════════════════════════════════════════════════════════════════
class AppState {
    static running := false
    static paused := false
    static recording := false
    static soundOn := true
    
    static clicks := 0
    static keys := 0
    static sessionStart := 0
    static lastAction := 0
    
    static peakCPS := 0
    static peakWPS := 0
    static avgCPS := 0
    static avgWPS := 0
    
    static currentTheme := "Quantum"
    static currentProfile := ""
    static hotkeyToggle := "\"
    static hotkeySound := "F10"
    
    static autoSaveEnabled := true
    static minimizeToTray := false
    static showNotifications := true
    
    static Reset() {
        this.clicks := 0
        this.keys := 0
        this.peakCPS := 0
        this.peakWPS := 0
        this.sessionStart := A_TickCount
    }
}

; ══════════════════════════════════════════════════════════════════════════
; ADVANCED THEME ENGINE
; ══════════════════════════════════════════════════════════════════════════
class ThemeEngine {
    static themes := Map(
        "Quantum", {
            bg: "0x0a0a14",
            panel: "0x12121e",
            header: "0x1a1a28",
            accent: "0x00ffff",
            accent2: "0xff00ff",
            text: "0x00ffff",
            textDim: "0x7f7f9f",
            border: "0x00ffff",
            success: "0x00ff88",
            error: "0xff0066",
            warning: "0xffcc00",
            glow: true,
            gradient: true
        },
        "Cyberpunk", {
            bg: "0x0a0a0a",
            panel: "0x121212",
            header: "0x1a1a1a",
            accent: "0x00ff41",
            accent2: "0xff006e",
            text: "0x00ff41",
            textDim: "0x808080",
            border: "0x00ff41",
            success: "0x00ff41",
            error: "0xff006e",
            warning: "0xffea00",
            glow: true,
            gradient: false
        },
        "Nord Aurora", {
            bg: "0x2E3440",
            panel: "0x3B4252",
            header: "0x434C5E",
            accent: "0x88C0D0",
            accent2: "0xBF616A",
            text: "0xECEFF4",
            textDim: "0xD8DEE9",
            border: "0x5E81AC",
            success: "0xA3BE8C",
            error: "0xBF616A",
            warning: "0xEBCB8B",
            glow: false,
            gradient: false
        },
        "Midnight Blue", {
            bg: "0x0d1117",
            panel: "0x161b22",
            header: "0x21262d",
            accent: "0x58a6ff",
            accent2: "0x1f6feb",
            text: "0xc9d1d9",
            textDim: "0x8b949e",
            border: "0x30363d",
            success: "0x3fb950",
            error: "0xf85149",
            warning: "0xd29922",
            glow: false,
            gradient: true
        },
        "Neon Dreams", {
            bg: "0x0f0a1a",
            panel: "0x1a0f28",
            header: "0x251436",
            accent: "0xff00ff",
            accent2: "0x00ffff",
            text: "0xffffff",
            textDim: "0xcc99ff",
            border: "0xff00ff",
            success: "0x00ff00",
            error: "0xff0066",
            warning: "0xffcc00",
            glow: true,
            gradient: true
        },
        "Tokyo Night", {
            bg: "0x1a1b26",
            panel: "0x24283b",
            header: "0x414868",
            accent: "0x7aa2f7",
            accent2: "0xbb9af7",
            text: "0xa9b1d6",
            textDim: "0x565f89",
            border: "0x7aa2f7",
            success: "0x9ece6a",
            error: "0xf7768e",
            warning: "0xe0af68",
            glow: false,
            gradient: false
        },
        "Dracula", {
            bg: "0x282a36",
            panel: "0x383a59",
            header: "0x44475a",
            accent: "0xff79c6",
            accent2: "0xbd93f9",
            text: "0xf8f8f2",
            textDim: "0x6272a4",
            border: "0xff79c6",
            success: "0x50fa7b",
            error: "0xff5555",
            warning: "0xf1fa8c",
            glow: true,
            gradient: false
        },
        "Monokai Pro", {
            bg: "0x2d2a2e",
            panel: "0x403e41",
            header: "0x5b595c",
            accent: "0xffd866",
            accent2: "0xff6188",
            text: "0xfcfcfa",
            textDim: "0x939293",
            border: "0xffd866",
            success: "0xa9dc76",
            error: "0xff6188",
            warning: "0xffd866",
            glow: false,
            gradient: false
        }
    )
    
    static Apply(themeName) {
        AppState.currentTheme := themeName
        theme := this.themes[themeName]
        global myGui
        myGui.BackColor := theme.bg
        return theme
    }
    
    static GetCurrent() {
        return this.themes[AppState.currentTheme]
    }
}

; ══════════════════════════════════════════════════════════════════════════
; MACRO SYSTEM
; ══════════════════════════════════════════════════════════════════════════
class MacroSystem {
    static steps := []
    static savedMacros := Map()
    
    static StartRecording() {
        this.steps := []
        AppState.recording := true
        
        Hotkey("~LButton", (*) => this.RecordAction("click", "Left"), "On")
        Hotkey("~RButton", (*) => this.RecordAction("click", "Right"), "On")
        Hotkey("~MButton", (*) => this.RecordAction("click", "Middle"), "On")
    }
    
    static StopRecording() {
        AppState.recording := false
        Hotkey("~LButton", "Off")
        Hotkey("~RButton", "Off")
        Hotkey("~MButton", "Off")
    }
    
    static RecordAction(type, data) {
        if !AppState.recording
            return
        
        this.steps.Push({
            type: type,
            data: data,
            time: A_TickCount,
            x: 0,
            y: 0
        })
        
        if type = "click" {
            MouseGetPos(&mx, &my)
            this.steps[-1].x := mx
            this.steps[-1].y := my
        }
    }
    
    static PlayMacro() {
        if this.steps.Length = 0
            return false
        
        startTime := this.steps[1].time
        
        for step in this.steps {
            delay := step.time - startTime
            if A_Index > 1
                Sleep(delay - (this.steps[A_Index - 1].time - startTime))
            
            if step.type = "click" {
                Click(step.data)
                AppState.clicks++
            } else if step.type = "key" {
                Send(step.data)
                AppState.keys++
            }
        }
        return true
    }
    
    static Save(name) {
        this.savedMacros[name] := this.steps.Clone()
    }
    
    static Load(name) {
        if this.savedMacros.Has(name) {
            this.steps := this.savedMacros[name].Clone()
            return true
        }
        return false
    }
}

; ══════════════════════════════════════════════════════════════════════════
; PROFILE MANAGER
; ══════════════════════════════════════════════════════════════════════════
class ProfileManager {
    static profiles := Map(
        "Gaming Ultra", {cps: 50, wps: 0, mode: 1, clickType: 1, buttonType: 1, random: true},
        "Productivity", {cps: 12, wps: 8, mode: 3, clickType: 1, buttonType: 1, random: false},
        "Precision Work", {cps: 5, wps: 3, mode: 3, clickType: 1, buttonType: 1, random: false},
        "Speed Test", {cps: 100, wps: 0, mode: 1, clickType: 1, buttonType: 1, random: false},
        "Typing Pro", {cps: 0, wps: 20, mode: 2, clickType: 1, buttonType: 1, random: true},
        "Balanced Mix", {cps: 15, wps: 10, mode: 3, clickType: 1, buttonType: 1, random: true}
    )
    
    static Apply(profileName) {
        if !this.profiles.Has(profileName)
            return false
        
        profile := this.profiles[profileName]
        global cpsInput, wpsInput, modeChoice, clickType, mouseButton, chkRandom
        
        cpsInput.Value := profile.cps
        wpsInput.Value := profile.wps
        modeChoice.Choose(profile.mode)
        clickType.Choose(profile.clickType)
        mouseButton.Choose(profile.buttonType)
        chkRandom.Value := profile.random
        
        AppState.currentProfile := profileName
        return true
    }
    
    static SaveCurrent(name) {
        global cpsInput, wpsInput, modeChoice, clickType, mouseButton, chkRandom
        
        this.profiles[name] := {
            cps: Integer(cpsInput.Text),
            wps: Integer(wpsInput.Text),
            mode: modeChoice.Value,
            clickType: clickType.Value,
            buttonType: mouseButton.Value,
            random: chkRandom.Value
        }
    }
}

; ══════════════════════════════════════════════════════════════════════════
; STATISTICS ENGINE
; ══════════════════════════════════════════════════════════════════════════
class Statistics {
    static history := []
    static maxHistory := 100
    
    static Update() {
        if !AppState.running
            return
        
        elapsed := Max(1, (A_TickCount - AppState.sessionStart) / 1000)
        currentCPS := Round(AppState.clicks / elapsed, 2)
        currentWPS := Round(AppState.keys / elapsed, 2)
        
        AppState.avgCPS := currentCPS
        AppState.avgWPS := currentWPS
        
        if currentCPS > AppState.peakCPS
            AppState.peakCPS := currentCPS
        if currentWPS > AppState.peakWPS
            AppState.peakWPS := currentWPS
        
        this.history.Push({
            time: A_TickCount,
            cps: currentCPS,
            wps: currentWPS,
            clicks: AppState.clicks,
            keys: AppState.keys
        })
        
        if this.history.Length > this.maxHistory
            this.history.RemoveAt(1)
    }
    
    static Export() {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd_HHmmss")
        filename := "Stats_" timestamp ".csv"
        
        content := "Timestamp,CPS,WPS,TotalClicks,TotalKeys`n"
        for entry in this.history {
            content .= FormatTime(entry.time, "yyyy-MM-dd HH:mm:ss") ","
            content .= entry.cps "," entry.wps "," entry.clicks "," entry.keys "`n"
        }
        
        try {
            FileAppend(content, filename)
            return filename
        }
        return ""
    }
}

; ══════════════════════════════════════════════════════════════════════════
; MAIN GUI CREATION
; ══════════════════════════════════════════════════════════════════════════
global myGui := Gui("+Resize -DPIScale +AlwaysOnTop", "HyperClicker Ultra Pro v5.0 ⚡")
theme := ThemeEngine.Apply("Quantum")

; ══════════════════════════════════════════════════════════════════════════
; PREMIUM HEADER
; ══════════════════════════════════════════════════════════════════════════
myGui.SetFont("s11 Bold", "Consolas")
headerBg := myGui.Add("Text", "x0 y0 w700 h60 Background" SubStr(theme.header, 3), "")

myGui.SetFont("s16 Bold", "Segoe UI")
titleText := myGui.Add("Text", "x20 y15 w500 h30 BackgroundTrans c" SubStr(theme.accent, 3), "⚡ HYPERCLICKER ULTRA PRO v5.0")

myGui.SetFont("s9", "Segoe UI")
editionText := myGui.Add("Text", "x540 y18 w140 h25 BackgroundTrans Right c" SubStr(theme.textDim, 3), "Supreme Edition")

; Live Status Indicator
myGui.SetFont("s10 Bold", "Segoe UI")
global statusLabel := myGui.Add("Text", "x20 y42 w350 h18 BackgroundTrans c" SubStr(theme.textDim, 3), "● STANDBY MODE")

; Session Timer
myGui.SetFont("s9", "Consolas")
global timerLabel := myGui.Add("Text", "x540 y42 w140 h18 BackgroundTrans Right c" SubStr(theme.accent2, 3), "⏱ 00:00:00")

; ══════════════════════════════════════════════════════════════════════════
; REAL-TIME PERFORMANCE DASHBOARD
; ══════════════════════════════════════════════════════════════════════════
myGui.SetFont("s8 Bold", "Segoe UI")
myGui.Add("Text", "x10 y70 w680 h24 Center Background" SubStr(theme.panel, 3) " c" SubStr(theme.accent, 3), "═══ REAL-TIME PERFORMANCE ANALYTICS ═══")

; Enhanced Stats Grid
myGui.SetFont("s10 Bold", "Consolas")
global cpsLabel := myGui.Add("Text", "x15 y100 w105 h28 Center Background" SubStr(theme.bg, 3) " c" SubStr(theme.accent, 3), "CPS: --")
global wpsLabel := myGui.Add("Text", "x125 y100 w105 h28 Center Background" SubStr(theme.bg, 3) " c" SubStr(theme.accent, 3), "WPS: --")
global clickLabel := myGui.Add("Text", "x235 y100 w110 h28 Center Background" SubStr(theme.bg, 3) " c" SubStr(theme.accent, 3), "Clicks: 0")
global keyLabel := myGui.Add("Text", "x350 y100 w110 h28 Center Background" SubStr(theme.bg, 3) " c" SubStr(theme.accent, 3), "Keys: 0")

myGui.SetFont("s9", "Consolas")
global peakCPSLabel := myGui.Add("Text", "x465 y100 w105 h28 Center Background" SubStr(theme.bg, 3) " c" SubStr(theme.accent2, 3), "Peak: --")
global peakWPSLabel := myGui.Add("Text", "x575 y100 w110 h28 Center Background" SubStr(theme.bg, 3) " c" SubStr(theme.accent2, 3), "WPeak: --")

; Animated Progress Bars
global progressBar1 := myGui.Add("Progress", "x15 y133 w670 h5 Background" SubStr(theme.panel, 3) " c" SubStr(theme.accent, 3), 0)
global progressBar2 := myGui.Add("Progress", "x15 y140 w670 h5 Background" SubStr(theme.panel, 3) " c" SubStr(theme.accent2, 3), 0)

; ══════════════════════════════════════════════════════════════════════════
; LEFT PANEL - AUTOMATION CONTROLS
; ══════════════════════════════════════════════════════════════════════════
myGui.SetFont("s9 Bold", "Segoe UI")
myGui.Add("Text", "x10 y155 w330 h28 Center Background" SubStr(theme.panel, 3) " c" SubStr(theme.accent, 3), "╔═══ AUTOMATION ENGINE ═══╗")

myGui.SetFont("s9", "Segoe UI")
; Mode Selection
myGui.Add("Text", "x20 y195 w90 h24 BackgroundTrans c" SubStr(theme.text, 3), "⚙ Mode:")
global modeChoice := myGui.Add("DropDownList", "x115 y192 w215 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3) " Choose1", 
    ["🖱 AutoClicker", "⌨ AutoTyper", "🔄 Both", "📹 Macro Replay"])

; Speed Controls with Live Sliders
myGui.Add("Text", "x20 y230 w90 h24 BackgroundTrans c" SubStr(theme.text, 3), "⚡ CPS:")
global cpsInput := myGui.Add("Edit", "x115 y227 w85 h26 Number Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3) " Center", "20")
global cpsUpDown := myGui.Add("UpDown", "Range1-999", 20)
global cpsSlider := myGui.Add("Slider", "x205 y227 w125 h26 Range1-100 ToolTip c" SubStr(theme.accent, 3), 20)
cpsSlider.OnEvent("Change", (*) => (cpsInput.Value := cpsSlider.Value))

myGui.Add("Text", "x20 y265 w90 h24 BackgroundTrans c" SubStr(theme.text, 3), "⌨ WPS:")
global wpsInput := myGui.Add("Edit", "x115 y262 w85 h26 Number Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3) " Center", "10")
global wpsUpDown := myGui.Add("UpDown", "Range1-100", 10)
global wpsSlider := myGui.Add("Slider", "x205 y262 w125 h26 Range1-50 ToolTip c" SubStr(theme.accent, 3), 10)
wpsSlider.OnEvent("Change", (*) => (wpsInput.Value := wpsSlider.Value))

; Click Configuration
myGui.Add("Text", "x20 y300 w90 h24 BackgroundTrans c" SubStr(theme.text, 3), "🎯 Button:")
global clickType := myGui.Add("DropDownList", "x115 y297 w100 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3) " Choose1", 
    ["Left", "Right", "Middle", "X1", "X2", "WheelUp", "WheelDn"])
global mouseButton := myGui.Add("DropDownList", "x220 y297 w110 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3) " Choose1", 
    ["Single", "Double", "Triple", "Hold"])

; Advanced Features
myGui.SetFont("s8 Bold", "Segoe UI")
myGui.Add("Text", "x20 y335 w310 h20 BackgroundTrans c" SubStr(theme.accent2, 3), "⚡ ADVANCED FEATURES")

myGui.SetFont("s9", "Segoe UI")
global chkRamp := myGui.Add("CheckBox", "x20 y360 c" SubStr(theme.text, 3), "📈 Ramp-Up Mode")
global chkRandom := myGui.Add("CheckBox", "x20 y385 c" SubStr(theme.text, 3), "🎲 Randomize ±")
global randInput := myGui.Add("Edit", "x150 y382 w60 Number Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3) " Center", "15")
myGui.Add("Text", "x215 y385 w25 h24 BackgroundTrans c" SubStr(theme.textDim, 3), "%")

global chkSmart := myGui.Add("CheckBox", "x20 y410 c" SubStr(theme.text, 3), "🧠 Smart Human Delay")
global chkPattern := myGui.Add("CheckBox", "x20 y435 c" SubStr(theme.text, 3), "🔀 Variation Pattern")
global chkJitter := myGui.Add("CheckBox", "x20 y460 c" SubStr(theme.text, 3), "🌊 Micro Jitter")

; ══════════════════════════════════════════════════════════════════════════
; RIGHT PANEL - PRECISION SETTINGS
; ══════════════════════════════════════════════════════════════════════════
myGui.SetFont("s9 Bold", "Segoe UI")
myGui.Add("Text", "x350 y155 w340 h28 Center Background" SubStr(theme.panel, 3) " c" SubStr(theme.accent, 3), "╔═══ PRECISION CONTROLS ═══╗")

myGui.SetFont("s9", "Segoe UI")
; Delay Controls
myGui.Add("Text", "x360 y195 w100 h24 BackgroundTrans c" SubStr(theme.text, 3), "⏱ Click Delay:")
global clickDelayInput := myGui.Add("Edit", "x465 y192 w215 Number Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3) " Center", "0")

myGui.Add("Text", "x360 y230 w100 h24 BackgroundTrans c" SubStr(theme.text, 3), "⏱ Type Delay:")
global typeDelayInput := myGui.Add("Edit", "x465 y227 w215 Number Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3) " Center", "0")

; Text Input
myGui.Add("Text", "x360 y265 w200 h22 BackgroundTrans c" SubStr(theme.text, 3), "📝 Auto-Type Text:")
myGui.SetFont("s8", "Segoe UI")
global templateBtn := myGui.Add("Button", "x565 y263 w115 h22 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3), "📋 Templates")
templateBtn.OnEvent("Click", (*) => ShowTemplates())

myGui.SetFont("s9", "Segoe UI")
global txtInput := myGui.Add("Edit", "x360 y290 w320 h65 Multi Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3), 
    "Welcome to HyperClicker Ultra Pro v5.0 Supreme Edition!")

; Auto-Stop Conditions
myGui.SetFont("s8 Bold", "Segoe UI")
myGui.Add("Text", "x360 y365 w320 h20 BackgroundTrans c" SubStr(theme.accent2, 3), "⏹ AUTO-STOP CONDITIONS (0 = unlimited)")

myGui.SetFont("s9", "Segoe UI")
myGui.Add("Text", "x360 y390 w90 h22 BackgroundTrans c" SubStr(theme.text, 3), "Max Clicks:")
global stopClicks := myGui.Add("Edit", "x455 y387 w85 Number Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3) " Center", "0")

myGui.Add("Text", "x360 y420 w90 h22 BackgroundTrans c" SubStr(theme.text, 3), "Max Keys:")
global stopKeys := myGui.Add("Edit", "x455 y417 w85 Number Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3) " Center", "0")

myGui.Add("Text", "x360 y450 w90 h22 BackgroundTrans c" SubStr(theme.text, 3), "Max Seconds:")
global stopTime := myGui.Add("Edit", "x455 y447 w85 Number Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3) " Center", "0")

; Quick Presets
myGui.SetFont("s8", "Segoe UI")
preset100 := myGui.Add("Button", "x550 y387 w60 h22 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3), "100")
preset1000 := myGui.Add("Button", "x620 y387 w60 h22 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3), "1000")
preset100.OnEvent("Click", (*) => (stopClicks.Value := "100"))
preset1000.OnEvent("Click", (*) => (stopClicks.Value := "1000"))

preset60 := myGui.Add("Button", "x550 y447 w60 h22 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3), "60s")
preset300 := myGui.Add("Button", "x620 y447 w60 h22 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3), "5min")
preset60.OnEvent("Click", (*) => (stopTime.Value := "60"))
preset300.OnEvent("Click", (*) => (stopTime.Value := "300"))

; ══════════════════════════════════════════════════════════════════════════
; CONTROL BUTTONS - Premium Design
; ══════════════════════════════════════════════════════════════════════════
myGui.SetFont("s13 Bold", "Segoe UI")
global btnStart := myGui.Add("Button", "x10 y495 w165 h55 Background" SubStr(theme.success, 3) " cFFFFFF", "▶ START")
global btnStop := myGui.Add("Button", "x180 y495 w165 h55 Background" SubStr(theme.error, 3) " cFFFFFF", "■ STOP")

myGui.SetFont("s10 Bold", "Segoe UI")
global btnPause := myGui.Add("Button", "x10 y560 w110 h40 Background" SubStr(theme.warning, 3) " c000000", "⏸ PAUSE")
global btnSound := myGui.Add("Button", "x125 y560 w110 h40 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3), "🔊 SOUND")
global btnTheme := myGui.Add("Button", "x240 y560 w105 h40 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3), "🎨 THEME")

; Right Side Buttons
myGui.SetFont("s11 Bold", "Segoe UI")
global btnRecord := myGui.Add("Button", "x355 y495 w165 h55 Background" SubStr(theme.accent2, 3) " cFFFFFF", "📹 RECORD")
global btnProfile := myGui.Add("Button", "x525 y495 w165 h55 Background" SubStr(theme.accent, 3) " c000000", "👤 PROFILE")

myGui.SetFont("s9 Bold", "Segoe UI")
btnStats := myGui.Add("Button", "x355 y560 w110 h40 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3), "📊 STATS")
btnMacro := myGui.Add("Button", "x470 y560 w110 h40 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3), "🎬 MACRO")
btnHelp := myGui.Add("Button", "x585 y560 w105 h40 Background" SubStr(theme.panel, 3) " c" SubStr(theme.text, 3), "❓ HELP")

; ══════════════════════════════════════════════════════════════════════════
; FOOTER INFO BAR
; ══════════════════════════════════════════════════════════════════════════
myGui.SetFont("s8", "Consolas")
myGui.Add("Text", "x10 y612 w340 h20 BackgroundTrans c" SubStr(theme.textDim, 3), 
    "Hotkey: " AppState.hotkeyToggle " │ Sound: " AppState.hotkeySound " │ Emergency: ESC")
myGui.Add("Text", "x360 y612 w330 h20 BackgroundTrans Right c" SubStr(theme.textDim, 3), 
    "© 2026 HyperClicker Ultra Pro v5.0 Supreme Edition")

; ══════════════════════════════════════════════════════════════════════════
; EVENT HANDLERS
; ══════════════════════════════════════════════════════════════════════════
btnStart.OnEvent("Click", (*) => AutomationEngine.Start())
btnStop.OnEvent("Click", (*) => AutomationEngine.Stop())
btnPause.OnEvent("Click", (*) => AutomationEngine.TogglePause())
btnSound.OnEvent("Click", (*) => ToggleSound())
btnTheme.OnEvent("Click", (*) => OpenThemeSelector())
btnRecord.OnEvent("Click", (*) => ToggleRecording())
btnProfile.OnEvent("Click", (*) => OpenProfileManager())
btnStats.OnEvent("Click", (*) => OpenStatistics())
btnMacro.OnEvent("Click", (*) => OpenMacroManager())
btnHelp.OnEvent("Click", (*) => OpenHelp())

myGui.Show("w700 h640")

; ══════════════════════════════════════════════════════════════════════════
; AUTOMATION ENGINE
; ══════════════════════════════════════════════════════════════════════════
class AutomationEngine {
    static Start() {
        if AppState.running
            return
        
        AppState.running := true
        AppState.paused := false
        AppState.Reset()
        
        UpdateStatus("● ACTIVE", ThemeEngine.GetCurrent().success)
        
        SetTimer(WorkLoop, 1)
        SetTimer(UpdateUI, 100)
        SetTimer(UpdateSessionTimer, 1000)
        
        if AppState.soundOn
            SoundBeep(1500, 50)
        
        Notify("▶ Started", "Automation engine activated!", 2)
    }
    
    static Stop() {
        if !AppState.running && !AppState.paused
            return
        
        AppState.running := false
        AppState.paused := false
        
        UpdateStatus("● STANDBY MODE", ThemeEngine.GetCurrent().textDim)
        
        SetTimer(WorkLoop, 0)
        SetTimer(UpdateUI, 0)
        SetTimer(UpdateSessionTimer, 0)
        
        global btnPause
        btnPause.Text := "⏸ PAUSE"
        
        ResetDisplays()
        
        if AppState.soundOn
            SoundBeep(1000, 50)
        
        Notify("■ Stopped", "Automation stopped.", 2)
    }
    
    static TogglePause() {
        global btnPause
        
        if !AppState.running && !AppState.paused
            return
        
        if AppState.running {
            AppState.running := false
            AppState.paused := true
            btnPause.Text := "▶ RESUME"
            UpdateStatus("⏸ PAUSED", ThemeEngine.GetCurrent().warning)
            SetTimer(WorkLoop, 0)
            if AppState.soundOn
                SoundBeep(1200, 30)
        } else if AppState.paused {
            AppState.running := true
            AppState.paused := false
            btnPause.Text := "⏸ PAUSE"
            UpdateStatus("● ACTIVE", ThemeEngine.GetCurrent().success)
            SetTimer(WorkLoop, 1)
            if AppState.soundOn
                SoundBeep(1500, 30)
        }
    }
}

; ══════════════════════════════════════════════════════════════════════════
; WORK LOOP - Core Automation Logic
; ══════════════════════════════════════════════════════════════════════════
WorkLoop() {
    if !AppState.running
        return
    
    global modeChoice, cpsInput, wpsInput, txtInput, clickType, mouseButton
    global clickDelayInput, typeDelayInput, chkRamp, chkRandom, randInput
    global chkSmart, chkPattern, chkJitter, stopClicks, stopKeys, stopTime
    
    static txtIndex := 1
    
    ; Get current settings
    mode := modeChoice.Text
    cps := (cpsInput.Text != "") ? Integer(cpsInput.Text) : 20
    wps := (wpsInput.Text != "") ? Integer(wpsInput.Text) : 10
    txt := txtInput.Text
    btn := clickType.Text
    clickMode := mouseButton.Text
    
    ; Calculate delays
    clickDelay := (clickDelayInput.Text != "") ? Integer(clickDelayInput.Text) : 0
    typeDelay := (typeDelayInput.Text != "") ? Integer(typeDelayInput.Text) : 0
    
    ; Apply ramp-up
    if chkRamp.Value {
        elapsed := (A_TickCount - AppState.sessionStart) / 1000
        rampFactor := Min(1, elapsed / 5)
        cps := Round(cps * rampFactor)
        wps := Round(wps * rampFactor)
    }
    
    ; Calculate base delays
    baseClickDelay := (clickDelay > 0) ? clickDelay : ((cps > 0) ? 1000/cps : 99999)
    baseTypeDelay := (typeDelay > 0) ? typeDelay : ((wps > 0) ? 1000/wps : 99999)
    
    ; Apply randomization
    if chkRandom.Value {
        randPercent := (randInput.Text != "") ? Integer(randInput.Text) : 15
        baseClickDelay *= (1 + Random(-randPercent, randPercent) / 100.0)
        baseTypeDelay *= (1 + Random(-randPercent, randPercent) / 100.0)
    }
    
    ; Apply smart human delay
    humanDelay := 0
    if chkSmart.Value {
        humanDelay := Random(5, 35)
    }
    
    ; Apply pattern variation
    if chkPattern.Value {
        pattern := Sin(A_TickCount / 1000) * 50
        baseClickDelay += pattern
    }
    
    ; Apply micro jitter
    if chkJitter.Value {
        jitter := Random(-10, 10)
        baseClickDelay += jitter
        baseTypeDelay += jitter
    }
    
    currentDelay := Min(baseClickDelay, baseTypeDelay) + humanDelay
    
    ; Execute actions
    if (A_TickCount - AppState.lastAction >= currentDelay) {
        AppState.lastAction := A_TickCount
        
        ; AutoClicker
        if (mode = "🖱 AutoClicker" || mode = "🔄 Both") {
            ExecuteClick(btn, clickMode)
        }
        
        ; AutoTyper
        if (mode = "⌨ AutoTyper" || mode = "🔄 Both") && (txt != "") {
            ExecuteType(txt, &txtIndex)
        }
        
        ; Macro Replay
        if (mode = "📹 Macro Replay") {
            MacroSystem.PlayMacro()
        }
        
        ; Check auto-stop conditions
        CheckAutoStop()
    }
}

ExecuteClick(btn, mode) {
    count := (mode = "Double") ? 2 : ((mode = "Triple") ? 3 : 1)
    
    if (mode = "Hold") {
        Click("Down " btn)
        Sleep(Random(50, 150))
        Click("Up " btn)
        AppState.clicks++
    } else {
        Loop count {
            try {
                Click(btn)
                AppState.clicks++
                if AppState.soundOn && Random(1, 10) = 1
                    SoundBeep(1200 + Random(-100, 100), 5)
            }
        }
    }
}

ExecuteType(txt, &index) {
    if (index <= StrLen(txt)) {
        try {
            char := SubStr(txt, index, 1)
            Send(char)
            index++
            AppState.keys++
            if AppState.soundOn && Random(1, 8) = 1
                SoundBeep(800, 3)
        }
    } else {
        index := 1
    }
}

CheckAutoStop() {
    global stopClicks, stopKeys, stopTime
    
    maxClicks := (stopClicks.Text != "") ? Integer(stopClicks.Text) : 0
    maxKeys := (stopKeys.Text != "") ? Integer(stopKeys.Text) : 0
    maxTime := (stopTime.Text != "") ? Integer(stopTime.Text) : 0
    
    elapsed := (A_TickCount - AppState.sessionStart) / 1000
    
    if (maxClicks > 0 && AppState.clicks >= maxClicks) ||
       (maxKeys > 0 && AppState.keys >= maxKeys) ||
       (maxTime > 0 && elapsed >= maxTime) {
        AutomationEngine.Stop()
        Notify("⏹ Auto-Stop", "Limit reached!", 2)
    }
}

; ══════════════════════════════════════════════════════════════════════════
; UI UPDATE FUNCTIONS
; ══════════════════════════════════════════════════════════════════════════
UpdateUI() {
    Statistics.Update()
    
    global cpsLabel, wpsLabel, clickLabel, keyLabel, peakCPSLabel, peakWPSLabel
    global progressBar1, progressBar2
    
    cpsLabel.Text := "CPS: " AppState.avgCPS
    wpsLabel.Text := "WPS: " AppState.avgWPS
    clickLabel.Text := "Clicks: " AppState.clicks
    keyLabel.Text := "Keys: " AppState.keys
    peakCPSLabel.Text := "Peak: " AppState.peakCPS
    peakWPSLabel.Text := "WPeak: " AppState.peakWPS
    
    ; Animate progress bars
    progressBar1.Value := Mod(A_TickCount / 20, 100)
    progressBar2.Value := Mod(A_TickCount / 30, 100)
}

UpdateSessionTimer() {
    global timerLabel
    
    if !AppState.running && !AppState.paused
        return
    
    elapsed := (A_TickCount - AppState.sessionStart) / 1000
    timerLabel.Text := "⏱ " FormatDuration(elapsed)
}

UpdateStatus(text, color) {
    global statusLabel
    statusLabel.Text := text
    statusLabel.SetFont("c" SubStr(color, 3))
}

ResetDisplays() {
    global cpsLabel, wpsLabel, progressBar1, progressBar2
    
    cpsLabel.Text := "CPS: --"
    wpsLabel.Text := "WPS: --"
    progressBar1.Value := 0
    progressBar2.Value := 0
}

; ══════════════════════════════════════════════════════════════════════════
; THEME SELECTOR
; ══════════════════════════════════════════════════════════════════════════
OpenThemeSelector() {
    themeGui := Gui("+AlwaysOnTop -DPIScale +Owner" myGui.Hwnd, "🎨 Theme Selector v5.0")
    themeGui.BackColor := "0x0a0a0a"
    themeGui.SetFont("s10 cFFFFFF", "Segoe UI")
    
    themeGui.SetFont("s15 Bold c00ffff", "Segoe UI")
    themeGui.Add("Text", "x20 y15 w560 Center", "═══ PREMIUM THEME COLLECTION ═══")
    
    themeGui.SetFont("s8 c808080", "Segoe UI")
    themeGui.Add("Text", "x20 y50 w560 Center", "Choose from 8 professionally designed color schemes")
    
    themeGui.SetFont("s9 cE0E0E0", "Segoe UI")
    yPos := 85
    
    for themeName, themeData in ThemeEngine.themes {
        ; Color preview boxes
        box1 := themeGui.Add("Text", "x30 y" yPos " w40 h40 Border Background" SubStr(themeData.accent, 3))
        box2 := themeGui.Add("Text", "x52 y" (yPos+12) " w18 h18 Border Background" SubStr(themeData.accent2, 3))
        
        ; Theme button
        btn := themeGui.Add("Button", "x80 y" yPos " w400 h40 Background" SubStr(themeData.bg, 3) " c" SubStr(themeData.text, 3), 
            "  " themeName (themeData.glow ? " ✨" : "") (themeData.gradient ? " 🌈" : ""))
        
        btn.OnEvent("Click", (*) => ApplyThemeAndClose(themeName, themeGui))
        
        ; Current indicator
        if (themeName = AppState.currentTheme) {
            themeGui.SetFont("s10 Bold cFFD700", "Segoe UI")
            themeGui.Add("Text", "x490 y" (yPos + 12) " w70 BackgroundTrans", "✓ ACTIVE")
            themeGui.SetFont("s9 cE0E0E0", "Segoe UI")
        }
        
        yPos += 50
    }
    
    themeGui.SetFont("s10 Bold cFFFFFF", "Segoe UI")
    closeBtn := themeGui.Add("Button", "x30 y" (yPos + 10) " w540 h45 Background43A047", "✓ CLOSE")
    closeBtn.OnEvent("Click", (*) => themeGui.Destroy())
    
    themeGui.Show("w600 h" (yPos + 75))
}

ApplyThemeAndClose(themeName, guiRef) {
    ThemeEngine.Apply(themeName)
    guiRef.Destroy()
    
    ; Refresh main GUI
    global myGui
    myGui.Hide()
    Sleep(50)
    myGui.Show("w700 h640")
    
    Notify("Theme Changed", "✨ " themeName " applied!", 2)
}

; ══════════════════════════════════════════════════════════════════════════
; RECORDING FUNCTIONS
; ══════════════════════════════════════════════════════════════════════════
ToggleRecording() {
    global btnRecord
    theme := ThemeEngine.GetCurrent()
    
    if !AppState.recording {
        MacroSystem.StartRecording()
        btnRecord.Text := "⏺ RECORDING"
        btnRecord.Opt("Background" SubStr(theme.error, 3))
        Notify("📹 Recording Started", "All actions will be captured", 2)
    } else {
        MacroSystem.StopRecording()
        btnRecord.Text := "📹 RECORD"
        btnRecord.Opt("Background" SubStr(theme.accent2, 3))
        Notify("⏹ Recording Stopped", MacroSystem.steps.Length " steps recorded", 2)
    }
}

; ══════════════════════════════════════════════════════════════════════════
; PROFILE MANAGER
; ══════════════════════════════════════════════════════════════════════════
OpenProfileManager() {
    profileGui := Gui("+AlwaysOnTop -DPIScale", "👤 Profile Manager Pro v5.0")
    profileGui.BackColor := "0x1a1a1a"
    profileGui.SetFont("s9 cE0E0E0", "Segoe UI")
    
    profileGui.SetFont("s14 Bold c64B5F6", "Segoe UI")
    profileGui.Add("Text", "x20 y15 w560 Center", "═══ CONFIGURATION PROFILES ═══")
    
    profileGui.SetFont("s9 c808080", "Segoe UI")
    profileGui.Add("Text", "x20 y50 w560 Center", "Quick-load optimized settings for different scenarios")
    
    profileGui.SetFont("s10 cFFFFFF", "Segoe UI")
    
    yPos := 85
    for profileName, profileData in ProfileManager.profiles {
        btn := profileGui.Add("Button", "x20 y" yPos " w560 h35 Background0x2a2a2a cE0E0E0", 
            profileName " - CPS:" profileData.cps " WPS:" profileData.wps)
        btn.OnEvent("Click", (*) => LoadProfile(profileName, profileGui))
        yPos += 40
    }
    
    profileGui.SetFont("s9 Bold cFFFFFF", "Segoe UI")
    
    profileGui.Add("Text", "x20 y" (yPos + 10) " w100 BackgroundTrans", "New Profile:")
    profileName := profileGui.Add("Edit", "x125 y" (yPos + 7) " w330 Background0x2a2a2a cE0E0E0", "Custom Profile")
    saveBtn := profileGui.Add("Button", "x465 y" (yPos + 5) " w115 h26 Background43A047", "💾 SAVE")
    
    saveBtn.OnEvent("Click", (*) => SaveNewProfile(profileName.Text, profileGui))
    
    profileGui.Show("w600 h" (yPos + 60))
}

LoadProfile(name, guiRef) {
    if ProfileManager.Apply(name) {
        guiRef.Destroy()
        Notify("Profile Loaded", "✓ " name, 2)
    }
}

SaveNewProfile(name, guiRef) {
    if (name != "" && name != "Custom Profile") {
        ProfileManager.SaveCurrent(name)
        guiRef.Destroy()
        Notify("Profile Saved", "✓ " name, 2)
    }
}

; ══════════════════════════════════════════════════════════════════════════
; STATISTICS WINDOW
; ══════════════════════════════════════════════════════════════════════════
OpenStatistics() {
    statsGui := Gui("+AlwaysOnTop -DPIScale", "📊 Performance Analytics v5.0")
    statsGui.BackColor := "0x0a0a0a"
    statsGui.SetFont("s9 cE0E0E0", "Segoe UI")
    
    statsGui.SetFont("s15 Bold c00ff41", "Consolas")
    statsGui.Add("Text", "x20 y15 w660 Center", "═══ PERFORMANCE DASHBOARD ═══")
    
    statsGui.SetFont("s9 c808080", "Segoe UI")
    statsGui.Add("Text", "x20 y50 w660 Center", "Real-time analytics and historical tracking")
    
    statsGui.SetFont("s10 c00ff41", "Consolas")
    
    ; Session metrics
    elapsed := (AppState.sessionStart > 0) ? (A_TickCount - AppState.sessionStart) / 1000 : 0
    
    statsGui.Add("Text", "x20 y85 w210 h25 Background0x121212 Border Center", "SESSION DURATION")
    statsGui.Add("Text", "x20 y115 w210 h45 Center Background0x1a1a1a c00ff41", FormatDuration(elapsed))
    
    statsGui.Add("Text", "x245 y85 w210 h25 Background0x121212 Border Center", "TOTAL ACTIONS")
    statsGui.Add("Text", "x245 y115 w210 h45 Center Background0x1a1a1a c00ff41", AppState.clicks + AppState.keys)
    
    statsGui.Add("Text", "x470 y85 w210 h25 Background0x121212 Border Center", "DATA POINTS")
    statsGui.Add("Text", "x470 y115 w210 h45 Center Background0x1a1a1a c00ff41", Statistics.history.Length)
    
    ; Performance stats
    statsGui.Add("Text", "x20 y180 w155 h25 Background0x121212 Border Center", "PEAK CPS")
    statsGui.Add("Text", "x20 y210 w155 h40 Center Background0x1a1a1a cff006e", Round(AppState.peakCPS, 2))
    
    statsGui.Add("Text", "x190 y180 w155 h25 Background0x121212 Border Center", "AVG CPS")
    statsGui.Add("Text", "x190 y210 w155 h40 Center Background0x1a1a1a cffea00", Round(AppState.avgCPS, 2))
    
    statsGui.Add("Text", "x360 y180 w155 h25 Background0x121212 Border Center", "PEAK WPS")
    statsGui.Add("Text", "x360 y210 w155 h40 Center Background0x1a1a1a cff006e", Round(AppState.peakWPS, 2))
    
    statsGui.Add("Text", "x530 y180 w150 h25 Background0x121212 Border Center", "AVG WPS")
    statsGui.Add("Text", "x530 y210 w150 h40 Center Background0x1a1a1a cffea00", Round(AppState.avgWPS, 2))
    
    ; Graph placeholder
    statsGui.SetFont("s8 c808080", "Segoe UI")
    graphText := "`n`n`nPERFORMANCE VISUALIZATION`n`n"
    graphText .= "Tracking " Statistics.history.Length " data points`n"
    graphText .= "Session uptime: " Round(elapsed / 60, 2) " minutes`n"
    graphText .= "Total clicks: " AppState.clicks " | Total keys: " AppState.keys
    
    statsGui.Add("Text", "x20 y270 w660 h180 Border Background0x1a1a1a Center", graphText)
    
    ; Action buttons
    statsGui.SetFont("s10 Bold cFFFFFF", "Segoe UI")
    exportBtn := statsGui.Add("Button", "x20 y470 w210 h40 Background64B5F6", "📤 EXPORT CSV")
    resetBtn := statsGui.Add("Button", "x245 y470 w210 h40 BackgroundE53935", "🔄 RESET ALL")
    closeBtn := statsGui.Add("Button", "x470 y470 w210 h40 Background43A047", "✓ CLOSE")
    
    exportBtn.OnEvent("Click", (*) => ExportStats(statsGui))
    resetBtn.OnEvent("Click", (*) => ResetStats(statsGui))
    closeBtn.OnEvent("Click", (*) => statsGui.Destroy())
    
    statsGui.Show("w700 h530 Center")
}

ExportStats(guiRef) {
    filename := Statistics.Export()
    if filename != "" {
        Notify("📤 Export Complete", "Saved as: " filename, 3)
    } else {
        Notify("❌ Export Failed", "Could not save file", 3)
    }
}

ResetStats(guiRef) {
    AppState.clicks := 0
    AppState.keys := 0
    AppState.peakCPS := 0
    AppState.peakWPS := 0
    Statistics.history := []
    guiRef.Destroy()
    Notify("🔄 Stats Reset", "All statistics cleared", 2)
}

; ══════════════════════════════════════════════════════════════════════════
; MACRO MANAGER
; ══════════════════════════════════════════════════════════════════════════
OpenMacroManager() {
    macroGui := Gui("+AlwaysOnTop -DPIScale", "🎬 Macro Manager v5.0")
    macroGui.BackColor := "0x1a1a1a"
    macroGui.SetFont("s9 cE0E0E0", "Segoe UI")
    
    macroGui.SetFont("s14 Bold c00ff41", "Segoe UI")
    macroGui.Add("Text", "x20 y15 w560 Center", "═══ MACRO STUDIO ═══")
    
    macroGui.SetFont("s9 cBDBDBD", "Segoe UI")
    macroGui.Add("Text", "x20 y55 w560", "Record and replay complex automation sequences")
    
    macroGui.SetFont("s11 Bold cFFFFFF", "Segoe UI")
    recordBtn := macroGui.Add("Button", "x20 y90 w270 h50 BackgroundFF5252", "● START RECORDING")
    playBtn := macroGui.Add("Button", "x310 y90 w270 h50 Background43A047", "▶ REPLAY MACRO")
    
    recordBtn.OnEvent("Click", (*) => (ToggleRecording(), macroGui.Destroy()))
    playBtn.OnEvent("Click", (*) => PlayAndClose(macroGui))
    
    macroGui.SetFont("s9 cE0E0E0", "Segoe UI")
    macroGui.Add("Text", "x20 y155 w560 h25 Background0x2a2a2a Center", 
        "Recorded Steps: " MacroSystem.steps.Length " | Saved Macros: " MacroSystem.savedMacros.Count)
    
    listBox := macroGui.Add("ListBox", "x20 y185 w560 h220 Background0x2a2a2a cE0E0E0")
    
    if MacroSystem.steps.Length > 0 {
        steps := []
        for step in MacroSystem.steps {
            if step.type = "click"
                steps.Push("🖱 Click " step.data " at (" step.x ", " step.y ") - " step.time "ms")
            else
                steps.Push("⌨ Key '" step.data "' - " step.time "ms")
        }
        listBox.Add(steps)
    } else {
        listBox.Add(["No macro recorded. Press 'START RECORDING' to begin."])
    }
    
    macroGui.SetFont("s9 Bold cFFFFFF", "Segoe UI")
    saveBtn := macroGui.Add("Button", "x20 y420 w180 h40 Background64B5F6", "💾 SAVE MACRO")
    loadBtn := macroGui.Add("Button", "x210 y420 w180 h40 Background64B5F6", "📂 LOAD MACRO")
    clearBtn := macroGui.Add("Button", "x400 y420 w180 h40 BackgroundE53935", "🗑 CLEAR")
    
    clearBtn.OnEvent("Click", (*) => (MacroSystem.steps := [], macroGui.Destroy(), Notify("Cleared", "Macro cleared", 1)))
    
    macroGui.Show("w600 h480 Center")
}

PlayAndClose(guiRef) {
    global modeChoice
    modeChoice.Choose(4)
    guiRef.Destroy()
    AutomationEngine.Start()
}

; ══════════════════════════════════════════════════════════════════════════
; HELP WINDOW
; ══════════════════════════════════════════════════════════════════════════
OpenHelp() {
    helpGui := Gui("+AlwaysOnTop -DPIScale", "❓ Help & Documentation v5.0")
    helpGui.BackColor := "0x0a0a0a"
    helpGui.SetFont("s9 cE0E0E0", "Segoe UI")
    
    helpGui.SetFont("s16 Bold c00ffff", "Segoe UI")
    helpGui.Add("Text", "x20 y20 w660 Center", "⚡ HYPERCLICKER ULTRA PRO v5.0")
    
    helpGui.SetFont("s10 cff00ff", "Segoe UI")
    helpGui.Add("Text", "x20 y55 w660 Center", "Supreme Edition - Complete Documentation")
    
    helpGui.SetFont("s9 c808080", "Segoe UI")
    helpGui.Add("Text", "x20 y85 w660 Center", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    helpGui.SetFont("s9 cE0E0E0", "Segoe UI")
    helpText := "
    (
🚀 QUICK START GUIDE:

1. Select automation mode (Clicker, Typer, Both, or Macro)
2. Configure speed (CPS = Clicks Per Second, WPS = Words Per Second)
3. Press START or hotkey (\) to begin
4. ESC for immediate emergency stop

⚡ NEW IN v5.0 SUPREME EDITION:

✨ Class-Based Architecture - Professional code organization
🎨 8 Premium Themes - Quantum, Tokyo Night, Dracula, Monokai & more
📊 Advanced Statistics - CSV export, history tracking, analytics
🌊 Micro Jitter - Ultra-realistic movement simulation
🎯 Enhanced Profiles - Gaming, Productivity, Speed Test presets
📹 Improved Macros - Position recording, better replay system
⚙ Better Controls - More options, finer precision
🎨 Modern UI - Cleaner design, better spacing, pro aesthetics

🎮 HOTKEYS:

\ (Backslash) - Toggle Start/Stop
F10 - Toggle sound effects
ESC - Emergency stop all automation
Ctrl+Alt+R - Toggle macro recording

💡 PRO TIPS:

• Use "Smart Human Delay" + "Micro Jitter" for natural automation
• Save custom profiles for quick switching between tasks
• Export statistics to track performance over time
• Combine randomization with pattern variation for best results
    )"
    
    helpGui.Add("Text", "x20 y115 w660", helpText)
    
    helpGui.SetFont("s8 c808080", "Segoe UI")
    helpGui.Add("Text", "x20 y500 w660", "⚡ Built with advanced AutoHotkey v2.0 | Optimized for performance")
    
    helpGui.SetFont("s10 Bold cFFFFFF", "Segoe UI")
    closeBtn := helpGui.Add("Button", "x20 y530 w660 h40 Background43A047", "✓ GOT IT!")
    closeBtn.OnEvent("Click", (*) => helpGui.Destroy())
    
    helpGui.Show("w700 h590 Center")
}

; ══════════════════════════════════════════════════════════════════════════
; TEMPLATES
; ══════════════════════════════════════════════════════════════════════════
ShowTemplates() {
    templateGui := Gui("+AlwaysOnTop -DPIScale", "📋 Text Templates v5.0")
    templateGui.BackColor := "0x1a1a1a"
    templateGui.SetFont("s9 cE0E0E0", "Segoe UI")
    
    templateGui.SetFont("s13 Bold c64B5F6", "Segoe UI")
    templateGui.Add("Text", "x20 y15 w560 Center", "═══ QUICK TEXT TEMPLATES ═══")
    
    templates := [
        "Welcome to HyperClicker Ultra Pro v5.0 Supreme Edition!",
        "The quick brown fox jumps over the lazy dog",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789",
        "abcdefghijklmnopqrstuvwxyz",
        "!@#$%^&*()_+-=[]{}|;:',.<>?/~``",
        "Testing automation... 123... 456... 789...",
        "Automated message generated by HyperClicker v5.0",
        "Hello World! This is an automated typing test.",
        "Pack my box with five dozen liquor jugs"
    ]
    
    templateGui.SetFont("s9 cFFFFFF", "Segoe UI")
    yPos := 55
    for template in templates {
        btn := templateGui.Add("Button", "x20 y" yPos " w560 h30 Background0x2a2a2a cE0E0E0", 
            SubStr(template, 1, 70) (StrLen(template) > 70 ? "..." : ""))
        btn.OnEvent("Click", (*) => LoadTemplate(template, templateGui))
        yPos += 35
    }
    
    templateGui.Show("w600 h" (yPos + 10))
}

LoadTemplate(template, guiRef) {
    global txtInput
    txtInput.Value := template
    guiRef.Destroy()
    Notify("Template Loaded", "✓ Ready to type", 1)
}

; ══════════════════════════════════════════════════════════════════════════
; UTILITY FUNCTIONS
; ══════════════════════════════════════════════════════════════════════════
ToggleSound() {
    global btnSound
    theme := ThemeEngine.GetCurrent()
    
    AppState.soundOn := !AppState.soundOn
    btnSound.Text := AppState.soundOn ? "🔊 SOUND" : "🔇 MUTE"
    btnSound.Opt("Background" (AppState.soundOn ? SubStr(theme.panel, 3) : SubStr(theme.error, 3)))
    
    Notify(AppState.soundOn ? "🔊 Sound On" : "🔇 Sound Off", "", 1)
}

ToggleStartStop() {
    if AppState.running || AppState.paused
        AutomationEngine.Stop()
    else
        AutomationEngine.Start()
}

FormatDuration(seconds) {
    hours := Floor(seconds / 3600)
    minutes := Floor(Mod(seconds, 3600) / 60)
    secs := Floor(Mod(seconds, 60))
    return Format("{:02d}:{:02d}:{:02d}", hours, minutes, secs)
}

Notify(title, message, duration := 2) {
    if AppState.showNotifications
        TrayTip(title, message, duration)
}

; ══════════════════════════════════════════════════════════════════════════
; TRAY MENU
; ══════════════════════════════════════════════════════════════════════════
A_IconTip := "HyperClicker Ultra Pro v5.0 Supreme"
TraySetIcon("shell32.dll", 44)

A_TrayMenu.Delete()
A_TrayMenu.Add("🖥 Show/Hide", (*) => ToggleGui())
A_TrayMenu.Add("▶ Start", (*) => AutomationEngine.Start())
A_TrayMenu.Add("■ Stop", (*) => AutomationEngine.Stop())
A_TrayMenu.Add("⏸ Pause", (*) => AutomationEngine.TogglePause())
A_TrayMenu.Add()
A_TrayMenu.Add("🎨 Themes", (*) => OpenThemeSelector())
A_TrayMenu.Add("📊 Statistics", (*) => OpenStatistics())
A_TrayMenu.Add("📹 Record Macro", (*) => ToggleRecording())
A_TrayMenu.Add("👤 Profiles", (*) => OpenProfileManager())
A_TrayMenu.Add()
A_TrayMenu.Add("❓ Help", (*) => OpenHelp())
A_TrayMenu.Add("❌ Exit", (*) => ExitApp())
A_TrayMenu.Default := "🖥 Show/Hide"

ToggleGui() {
    if WinExist("HyperClicker Ultra Pro v5.0 ⚡") {
        if WinActive()
            WinHide()
        else {
            WinShow()
            WinActivate()
        }
    }
}

; ══════════════════════════════════════════════════════════════════════════
; HOTKEYS
; ══════════════════════════════════════════════════════════════════════════
Hotkey(AppState.hotkeyToggle, (*) => ToggleStartStop(), "On")
Hotkey(AppState.hotkeySound, (*) => ToggleSound(), "On")
Hotkey("Esc", (*) => EmergencyStop(), "On")
Hotkey("^!r", (*) => ToggleRecording(), "On")

EmergencyStop() {
    if AppState.running || AppState.paused {
        AutomationEngine.Stop()
        Notify("🚨 EMERGENCY STOP", "All automation halted!", 3)
    }
}

; ══════════════════════════════════════════════════════════════════════════
; SESSION LOGGING
; ══════════════════════════════════════════════════════════════════════════
SaveSessionLog() {
    if !DirExist("Logs")
        DirCreate("Logs")
    
    elapsed := (A_TickCount - AppState.sessionStart) / 1000
    timestamp := FormatTime(A_Now, "yyyy-MM-dd_HHmmss")
    filename := "Logs\Session_" timestamp ".log"
    
    logContent := "
    (
═══════════════════════════════════════════════════════════
HyperClicker Ultra Pro v5.0 Supreme Edition - Session Log
═══════════════════════════════════════════════════════════
Session ID: " GenerateSessionID() "
Date: " FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") "
Duration: " FormatDuration(elapsed) "
Theme: " AppState.currentTheme "
Profile: " AppState.currentProfile "

PERFORMANCE METRICS:
─────────────────────────────────────
Total Clicks: " AppState.clicks "
Total Keys: " AppState.keys "
Total Actions: " (AppState.clicks + AppState.keys) "

Average CPS: " Round(AppState.avgCPS, 2) "
Average WPS: " Round(AppState.avgWPS, 2) "
Peak CPS: " Round(AppState.peakCPS, 2) "
Peak WPS: " Round(AppState.peakWPS, 2) "

DATA TRACKING:
─────────────────────────────────────
History Data Points: " Statistics.history.Length "
Macro Steps Recorded: " MacroSystem.steps.Length "
Saved Macros: " MacroSystem.savedMacros.Count "
═══════════════════════════════════════════════════════════
    )"
    
    try {
        FileAppend(logContent, filename)
        Notify("💾 Log Saved", "Session exported: " filename, 3)
        return true
    } catch as err {
        Notify("❌ Error", "Failed to save: " err.Message, 3)
        return false
    }
}

GenerateSessionID() {
    return Format("{:08X}-{:04X}-{:04X}", A_TickCount, Random(0, 65535), Random(0, 65535))
}

; ══════════════════════════════════════════════════════════════════════════
; EXIT HANDLER
; ══════════════════════════════════════════════════════════════════════════
OnExit(SaveOnExit)

SaveOnExit(ExitReason, ExitCode) {
    if AppState.autoSaveEnabled && (AppState.clicks > 0 || AppState.keys > 0) {
        result := MsgBox(
            "Save session log before exiting?`n`n" 
            "Clicks: " AppState.clicks " | Keys: " AppState.keys "`n"
            "Duration: " FormatDuration((A_TickCount - AppState.sessionStart) / 1000),
            "HyperClicker Ultra Pro v5.0",
            "YesNo Icon? 32"
        )
        if (result = "Yes")
            SaveSessionLog()
    }
}

; ══════════════════════════════════════════════════════════════════════════
; INITIALIZATION COMPLETE
; ══════════════════════════════════════════════════════════════════════════
Notify("HyperClicker v5.0", "✨ Supreme Edition Ready! Press " AppState.hotkeyToggle " to start.", 3)