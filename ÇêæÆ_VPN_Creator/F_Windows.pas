unit F_Windows;

interface

uses
  Windows;

const
  HEAP_ZERO_MEMORY = $00000008;

function GetVersionExW(var lpVersionInformation: TOSVersionInfoW): BOOL; stdcall;

implementation

function GetVersionExW; external kernel32 name 'GetVersionExW';

end.