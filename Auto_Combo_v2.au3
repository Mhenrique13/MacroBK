#RequireAdmin
#include <GUIConstantsEx.au3>
#include <Misc.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>

Global $configFile = @ScriptDir & "\config.ini"
Global $comboAtivo = False
Global $ultimoEstadoCombo = -1

; Carrega configurações do ini
Global $t1_a = "100", $t2_a = "100", $t3_a = "100", $ordemCombo = "123"
If FileExists($configFile) Then
    $t1_a = IniRead($configFile, "Label1", "Skill1_Skill2", "100")
    $t2_a = IniRead($configFile, "Label1", "Skill2_Skill3", "100")
    $t3_a = IniRead($configFile, "Label1", "DelayFinal", "100")
    $ordemCombo = IniRead($configFile, "Label1", "OrdemCombo", "123")
EndIf

; GUI
Global $gui = GUICreate("Auto Combo BeyBlade", 350, 300, -1, -1, $WS_OVERLAPPEDWINDOW)
GUISetBkColor(0x1E1E1E)

Global $hTab = GUICtrlCreateTab(10, 10, 330, 240)
Global $tab1 = GUICtrlCreateTabItem("HELPER")

GUICtrlCreateLabel("Tempo Skill 1 - 2 (ms):", 20, 40, 180, 20)
Global $input1_a = GUICtrlCreateInput($t1_a, 210, 35, 100, 22, $ES_CENTER)
GUICtrlSetBkColor($input1_a, 0x2D2D30)
GUICtrlSetColor($input1_a, 0xFFFFFF)

GUICtrlCreateLabel("Tempo Skill 2 - 3 (ms):", 20, 75, 180, 20)
Global $input2_a = GUICtrlCreateInput($t2_a, 210, 70, 100, 22, $ES_CENTER)
GUICtrlSetBkColor($input2_a, 0x2D2D30)
GUICtrlSetColor($input2_a, 0xFFFFFF)

GUICtrlCreateLabel("Delay após Skill 3 (ms):", 20, 110, 180, 20)
Global $input3_a = GUICtrlCreateInput($t3_a, 210, 105, 100, 22, $ES_CENTER)
GUICtrlSetBkColor($input3_a, 0x2D2D30)
GUICtrlSetColor($input3_a, 0xFFFFFF)

GUICtrlCreateLabel("Ordem do Combo (2 a 5 dígitos):", 20, 145, 200, 20)
Global $inputOrdem = GUICtrlCreateInput($ordemCombo, 210, 140, 100, 22, $ES_CENTER)
GUICtrlSetBkColor($inputOrdem, 0x2D2D30)
GUICtrlSetColor($inputOrdem, 0xFFFFFF)

; Checkbox para ativar combo
Global $chkCombo1 = GUICtrlCreateCheckbox("Ativar Combo", 20, 175, 150, 20)
GUICtrlSetColor($chkCombo1, 0xCCCCCC)
GUICtrlSetFont($chkCombo1, 9, 400, 0, "Segoe UI")
GUICtrlSetState($chkCombo1, $GUI_UNCHECKED)

GUICtrlCreateTabItem("")

Global $lblStatus = GUICtrlCreateLabel("Combo: Desativado | F5: Liga/Desliga | F10: Sair", 10, 260, 320, 20, $SS_CENTER)
GUICtrlSetColor($lblStatus, 0xCCCCCC)
GUICtrlSetFont($lblStatus, 9, 400, 0, "Segoe UI")

GUISetState(@SW_SHOW)

; Hotkeys
HotKeySet("{F5}", "AlternarCombo")
HotKeySet("{F10}", "FecharScript")

; Loop principal
While 1
    $nMsg = GUIGetMsg()
    If $nMsg = $GUI_EVENT_CLOSE Then FecharScript()

    ; Habilitar/desabilitar campos apenas quando o estado muda
    Local $estadoAtual = GUICtrlRead($chkCombo1)
    If $estadoAtual <> $ultimoEstadoCombo Then
        If $estadoAtual = $GUI_CHECKED Then
            GUICtrlSetState($input1_a, $GUI_DISABLE)
            GUICtrlSetState($input2_a, $GUI_DISABLE)
            GUICtrlSetState($input3_a, $GUI_DISABLE)
            GUICtrlSetState($inputOrdem, $GUI_DISABLE)
        Else
            GUICtrlSetState($input1_a, $GUI_ENABLE)
            GUICtrlSetState($input2_a, $GUI_ENABLE)
            GUICtrlSetState($input3_a, $GUI_ENABLE)
            GUICtrlSetState($inputOrdem, $GUI_ENABLE)
        EndIf
        $ultimoEstadoCombo = $estadoAtual
    EndIf

    ; Executar combo
    If $comboAtivo And $estadoAtual = $GUI_CHECKED And _IsPressed("02") Then
        Local $v1 = GUICtrlRead($input1_a)
        Local $v2 = GUICtrlRead($input2_a)
        Local $v3 = GUICtrlRead($input3_a)
        Local $ordem = GUICtrlRead($inputOrdem)

        If Not StringIsInt($v1) Or Not StringIsInt($v2) Or Not StringIsInt($v3) Then
            GUICtrlSetData($lblStatus, "Erro: insira apenas números válidos")
            ContinueLoop
        EndIf

        If Not StringRegExp($ordem, "^[123]{2,5}$") Then
            GUICtrlSetData($lblStatus, "Erro: ordem deve ter 2 a 5 dígitos entre 1 e 3")
            ContinueLoop
        EndIf

        ExecutarCombo(Int($v1), Int($v2), Int($v3), $ordem)
        Sleep(10)
    EndIf

    Sleep(10)
WEnd

Func AlternarCombo()
    $comboAtivo = Not $comboAtivo

    Local $status = $comboAtivo ? "Ativado" : "Desativado"
    WinSetTitle($gui, "", "BeyBlade - " & $status)
    TrayTip("BeyBlade", "Combo " & StringLower($status), 1)
    GUICtrlSetData($lblStatus, "Combo: " & $status & " | F5: Liga/Desliga | F10: Sair")
EndFunc

Func ExecutarCombo($d1, $d2, $d3, $ordem)
    Local $delays[3] = [$d1, $d2, $d3]
    Local $teclas[3] = ["{1}", "{2}", "{3}"]

    For $i = 1 To StringLen($ordem)
        Local $indice = Int(StringMid($ordem, $i, 1)) - 1
        If $indice >= 0 And $indice <= 2 Then
            Send($teclas[$indice])
            If $i < StringLen($ordem) Then Sleep($delays[Mod($i - 1, 3)])
        EndIf
    Next
EndFunc

Func SalvarConfiguracao()
    IniWrite($configFile, "Label1", "Skill1_Skill2", GUICtrlRead($input1_a))
    IniWrite($configFile, "Label1", "Skill2_Skill3", GUICtrlRead($input2_a))
    IniWrite($configFile, "Label1", "DelayFinal", GUICtrlRead($input3_a))
    IniWrite($configFile, "Label1", "OrdemCombo", GUICtrlRead($inputOrdem))
    IniWrite($configFile, "Config", "ComboAtivo", $comboAtivo ? "1" : "0")
EndFunc

Func FecharScript()
    SalvarConfiguracao()
    Exit
EndFunc
