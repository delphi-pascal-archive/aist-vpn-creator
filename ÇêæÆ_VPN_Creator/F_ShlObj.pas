unit F_ShlObj;

interface

uses
  Windows, F_ActiveX;

{ Object identifiers in the explorer's name space (ItemID and IDList) }

const
  // Network and Dial-up Connections
  CSIDL_CONNECTIONS = $0031;

{ SHGetSpecialFolderLocation constants }

const
  // Desktop
  CSIDL_DESKTOP = $0000;

{ Interface IDs }

const
  IID_IShellFolder: TGUID = (D1: $000214E6; D2: $0000; D3: $0000; D4: ($C0, $00, $00, $00, $00, $00, $00, $46));
  CLSID_ShellLink : TGUID = (D1: $00021401; D2: $0000; D3: $0000; D4: ($C0, $00, $00, $00, $00, $00, $00, $46));

{ IShellFolder.GetDisplayNameOf/SetNameOf uFlags }

const
  // default (display purpose)
  SHGDN_NORMAL       = 0;
  // for default view
  SHCONTF_NONFOLDERS = 64;

{ String constants for Interface IDs }

const
  SID_IShellLinkA  = '{000214EE-0000-0000-C000-000000000046}';
  SID_IShellLinkW  = '{000214F9-0000-0000-C000-000000000046}';
  SID_IShellFolder = '{000214E6-0000-0000-C000-000000000046}';
  SID_IEnumIDList  = '{000214F2-0000-0000-C000-000000000046}';

{ IShellLink Interface }

type
  IShellLinkA = interface(IUnknown)
    [SID_IShellLinkA]
    function GetPath(pszFile: PAnsiChar; cchMaxPath: Integer; var pfd: TWin32FindData; fFlags: DWORD): HResult; stdcall;
    function GetIDList(var ppidl: PItemIDList): HResult; stdcall;
    function SetIDList(pidl: PItemIDList): HResult; stdcall;
    function GetDescription(pszName: PAnsiChar; cchMaxName: Integer): HResult; stdcall;
    function SetDescription(pszName: PAnsiChar): HResult; stdcall;
    function GetWorkingDirectory(pszDir: PAnsiChar; cchMaxPath: Integer): HResult; stdcall;
    function SetWorkingDirectory(pszDir: PAnsiChar): HResult; stdcall;
    function GetArguments(pszArgs: PAnsiChar; cchMaxPath: Integer): HResult; stdcall;
    function SetArguments(pszArgs: PAnsiChar): HResult; stdcall;
    function GetHotkey(var pwHotkey: Word): HResult; stdcall;
    function SetHotkey(wHotkey: Word): HResult; stdcall;
    function GetShowCmd(out piShowCmd: Integer): HResult; stdcall;
    function SetShowCmd(iShowCmd: Integer): HResult; stdcall;
    function GetIconLocation(pszIconPath: PAnsiChar; cchIconPath: Integer; out piIcon: Integer): HResult; stdcall;
    function SetIconLocation(pszIconPath: PAnsiChar; iIcon: Integer): HResult; stdcall;
    function SetRelativePath(pszPathRel: PAnsiChar; dwReserved: DWORD): HResult; stdcall;
    function Resolve(Wnd: HWND; fFlags: DWORD): HResult; stdcall;
    function SetPath(pszFile: PAnsiChar): HResult; stdcall;
  end;

  IShellLinkW = interface(IUnknown)
    [SID_IShellLinkW]
    function GetPath(pszFile: PWideChar; cchMaxPath: Integer; var pfd: TWin32FindData; fFlags: DWORD): HResult; stdcall;
    function GetIDList(var ppidl: PItemIDList): HResult; stdcall;
    function SetIDList(pidl: PItemIDList): HResult; stdcall;
    function GetDescription(pszName: PWideChar; cchMaxName: Integer): HResult; stdcall;
    function SetDescription(pszName: PWideChar): HResult; stdcall;
    function GetWorkingDirectory(pszDir: PWideChar; cchMaxPath: Integer): HResult; stdcall;
    function SetWorkingDirectory(pszDir: PWideChar): HResult; stdcall;
    function GetArguments(pszArgs: PWideChar; cchMaxPath: Integer): HResult; stdcall;
    function SetArguments(pszArgs: PWideChar): HResult; stdcall;
    function GetHotkey(var pwHotkey: Word): HResult; stdcall;
    function SetHotkey(wHotkey: Word): HResult; stdcall;
    function GetShowCmd(out piShowCmd: Integer): HResult; stdcall;
    function SetShowCmd(iShowCmd: Integer): HResult; stdcall;
    function GetIconLocation(pszIconPath: PWideChar; cchIconPath: Integer; out piIcon: Integer): HResult; stdcall;
    function SetIconLocation(pszIconPath: PWideChar; iIcon: Integer): HResult; stdcall;
    function SetRelativePath(pszPathRel: PWideChar; dwReserved: DWORD): HResult; stdcall;
    function Resolve(Wnd: HWND; fFlags: DWORD): HResult; stdcall;
    function SetPath(pszFile: PWideChar): HResult; stdcall;
  end;
  IShellLink = IShellLinkA;

{ IEnumIDList interface }

type
  IEnumIDList = interface(IUnknown)
    [SID_IEnumIDList]
    function Next(celt: ULONG; out rgelt: PItemIDList; var pceltFetched: ULONG): HResult; stdcall;
    function Skip(celt: ULONG): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumIDList): HResult; stdcall;
  end;

{ record for returning strings from IShellFolder member functions }

type
  PSTRRet = ^TStrRet;
  _STRRET = record
     uType: UINT;                               { One of the STRRET_* values }
     case Integer of
       0: (pOleStr: LPWSTR);                    { must be freed by caller of GetDisplayNameOf }
       1: (pStr: LPSTR);                        { NOT USED }
       2: (uOffset: UINT);                      { Offset into SHITEMID (ANSI) }
       3: (cStr: array[0..MAX_PATH-1] of Char); { Buffer to fill in }
    end;
  TStrRet = _STRRET;
  STRRET = _STRRET;
  
{ structure STRRET for returning strings from IShellFolder member functions }

const
  STRRET_WSTR = $0000;
  STRRET_CSTR = $0002;

{ IShellFolder interface }

type
  IShellFolder = interface(IUnknown)
    [SID_IShellFolder]
    function ParseDisplayName(hwndOwner: HWND; pbcReserved: Pointer; lpszDisplayName: POLESTR; out pchEaten: ULONG; out ppidl: PItemIDList; var dwAttributes: ULONG): HResult; stdcall;
    function EnumObjects(hwndOwner: HWND; grfFlags: DWORD; out EnumIDList: IEnumIDList): HResult; stdcall;
    function BindToObject(pidl: PItemIDList; pbcReserved: Pointer; const riid: TIID; out ppvOut): HResult; stdcall;
    function BindToStorage(pidl: PItemIDList; pbcReserved: Pointer; const riid: TIID; out ppvObj): HResult; stdcall;
    function CompareIDs(lParam: LPARAM; pidl1, pidl2: PItemIDList): HResult; stdcall;
    function CreateViewObject(hwndOwner: HWND; const riid: TIID; out ppvOut): HResult; stdcall;
    function GetAttributesOf(cidl: UINT; var apidl: PItemIDList; var rgfInOut: UINT): HResult; stdcall;
    function GetUIObjectOf(hwndOwner: HWND; cidl: UINT; var apidl: PItemIDList; const riid: TIID; prgfInOut: Pointer; out ppvOut): HResult; stdcall;
    function GetDisplayNameOf(pidl: PItemIDList; uFlags: DWORD; var lpName: STRRET): HResult; stdcall;
    function SetNameOf(hwndOwner: HWND; pidl: PItemIDList; lpszName: POLEStr; uFlags: DWORD; var ppidlOut: PItemIDList): HResult; stdcall;
  end;

function SHGetMalloc(var ppMalloc: IMalloc): HResult; stdcall;
function SHGetFolderLocation(hWndOwner: HWND; csidl: Integer; hToken: THandle; dwReserved: DWORD; var pidl: PItemIDList): HResult; stdcall;
function SHGetDesktopFolder(var ppshf: IShellFolder): HResult; stdcall;
function SHGetSpecialFolderLocation(hwndOwner: HWND; nFolder: Integer; var ppidl: PItemIDList): HResult; stdcall;
function SHGetPathFromIDList(pidl: PItemIDList; pszPath: PChar): BOOL; stdcall;
function SHGetPathFromIDListA(pidl: PItemIDList; pszPath: PAnsiChar): BOOL; stdcall;
function SHGetPathFromIDListW(pidl: PItemIDList; pszPath: PWideChar): BOOL; stdcall;

implementation

const
  shell32 = 'shell32.dll';

function SHGetMalloc;                external shell32 name 'SHGetMalloc';
function SHGetFolderLocation;        external shell32 name 'SHGetFolderLocation';
function SHGetDesktopFolder;         external shell32 name 'SHGetDesktopFolder';
function SHGetSpecialFolderLocation; external shell32 name 'SHGetSpecialFolderLocation';
function SHGetPathFromIDList;        external shell32 name 'SHGetPathFromIDListA';
function SHGetPathFromIDListA;       external shell32 name 'SHGetPathFromIDListA';
function SHGetPathFromIDListW;       external shell32 name 'SHGetPathFromIDListW';

end.