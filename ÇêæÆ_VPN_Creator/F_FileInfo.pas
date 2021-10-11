unit F_FileInfo;

interface

uses
  Windows, F_SysUtils, F_Windows;

type
  PStringFileInfoW = ^TStringFileInfoW;
  TStringFileInfoW = packed record
    pszCompanyName     : WideString;
    pszFileDescription : WideString;
    pszFileVersion     : WideString;
    pszInternalName    : WideString;
    pszLegalCopyright  : WideString;
    pszLegalTrademarks : WideString;
    pszOriginalFilename: WideString;
    pszProductName     : WideString;
    pszProductVersion  : WideString;
    pszComments        : WideString;
    pszPrivateBuild    : WideString;
    pszSpecialBuild    : WideString;
    pszLanguageName    : WideString;
    pszLanguageID      : WideString;
  end;

procedure GetFileInfoW(sAppName: WideString; var sfi: TStringFileInfoW);

implementation

var
  AQueryValue: Array [1..14] of WideString = (
    'CompanyName',
    'FileDescription',
    'FileVersion',
    'InternalName',
    'LegalCopyright',
    'LegalTrademarks',
    'OriginalFileName',
    'ProductName',
    'ProductVersion',
    'Comments',
    'PrivateBuild',
    'SpecialBuild',
    'LanguageName',
    'LanguageID'
  );

procedure GetFileInfoW(sAppName: WideString; var sfi: TStringFileInfoW);
type
  TChrSet = Array [0..1] of Word;
  PChrset = ^TChrSet;
var
  pcValue : PChrSet;
  iAppSize: DWORD;
  pcBuf   : Pointer;
  puLen   : DWORD;
  sLangID : WideString;

  function GetFileInfoProcW(sQueryValue: WideString): WideString;
  var
    sBlock: WideString;
    pInfo : Pointer;
  begin
    sBlock := FormatW('\StringFileInfo\%s\%s', [sLangID, sQueryValue]);
    if VerQueryValueW(pcBuf, @sBlock[1], pInfo, puLen) then
      Result := PWideChar(pInfo)
    else
      Result := '';
  end;

begin
  iAppSize := GetFileVersionInfoSizeW(@sAppName[1], iAppSize);
  if (iAppSize > 0) then
  try
    pcBuf := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, iAppSize);
    GetFileVersionInfoW(@sAppName[1], 0, iAppSize, pcBuf);
    VerQueryValueW(pcBuf, '\VarFileInfo\Translation', Pointer(pcValue), puLen);
    if (puLen > 0) then
    try

      sLangID := FormatW('%.4x%.4x',[pcValue[0], pcValue[1]]);

      sfi.pszCompanyName      := GetFileInfoProcW(AQueryValue[1]);
      sfi.pszFileDescription  := GetFileInfoProcW(AQueryValue[2]);
      sfi.pszFileVersion      := GetFileInfoProcW(AQueryValue[3]);
      sfi.pszInternalName     := GetFileInfoProcW(AQueryValue[4]);
      sfi.pszLegalCopyright   := GetFileInfoProcW(AQueryValue[5]);
      sfi.pszLegalTrademarks  := GetFileInfoProcW(AQueryValue[6]);
      sfi.pszOriginalFilename := GetFileInfoProcW(AQueryValue[7]);
      sfi.pszProductName      := GetFileInfoProcW(AQueryValue[8]);
      sfi.pszProductVersion   := GetFileInfoProcW(AQueryValue[9]);
      sfi.pszComments         := GetFileInfoProcW(AQueryValue[10]);
      sfi.pszPrivateBuild     := GetFileInfoProcW(AQueryValue[11]);
      sfi.pszSpecialBuild     := GetFileInfoProcW(AQueryValue[12]);
      sfi.pszLanguageName     := GetFileInfoProcW(AQueryValue[13]);
      sfi.pszLanguageID       := GetFileInfoProcW(AQueryValue[14]);

    finally
    end;
  finally
    HeapFree(GetProcessHeap, 0, pcBuf);
  end;
end;

end.