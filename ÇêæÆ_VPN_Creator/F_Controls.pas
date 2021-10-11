unit F_Controls;

interface

uses
  Windows, Messages;

function Edit_GetTextW(hWnd: HWND): WideString;

implementation

//

function Edit_GetTextW(hWnd: HWND): WideString;
var
  L: Integer;
begin
  L := SendMessageW(hWnd, WM_GETTEXTLENGTH, 0, 0);
  if (L > 0) then
    begin
      SetLength(Result, L + 1);
      SendMessageW(hWnd, WM_GETTEXT, L + 1, Integer(@Result[1]));
    end
  else
    Result := '';
end;

end.