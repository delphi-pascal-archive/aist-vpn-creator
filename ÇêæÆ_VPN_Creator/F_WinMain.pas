unit F_WinMain;

interface

uses
  Windows, Messages, CommCtrl, F_CommCtrl, F_SysUtils, F_FileInfo, F_Resources,
  D_WelcWind, D_SettWind, D_FinsWind;

function WinMain(hInstance: HINST; hPrevInstance: HINST; lpCmdLine: LPSTR; nCmdShow: Integer): Integer; stdcall;

implementation

function WinMain(hInstance: HINST; hPrevInstance: HINST; lpCmdLine: LPSTR; nCmdShow: Integer): Integer; stdcall;
var
  hMutex : THandle;
  pszText: WideString;
  iccex  : TInitCommonControlsEx;
  psh    : TPropSheetHeaderW;
begin

  // извлекаем информацию из ресурса версии и заполняем ей подготовленную
  // структуру, которую вдальнейшем будем использовать для чтения/записи
  // настроек программы и вывода текста в заголовке сообщений.

  ZeroMemory(@exeInfo, SizeOf(TStringFileInfoW));
  GetFileInfoW(AnsiStringToWide(ParamStr(0), CP_ACP), exeInfo);

  // создаем Mutex для проверки запуска копий приложения.

  hMutex := CreateMutexW(nil, FALSE, MAKEINTRESOURCEW(exeInfo.pszProductName));
  if (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    pszText := LoadStrInstW(hInstance, RC_STRING_COPYRUN);
    MessageBoxW(
      GetActiveWindow,
      @pszText[1],
      MAKEINTRESOURCEW(exeInfo.pszProductName),
      MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL
    );
    Halt;
  end;

  // инициализируем библиотеку стандартных органов управления.

  iccex.dwSize := SizeOf(TInitCommonControlsEx);
  iccex.dwICC  := ICC_ANIMATE_CLASS or ICC_PROGRESS_CLASS or ICC_TAB_CLASSES or
    ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES;
  InitCommonControlsEx(iccex);

  //

  pszText := FormatW(LoadStrInstW(hInstance, RC_STRING_CWINDOW),
    [exeInfo.pszProductName, exeInfo.pszFileVersion]);

  // создаем и отображаем страницы мастера.

  ZeroMemory(@psp, SizeOf(TPropSheetPageW));

  psp.dwSize            := SizeOf(TPropSheetPageW);
  psp.dwFlags           := PSP_USETITLE or PSP_HIDEHEADER;
  psp.pszTitle          := @pszText[1];
  psp.pfnDlgProc        := @WelcDlgProc;
  psp.pszTemplate       := MAKEINTRESOURCEW(RC_DIALOG_WELCOME);
  ahpsp[0]              := CreatePropertySheetPageW(psp);

  ZeroMemory(@psp, SizeOf(TPropSheetPageW));

  psp.dwSize            := SizeOf(TPropSheetPageW);
  psp.dwFlags           := PSP_USETITLE or PSP_USEHEADERTITLE or PSP_USEHEADERSUBTITLE;
  psp.pszTitle          := @pszText[1];
  psp.pszHeaderTitle    := MAKEINTRESOURCEW(LoadStrInstW(hInstance, RC_STRING_THEADER));
  psp.pszHeaderSubTitle := MAKEINTRESOURCEW(LoadStrInstW(hInstance, RC_STRING_SHEADER));
  psp.pszTemplate       := MAKEINTRESOURCEW(RC_DIALOG_SETTINGS);
  psp.pfnDlgProc        := @SettDlgProc;
  ahpsp[1]              := CreatePropertySheetPageW(psp);

  ZeroMemory(@psp, SizeOf(TPropSheetPageW));

  psp.dwSize            := SizeOf(TPropSheetPageW);
  psp.dwFlags           := PSP_USETITLE or PSP_HIDEHEADER;
  psp.pszTitle          := @pszText[1];
  psp.pszTemplate       := MAKEINTRESOURCEW(RC_DIALOG_FINISH);
  psp.pfnDlgProc        := @FinsDlgProc;
  ahpsp[2]              := CreatePropertySheetPageW(psp);

  ZeroMemory(@psh, SizeOf(TPropSheetHeaderW));

  psh.dwSize         := SizeOf(TPropSheetHeaderW);
  psh.hInstance      := hInstance;
  psh.hwndParent     := 0;
  psh.phpage         := @ahpsp[0];
  psh.nStartPage     := 0;
  psh.nPages         := Length(ahpsp);
  psh.pszbmWatermark := MAKEINTRESOURCEW(RC_BITMAP_WATERMARK);
  psh.pszbmHeader    := MAKEINTRESOURCEW(RC_BITMAP_HEADER);
  psh.dwFlags        := PSH_WIZARD97 or PSH_WATERMARK or PSH_HEADER or PSH_USEICONID;
  psh.pszIcon        := MAKEINTRESOURCEW(RC_ICONEX_CAPTION);

  PropertySheetW(psh);

  // удаляем именованный объект.

  if (hMutex <> 0) then
  begin
    ReleaseMutex(hMutex);
    CloseHandle(hMutex);
  end;

  //

  Result := 0;

end;

end.