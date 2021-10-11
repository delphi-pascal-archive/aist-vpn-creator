unit F_RasApi;

interface

uses
  Windows;

// RASIPADDR structure

type
  PRASIPADDR = ^RASIPADDR;
  RASIPADDR = record
    a: Byte;
    b: Byte;
    c: Byte;
    d: Byte;
  end;

const
  RAS_MaxAreaCode       = 10;
  RAS_MaxPhoneNumber    = 128;
  RAS_MaxDeviceType     = 16;
  RAS_MaxDeviceName     = 128;
  RAS_MaxPadType        = 32;
  RAS_MaxX25Address     = 200;
  RAS_MaxFacilities     = 200;
  RAS_MaxUserData       = 200;
  RAS_MaxDnsSuffix      = 255;
  RAS_MaxEntryName      = 256;
  RAS_MaxCallbackNumber = RAS_MaxPhoneNumber;
  UNLEN                 = 256; // Maximum user name length
  PWLEN                 = 256; // Maximum password length
  CNLEN                 = 15; // Computer name length
  DNLEN                 = CNLEN; // Maximum domain name length

// RASCREDENTIALS structure

type
  RASCREDENTIALSA = record
    dwSize    : DWORD;
    dwMask    : DWORD;
    szUserName: Array [0..UNLEN] of AnsiChar;
    szPassword: Array [0..PWLEN] of AnsiChar;
    szDomain  : Array [0..DNLEN] of AnsiChar;
  end;

  RASCREDENTIALSW = record
    dwSize    : DWORD;
    dwMask    : DWORD;
    szUserName: Array [0..UNLEN] of WideChar;
    szPassword: Array [0..PWLEN] of WideChar;
    szDomain  : Array [0..DNLEN] of WideChar;
  end;

  LPRASCREDENTIALSW = ^RASCREDENTIALSW;
  LPRASCREDENTIALSA = ^RASCREDENTIALSA;
  LPRASCREDENTIALS = ^RASCREDENTIALS;
  RASCREDENTIALS = RASCREDENTIALSA;

const
  // RASCREDENTIALS dwMask values

  RASCM_UserName = $00000001;
  RASCM_Password = $00000002;

// RASDIALPARAMS structure

type
  tagRASDIALPARAMSA = record
    dwSize          : DWORD;
    szEntryName     : Array [0..RAS_MaxEntryName] of AnsiChar;
    szPhoneNumber   : Array [0..RAS_MaxPhoneNumber] of AnsiChar;
    szCallbackNumber: Array [0..RAS_MaxCallbackNumber] of AnsiChar;
    szUserName      : Array [0..UNLEN] of AnsiChar;
    szPassword      : Array [0..PWLEN] of AnsiChar;
    szDomain        : Array [0..DNLEN] of AnsiChar;
    // {$IFDEF WINVER_0x401_OR_GREATER}
    dwSubEntry      : DWORD;
    dwCallbackId    : DWORD;
  end;

  tagRASDIALPARAMSW = record
    dwSize          : DWORD;
    szEntryName     : Array [0..RAS_MaxEntryName] of WideChar;
    szPhoneNumber   : Array [0..RAS_MaxPhoneNumber] of WideChar;
    szCallbackNumber: Array [0..RAS_MaxCallbackNumber] of WideChar;
    szUserName      : Array [0..UNLEN] of WideChar;
    szPassword      : Array [0..PWLEN] of WideChar;
    szDomain        : Array [0..DNLEN] of WideChar;
    // {$IFDEF WINVER_0x401_OR_GREATER}
    dwSubEntry      : DWORD;
    dwCallbackId    : DWORD;
  end;

  PRASDIALPARAMSA = ^RASDIALPARAMSA;
  PRASDIALPARAMSW = ^RASDIALPARAMSW;
  PRASDIALPARAMS = PRASDIALPARAMSA;
  tagRASDIALPARAMS = tagRASDIALPARAMSA;
  RASDIALPARAMSA = tagRASDIALPARAMSA;
  RASDIALPARAMSW = tagRASDIALPARAMSW;
  RASDIALPARAMS = RASDIALPARAMSA;

// RASENTRY structure

type
  tagRASENTRYA = record
    dwSize                    : DWORD;
    dwfOptions                : DWORD;
    // Настройки телефонного номера
    dwCountryID               : DWORD;
    dwCountryCode             : DWORD;
    szAreaCode                : Array [0..RAS_MaxAreaCode] of AnsiChar;
    szLocalPhoneNumber        : Array [0..RAS_MaxPhoneNumber] of AnsiChar;
    dwAlternateOffset         : DWORD;
    // PPP(Протокол Point-to-point)/Ip
    ipaddr                    : RASIPADDR;
    ipaddrDns                 : RASIPADDR;
    ipaddrDnsAlt              : RASIPADDR;
    ipaddrWins                : RASIPADDR;
    ipaddrWinsAlt             : RASIPADDR;
    // Протокол
    dwFrameSize               : DWORD;
    dwfNetProtocols           : DWORD;
    dwFramingProtocol         : DWORD;
    // Сценарии
    szScript                  : Array [0..MAX_PATH-1] of AnsiChar;
    // Автодозвон
    szAutodialDll             : Array [0..MAX_PATH-1] of AnsiChar;
    szAutodialFunc            : Array [0..MAX_PATH-1] of AnsiChar;
    // Устройство
    szDeviceType              : Array [0..RAS_MaxDeviceType] of AnsiChar;
    szDeviceName              : Array [0..RAS_MaxDeviceName]of AnsiChar;
    // X.25
    szX25PadType              : Array [0..RAS_MaxPadType] of AnsiChar;
    szX25Address              : Array [0..RAS_MaxX25Address] of AnsiChar;
    szX25Facilities           : Array [0..RAS_MaxFacilities] of AnsiChar;
    szX25UserData             : Array [0..RAS_MaxUserData] of AnsiChar;
    dwChannels                : DWORD;
    // Зарезервировано
    dwReserved1               : DWORD;
    dwReserved2               : DWORD;
    //  {$IFDEF WINVER_0x401_OR_GREATER}
    // Подключение из многих соединений
    dwSubEntries              : DWORD;
    dwDialMode                : DWORD;
    dwDialExtraPercent        : DWORD;
    dwDialExtraSampleSeconds  : DWORD;
    dwHangUpExtraPercent      : DWORD;
    dwHangUpExtraSampleSeconds: DWORD;
    // Время простоя до разъединения
    dwIdleDisconnectSeconds   : DWORD;
    // {$IFDEF WINVER_0x500_OR_GREATER}
    dwType                    : DWORD;
    dwEncryptionType          : DWORD;
    dwCustomAuthKey           : DWORD;
    guidId                    : TGUID;
    szCustomDialDll           : Array [0..MAX_PATH-1] of AnsiChar;
    dwVpnStrategy             : DWORD;
    //  {$IFDEF WINVER_0x501_OR_GREATER}
    dwfOptions2               : DWORD;
    dwfOptions3               : DWORD;
    szDnsSuffix               : Array [0..RAS_MaxDnsSuffix] of AnsiChar;
    dwTcpWindowSize           : DWORD;
    szPrerequisitePbk         : Array [0..MAX_PATH-1] of AnsiChar;
    szPrerequisiteEntry       : Array [0..RAS_MaxEntryName] of AnsiChar;
    dwRedialCount             : DWORD;
    dwRedialPause             : DWORD;
    //  {$IFDEF WINVER_0x600_OR_GREATER}
    //    ipv6addrDns   : RASIPV6ADDR;
    //    ipv6addrDnsAlt: RASIPV6ADDR;
    //  {$ENDIF}
    //    dwIPv4InterfaceMetric: DWORD;
    //    dwIPv6InterfaceMetric: DWORD;
  end;

  tagRASENTRYW = record
    dwSize                    : DWORD;
    dwfOptions                : DWORD;
    // Настройки телефонного номера
    dwCountryID               : DWORD;
    dwCountryCode             : DWORD;
    szAreaCode                : Array [0..RAS_MaxAreaCode] of WideChar;
    szLocalPhoneNumber        : Array [0..RAS_MaxPhoneNumber] of WideChar;
    dwAlternateOffset         : DWORD;
    // PPP(Протокол Point-to-point)/Ip
    ipaddr                    : RASIPADDR;
    ipaddrDns                 : RASIPADDR;
    ipaddrDnsAlt              : RASIPADDR;
    ipaddrWins                : RASIPADDR;
    ipaddrWinsAlt             : RASIPADDR;
    // Протокол
    dwFrameSize               : DWORD;
    dwfNetProtocols           : DWORD;
    dwFramingProtocol         : DWORD;
    // Сценарии
    szScript                  : Array [0..MAX_PATH-1] of WideChar;
    // Автодозвон
    szAutodialDll             : Array [0..MAX_PATH-1] of WideChar;
    szAutodialFunc            : Array [0..MAX_PATH-1] of WideChar;
    // Устройство
    szDeviceType              : Array [0..RAS_MaxDeviceType] of WideChar;
    szDeviceName              : Array [0..RAS_MaxDeviceName]of WideChar;
    // X.25
    szX25PadType              : Array [0..RAS_MaxPadType] of WideChar;
    szX25Address              : Array [0..RAS_MaxX25Address] of WideChar;
    szX25Facilities           : Array [0..RAS_MaxFacilities] of WideChar;
    szX25UserData             : Array [0..RAS_MaxUserData] of WideChar;
    dwChannels                : DWORD;
    // Зарезервировано
    dwReserved1               : DWORD;
    dwReserved2               : DWORD;
    //  {$IFDEF WINVER_0x401_OR_GREATER}
    // Подключение из многих соединений
    dwSubEntries              : DWORD;
    dwDialMode                : DWORD;
    dwDialExtraPercent        : DWORD;
    dwDialExtraSampleSeconds  : DWORD;
    dwHangUpExtraPercent      : DWORD;
    dwHangUpExtraSampleSeconds: DWORD;
    // Время простоя до разъединения
    dwIdleDisconnectSeconds   : DWORD;
    // {$IFDEF WINVER_0x500_OR_GREATER}
    dwType                    : DWORD;
    dwEncryptionType          : DWORD;
    dwCustomAuthKey           : DWORD;
    guidId                    : TGUID;
    szCustomDialDll           : Array [0..MAX_PATH-1] of WideChar;
    dwVpnStrategy             : DWORD;
    //  {$IFDEF WINVER_0x501_OR_GREATER}
    dwfOptions2               : DWORD;
    dwfOptions3               : DWORD;
    szDnsSuffix               : Array [0..RAS_MaxDnsSuffix] of WideChar;
    dwTcpWindowSize           : DWORD;
    szPrerequisitePbk         : Array [0..MAX_PATH-1] of WideChar;
    szPrerequisiteEntry       : Array [0..RAS_MaxEntryName] of WideChar;
    dwRedialCount             : DWORD;
    dwRedialPause             : DWORD;
    //  {$IFDEF WINVER_0x600_OR_GREATER}
    //    ipv6addrDns   : RASIPV6ADDR;
    //    ipv6addrDnsAlt: RASIPV6ADDR;
    //  {$ENDIF}
    //    dwIPv4InterfaceMetric: DWORD;
    //    dwIPv6InterfaceMetric: DWORD;
  end;

  tagRASENTRY = tagRASENTRYA;
  RASENTRYA = tagRASENTRYA;
  RASENTRYW = tagRASENTRYW;
  RASENTRY = RASENTRYA;

const
// RASENTRY dwfOptions bit flags

  RASEO_RemoteDefaultGateway      = $00000010;
  RASEO_ModemLights               = $00000100;
  RASEO_RequireEncryptedPw        = $00000400;
  RASEO_RequireMsEncryptedPw      = $00000800;
  RASEO_RequireDataEncryption     = $00001000;
  RASEO_PreviewUserPw             = $01000000;
  RASEO_ShowDialingProgress       = $04000000;

// RASENTRY dwfOptions bit flags

  RASEO2_DontNegotiateMultilink   = $00000004;
  RASEO2_ReconnectIfDropped       = $00000100;

// RASENTRY dwProtocols bit flags

  RASNP_Ip = $00000004;

// RASENTRY dwFramingProtocols bit flags

  RASFP_Ppp = $00000001;

// RASENTRY dwIdleDisconnectSeconds constants

  RASIDS_Disabled = $FFFFFFFF;

// RASENTRY szDeviceType default strings

  RASDT_Vpn = 'vpn';

// RASENTRY dwDialMode values

  RASEDM_DialAll = 1;

// The entry type used to determine which UI properties
// are to be presented to user.  This generally corresponds
// to a Connections "add" wizard selection.

  RASET_Vpn = 2; // Virtual private network

// There is currently no difference between RASCTRYINFOA and RASCTRYINFOW.
// This may change in the future.

  ET_None    = 0; // No encryption
  VS_Default = 0; // default (PPTP for now)

function RasSetEntryPropertiesA(lpszPhonebook, szEntry: PAnsiChar; lpbEntry: Pointer; dwEntrySize: Longint; lpbDeviceInfo: Pointer; dwDeviceInfoSize: Longint): Longint; stdcall;
function RasSetEntryPropertiesW(lpszPhonebook, szEntry: PWideChar; lpbEntry: Pointer; dwEntrySize: Longint; lpbDeviceInfo: Pointer; dwDeviceInfoSize: Longint): Longint; stdcall;
function RasSetEntryProperties(lpszPhonebook, szEntry: PAnsiChar; lpbEntry: Pointer; dwEntrySize: Longint; lpbDeviceInfo: Pointer; dwDeviceInfoSize: Longint): Longint; stdcall;

function RasGetEntryPropertiesA(lpszPhonebook, szEntry: PAnsiChar; lpbEntry: Pointer; var lpdwEntrySize: Longint; lpbDeviceInfo: Pointer; var lpdwDeviceInfoSize: Longint): Longint; stdcall;
function RasGetEntryPropertiesW(lpszPhonebook, szEntry: PWideChar; lpbEntry: Pointer; var lpdwEntrySize: Longint; lpbDeviceInfo: Pointer; var lpdwDeviceInfoSize: Longint): Longint; stdcall;
function RasGetEntryProperties(lpszPhonebook, szEntry: PAnsiChar; lpbEntry: Pointer; var lpdwEntrySize: Longint; lpbDeviceInfo: Pointer; var lpdwDeviceInfoSize: Longint): Longint; stdcall;

function RasSetEntryDialParamsA(lpszPhonebook: PAnsiChar; lprasdialparams: PRASDIALPARAMSA; fRemovePassword: BOOL): DWORD; stdcall;
function RasSetEntryDialParamsW(lpszPhonebook: PWideChar; lprasdialparams: PRASDIALPARAMSW; fRemovePassword: BOOL): DWORD; stdcall;
function RasSetEntryDialParams(lpszPhonebook: PAnsiChar; lprasdialparams: PRASDIALPARAMS; fRemovePassword: BOOL): DWORD; stdcall;

function RasSetCredentialsA(lpszPhoneBook, lpszEntry: PAnsiChar; var lpCredentials: RASCREDENTIALSA; fRemovePassword: LongBool): Longint; stdcall;
function RasSetCredentialsW(lpszPhoneBook, lpszEntry: PWideChar; var lpCredentials: RASCREDENTIALSW; fRemovePassword: LongBool): Longint; stdcall;
function RasSetCredentials(lpszPhoneBook, lpszEntry: PAnsiChar; var lpCredentials: RASCREDENTIALS; fRemovePassword: LongBool): Longint; stdcall;

implementation

const
  raslib = 'rasapi32.dll';

function RasSetEntryPropertiesA; external raslib name 'RasSetEntryPropertiesA';
function RasSetEntryPropertiesW; external raslib name 'RasSetEntryPropertiesW';
function RasSetEntryProperties;  external raslib name 'RasSetEntryPropertiesA';

function RasGetEntryPropertiesA; external raslib name 'RasGetEntryPropertiesA';
function RasGetEntryPropertiesW; external raslib name 'RasGetEntryPropertiesW';
function RasGetEntryProperties;  external raslib name 'RasGetEntryPropertiesA';

function RasSetEntryDialParamsA; external raslib name 'RasSetEntryDialParamsA';
function RasSetEntryDialParamsW; external raslib name 'RasSetEntryDialParamsW';
function RasSetEntryDialParams;  external raslib name 'RasSetEntryDialParamsA';

function RasSetCredentialsA;     external raslib name 'RasSetCredentialsA';
function RasSetCredentialsW;     external raslib name 'RasSetCredentialsW';
function RasSetCredentials;      external raslib name 'RasSetCredentialsA';

end.