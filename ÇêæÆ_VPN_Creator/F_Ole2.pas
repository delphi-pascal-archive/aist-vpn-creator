unit F_Ole2;

interface

uses
  F_ActiveX, F_ShlObj;

function CoInitialize(pvReserved: Pointer): HResult; stdcall;
procedure CoUninitialize; stdcall;
function CoCreateInstance(const clsid: TCLSID; unkOuter: IUnknown; dwClsContext: Longint; const iid: TIID; var pv): HResult; stdcall;

implementation

const
  ole32 = 'ole32.dll';

function CoInitialize;     external ole32 name 'CoInitialize';
procedure CoUninitialize;  external ole32 name 'CoUninitialize';
function CoCreateInstance; external ole32 name 'CoCreateInstance';

end.