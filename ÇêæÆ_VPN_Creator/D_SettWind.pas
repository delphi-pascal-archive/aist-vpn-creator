unit D_SettWind;

interface

uses
  Windows, Messages, CommCtrl, F_FileInfo, F_LinkStat, F_SysUtils, F_MyMsgBox,
  F_Controls, F_Resources, D_ScanProc;

function SettDlgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;

implementation

//

function SettDlgProc_OnWmInitDialog(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  bldfnt: HFONT;
begin

  //

  hApp[1] := hWnd;

  //

  CreateStaticHyperlinkW(GetDlgItem(hApp[1], IDC_STATIC_SERVER));

  //

  SendMessageW(GetDlgItem(hApp[1], IDC_COMBO_SERVER), CB_ADDSTRING, 0,
    Integer(@pszServ[1]));
  SendMessageW(GetDlgItem(hApp[1], IDC_COMBO_SERVER), CB_SETCURSEL, 0, 0);

  //

  bldfnt := GetWindowBoldFontW(hApp[1], GetWindowFontSizeW(hApp[1], 8));
  if (bldfnt <> 0) then
    SendMessageW(GetDlgItem(hApp[1], IDC_STATIC_WARN), WM_SETFONT,
      Integer(bldfnt), Integer(TRUE));

  //

  Result := 0;

end;

//

function SettDlgProc_OnWmCommand(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
const
  dwRes: Array [Boolean] of DWORD = (PSWIZB_BACK, PSWIZB_BACK or PSWIZB_NEXT);
var
  dwEntry: DWORD;
  dwUser : DWORD;
  dwPass : DWORD;
begin

  //

  case HiWord(wParam) of

    //

    BN_CLICKED:
      case LoWord(wParam) of

        //

        IDC_STATIC_SERVER:
          begin

            DialogBoxW(hInstance, MAKEINTRESOURCEW(RC_DIALOG_UPDATE), hApp[1],
              @ScanDlgProc);

          end;

      end;

    //

    EN_UPDATE:
      case LoWord(wParam) of
        IDC_STATIC_ENTRY,
        IDC_STATIC_USER,
        IDC_STATIC_PASSW:
        begin

          dwEntry := SendMessageW(GetDlgItem(hApp[1], IDC_STATIC_ENTRY),
            WM_GETTEXTLENGTH, 0, 0);
          dwUser := SendMessageW(GetDlgItem(hApp[1], IDC_STATIC_USER),
            WM_GETTEXTLENGTH, 0, 0);
          dwPass := SendMessageW(GetDlgItem(hApp[1], IDC_STATIC_PASSW),
            WM_GETTEXTLENGTH, 0, 0);

          SendMessageW(
            GetParent(hApp[1]),
            PSM_SETWIZBUTTONS,
            0,
            dwRes[(dwEntry > 0) and (dwUser > 0) and (dwPass > 0)]
          );

        end;
      end;
      
  end;

  //

  Result := 0;

end;

//

function SettDlgProc_OnWmCtlColorStatic(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin

  //

  case GetDlgCtrlId(lParam) of 
    IDC_STATIC_WARN:
    begin

      SetBkMode(wParam, TRANSPARENT);
      SetTextColor(wParam, RGB(255, 0, 0));
      Result := GetStockObject(NULL_BRUSH);

    end;
  else

    Result := 0;

  end;

end;

//

function SettDlgProc_OnWmNotify(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  pnmh : PNMHdr;
  dwRes: DWORD;
begin

  //

  pnmh := PNMHdr(lParam);

  case pnmh.code of

    //

    PSN_WIZNEXT:
    begin

      SendMessageW(GetParent(hApp[1]), PSM_SETWIZBUTTONS, 0,
        Integer(PSWIZB_NEXT));

    end;

    //

    PSN_SETACTIVE:
    begin

       SendMessageW(hApp[1], WM_COMMAND, MAKELPARAM(IDC_STATIC_ENTRY, EN_UPDATE),
         0);
       SendMessageW(hApp[1], WM_COMMAND, MAKELPARAM(IDC_STATIC_USER, EN_UPDATE),
         0);
       SendMessageW(hApp[1], WM_COMMAND, MAKELPARAM(IDC_STATIC_PASSW, EN_UPDATE),
         0);

    end;

    //

    PSN_QUERYCANCEL:
    begin

      dwRes := ExtMessageBoxW(
        GetParent(hApp[1]),
        MAKEINTRESOURCEW(LoadStrInstW(hInstance, RC_STRING_QCANCEL)),
        MAKEINTRESOURCEW(exeInfo.pszProductName),
        MB_YESNO or MB_ICONASTERISK
      );

      SetWindowLongW(hApp[1], DWL_MSGRESULT, Integer(dwRes = IDNO));

    end;

    //

    PSN_WIZBACK:
    begin

      SendMessageW(GetParent(hApp[1]), PSM_SETCURSEL, GetParent(hApp[1]),
        Integer(ahpsp[1]));

    end;

  end;

  //

  Result := 1;

end;


//

function SettDlgProc_OnWmDestroy(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  bldfnt: HFONT;
begin

  //

  RemoveStaticHyperlinkW(GetDlgItem(hApp[1], IDC_STATIC_SERVER));

  //

  bldfnt := HFONT(SendMessageW(GetDlgItem(hApp[1], IDC_STATIC_WARN),
    WM_GETFONT, 0, 0));
  if (bldfnt <> 0) then
    DeleteObject(bldfnt);

  //

  Result := 0;

end;

//

function SettDlgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
begin

  case uMsg of

    //

    WM_INITDIALOG:
    begin

      Result := BOOL(SettDlgProc_OnWmInitDialog(hWnd, uMsg, wParam, lParam));

    end;

    //

    WM_COMMAND:
    begin

      Result := BOOL(SettDlgProc_OnWmCommand(hWnd, uMsg, wParam, lParam));

    end;

    //

    WM_CTLCOLORSTATIC:
    begin

      Result := BOOL(SettDlgProc_OnWmCtlColorStatic(hWnd, uMsg, wParam, lParam));

    end;

    //

    WM_NOTIFY:
    begin

      Result := BOOL(SettDlgProc_OnWmNotify(hWnd, uMsg, wParam, lParam));

    end;

    //

    WM_DESTROY:
    begin

      Result := BOOL(SettDlgProc_OnWmDestroy(hWnd, uMsg, wParam, lParam));

    end;

  else
    Result := FALSE;
  end;

end;

end.