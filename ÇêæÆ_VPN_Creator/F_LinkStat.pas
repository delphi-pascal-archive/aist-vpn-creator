unit F_LinkStat;

{******************************************************************************}
{                                                                              }
{ Проект             : Static Subclass Hyperlink                               }
{ Последнее изменение: 07.01.2010                                              }
{ Авторские права    : © Мельников Максим Викторович, 2010                     }
{ Электронная почта  : maks1509@inbox.ru                                       }
{                                                                              }
{******************************************************************************}
{                                                                              }
{ Эта программа является свободным программным обеспечением. Вы можете         }
{ распространять и/или модифицировать её согласно условиям Стандартной         }
{ Общественной Лицензии GNU, опубликованной Фондом Свободного Программного     }
{ Обеспечения, версии 3 или, по Вашему желанию, любой более поздней версии.    }
{                                                                              }
{ Эта программа распространяется в надежде, что она будет полезной, но БЕЗ     }
{ ВСЯКИХ ГАРАНТИЙ, в том числе подразумеваемых гарантий ТОВАРНОГО СОСТОЯНИЯ    }
{ ПРИ ПРОДАЖЕ и ГОДНОСТИ ДЛЯ ОПРЕДЕЛЁННОГО ПРИМЕНЕНИЯ. Смотрите Стандартную    }
{ Общественную Лицензию GNU для получения дополнительной информации.           }
{                                                                              }
{ Вы должны были получить копию Стандартной Общественной Лицензии GNU          }
{ вместе с программой. В случае её отсутствия, посмотрите                      }
{ http://www.gnu.org/copyleft/gpl.html                                         }
{                                                                              }
{******************************************************************************}

interface

uses
  Windows, Messages, CommCtrl, F_Windows;

const
  //
  SCM_EX_SETHOVERCLR  = WM_USER + 101; // установить цвет для наведенного состояния.
  SCM_EX_SETNORMALCLR = WM_USER + 102; // установить цвет для обычного состояния.
  SCM_EX_SETPRESSCLR  = WM_USER + 103; // установить цвет для нажатого состояния.
  SCM_EX_SETBCKGNDCLR = WM_USER + 104; // установить цвет для фона текста.
  SCM_EX_SETTIPTEXT   = WM_USER + 105; // установить текст всплывающей подсказки.
  //
  SCM_EX_GETHOVERCLR  = WM_USER + 111; // получить цвет для наведенного состояния.
  SCM_EX_GETNORMALCLR = WM_USER + 112; // получить цвет для обычного состояния.
  SCM_EX_GETPRESSCLR  = WM_USER + 113; // получить цвет для нажатого состояния.
  SCM_EX_GETBCKGNDCLR = WM_USER + 114; // получить цвет для фона текста.
  SCM_EX_GETTIPTEXT   = WM_USER + 115; // получить текст всплывающей подсказки.

// создание элемента управления Hyperlink.

procedure CreateStaticHyperlinkW(hWnd: HWND);

// удаление элемента управления Hyperlink.

procedure RemoveStaticHyperlinkW(hWnd: HWND);

implementation

type
  TLinkWndProc = function(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

  P_LINK_PRO = ^T_LINK_PRO;
  T_LINK_PRO = packed record
    LinkProc  : TLinkWndProc;
    hCursor   : HCURSOR;
    hFont     : HFONT;
    rcClient  : TRect;
    //
    clrHover  : TColorRef;
    clrNormal : TColorRef;
    clrPress  : TColorRef;
    clrBckgnd : TColorRef; // CLR_NONE
    pszText   : Array [0..MAX_PATH-1] of WideChar;
    //
    bIsHover  : Boolean;
    bIsPress  : Boolean;
    bIsEnabled: Boolean;
    //
    hToolTip  : HWND;
    ti        : TToolInfoW;
    pszToolTip: Array [0..MAX_PATH-1] of WideChar;
    //
    dtStyle   : DWORD;
    //
    hdcMem    : HDC;
    hbmMem    : HBITMAP;
    hbmOld    : HBITMAP;
  end;

var
  plp: P_LINK_PRO;

//

function LinkWndProc_OnSetHoverClr(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  plp.clrHover := TColorRef(wParam);
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  //
  Result := 0;
end;

//

function LinkWndProc_OnGetHoverClr(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  //
  Result := LRESULT(plp.clrHover);
end;

//

function LinkWndProc_OnSetNormalClr(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  plp.clrNormal := TColorRef(wParam);
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  //
  Result := 0;
end;

//

function LinkWndProc_OnGetNormalClr(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  //
  Result := LRESULT(plp.clrNormal);
end;

//

function LinkWndProc_OnSetPressClr(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  plp.clrPress := TColorRef(wParam);
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  //
  Result := 0;
end;

//

function LinkWndProc_OnGetPressClr(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  //
  Result := LRESULT(plp.clrPress);
end;

//

function LinkWndProc_OnSetBckgdClr(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  plp.clrBckgnd := TColorRef(wParam);
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  //
  Result := 0;
end;

//

function LinkWndProc_OnGetBckgdClr(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  //
  Result := LRESULT(plp.clrBckgnd);
end;

//

function LinkWndProc_OnSetTipText(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  lstrcpynW(plp.pszToolTip, PWideChar(wParam), wParam);
  //
  Result := 0;
end;

//

function LinkWndProc_OnGetTipText(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  //
  lstrcpynW(PWideChar(lParam), plp.pszToolTip, lstrlenW(plp.pszToolTip) + 1);
  //
  Result := 0;
end;

//

function LinkWndProc_OnWmSetFont(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  plp.hFont := HFONT(wParam);
  //
  Result := CallWindowProcW(@plp.LinkProc, hWnd, uMsg, wParam, lParam);
  //
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
end;

//

function LinkWndProc_OnWmSetText(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  ZeroMemory(@plp.pszText, SizeOf(plp.pszText));
  lstrcpynW(plp.pszText, PWideChar(lParam), lParam);
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  Result := DefWindowProcW(hWnd, uMsg, wParam, lParam);
end;

//

function LinkWndProc_OnWmEnable(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  plp.bIsEnabled := BOOL(wParam);
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  //
  Result := 0;
end;

//

function LinkWndProc_OnWmMouseLeave(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  pt: TPoint;
begin
  if IsWindow(plp.hToolTip) then
    SendMessageW(plp.hToolTip, TTM_TRACKACTIVATE, Integer(FALSE), 0);
  //
  GetCursorPos(pt);
  ScreenToClient(hWnd, pt);
  //
  plp.bIsHover := FALSE;
  plp.bIsPress := FALSE;
  //
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  //
  Result := 0;
end;

//

function LinkWndProc_OnWmMouseMove(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  tme: Windows.TTrackMouseEvent;
  pt : TPoint;
begin
  //
  GetCursorPos(pt);
  ScreenToClient(hWnd, pt);
  //
  tme.cbSize      := SizeOf(Windows.TTrackMouseEvent);
  tme.dwFlags     := TME_LEAVE;
  tme.hwndTrack   := hWnd;
  tme.dwHoverTime := HOVER_DEFAULT;
  //
  plp.bIsHover := Windows.TrackMouseEvent(tme) and PtInRect(plp.rcClient, pt);
  plp.bIsPress := {(wParam = MK_LBUTTON) and} (GetCapture = hWnd) and PtInRect(plp.rcClient, pt);
  //
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  //
  Result := 0;
end;

//

function LinkWndProc_OnWmCaptureChanged(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  plp.bIsPress := FALSE;
  //
  Result := 0;
end;

//

function LinkWndProc_OnWmNcHitTest(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  //
  Result := HTCLIENT;
end;

//

function LinkWndProc_OnWmlButtonDown(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  //
  if IsWindow(plp.hToolTip) then
    SendMessageW(plp.hToolTip, TTM_TRACKACTIVATE, Integer(FALSE), 0);
  plp.bIsPress := TRUE;
  SetFocus(hWnd);
  SetCapture(hWnd);
  //
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  //
  Result := 0;
end;

//

function LinkWndProc_OnWmlButtonUp(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  pt: TPoint;
begin
  //
  GetCursorPos(pt);
  ScreenToClient(hWnd, pt);
  if (PtInRect(plp.rcClient, pt) and (GetCapture = hWnd)) then
    SendMessageW(GetParent(hWnd), WM_COMMAND, MakeLong(GetDlgCtrlID(hWnd), STN_CLICKED), 0);
  // plp.bIsPress := FALSE;
  ReleaseCapture;
  //
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  //
  Result := 0;
end;

//

function LinkWndProc_OnWmSetCursor(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  pt: TPoint;
begin
  //
  if IsWindow(plp.hToolTip) then
    begin
      SendMessageW(plp.hToolTip, TTM_TRACKACTIVATE, Integer(TRUE), Integer(@plp.ti));
      GetCursorPos(pt);
      SendMessageW(plp.hToolTip, TTM_TRACKPOSITION, 0, MakeLong(pt.x, pt.y));
    end;
  //
  if (plp.hCursor <> 0) then
    SetCursor(plp.hCursor);
  //
  Result := 0;
end;

//

function LinkWndProc_OnWmSize(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  hdcIn: HDC;
begin
  GetClientRect(hWnd, plp.rcClient);
  //
  if (plp.hdcMem <> 0) then
    begin
      SelectObject(plp.hdcMem, plp.hbmOld);
      DeleteObject(plp.hbmMem);
      DeleteDC(plp.hdcMem);
    end;
  hdcIn := GetDC(hWnd);
  plp.hdcMem := CreateCompatibleDC(hdcIn);
  plp.hbmMem := CreateCompatibleBitmap(hdcIn, plp.rcClient.Right - plp.rcClient.Left, plp.rcClient.Bottom - plp.rcClient.Top);
  plp.hbmOld := SelectObject(plp.hdcMem, plp.hbmMem);
  ReleaseDC(hWnd, hdcIn);
  //
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  //
  Result := CallWindowProcW(@plp.LinkProc, hWnd, uMsg, wParam, lParam);
end;

//

function LinkWndProc_OnWmPaint(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  hdcIn : HDC;
  ps    : TPaintStruct;
  hbrNew: HBRUSH;
begin
  if (wParam = 0) then
    hdcIn := BeginPaint(hWnd, ps)
  else
    hdcIn := wParam;

  if (plp.clrBckgnd = CLR_DEFAULT) then
    FillRect(plp.hdcMem, plp.rcClient, HBRUSH(COLOR_BTNFACE + 1))
  else
    begin
      hbrNew := CreateSolidBrush(plp.clrBckgnd);
      FillRect(plp.hdcMem, plp.rcClient, hbrNew);
      DeleteObject(hbrNew);
    end;

  if plp.bIsEnabled then
    begin
      if (plp.bIsHover and plp.bIsPress) then
        SetTextColor(plp.hdcMem, plp.clrPress)
      else
      if (plp.bIsHover and not plp.bIsPress) then
        SetTextColor(plp.hdcMem, plp.clrHover)
      else
        SetTextColor(plp.hdcMem, plp.clrNormal);
    end
  else
    SetTextColor(plp.hdcMem, GetSysColor(COLOR_GRAYTEXT));

  SetBkMode(plp.hdcMem, TRANSPARENT);
  SetBkColor(plp.hdcMem, TRANSPARENT);

  SelectObject(plp.hdcMem, plp.hFont);

  DrawTextW(plp.hdcMem, plp.pszText, {lstrlenW(plp.pszText)}-1, plp.rcClient, plp.dtStyle);

  BitBlt(hdcIn, 0, 0, plp.rcClient.Right - plp.rcClient.Left, plp.rcClient.Bottom - plp.rcClient.Top, plp.hdcMem, 0, 0, SRCCOPY);

  if (wParam = 0) then
    EndPaint(hWnd, ps);

  Result := 0;
end;

//

function LinkWndProc_OnWmEraseBkgnd(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  if (plp.clrBckgnd <> CLR_DEFAULT) then
   begin
     FillRect(HDC(wParam), plp.rcClient, HBRUSH(COLOR_BTNFACE + 1));
     //
     Result := 1;
   end
  else
    Result := DefWindowProcW(hWnd, uMsg, wParam, lParam);
end;

//

function LinkWndProc_OnWmSysColorChange(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);
  //
  Result := 0;
end;

//

function LinkWndProc_OnWmNotify(plp: P_LINK_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  pnmh: PNMHdr;
  ptit: PToolTipTextW;
begin
  //
  pnmh := PNMHdr(lParam);
  case pnmh.code of
    TTN_NEEDTEXTW:
      begin
        ptit := PToolTipTextW(lParam);
        ptit.lpszText := plp.pszToolTip;
      end;
  end;
  //
  Result := 0;
end;

//

function LinkWndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin

  plp := P_LINK_PRO(GetWindowLongW(hWnd, GWL_USERDATA));

  if (plp = nil) then
    begin
      Result := DefWindowProcW(hWnd, uMsg, wParam, lParam);
      Exit;
    end;

  case uMsg of

    //

    SCM_EX_SETHOVERCLR:
      begin
        Result := LinkWndProc_OnSetHoverClr(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SCM_EX_GETHOVERCLR:
      begin
        Result := LinkWndProc_OnGetHoverClr(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SCM_EX_SETNORMALCLR:
      begin
        Result := LinkWndProc_OnSetNormalClr(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SCM_EX_GETNORMALCLR:
      begin
        Result := LinkWndProc_OnGetNormalClr(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SCM_EX_SETPRESSCLR:
      begin
        Result := LinkWndProc_OnSetPressClr(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SCM_EX_GETPRESSCLR:
      begin
        Result := LinkWndProc_OnGetPressClr(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SCM_EX_SETBCKGNDCLR:
      begin
        Result := LinkWndProc_OnSetBckgdClr(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SCM_EX_GETBCKGNDCLR:
      begin
        Result := LinkWndProc_OnGetBckgdClr(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SCM_EX_SETTIPTEXT:
      begin
        Result := LinkWndProc_OnSetTipText(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SCM_EX_GETTIPTEXT:
      begin
        Result := LinkWndProc_OnGetTipText(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_DESTROY:
      begin
        RemoveStaticHyperlinkW(hWnd);
      end;

    //

    WM_SETFONT:
      begin
        Result := LinkWndProc_OnWmSetFont(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_SETTEXT:
      begin
        Result := LinkWndProc_OnWmSetText(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_ENABLE:
      begin
        Result := LinkWndProc_OnWmEnable(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_MOUSELEAVE:
      begin
        Result := LinkWndProc_OnWmMouseLeave(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_MOUSEMOVE:
      begin
        Result := LinkWndProc_OnWmMouseMove(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_CAPTURECHANGED:
      begin
        Result := LinkWndProc_OnWmCaptureChanged(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_NCHITTEST:
      begin
        Result := LinkWndProc_OnWmNcHitTest(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_LBUTTONDOWN:
      begin
        Result := LinkWndProc_OnWmlButtonDown(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_LBUTTONUP:
      begin
        Result := LinkWndProc_OnWmlButtonUp(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_SETCURSOR:
      begin
        Result := LinkWndProc_OnWmSetCursor(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_SIZE:
      begin
        Result := LinkWndProc_OnWmSize(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_PRINTCLIENT,
    WM_PAINT,
    WM_UPDATEUISTATE: // перерисовка окна без вызова WM_PAINT.
      begin
        Result := LinkWndProc_OnWmPaint(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_ERASEBKGND:
      begin
        Result := LinkWndProc_OnWmEraseBkgnd(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_SYSCOLORCHANGE:
      begin
        Result := LinkWndProc_OnWmSysColorChange(plp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_NOTIFY:
      begin
        Result := LinkWndProc_OnWmNotify(plp, hWnd, uMsg, wParam, lParam);
      end;

    else
      Result := CallWindowProcW(@plp.LinkProc, hWnd, uMsg, wParam, lParam);
  end;

end;

//

procedure CreateStaticHyperlinkW(hWnd: HWND);
var
  iccex  : TInitCommonControlsEx;
  dtStyle: DWORD;
  dwLen  : Integer;
begin

  InitCommonControls;
  iccex.dwSize := SizeOf(TInitCommonControlsEx);
  iccex.dwICC  := ICC_BAR_CLASSES;
  InitCommonControlsEx(iccex);

  RemoveStaticHyperlinkW(hWnd);

  plp := P_LINK_PRO(HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, SizeOf(T_LINK_PRO)));

  ZeroMemory(plp, SizeOf(plp));
  plp.LinkProc   := TLinkWndProc(Pointer(GetWindowLongW(hWnd, GWL_WNDPROC)));
  plp.hCursor    := LoadImageW(0, MAKEINTRESOURCEW(IDC_HAND), IMAGE_CURSOR, 0, 0, LR_SHARED or LR_DEFAULTSIZE);

  plp.hFont      := SendMessageW(hWnd, WM_GETFONT, 0, 0);

  GetClientRect(hWnd, plp.rcClient);

  plp.clrHover   := RGB(255, 0, 0);
  plp.clrNormal  := RGB(0, 0, 255);
  plp.clrPress   := RGB(0, 0, 128);
  plp.clrBckgnd  := CLR_DEFAULT;

  dwLen := SendMessageW(hWnd, WM_GETTEXTLENGTH, 0, 0);
  if (dwLen > 0) then
    begin
      ZeroMemory(@plp.pszText, SizeOf(plp.pszText));
      SendMessageW(hWnd, WM_GETTEXT, SizeOf(plp.pszText), Integer(@plp.pszText));
    end;

  plp.bIsHover   := FALSE;
  plp.bIsPress   := FALSE;
  plp.bIsEnabled := IsWindowEnabled(hWnd);

  plp.hToolTip   := CreateWindowExW(WS_EX_TOPMOST, TOOLTIPS_CLASS, nil, WS_POPUP or TTS_NOPREFIX or TTS_ALWAYSTIP, Integer(CW_USEDEFAULT), Integer(CW_USEDEFAULT), Integer(CW_USEDEFAULT), Integer(CW_USEDEFAULT), GetParent(hWnd), 0, hInstance, nil);
  if IsWindow(plp.hToolTip) then
    begin
      plp.ti.cbSize   := SizeOf(TToolInfoW);
      plp.ti.uFlags   := TTF_SUBCLASS or TTF_IDISHWND;
      plp.ti.hwnd     := hWnd;
      plp.ti.uId      := hWnd;
      plp.ti.lpszText := LPSTR_TEXTCALLBACKW;
      SetRectEmpty(plp.ti.Rect);
      ZeroMemory(@plp.pszToolTip, SizeOf(plp.pszToolTip));
      SendMessageW(plp.hToolTip, TTM_ADDTOOLW, 0, Integer(@plp.ti));
    end;

  dtStyle := GetWindowLongW(hWnd, GWL_STYLE);

  case (dtStyle and SS_TYPEMASK) of
    SS_LEFT          : plp.dtStyle := DT_LEFT or DT_EXPANDTABS {or DT_WORDBREAK};
    SS_CENTER        : plp.dtStyle := DT_CENTER or DT_EXPANDTABS {or DT_WORDBREAK};
    SS_RIGHT         : plp.dtStyle := DT_RIGHT or DT_EXPANDTABS {or DT_WORDBREAK};
    SS_SIMPLE        : plp.dtStyle := DT_LEFT or DT_SINGLELINE;
    SS_LEFTNOWORDWRAP: plp.dtStyle := DT_LEFT or DT_EXPANDTABS;
  end;
  if ((dtStyle and SS_CENTERIMAGE) = 0) then
    plp.dtStyle := plp.dtStyle or DT_VCENTER;
  if ((dtStyle and SS_NOTIFY) = 0) then
    SetWindowLongW(hWnd, GWL_STYLE, dtStyle or SS_NOTIFY);

  SetWindowLongW(hWnd, GWL_USERDATA, Longint(plp));

  SetWindowLongW(hWnd, GWL_WNDPROC, Longint(@LinkWndProc));

  // так как мы создаем hdcMem заного при изменении размеров окна элемента
  // управления, то не будем здесь создавать изначально контексты, а просто
  // уведомим элемент управления сообщением об изменении размеров.

  SendMessageW(hWnd, WM_SIZE, 0, 0); // RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);

end;

//

procedure RemoveStaticHyperlinkW(hWnd: HWND);
begin

  plp := P_LINK_PRO(GetWindowLongW(hWnd, GWL_USERDATA));
  if (plp <> nil) then
    begin

      if (plp.hCursor <> 0) then
        DestroyCursor(plp.hCursor);

      plp.ti.hwnd := hWnd;
      plp.ti.uId  := hWnd;
      if IsWindow(plp.hToolTip) then
        begin
          SendMessageW(plp.hToolTip, TTM_DELTOOLW, 0, Integer(@plp.ti));
          DestroyWindow(plp.hToolTip);
        end;

      if (plp.hdcMem <> 0) then
        begin
          SelectObject(plp.hdcMem, plp.hbmOld);
          DeleteObject(plp.hbmMem);
          DeleteDC(plp.hdcMem);
        end;

      //

      SetWindowLongW(hWnd, GWL_WNDPROC, Longint(@plp.LinkProc));
      RedrawWindow(hWnd, @plp.rcClient, 0, RDW_INVALIDATE or RDW_ERASE);

      SetWindowLongW(hWnd, GWL_USERDATA, 0);
      HeapFree(GetProcessHeap, 0, plp);

    end;

end;

end.