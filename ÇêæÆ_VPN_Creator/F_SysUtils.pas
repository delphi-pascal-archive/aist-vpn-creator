unit F_SysUtils;

interface

uses
  Windows, Messages;

function LoadStrInstW(hInst: HMODULE; I: Integer): WideString;
function FormatW(szString: WideString; const Params: Array of const): WideString;
function WideStringToAnsi(pszText: WideString; CodePage: WORD): AnsiString;
function AnsiStringToWide(pszText: AnsiString; CodePage: WORD): WideString;
function ExtractFilePathW(pszText: WideString): WideString;
function ExcludeTrailingPathDelimiterW(szString: WideString): WideString;
function SetCenterDialogPos(hDialog, hParent: HWND; IsParent: Boolean): Boolean;
function GetWindowFontSizeW(hWnd: HWND; pSize: Integer): Integer;
function GetWindowBoldFontW(hWnd: THandle; fntHeight: Integer): HFONT;

implementation

//

function LoadStrInstW(hInst: HMODULE; I: Integer): WideString;
var
  lpBuffer: Array [0..MAX_PATH-1] of WideChar;
begin
  LoadStringW(hInst, I, lpBuffer, Length(lpBuffer));
  Result := lpBuffer;
end;

//

function FormatW(szString: WideString; const Params: Array of const): WideString;
var
  lpChar: Array [0..1023] of WideChar;
  lpWord: Array [0..15] of LongWord;
  nIndex: Integer;
begin
  for nIndex := High(Params) downto 0 do
    lpWord[nIndex] := Params[nIndex].VInteger;
  wvsprintfW(@lpChar, @szString[1], @lpWord);
  Result := lpChar;
end;

//

function WideStringToAnsi(pszText: WideString; CodePage: WORD): AnsiString;
var
  dwBytes: Integer;
  dwFlags: DWORD;
begin
  if (pszText <> '') then
    begin
      dwFlags := WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR;
      dwBytes := WideCharToMultiByte(CodePage, dwFlags, @pszText[1], -1, nil, 0,
        nil, nil);
      SetLength(Result, dwBytes - 1);
      if (dwBytes > 1) then
        WideCharToMultiByte(CodePage, dwFlags, @pszText[1], -1, @Result[1],
          dwBytes - 1, nil, nil);
    end
  else
    Result := '';
end;

//

function AnsiStringToWide(pszText: AnsiString; CodePage: WORD): WideString;
var
  dwBytes: Integer;
begin
  if (pszText <> '') then
    begin
      dwBytes := MultiByteToWideChar(CodePage, MB_PRECOMPOSED, @pszText[1], -1,
        nil, 0);
      SetLength(Result, dwBytes - 1);
      if (dwBytes > 1) then
        MultiByteToWideChar(CodePage, MB_PRECOMPOSED, @pszText[1], -1, @Result[1],
          dwBytes - 1);
    end
  else
    Result := '';
end;

//

function ExtractFilePathW(pszText: WideString): WideString;
var
  L: Integer;
begin
  Result := '';
  L := Length(pszText);
  while (L > 0) do
    begin
      if (pszText[L] = ':') or (pszText[L] = '\') then
        begin
          Result := Copy(pszText, 1, L);
          Break;
        end;
      Dec(L);
    end;
end;

//

function ExcludeTrailingPathDelimiterW(szString: WideString): WideString;
var
  I: Integer;
begin
  Result := szString;
  I := Length(Result);
  while (I > 0) and (Result[I] = '\') do
    Dec(I);
  SetLength(Result, I);
end;

//

function SetCenterDialogPos(hDialog, hParent: HWND; IsParent: Boolean): Boolean;
var
  wRect  : TRect;
  pRect  : TRect;
  wArea  : TRect;
  xLeft  : Integer;
  yTop   : Integer;
  iWidth : Integer;
  iHeight: Integer;
  dwFlags: DWORD;
begin
  case IsParent of
    FALSE:
      begin
        GetWindowRect(hDialog, wRect);
        iWidth  := wRect.Right - wRect.Left;
        iHeight := wRect.Bottom - wRect.Top;
        xLeft := (GetSystemMetrics(SM_CXSCREEN) - iWidth) div 2;
        yTop  := (GetSystemMetrics(SM_CYSCREEN) - iHeight) div 2;
      end;
    TRUE:
      begin
        GetWindowRect(hDialog, wRect);
        GetWindowRect(hParent, pRect);
        iWidth  := wRect.Right - wRect.Left;
        iHeight := wRect.Bottom - wRect.Top;
        SystemParametersInfoW(SPI_GETWORKAREA, 0, @wArea, 0);
        xLeft := pRect.Left + ((pRect.Right - pRect.Left - iWidth) div 2);
        if (xLeft < 0) then
          xLeft := 0
        else
        if ((xLeft + iWidth) > (wArea.Right - wArea.Left)) then
          xLeft := wArea.Right - wArea.Left - iWidth;
        yTop := pRect.Top + ((pRect.Bottom - pRect.Top - iHeight) div 2);
        if (yTop < 0) then
          yTop := 0
        else
        if ((yTop + iHeight) > (wArea.Bottom - wArea.Top)) then
          yTop := wArea.Bottom - wArea.Top - iHeight;
      end;
  end;
  dwFlags := SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER;
  Result := SetWindowPos(hDialog, 0, xLeft, yTop, 0, 0, dwFlags);
end;

//

function GetWindowFontSizeW(hWnd: HWND; pSize: Integer): Integer;
var
  dc: HDC;
begin
  dc := GetDC(hWnd);
  Result := -MulDiv(pSize, GetDeviceCaps(dc, LOGPIXELSY), 72);
  ReleaseDC(hWnd, dc);
end;

//

function GetWindowBoldFontW(hWnd: THandle; fntHeight: Integer): HFONT;
var
  lf   : TLogFontW;
  dwRes: Integer;
  hfnt : HFONT;
begin
  hfnt := HFONT(SendMessageW(hWnd, WM_GETFONT, 0, 0));
  ZeroMemory(@lf, SizeOf(TLogFontW));
  if (hfnt <> 0) then
    dwRes := GetObjectW(hfnt, SizeOf(TLogFontW), @lf);
  if (dwRes <> 0) then
  begin
    lf.lfHeight := fntHeight;
    lf.lfWeight := FW_BOLD;
    hfnt := CreateFontIndirectW(lf);
  end;
  Result := hfnt;
end;

end.