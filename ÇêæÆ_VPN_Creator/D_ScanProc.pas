unit D_ScanProc;

interface

uses
  Windows, Messages, CommCtrl, WinSock, F_SysUtils, F_StatAnim, F_Resources;

function ScanDlgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;

implementation

//

function ThreadCallback(LpParameter: Pointer): DWORD; stdcall;
type
  TaPInAddr = Array [0..MAX_PATH-1] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  pszText: WideString;
  pszUTF8: AnsiString;
  dwErr  : DWORD;
  phe    : PHostEnt;
  addr   : PaPInAddr;
  ws     : TWSAData;
  i      : Integer;
begin

  //

  Result := 0;

  //

  SetThreadPriority(hThread, THREAD_PRIORITY_BELOW_NORMAL);

  //

  dwErr := WSAStartup(MAKEWORD(1, 0), ws);
  if (dwErr = NOERROR) then
  try
    pszUTF8 := WideStringToAnsi(pszServ, CP_ACP);
    phe := GetHostByName(@pszUTF8[1]);
    if (phe <> nil) then
    begin
      addr := PaPInAddr(phe^.h_addr_list);
      i := 0;
      SendMessageW(GetDlgItem(hApp[1], IDC_COMBO_SERVER), CB_RESETCONTENT, 0, 0);
      SendMessageW(GetDlgItem(hApp[1], IDC_COMBO_SERVER), CB_ADDSTRING, 0,
        Integer(@pszServ[1]));
      while (addr^[I] <> nil) do
      begin
        pszUTF8 := inet_ntoa(addr[I]^);
        pszText := AnsiStringToWide(pszUTF8, CP_ACP);
        SendMessageW(GetDlgItem(hApp[1], IDC_COMBO_SERVER), CB_ADDSTRING, 0,
          Integer(@pszText[1]));
        pszText := FormatW(LoadStrInstW(hInstance, RC_STRING_IPHOST), [pszText]);
        SendMessageW(GetDlgItem(hApp[3], IDC_STATIC_ADDRESS), WM_SETTEXT, 0,
          Integer(@pszText[1]));
        Inc(i);
        Sleep(35);
      end;
      SendMessageW(GetDlgItem(hApp[1], IDC_COMBO_SERVER), CB_SETCURSEL, 0, 0);
    end;
  finally
    WSACleanup;
  end;

  //

  SendMessageW(hApp[3], WM_DESTROY, 0, 0);

end;

//

function ScanDlgProc_OnWmInitDialog(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  pszText : WideString;
  ThreadID: LongWord;
  himl    : HIMAGELIST;
begin

  //

  hApp[3] := hWnd;

  //

  SetCenterDialogPos(hApp[3], hApp[1], TRUE);

  //

  pszText := FormatW(LoadStrInstW(hInstance, RC_STRING_IPSERVER), [pszServ]);
  SendMessageW(GetDlgItem(hApp[3], IDC_STATIC_ADDRESS), WM_SETTEXT, 0,
    Integer(@pszText[1]));

  //

  CreateAnimateStaticW(GetDlgItem(hApp[3], IDC_STATIC_ANIMATE));
  himl := ImageList_LoadImageW(hInstance, MAKEINTRESOURCEW(RC_BITMAP_WAITING),
    GetSystemMetrics(SM_CXSMICON), 0, CLR_DEFAULT, IMAGE_BITMAP, LR_DEFAULTCOLOR
    or LR_CREATEDIBSECTION);
  if (himl <> 0) then
    SendMessageW(GetDlgItem(hApp[3], IDC_STATIC_ANIMATE), SS_SETIMAGELIST, himl,
      0);

  //

  hThread := CreateThread(nil, 0, @ThreadCallback, nil, 0, ThreadID);
  if (hThread <> 0) then
    begin
      CloseHandle(hThread);
      hThread := 0;
    end;

  //

  Result := 0;

end;

//

function ScanDlgProc_OnWmDestroy(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  himl: HIMAGELIST;
begin

  //

  if (hThread <> 0) then
    begin
      CloseHandle(hThread);
      hThread := 0;
    end;

  //

  himl := SendMessageW(GetDlgItem(hApp[3], IDC_STATIC_ANIMATE), SS_GETIMAGELIST,
    0, 0);
  if (himl <> 0) then
    ImageList_Destroy(himl);
  RemoveAnimateStaticW(GetDlgItem(hApp[3], IDC_STATIC_ANIMATE));

  //

  EndDialog(hApp[3], wParam);

  //

  Result := 0;

end;

//

function ScanDlgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
begin

  case uMsg of

    //

    WM_INITDIALOG:
      begin
        Result := BOOL(ScanDlgProc_OnWmInitDialog(hWnd, uMsg, wParam, lParam));
      end;

    //

    WM_DESTROY:
      begin
        Result := BOOL(ScanDlgProc_OnWmDestroy(hWnd, uMsg, wParam, lParam));
      end;

  else
    Result := FALSE;
  end;

end;

end.