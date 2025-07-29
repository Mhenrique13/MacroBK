#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>

Global $delay1 = 100, $delay2 = 100, $delay3 = 100, $delay4 = 100
Global $comboAtivo = False
Global $selectedWinHandle = ""

; Cria GUI
$hGUI = GUICreate("Combo AutoIt - Selecionar Janela", 400, 220)
GUICtrlCreateLabel("Selecione a janela SkyMU:", 10, 10, 380, 20)

; Listbox para janelas
$lbWins = GUICtrlCreateList("", 10, 35, 380, 120)

; Botão para atualizar lista
$btnRefresh = GUICtrlCreateButton("Atualizar Lista", 10, 160, 180, 30)
; Botão para confirmar seleção
$btnSelect = GUICtrlCreateButton("Selecionar Janela", 210, 160, 180, 30)

; Botão toggle combo
$btnToggle = GUICtrlCreateButton("Ativar Combo (F5)", 10, 195, 380, 25)

GUISetState(@SW_SHOW, $hGUI)

; Popula lista na inicialização
_ListWindows()

; Registra timer para verificar input sem travar GUI
AdlibRegister("CheckInput", 10)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $btnRefresh
            _ListWindows()
        Case $btnSelect
            Local $selIndex = GUICtrlRead($lbWins)
            If $selIndex = "" Then
                MsgBox(48, "Aviso", "Selecione uma janela antes de confirmar.")
            Else
                $selectedWinHandle = StringSplit($selIndex, "|")[1] ; pega handle da janela
                TrayTip("Janela Selecionada", "Janela selecionada para combo.", 3)
            EndIf
        Case $btnToggle
            $comboAtivo = Not $comboAtivo
            If $comboAtivo Then
                GUICtrlSetData($btnToggle, "Desativar Combo (F5)")
                TrayTip("Combo Ativado", "Combo ativado!", 3)
            Else
                GUICtrlSetData($btnToggle, "Ativar Combo (F5)")
                TrayTip("Combo Desativado", "Combo desativado!", 3)
            EndIf
    EndSwitch
    Sleep(10)
WEnd

Func _ListWindows()
    GUICtrlSetData($lbWins, "") ; limpa listbox
    Local $aList = WinList()
    For $i = 1 To $aList[0][0]
        If StringInStr($aList[$i][0], "SkyMU - S20 Part") Then
            ; Exibe no formato: Título | Handle (hex)
            Local $strItem = $aList[$i][0] & " | " & Hex($aList[$i][1], 8)
            GUICtrlSetData($lbWins, $strItem, 1)
        EndIf
    Next
EndFunc

Func CheckInput()
    ; Toggle F5 via tecla também
    If _IsKeyPressed(0x74) Then ; F5
        $comboAtivo = Not $comboAtivo
        If $comboAtivo Then
            GUICtrlSetData($btnToggle, "Desativar Combo (F5)")
            TrayTip("Combo Ativado", "Combo ativado!", 3)
        Else
            GUICtrlSetData($btnToggle, "Ativar Combo (F5)")
            TrayTip("Combo Desativado", "Combo desativado!", 3)
        EndIf
        Sleep(300)
    EndIf

    If $comboAtivo And _IsRightMousePressed() And $selectedWinHandle <> "" Then
        If WinExists(HexToDec($selectedWinHandle)) Then
            SendCombo(HexToDec($selectedWinHandle))
        EndIf
    EndIf
EndFunc

Func SendCombo($hWnd)
    ; Ativa janela pelo handle
    WinActivate($hWnd)
    Local $active = WinWaitActive($hWnd, "", 2000)
    If $active = 0 Then
        TrayTip("Erro", "Não foi possível ativar a janela alvo!", 3)
        Return
    EndIf

    Send("1")
    Sleep($delay1)
    Send("2")
    Sleep($delay2)
    Send("3")
    Sleep($delay3)
    Send("2")
    Sleep($delay4)
EndFunc

Func _IsRightMousePressed()
    Return BitAND(_WinAPI_GetAsyncKeyState(0x02), 0x8000) <> 0
EndFunc

Func _IsKeyPressed($vKey)
    Return BitAND(_WinAPI_GetAsyncKeyState($vKey), 0x8000) <> 0
EndFunc

Func _WinAPI_GetAsyncKeyState($vKey)
    Return DllCall("user32.dll", "short", "GetAsyncKeyState", "int", $vKey)[0]
EndFunc

Func HexToDec($hex)
    Return Number("0x" & $hex)
EndFunc
