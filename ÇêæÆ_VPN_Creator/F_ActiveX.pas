unit F_ActiveX;

interface

uses
  Windows;

{ Interface ID }

type
  PIID = PGUID;
  TIID = TGUID;

{ Class ID }

type
  PCLSID = PGUID;
  TCLSID = TGUID;
  TOleChar = WideChar;
  POleStr = PWideChar;
  PObjectID = ^TObjectID;
  TObjectID = record
    Lineage: TGUID;
    Uniquifier: Longint;
  end;

{ TSHItemID - Item ID }

type
  PSHItemID = ^TSHItemID;
  _SHITEMID = record
    cb  : Word;                         { Size of the ID (including cb itself) }
    abID: Array[0..0] of Byte;        { The item ID (variable length) }
  end;
  TSHItemID = _SHITEMID;
  SHITEMID = _SHITEMID;

{ TItemIDList - List if item IDs (combined with 0-terminator) }

type
  PItemIDList = ^TItemIDList;
  _ITEMIDLIST = record
     mkid: TSHItemID;
   end;
  TItemIDList = _ITEMIDLIST;
  ITEMIDLIST = _ITEMIDLIST;

{ from WTYPES.H }

const
  CLSCTX_INPROC_SERVER = 1;
  CLSCTX_LOCAL_SERVER  = 4;

{ IPersist interface }

type
  IPersist = interface(IUnknown)
    ['{0000010C-0000-0000-C000-000000000046}']
    function GetClassID(out classID: TCLSID): HResult; stdcall;
  end;

{ IPersistFile interface }

type
  IPersistFile = interface(IPersist)
    ['{0000010B-0000-0000-C000-000000000046}']
    function IsDirty: HResult; stdcall;
    function Load(pszFileName: POleStr; dwMode: Longint): HResult; stdcall;
    function Save(pszFileName: POleStr; fRemember: BOOL): HResult; stdcall;
    function SaveCompleted(pszFileName: POleStr): HResult; stdcall;
    function GetCurFile(out pszFileName: POleStr): HResult; stdcall;
  end;

{ IMalloc interface }

type
  IMalloc = interface(IUnknown)
    ['{00000002-0000-0000-C000-000000000046}']
    function Alloc(cb: Longint): Pointer; stdcall;
    function Realloc(pv: Pointer; cb: Longint): Pointer; stdcall;
    procedure Free(pv: Pointer); stdcall;
    function GetSize(pv: Pointer): Longint; stdcall;
    function DidAlloc(pv: Pointer): Integer; stdcall;
    procedure HeapMinimize; stdcall;
  end;

implementation

end.


