unit D_FinsWind;

interface

uses
  Windows, Messages, CommCtrl, F_Windows, F_Controls, F_FileInfo, F_SysUtils,
  F_MyMsgBox, F_Ole2, F_ActiveX, F_ShlObj, F_RasApi, F_Resources;

function FinsDlgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;

implementation

//

function FinsDlgProc_OnWmInitDialog(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  bldfnt: HFONT;
begin

  //

  hApp[2] := hWnd;

  //

  bldfnt := HFONT(SendMessageW(GetDlgItem(hApp[0], IDC_STATIC_WELCOME),
    WM_GETFONT, 0, 0));

  if (bldfnt <> 0) then
    SendMessageW(GetDlgItem(hApp[2], IDC_STATIC_FINISH), WM_SETFONT,
      Integer(bldfnt), Integer(TRUE));

  //

  Result := 0;

end;

//

function FinsDlgProc_OnWmNotify(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  pnmh   : PNMHdr;
  dwRes  : DWORD;
  pszText: WideString;

  //

  function GetNextItemID(pidl: PItemIDList): PItemIDList;
  var
    cb: DWORD;
  begin
    Result := nil;
    if (pidl = nil) then
      Exit;
    cb := pidl.mkid.cb;
    if (cb = 0) then
      Exit;
    pidl := PItemIDList(Cardinal(pidl) + cb);
    if (pidl.mkid.cb <> 0) then
      Result := pidl;
  end;

  //

  function GetPIDSize(pidl: PItemIDList): DWORD;
  begin
    Result := 0;
    if (pidl <> nil) then
    begin
      Result := SizeOf(pidl.mkid.cb);
      while (pidl <> nil) do
      begin
        Inc(Result, pidl.mkid.cb);
        pidl := GetNextItemID(pidl);
      end;
    end;
  end;

  //

  function IsDesktopFolder(pidl: PItemIDList): Boolean;
  begin
    if Assigned(pidl) then
      Result := (pidl.mkid.cb = 0)
    else
      Result := FALSE;
  end;

  //

  function ConcatPIDL(destpidl, srcpidl: PItemIDList): PItemIDList;
  var
    cb1: DWORD;
    cb2: DWORD;
    pmc: IMalloc;
    hr : HRESULT;
  begin
    Result := nil;
    hr := SHGetMalloc(pmc);
    if SUCCEEDED(hr) then
    begin
      cb1 := 0;
      cb2 := 0;
      if Assigned(destpidl) then
      begin
        if not IsDesktopFolder(destpidl) then
          cb1 := GetPIDSize(destpidl) - SizeOf(destpidl^.mkid.cb);
      end;
      if Assigned(srcpidl) then
        cb2 := GetPIDSize(srcpidl);
      Result := pmc.Alloc(cb1 + cb2);
      if Assigned(Result) then
      begin
        if Assigned(destpidl) then
          CopyMemory(Result, destpidl, cb1);
        if Assigned(srcpidl) then
          CopyMemory(Pointer(DWORD(Result) + cb1), srcpidl, cb2);
      end;
      pmc := nil;
    end;
  end;

  //

  procedure CreateShellVpnLink(pszEntry: WideString);
  var
    pMalloc    : IMalloc;
    Desktop    : IShellFolder;
    pidlDesktop: PItemIDList;
    pszPath    : Array [0..MAX_PATH-1] of WideChar;
    pidlConnect: PItemIDList;
    Network    : IShellFolder;
    Items      : IEnumIDList;
    pidl2      : PItemIDList;
    dwFetched  : Cardinal;
    Connection : STRRET;
    ObjectName : WideString;
    pfLink     : IUnknown;
    isLink     : IShellLink;
    ipFile     : IPersistFile;
    pidl3      : PItemIDList;
    szFileName : WideString;
  begin
    CoInitialize(nil);
    try
      // acquire shell's allocator
      if (SHGetMalloc(pMalloc) = S_OK) then
      try
        // acquire shell namespace root folder
        if (SHGetDesktopFolder(Desktop) = S_OK) then
        try
          if (SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, pidlDesktop) = S_OK) then
          try
            ZeroMemory(@pszPath, SizeOf(pszPath));
            SHGetPathFromIDListW(pidlDesktop, @pszPath);
            if (SHGetSpecialFolderLocation(0, CSIDL_CONNECTIONS, pidlConnect) = S_OK) then
            try
              Desktop.BindToObject(pidlConnect, nil, IID_IShellFolder, Network);
              Network.EnumObjects(0, SHCONTF_NONFOLDERS, Items);
              while (Items.Next(1, pidl2, dwFetched) = S_OK) do
              try
                if (dwFetched > 0) and Assigned(pidl2) then
                try
                  Network.GetDisplayNameOf(pidl2, SHGDN_NORMAL, Connection);
                  ObjectName := Connection.pOleStr;
                  if (lstrcmpiW(@ObjectName[1], @pszEntry[1]) = 0) then
                  try
                    CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IUnknown, pfLink);
                    isLink := pfLink as IShellLink;
                    ipFile := pfLink as IPersistFile;
                    pidl3 := ConcatPIDL(pidlConnect, pidl2);
                    isLink.SetIDList(pidl3);
                    szFileName := FormatW('%s\%s.lnk', [ExcludeTrailingPathDelimiterW(pszPath), pszEntry]);
                    ipFile.Save(@szFileName[1], FALSE);
                    pMalloc.Free(pidl3);
                  finally
                    {
                    pfLink := nil;
                    isLink := nil;
                    ipFile := nil;
                    }
                  end;
                finally
                  pMalloc.Free(pidl2); // release folder
                end;
              finally
              end;
            finally
              Network := nil;
              pMalloc.Free(pidlConnect); // release folder
            end;
          finally
            pMalloc.Free(pidlDesktop); // release folder
          end;
        finally
          Desktop := nil; // release shell namespace root folder
        end;
      finally
        pMalloc := nil; // release shell's allocator
      end;
    finally
      CoUninitialize;
    end;
  end;

  //

  function CreateRasVpnConnection(szEntryName, szPhoneName, szUserName, szPassword: WideString): LRESULT;
  var
    osvi     : TOSVersionInfoW;
    rEntry   : RASENTRYW;
    rDial    : RASDIALPARAMSW;
    lpCred   : RASCREDENTIALSW;
    dwSize   : Integer;
    EntrySize: Integer;
    InfoSize : Integer;
    dwFlags  : DWORD;
    dwFlags2 : DWORD;
    dwRes    : DWORD;
  begin
    // заполняем структуру RASENTRY и узнаем нужный размер для корректного вызова
    // функции RasSetEntryProperties
    dwSize := SizeOf(RASENTRYW);
    RasGetEntryPropertiesW(nil, nil, nil, EntrySize, nil, InfoSize);
    if (EntrySize < dwSize) then
      dwSize := EntrySize;
    // Задаём флаговые параметры VPN соединения
    dwFlags :=
      // Вкладка 'Параметры', флаг 'Запрашивать имя, пароль, сертификат и т.д.', вкл
      RASEO_PreviewUserPw or
      // Вкладка 'Общие', флаг 'При подключении вывести значок в области уведомлений', вкл
      RASEO_ModemLights or
      // Вкладка 'Общие', флаг 'Отображать ход подключения', вкл
      RASEO_ShowDialingProgress or
      // Использовать основной шлюз
      RASEO_RemoteDefaultGateway or
      // Зашифрованный пароль будет использоваться при проверке подлинности с сервером
      RASEO_RequireEncryptedPw or
      // Использовать автоматически логин, пароль и домен из Windows
      RASEO_RequireDataEncryption or
      // Пароль будет зашифрован по схеме Microsoft
      RASEO_RequireMsEncryptedPw;
    dwFlags2 :=
      // Вкладка 'Параметры', флаг 'Согласовывать многоканальное подключение для одноканальных', выкл
      RASEO2_DontNegotiateMultilink or
      // Вкладка 'Параметры', флаг 'Перезвонить при разрыве связи', вкл
      RASEO2_ReconnectIfDropped;
    // Заполняем структуру RASENTRY
    ZeroMemory(@rEntry, SizeOf(RASENTRYW));
    rEntry.dwSize                  := dwSize;
    rEntry.dwfOptions              := dwFlags;
    // Тип используемого протокола = TCP/IP
    rEntry.dwfNetProtocols         := RASNP_Ip;
    // Тип используемого протокола сервера удаленного доступа = Point-to-Point Protocol (PPP)
    rEntry.dwFramingProtocol       := RASFP_Ppp;
    // Тип создаваемого подключения - Виртуальная частная сеть (VPN)
    rEntry.dwType                  := RASET_Vpn;
    // Значение выпадающего списка 'Тип VPN' = 'Автоматически'
    // Вызывается сначала только PPTP, если же попытка заканчивается неудачей, то вызывается L2TP
    rEntry.dwVpnStrategy           := VS_Default;
    rEntry.dwfOptions2             := dwFlags2;
    // Вкладка 'Безопасность', флаг 'Требуется шифрование данных', вкл
    // Диалог 'Дополнительные параметры безопасности', список 'Шифрование данных' = 'обязательное'
    // Тип шифрования данных при подключении = Шифрование не используется
    rEntry.dwEncryptionType        := ET_None;
    // Используем соединение устройств с множеством «подвходов»
    rEntry.dwDialMode              := RASEDM_DialAll;
    // Вкладка 'Параметры', 'Число повторений набора номера' = 3
    rEntry.dwRedialCount           := 3;
    // Вкладка 'Параметры', 'Интервал между повторениями' = 60 секунд
    rEntry.dwRedialPause           := 60;
    lstrcpyW(rEntry.szLocalPhoneNumber, @szPhoneName[1]);
    lstrcpyW(rEntry.szDeviceType, RASDT_Vpn);
    // Создаем новое подключение с нужными параметрами
    dwRes := RasSetEntryPropertiesW(nil, @szEntryName[1], @rEntry, dwSize, nil, 0);
    case dwRes of
      ERROR_SUCCESS:
        begin
          // выполняем проверку версии ОС. начиная с ОС Win XP и старше, логин и
          // пароль (фактически это нам и требуется) можно изменить функцией
          // RasSetCredentials, а в предыдущих ОС можно с помощью функции
          // RasSetEntryDialParams. в Win XP еще можно изменить пароль функцией
          // RasSetEntryDialParams, а вот уже в Win Vista и старше не получится.

          ZeroMemory(@osvi, SizeOf(TOSVersionInfoW));
          osvi.dwOSVersionInfoSize := SizeOf(TOSVersionInfoW);
          F_Windows.GetVersionExW(osvi);

          if ((osvi.dwPlatformId = VER_PLATFORM_WIN32_NT) and
            (osvi.dwMajorVersion >= 5) and (osvi.dwMinorVersion >= 1)) then
            begin
              // Заполняем структуру RASCREDENTIALS
              ZeroMemory(@lpCred, SizeOf(RASCREDENTIALSW));
              lpCred.dwMask := RASCM_UserName or RASCM_Password;
              lpCred.dwSize := SizeOf(RASCREDENTIALSW);
              lstrcpyW(lpCred.szUserName, @szUserName[1]);
              lstrcpyW(lpCred.szPassword, @szPassword[1]);
              // Изменяем логин и пароль созданного подключения
              dwRes := RasSetCredentialsW(nil, @szEntryName[1], lpCred, FALSE);
            end
          else
            begin
              // Заполняем структуру RASDIALPARAMS
              ZeroMemory(@rDial, SizeOf(RASDIALPARAMSW));
              rDial.dwSize := SizeOf(RASDIALPARAMSW);
              lstrcpyW(rDial.szEntryName, @szEntryName[1]);
              lstrcpyW(rDial.szUserName, @szUserName[1]);
              lstrcpyW(rDial.szPassword, @szPassword[1]);
              // Изменяем логин и пароль созданного подключения
              dwRes := RasSetEntryDialParamsW(nil, @rDial, FALSE);
            end;
        end;
    end;
    Result := dwRes;
  end;

begin

  //

  pnmh := PNMHdr(lParam);

  case pnmh.code of

    //

    PSN_SETACTIVE:
    begin

      pszText := FormatW(
        LoadStrInstW(hInstance, RC_STRING_VPNINFO),
        [
        Edit_GetTextW(GetDlgItem(hApp[1], IDC_STATIC_ENTRY)),
        Edit_GetTextW(GetDlgItem(hApp[1], IDC_COMBO_SERVER)),
        Edit_GetTextW(GetDlgItem(hApp[1], IDC_STATIC_USER))
        ]
      );

      SendMessageW(GetDlgItem(hApp[2], IDC_STATIC_VPNINFO), WM_SETTEXT, 0,
        Integer(@pszText[1]));

      SendMessageW(GetParent(hApp[2]), PSM_SETWIZBUTTONS, 0,
        Integer(PSWIZB_BACK or PSWIZB_FINISH));

    end;

    //

    PSN_QUERYCANCEL:
    begin

      dwRes := ExtMessageBoxW(
        GetParent(hApp[2]),
        MAKEINTRESOURCEW(LoadStrInstW(hInstance, RC_STRING_QCANCEL)),
        MAKEINTRESOURCEW(exeInfo.pszProductName),
        MB_YESNO or MB_ICONASTERISK
      );

      SetWindowLongW(hApp[2], DWL_MSGRESULT, Integer(dwRes = IDNO));

    end;

    //

    PSN_WIZFINISH:
    begin

      pszText := Edit_GetTextW(GetDlgItem(hApp[1], IDC_STATIC_ENTRY));

      dwRes := CreateRasVpnConnection(
        pszText,
        Edit_GetTextW(GetDlgItem(hApp[1], IDC_COMBO_SERVER)),
        Edit_GetTextW(GetDlgItem(hApp[1], IDC_STATIC_USER)),
        Edit_GetTextW(GetDlgItem(hApp[1], IDC_STATIC_PASSW))
      );

      if (dwRes = ERROR_SUCCESS) then
      begin
        dwRes := SendMessageW(GetDlgItem(hApp[2], IDC_CHECK_SHORTCUT),
          BM_GETCHECK, 0, 0);
        if (dwRes = BST_CHECKED) then
          CreateShellVpnLink(pszText);
      end;

    end;

  end;

  //

  Result := 1;

end;

//

function FinsDlgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
begin

  case uMsg of

    //

    WM_INITDIALOG:
    begin

      Result := BOOL(FinsDlgProc_OnWmInitDialog(hWnd, uMsg, wParam, lParam));

    end;

    //

    WM_NOTIFY:
    begin

      Result := BOOL(FinsDlgProc_OnWmNotify(hWnd, uMsg, wParam, lParam));

    end;

  else
    Result := FALSE;
  end;

end;

end.