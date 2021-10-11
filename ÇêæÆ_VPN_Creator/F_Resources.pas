unit F_Resources;

interface

uses
  Windows, CommCtrl, F_FileInfo;

const

  { id dialog resources }

  RC_DIALOG_WELCOME   = 101;
  RC_DIALOG_SETTINGS  = 102;
  RC_DIALOG_FINISH    = 103;
  RC_DIALOG_UPDATE    = 104;

  { id icon resources }

  RC_ICONEX_CAPTION   = 101;

  { id bitmap resources }

  RC_BITMAP_WATERMARK = 101;
  RC_BITMAP_HEADER    = 102;
  RC_BITMAP_WAITING   = 103;

  { id dialog controls #101 }

  IDC_STATIC_WELCOME  = 10101;

  { id dialog controls #102 }

  IDC_STATIC_ENTRY    = 10201;
  IDC_STATIC_SERVER   = 10202;
  IDC_COMBO_SERVER    = 10203;
  IDC_STATIC_USER     = 10204;
  IDC_STATIC_PASSW    = 10205;
  IDC_STATIC_WARN     = 10206;

  { id dialog controls #103 }

  IDC_STATIC_FINISH   = 10301;
  IDC_STATIC_VPNINFO  = 10302;
  IDC_CHECK_SHORTCUT  = 10303;

  { id dialog controls #104 }

  IDC_STATIC_ANIMATE  = 10401;
  IDC_STATIC_ADDRESS  = 10402;

  { id stringtable resources }

  RC_STRING_CWINDOW   = 1600;
  RC_STRING_COPYRUN   = 1601;
  RC_STRING_QCANCEL   = 1602;
  RC_STRING_RESMAN    = 1603;

  RC_STRING_THEADER   = 1616;
  RC_STRING_SHEADER   = 1617;

  RC_STRING_VPNINFO   = 1632;

  RC_STRING_IPSERVER  = 1648;
  RC_STRING_IPHOST    = 1649;

var
  psp    : TPropSheetPageW;
  ahpsp  : Array [0..2] of HPropSheetPage;
  hApp   : Array [0..3] of HWND;
  exeInfo: TStringFileInfoW;
  pszServ: WideString = 'server.avtograd.ru';
  hThread: DWORD;

implementation

end.