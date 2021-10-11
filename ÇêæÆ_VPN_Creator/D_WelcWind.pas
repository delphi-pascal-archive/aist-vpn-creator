unit D_WelcWind;

interface

uses
  Windows, Messages, CommCtrl, F_WinSvc, F_FileInfo, F_SysUtils, F_MyMsgBox,
  F_Resources;

function WelcDlgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;

implementation

//

function WelcDlgProc_OnWmInitDialog(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  bldfnt: HFONT;
begin

  //

  hApp[0] := hWnd;

  //

  bldfnt := GetWindowBoldFontW(hApp[0], GetWindowFontSizeW(hApp[0], 12));

  if (bldfnt <> 0) then
    SendMessageW(GetDlgItem(hApp[0], IDC_STATIC_WELCOME), WM_SETFONT,
      Integer(bldfnt), Integer(TRUE));

  //

  SetCenterDialogPos(GetParent(hApp[0]), 0, FALSE);

  //

  Result := 0;

end;

//

function WelcDlgProc_OnWmNotify(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  pnmh : PNMHdr;
  dwRes: DWORD;
  bRes : Boolean;

  //

  function IsRasManRunning: Boolean;
  var
    schSCManager : SC_HANDLE;
    schService   : SC_HANDLE;
    ssStatus     : TServiceStatusProcess;
    dwBytesNeeded: DWORD;
    pszService   : PWideChar;
  begin
    Result := FALSE;
    schSCManager := OpenSCManagerW(nil, nil, SC_MANAGER_ALL_ACCESS);
    if (schSCManager <> 0) then
    try
      pszService := 'RasMan';
      schService := OpenServiceW(schSCManager, pszService, SERVICE_QUERY_STATUS);
      if (schService <> 0) then
      try
        QueryServiceStatusEx(
          schService,
          SC_STATUS_PROCESS_INFO,
          @ssStatus,
          SizeOf(SERVICE_STATUS_PROCESS),
          dwBytesNeeded
        );
        Result := ssStatus.dwCurrentState = SERVICE_RUNNING;
      finally
        CloseServiceHandle(schService);
      end;
    finally
      CloseServiceHandle(schSCManager);
    end;

end;

begin

  //

  pnmh := PNMHdr(lParam);

  case pnmh.code of

    //

    PSN_WIZNEXT:
    begin

      bRes := not IsRasManRunning;
      if bRes then
        ExtMessageBoxW(
          GetParent(hApp[0]),
          MAKEINTRESOURCEW(LoadStrInstW(hInstance, RC_STRING_RESMAN)),
          MAKEINTRESOURCEW(exeInfo.pszProductName),
          MB_OK or MB_ICONSTOP
        );
      SetWindowLongW(hApp[0], DWL_MSGRESULT, Integer(bRes));

    end;

    //

    PSN_SETACTIVE:
    begin

      SendMessageW(GetParent(hApp[0]), PSM_SETWIZBUTTONS, 0,
        Integer(PSWIZB_NEXT));

    end;

    //

    PSN_QUERYCANCEL:
    begin

      dwRes := ExtMessageBoxW(
        GetParent(hApp[0]),
        MAKEINTRESOURCEW(LoadStrInstW(hInstance, RC_STRING_QCANCEL)),
        MAKEINTRESOURCEW(exeInfo.pszProductName),
        MB_YESNO or MB_ICONASTERISK
      );

      SetWindowLongW(hApp[0], DWL_MSGRESULT, Integer(dwRes = IDNO));

    end;

  end;

  //

  Result := 1;

end;

//

function WelcDlgProc_OnWmDestroy(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  bldfnt: HFONT;
begin

  //

  bldfnt := HFONT(SendMessageW(GetDlgItem(hApp[0], IDC_STATIC_WELCOME),
    WM_GETFONT, 0, 0));
  if (bldfnt <> 0) then
    DeleteObject(bldfnt);

  //

  Result := 0;

end;

//

function WelcDlgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
begin

  case uMsg of

    //

    WM_INITDIALOG:
    begin

      Result := BOOL(WelcDlgProc_OnWmInitDialog(hWnd, uMsg, wParam, lParam));

    end;

    //

    WM_NOTIFY:
    begin

      Result := BOOL(WelcDlgProc_OnWmNotify(hWnd, uMsg, wParam, lParam));

    end;

    //

    WM_DESTROY:
    begin

      Result := BOOL(WelcDlgProc_OnWmDestroy(hWnd, uMsg, wParam, lParam));

    end;

  else
    Result := FALSE;
  end;

end;

end.