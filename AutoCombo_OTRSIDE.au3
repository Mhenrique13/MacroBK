#RequireAdmin
#include <GUIConstantsEx.au3>
#include <Misc.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#Compiler_Icon=otr.ico

Global $configFile = @ScriptDir & "\config.ini"
Global $comboAtivo = False
Global $comboAtivoIndex = "1"
Global $comboCount = 0
Global $disparoTecla4Apos = 4

; Impede que ESC feche o programa
HotKeySet("{ESC}", "_IgnorarESC")
Func _IgnorarESC()
    ; Não faz nada
EndFunc

; Carrega INI
If FileExists($configFile) Then
    $t1_a = IniRead($configFile, "Label1", "Skill1_Skill2", "100")
    $t2_a = IniRead($configFile, "Label1", "Skill2_Skill3", "100")
    $t3_a = IniRead($configFile, "Label1", "DelayFinal", "100")
    $t1_b = IniRead($configFile, "Label2", "Skill1_Skill2", "100")
    $t2_b = IniRead($configFile, "Label2", "Skill2_Skill3", "100")
    $t3_b = IniRead($configFile, "Label2", "DelayFinal", "100")
    $comboAtivoIndex = IniRead($configFile, "Config", "ComboAtivo", "1")
    $disparoTecla4Apos = IniRead($configFile, "Config", "DisparoTecla4Apos", "4")
EndIf

; GUI
Global $gui = GUICreate("COMBO BK OTRSIDE ", 350, 290, -1, -1, $WS_OVERLAPPEDWINDOW)
GUISetBkColor(0x1E1E1E)

Global $hTab = GUICtrlCreateTab(10, 10, 330, 220)

GUICtrlCreateTabItem("PVP - 1")
GUICtrlCreateLabel("Tempo Skill 1 - 2 (ms):", 20, 40)
Global $input1_a = GUICtrlCreateInput($t1_a, 210, 35, 100, 22, $ES_CENTER)
GUICtrlCreateLabel("Tempo Skill 2 - 3 (ms):", 20, 75)
Global $input2_a = GUICtrlCreateInput($t2_a, 210, 70, 100, 22, $ES_CENTER)
GUICtrlCreateLabel("Delay após Skill 3 (ms):", 20, 110)
Global $input3_a = GUICtrlCreateInput($t3_a, 210, 105, 100, 22, $ES_CENTER)
Global $chkCombo1 = GUICtrlCreateCheckbox("Ativar Combo", 20, 140, 150, 20)
GUICtrlCreateLabel("Disparar tecla 4 a cada (combos):", 20, 170)
Global $inputDisparo4 = GUICtrlCreateInput($disparoTecla4Apos, 210, 165, 100, 22, $ES_CENTER)

GUICtrlCreateTabItem("PVP  - 2")
GUICtrlCreateLabel("Tempo Skill 1 - 2 (ms):", 20, 40)
Global $input1_b = GUICtrlCreateInput($t1_b, 210, 35, 100, 22, $ES_CENTER)
GUICtrlCreateLabel("Tempo Skill 2 - 3 (ms):", 20, 75)
Global $input2_b = GUICtrlCreateInput($t2_b, 210, 70, 100, 22, $ES_CENTER)
GUICtrlCreateLabel("Delay após Skill 3 (ms):", 20, 110)
Global $input3_b = GUICtrlCreateInput($t3_b, 210, 105, 100, 22, $ES_CENTER)
Global $chkCombo2 = GUICtrlCreateCheckbox("Ativar Combo 2", 20, 140, 150, 20)

GUICtrlCreateTabItem("")
Global $lblStatus = GUICtrlCreateLabel("F5: Ativa Combo | F10: Sair", 10, 250, 320, 20, $SS_CENTER)

GUICtrlSetState($chkCombo1, $GUI_UNCHECKED)
GUICtrlSetState($chkCombo2, $GUI_UNCHECKED)
_GUICtrlSetInputsEnabled(True)

GUISetState(@SW_SHOW)

HotKeySet("{F5}", "AlternarCombo")
HotKeySet("{F10}", "FecharScript")

While 1
    $nMsg = GUIGetMsg()
    If $nMsg = $GUI_EVENT_CLOSE Then FecharScript()

    If GUICtrlRead($chkCombo1) = $GUI_CHECKED Then
        GUICtrlSetState($chkCombo2, $GUI_UNCHECKED)
        $comboAtivoIndex = "1"
    ElseIf GUICtrlRead($chkCombo2) = $GUI_CHECKED Then
        GUICtrlSetState($chkCombo1, $GUI_UNCHECKED)
        $comboAtivoIndex = "2"
    EndIf

    If $comboAtivo And (GUICtrlRead($chkCombo1) = $GUI_CHECKED Or GUICtrlRead($chkCombo2) = $GUI_CHECKED) And _IsPressed("02") Then
        Local $v1, $v2, $v3
        If $comboAtivoIndex = "1" Then
            $v1 = GUICtrlRead($input1_a)
            $v2 = GUICtrlRead($input2_a)
            $v3 = GUICtrlRead($input3_a)
        Else
            $v1 = GUICtrlRead($input1_b)
            $v2 = GUICtrlRead($input2_b)
            $v3 = GUICtrlRead($input3_b)
        EndIf

        If Not StringIsInt($v1) Or Not StringIsInt($v2) Or Not StringIsInt($v3) Then
            MsgBox(16, "Erro", "Por favor, insira apenas números válidos.")
            ContinueLoop
        EndIf

        ExecutarCombo(Int($v1), Int($v2), Int($v3))
        $comboCount += 1

        Local $maxComboDisparo = GUICtrlRead($inputDisparo4)
        If Not StringIsInt($maxComboDisparo) Or $maxComboDisparo <= 0 Then
            $maxComboDisparo = 4
        EndIf

        If $comboCount >= $maxComboDisparo Then
            Sleep(15)
            Send("{4}")
            $comboCount = 0
        EndIf

        Sleep(10)
    EndIf

    Sleep(50)
WEnd

Func AlternarCombo()
    $comboAtivo = Not $comboAtivo

    If $comboAtivo Then
        _GUICtrlSetInputsEnabled(False)
        WinSetTitle($gui, "", "COMBO OTRSIDE - Ativado")
        TrayTip("OTRSIDE", "Combo ativado", 1)
    Else
        _GUICtrlSetInputsEnabled(True)
        WinSetTitle($gui, "", "COMBO OTRSIDE - Desativado")
        TrayTip("OTRSIDE", "Combo desativado", 1)
    EndIf
EndFunc

Func ExecutarCombo($d1, $d2, $d3)
    Send("{1}")
    Sleep($d1)
    Send("{2}")
    Sleep($d2)
    Send("{3}")
    Sleep($d3)
    Send("{1}")
    Sleep(15)
EndFunc

Func SalvarConfiguracao()
    IniWrite($configFile, "Label1", "Skill1_Skill2", GUICtrlRead($input1_a))
    IniWrite($configFile, "Label1", "Skill2_Skill3", GUICtrlRead($input2_a))
    IniWrite($configFile, "Label1", "DelayFinal", GUICtrlRead($input3_a))
    IniWrite($configFile, "Label2", "Skill1_Skill2", GUICtrlRead($input1_b))
    IniWrite($configFile, "Label2", "Skill2_Skill3", GUICtrlRead($input2_b))
    IniWrite($configFile, "Label2", "DelayFinal", GUICtrlRead($input3_b))
    IniWrite($configFile, "Config", "ComboAtivo", $comboAtivoIndex)
    IniWrite($configFile, "Config", "DisparoTecla4Apos", GUICtrlRead($inputDisparo4))
EndFunc

Func FecharScript()
    SalvarConfiguracao()
    Exit
EndFunc

Func _GUICtrlSetInputsEnabled($enabled)
    Local $state = $enabled ? $GUI_ENABLE : $GUI_DISABLE
    GUICtrlSetState($input1_a, $state)
    GUICtrlSetState($input2_a, $state)
    GUICtrlSetState($input3_a, $state)
    GUICtrlSetState($input1_b, $state)
    GUICtrlSetState($input2_b, $state)
    GUICtrlSetState($input3_b, $state)
    GUICtrlSetState($inputDisparo4, $state)
EndFunc
