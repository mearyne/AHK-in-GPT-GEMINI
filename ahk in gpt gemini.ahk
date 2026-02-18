; ==============================================================================
; 1. 관리자 권한 강제 실행 및 환경 설정
; ==============================================================================
full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

#NoEnv
#SingleInstance Force
SetTitleMatchMode, 2 
SetWorkingDir, %A_ScriptDir%
FileEncoding, UTF-8

HistoryFile := A_ScriptDir . "\history.txt"
if !FileExist(HistoryFile)
    FileAppend, , %HistoryFile%

; ==============================================================================
; 2. GUI 생성
; ==============================================================================
Gui, -DPIScale
Gui, Font, s10, Malgun Gothic

Gui, Add, Text, w600, [Prompt Input] (Enter: New Line / Shift+Enter: Search)
Gui, Add, Edit, vUserPrompt w600 r6 +Multi, 

Gui, Add, Checkbox, vUseGemini Checked, Gemini
Gui, Add, Checkbox, vUseGPT Checked x+10, ChatGPT
Gui, Add, Checkbox, vAlwaysNew x+20, [NEW] 무조건 새 탭 사용

; [수정] Enter 키로 버튼이 눌리지 않도록 Default 옵션 제거
Gui, Add, Button, gStartSearch xm w120 h40, Dual Search
Gui, Add, Button, gClearInput x+10 w120 h40, Clear

Gui, Add, Text, xm w600, [History List] (Ctrl/Shift+Click for Multi-select)
Gui, Add, ListView, r12 w520 vHistoryLV gLVEvent AltSubmit, Fav|Time|Prompt

Gui, Add, Button, gToggleFav x+10 yp+20 w80 h40, Favorite`n(On/Off)
Gui, Add, Button, gEditHistory wp h40, Edit`nSelected
Gui, Add, Button, gCopySelected wp h40, Copy`nSelected
Gui, Add, Button, gDeleteSelected wp h40, Delete`nSelected

Gui, Show, w630 h690 Center, Dual Search Helper
Gosub, LoadHistory
return 

; ==============================================================================
; 3. 실행 레이블 (Label) 및 단축키 영역
; ==============================================================================

; [추가] GUI 내에서 Shift + Enter 입력 시 검색 실행
#IfWinActive, Dual Search Helper
+Enter:: Gosub, StartSearch
#IfWinActive

F1::
    Gui, Show, w630 h690 Center, Dual Search Helper
    WinActivate, Dual Search Helper
return

StartSearch:
    Gui, Submit, NoHide
    if (UserPrompt = "")
        return
    
    if (!UseGemini && !UseGPT) 
    {
        MsgBox, 48, 알림, 검색할 사이트를 선택해주세요.
        return
    }

    FormatTime, CurrentTime, %A_Now%, yyyy-MM-dd HH:mm
    LV_Insert(1, "", "", CurrentTime, UserPrompt)
    Gosub, SaveHistoryToFile
    SearchValue := UserPrompt
    Gosub, WebSearchLogic
return

WebSearchLogic:
    if !WinExist("ahk_exe msedge.exe")
    {
        Run, msedge.exe
        WinWait, ahk_exe msedge.exe,, 10
        JustStarted := true 
        IsFirstTab := true  
        Sleep, 1000 
    }
    else
    {
        JustStarted := false
        IsFirstTab := false
    }
    
    WinActivate, ahk_exe msedge.exe
    WinWaitActive, ahk_exe msedge.exe,, 3

    IsFirstAction := EdgeWasNotRunning

    if (UseGemini) 
    {
        ExecuteSearch("Gemini", "gemini.google.com", "https://gemini.google.com/app", AlwaysNew, IsFirstTab, JustStarted, SearchValue)
        Sleep, 600 
    }

    if (UseGPT) 
    {
        ExecuteSearch("ChatGPT", "chatgpt.com", "https://chatgpt.com/", AlwaysNew, IsFirstTab, JustStarted, SearchValue)
    }
return

DeleteSelected:
    SelectedCount := 0
    RowNumber := 0
    Loop
    {
        RowNumber := LV_GetNext(RowNumber)
        if not RowNumber
            break
        SelectedCount++
    }
    if (SelectedCount = 0)
        return
    MsgBox, 36, 삭제 확인, 선택한 %SelectedCount%개의 항목을 일괄 삭제하시겠습니까?
    IfMsgBox, No
        return
    Loop
    {
        RowNumber := LV_GetNext(0)
        if not RowNumber
            break
        LV_Delete(RowNumber)
    }
    Gosub, SaveHistoryToFile
return

LVEvent:
    if (A_GuiEvent = "DoubleClick") 
    {
        LV_GetText(SearchValue, A_EventInfo, 3)
        if (SearchValue != "") 
        {
            Gui, Submit, NoHide
            Gosub, WebSearchLogic
        }
    }
return

EditHistory:
    Row := LV_GetNext(0)
    if (Row = 0)
        return
    LV_GetText(OldText, Row, 3)
    GuiControl,, UserPrompt, %OldText%
    GuiControl, Focus, UserPrompt
return

CopySelected:
    Row := LV_GetNext(0)
    if (Row = 0)
        return
    LV_GetText(CurrentText, Row, 3)
    Clipboard := CurrentText
return

ToggleFav:
    Row := LV_GetNext(0)
    if (Row = 0)
        return
    LV_GetText(isFav, Row, 1)
    if (isFav = "★")
        LV_Modify(Row, "Col1", "")
    else
        LV_Modify(Row, "Col1", "★")
    Gosub, SaveHistoryToFile
    Gosub, LoadHistory
return

ClearInput:
    GuiControl,, UserPrompt, 
return

LoadHistory:
    Gui, ListView, HistoryLV
    LV_Delete()
    if FileExist(HistoryFile) 
    {
        FileRead, FullContent, %HistoryFile%
        if (!ErrorLevel) 
        {
            FavList := [], NormalList := []
            Loop, Parse, FullContent, `n, `r 
            {
                if (A_LoopField = "")
                    continue
                DataArray := StrSplit(A_LoopField, "|")
                timePart := DataArray[1], favPart := DataArray[2], contentPart := DataArray[3]
                Display := StrReplace(contentPart, "<br>", "`n")
                if (favPart = "1")
                    FavList.Push({time: timePart, content: Display})
                else
                    NormalList.Push({time: timePart, content: Display})
            }
            For idx, item in NormalList
                LV_Insert(1, "", "", item.time, item.content)
            For idx, item in FavList
                LV_Insert(1, "", "★", item.time, item.content)
        }
    }
    LV_ModifyCol(1, 40)
    LV_ModifyCol(2, 120)
    LV_ModifyCol(3, 340)
return

SaveHistoryToFile:
    FileDelete, %HistoryFile%
    Count := LV_GetCount()
    Loop, % Count 
    {
        Idx := Count - A_Index + 1
        LV_GetText(isFav, Idx, 1)
        LV_GetText(timeVal, Idx, 2)
        LV_GetText(contentVal, Idx, 3)
        favFlag := (isFav = "★") ? "1" : "0"
        contentSave := StrReplace(contentVal, "`n", "<br>")
        contentSave := StrReplace(contentSave, "`r", "")
        FileAppend, %timeVal%|%favFlag%|%contentSave%`n, %HistoryFile%
    }
return

GuiClose:
GuiEscape:
    Gui, Hide
return

; ==============================================================================
; 4. 함수(Function) 정의
; ==============================================================================

ExecuteSearch(Keyword, UrlSnippet, TargetUrl, ForceNew, ByRef FirstTab, JustStarted, Prompt) 
{
    Found := false
    
    if (!ForceNew && !JustStarted && !FirstTab) 
    {
        Loop, 5 
        {
            WinGetTitle, CurrentTitle, ahk_exe msedge.exe
            if (InStr(CurrentTitle, Keyword)) 
            {
                Found := true
                break
            }
            
            Clipboard := ""
            Send, ^l
            Sleep, 100 
            Send, ^c
            ClipWait, 0.3 
            
            if (InStr(Clipboard, UrlSnippet)) 
            {
                Found := true
                Send, {Esc} 
                Sleep, 100 
                break
            }
            Send, {Esc} 
            Sleep, 50 
            Send, ^{Tab}
            Sleep, 200 
        }
    }

    if (!Found) 
    {
        if (FirstTab) 
        {
            Send, ^l
            FirstTab := false 
        } 
        else 
        {
            Send, ^t
            Sleep, 250 
            Send, ^l
        }
        Clipboard := TargetUrl
        ClipWait, 1
        Send, ^v{Enter}
        Sleep, 1500 
    }

    Send, {Esc}
    Sleep, 250 
    
    Clipboard := ""
    Clipboard := Prompt
    ClipWait, 1
    Sleep, 300 
    
    Send, ^a{Backspace} 
    Sleep, 100 
    Send, ^v
    Sleep, 250 
    Send, {Enter}
}