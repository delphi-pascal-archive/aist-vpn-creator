unit F_MyMsgBox;

interface

uses
  Windows, Messages, F_SysUtils;

function ExtMessageBoxW(hWnd: HWND; pszText, pszCaption: PWideChar; dwFlags: DWORD): Integer;

implementation

var
  hhk: HHOOK;
  ico: HICON;

//

function SysMsgProcW(nCode: UINT; wParam: WPARAM; lParam: LPARAM): Integer; stdcall;
begin
  case nCode of
    HCBT_ACTIVATE:
      begin
        if (ico <> 0) then
          SendMessageW(wParam, WM_SETICON, ICON_SMALL, ico);
        SetCenterDialogPos(wParam, GetParent(wParam), TRUE);
        UnhookWindowsHookEx(hhk);
        Result := 0;
      end;
    else
      Result := CallNextHookEx(hhk, nCode, wParam, lParam);
  end;
end;

//

function ExtMessageBoxW(hWnd: HWND; pszText, pszCaption: PWideChar; dwFlags: DWORD): Integer;
begin
  ico := GetClassLongW(hWnd, GCL_HICON);
  if (ico = 0) then
    ico := SendMessageW(hWnd, WM_GETICON, ICON_SMALL, 0);
  hhk := SetWindowsHookExW(WH_CBT, @SysMsgProcW, hInstance, 0);
  Result := MessageBoxW(hWnd, pszText, pszCaption, dwFlags);
end;

end.