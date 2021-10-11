unit F_StatAnim;

interface

uses
  Windows, Messages, CommCtrl, F_Windows;

procedure CreateAnimateStaticW(hWnd: HWND);
procedure RemoveAnimateStaticW(hWnd: HWND);

const
  SS_SETIMAGELIST   = WM_USER + 101;
  SS_SETELAPSEDTIME = WM_USER + 102;
  SS_GETIMAGELIST   = WM_USER + 111;
  SS_GETELAPSEDTIME = WM_USER + 112;

implementation

const
  IDC_ANIMATETIMER = 101;

type
  TStatWndProc = function(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

  P_STAT_PRO = ^T_STAT_PRO;
  T_STAT_PRO = packed record
    StatProc  : TStatWndProc;
    rcClient  : TRect;
    //
    hdcMem    : HDC;
    hbmMem    : HBITMAP;
    hbmOld    : HBITMAP;
    //
    himl      : HIMAGELIST;
    //
    imgSize   : Integer;
    imgCount  : Integer;
    imgCurrent: Integer;
    //
    dwElapse  : Integer;
  end;

var
  psp: P_STAT_PRO;

//

function StatWndProc_OnWmSize(psp: P_STAT_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  hdcIn: HDC;
begin

  //

  GetClientRect(hWnd, psp.rcClient);

  //

  if (psp.hdcMem <> 0) then
    begin
      SelectObject(psp.hdcMem, psp.hbmOld);
      DeleteObject(psp.hbmMem);
      DeleteDC(psp.hdcMem);
    end;

  //

  hdcIn := GetDC(hWnd);
  psp.hdcMem := CreateCompatibleDC(hdcIn);
  psp.hbmMem := CreateCompatibleBitmap(
    hdcIn,
    psp.rcClient.Right - psp.rcClient.Left,
    psp.rcClient.Bottom - psp.rcClient.Top
  );
  psp.hbmOld := SelectObject(psp.hdcMem, psp.hbmMem);
  ReleaseDC(hWnd, hdcIn);

  //

  Result := CallWindowProcW(@psp.StatProc, hWnd, uMsg, wParam, lParam);

  //

  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);

end;

//

function StatWndProc_OnWmPaint(psp: P_STAT_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

var
  hdcIn: HDC;
  ps   : TPaintStruct;
begin

  //

  if (wParam = 0) then
    hdcIn := BeginPaint(hWnd, ps)
  else
    hdcIn := wParam;

  //

  CallWindowProcW(@psp.StatProc, hWnd, WM_PRINTCLIENT, psp.hdcMem, PRF_CLIENT);

  {
  CallWindowProcW(@psp.StatProc, hWnd, WM_ERASEBKGND, psp.hdcMem, 0);
  }

  if (psp.himl <> 0) then
    ImageList_DrawEx(
      psp.himl,
      psp.imgCurrent - 1,
      psp.hdcMem,
      psp.rcClient.Left + ((psp.rcClient.Right - psp.rcClient.Left) div 2) - (psp.imgSize div 2),
      psp.rcClient.Top + ((psp.rcClient.Bottom - psp.rcClient.Top) div 2) - (psp.imgSize div 2),
      psp.imgSize,
      psp.imgSize,
      CLR_DEFAULT,
      CLR_DEFAULT,
      ILD_NORMAL or ILD_TRANSPARENT
    );

  BitBlt(
    hdcIn,
    0,
    0,
    psp.rcClient.Right - psp.rcClient.Left,
    psp.rcClient.Bottom - psp.rcClient.Top,
    psp.hdcMem,
    0,
    0,
    SRCCOPY
  );

  //

  if (wParam = 0) then
    EndPaint(hWnd, ps);

  //

  Result := 0;

end;

//

function StatWndProc_OnWmTimer(psp: P_STAT_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin

  //

  Inc(psp.imgCurrent);
  if (psp.imgCurrent > psp.imgCount) then
    psp.imgCurrent := 1;

  //

  RedrawWindow(hWnd, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE);

  //

  Result := 0;

end;

//

function StatWndProc_OnWmEraseBkgnd(psp: P_STAT_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin

  //

  Result := 1;

end;

//

function StatWndProc_OnSetImageList(psp: P_STAT_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin

  //

  KillTimer(hWnd, IDC_ANIMATETIMER);

  //

  psp.himl := HIMAGELIST(wParam);

  //


  if (psp.himl <> 0) then
    begin

      ImageList_GetIconSize(psp.himl, psp.imgSize, psp.imgSize);
      psp.imgCount := ImageList_GetImageCount(psp.himl);
      SetTimer(hWnd, IDC_ANIMATETIMER, psp.dwElapse, nil);

    end;

  //

  Result := 0;

end;

//

function StatWndProc_OnSetElapsedTime(psp: P_STAT_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin

  //

  KillTimer(hWnd, IDC_ANIMATETIMER);

  //

  psp.dwElapse := wParam;

  //

  SetTimer(hWnd, IDC_ANIMATETIMER, psp.dwElapse, nil);


  //

  Result := 0;

end;

//

function StatWndProc_OnGetImageList(psp: P_STAT_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin

  //

  Result := LRESULT(psp.himl);

end;

//

function StatWndProc_OnGetElapsedTime(psp: P_STAT_PRO; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin

  //

  Result := LRESULT(psp.dwElapse);

end;

//

function StatWndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin

  psp := P_STAT_PRO(GetWindowLongW(hWnd, GWL_USERDATA));

  if (psp = nil) then
    begin
      Result := DefWindowProcW(hWnd, uMsg, wParam, lParam);
      Exit;
    end;

  case uMsg of

    //

    WM_DESTROY:
      begin
        RemoveAnimateStaticW(hWnd);
      end;

    //

    WM_SIZE:
      begin
        Result := StatWndProc_OnWmSize(psp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_PRINTCLIENT,
    WM_PAINT,
    WM_UPDATEUISTATE: // перерисовка окна без вызова WM_PAINT.
      begin
        Result := StatWndProc_OnWmPaint(psp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_TIMER:
      begin
        Result := StatWndProc_OnWmTimer(psp, hWnd, uMsg, wParam, lParam);
      end;

    //

    WM_ERASEBKGND:
      begin
        Result := StatWndProc_OnWmEraseBkgnd(psp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SS_SETIMAGELIST:
      begin
        Result := StatWndProc_OnSetImageList(psp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SS_SETELAPSEDTIME:
      begin
        Result := StatWndProc_OnSetElapsedTime(psp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SS_GETIMAGELIST:
      begin
        Result := StatWndProc_OnGetImageList(psp, hWnd, uMsg, wParam, lParam);
      end;

    //

    SS_GETELAPSEDTIME:
      begin
        Result := StatWndProc_OnGetElapsedTime(psp, hWnd, uMsg, wParam, lParam);
      end;

    else
      Result := CallWindowProcW(@psp.StatProc, hWnd, uMsg, wParam, lParam);
  end;

end;

//

procedure CreateAnimateStaticW(hWnd: HWND);
begin

  RemoveAnimateStaticW(hWnd);

  psp := P_STAT_PRO(HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, SizeOf(T_STAT_PRO)));
  ZeroMemory(psp, SizeOf(T_STAT_PRO));

  psp.StatProc   := TStatWndProc(Pointer(GetWindowLongW(hWnd, GWL_WNDPROC)));
  psp.himl       := 0;
  psp.imgSize    := 0;
  psp.imgCount   := 0;
  psp.imgCurrent := 0;
  psp.dwElapse   := 50;

  KillTimer(hWnd, IDC_ANIMATETIMER);

  SetWindowLongW(hWnd, GWL_USERDATA, Longint(psp));

  SetWindowLongW(hWnd, GWL_WNDPROC, Longint(@StatWndProc));

  SendMessageW(hWnd, WM_SIZE, 0, 0);

end;

//

procedure RemoveAnimateStaticW(hWnd: HWND);
begin

  psp := P_STAT_PRO(GetWindowLongW(hWnd, GWL_USERDATA));
  if (psp <> nil) then
    begin

      //

      if (psp.hdcMem <> 0) then
        begin
          SelectObject(psp.hdcMem, psp.hbmOld);
          DeleteObject(psp.hbmMem);
          DeleteDC(psp.hdcMem);
        end;

      //

      KillTimer(hWnd, IDC_ANIMATETIMER);

      //

      SetWindowLongW(hWnd, GWL_WNDPROC, Longint(@psp.StatProc));
      RedrawWindow(hWnd, @psp.rcClient, 0, RDW_INVALIDATE or RDW_ERASE);

      SetWindowLongW(hWnd, GWL_USERDATA, 0);
      HeapFree(GetProcessHeap, 0, psp);

    end;

end;

end.