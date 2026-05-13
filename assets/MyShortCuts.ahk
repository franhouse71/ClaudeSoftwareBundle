#Requires AutoHotkey v2.0

Numpad1::OpenColoredTab()

OpenColoredTab() {
    colors := ["#E74C3C", "#3498DB", "#2ECC71", "#F39C12", "#9B59B6",
               "#1ABC9C", "#E67E22", "#E91E63", "#00BCD4", "#8BC34A",
               "#FF5722", "#607D8B", "#795548", "#009688", "#673AB7",
               "#2196F3", "#4CAF50", "#FFC107", "#FF9800", "#9C27B0"]

    regKey := "HKCU\Software\MyAHKShortcuts"
    index := RegRead(regKey, "TabColorIndex", 0)

    color := colors[Mod(index, colors.Length) + 1]

    RegWrite index + 1, "REG_DWORD", regKey, "TabColorIndex"

    Run('wt new-tab --tabColor "' color '" -p "Windows PowerShell" powershell.exe -NoExit -Command "clauded"')
}