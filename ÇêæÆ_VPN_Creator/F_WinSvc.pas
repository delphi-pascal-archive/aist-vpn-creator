unit F_WinSvc;

interface

uses
  Windows;

type
  LPSERVICE_STATUS = ^SERVICE_STATUS;
  _SERVICE_STATUS = record
    dwServiceType: DWORD;
    dwCurrentState: DWORD;
    dwControlsAccepted: DWORD;
    dwWin32ExitCode: DWORD;
    dwServiceSpecificExitCode: DWORD;
    dwCheckPoint: DWORD;
    dwWaitHint: DWORD;
  end;
  SERVICE_STATUS = _SERVICE_STATUS;
  TServiceStatus = SERVICE_STATUS;
  PServiceStatus = LPSERVICE_STATUS;
  LPSERVICE_STATUS_PROCESS = ^SERVICE_STATUS_PROCESS;
  _SERVICE_STATUS_PROCESS = record
    dwServiceType: DWORD;
    dwCurrentState: DWORD;
    dwControlsAccepted: DWORD;
    dwWin32ExitCode: DWORD;
    dwServiceSpecificExitCode: DWORD;
    dwCheckPoint: DWORD;
    dwWaitHint: DWORD;
    dwProcessId: DWORD;
    dwServiceFlags: DWORD;
  end;
  SERVICE_STATUS_PROCESS = _SERVICE_STATUS_PROCESS;
  TServiceStatusProcess = SERVICE_STATUS_PROCESS;
  PServiceStatusProcess = LPSERVICE_STATUS_PROCESS;


//
// Service Status Enumeration Structure
//
  LPENUM_SERVICE_STATUSA = ^ENUM_SERVICE_STATUSA;
  {$EXTERNALSYM LPENUM_SERVICE_STATUSA}
  _ENUM_SERVICE_STATUSA = record
    lpServiceName: LPSTR;
    lpDisplayName: LPSTR;
    ServiceStatus: SERVICE_STATUS;
  end;
  {$EXTERNALSYM _ENUM_SERVICE_STATUSA}
  ENUM_SERVICE_STATUSA = _ENUM_SERVICE_STATUSA;
  {$EXTERNALSYM ENUM_SERVICE_STATUSA}
  TEnumServiceStatusA = ENUM_SERVICE_STATUSA;
  PEnumServiceStatusA = LPENUM_SERVICE_STATUSA;
  LPENUM_SERVICE_STATUSW = ^ENUM_SERVICE_STATUSW;
  {$EXTERNALSYM LPENUM_SERVICE_STATUSW}
  _ENUM_SERVICE_STATUSW = record
    lpServiceName: LPWSTR;
    lpDisplayName: LPWSTR;
    ServiceStatus: SERVICE_STATUS;
  end;
  {$EXTERNALSYM _ENUM_SERVICE_STATUSW}
  ENUM_SERVICE_STATUSW = _ENUM_SERVICE_STATUSW;
  {$EXTERNALSYM ENUM_SERVICE_STATUSW}
  TEnumServiceStatusW = ENUM_SERVICE_STATUSW;
  PEnumServiceStatusW = LPENUM_SERVICE_STATUSW;
  PEnumServiceStatus = PEnumServiceStatusA;

  _SC_STATUS_TYPE = (SC_STATUS_PROCESS_INFO);
  SC_STATUS_TYPE = _SC_STATUS_TYPE;

//
// Handle Types
//

  {$EXTERNALSYM SC_HANDLE}
  SC_HANDLE = THandle;
  {$EXTERNALSYM LPSC_HANDLE}
  LPSC_HANDLE = ^SC_HANDLE;

const  //
// Service State -- for Enum Requests (Bit Mask)
//
  {$EXTERNALSYM SERVICE_ACTIVE}
  SERVICE_ACTIVE                 = $00000001;
  {$EXTERNALSYM SERVICE_INACTIVE}
  SERVICE_INACTIVE               = $00000002;
  {$EXTERNALSYM SERVICE_STATE_ALL}
  SERVICE_STATE_ALL              = (SERVICE_ACTIVE   or
                                    SERVICE_INACTIVE);


//
// Service Control Manager object specific access types
//
  {$EXTERNALSYM SC_MANAGER_CONNECT}
  SC_MANAGER_CONNECT             = $0001;
  {$EXTERNALSYM SC_MANAGER_CREATE_SERVICE}
  SC_MANAGER_CREATE_SERVICE      = $0002;
  {$EXTERNALSYM SC_MANAGER_ENUMERATE_SERVICE}
  SC_MANAGER_ENUMERATE_SERVICE   = $0004;
  {$EXTERNALSYM SC_MANAGER_LOCK}
  SC_MANAGER_LOCK                = $0008;
  {$EXTERNALSYM SC_MANAGER_QUERY_LOCK_STATUS}
  SC_MANAGER_QUERY_LOCK_STATUS   = $0010;
  {$EXTERNALSYM SC_MANAGER_MODIFY_BOOT_CONFIG}
  SC_MANAGER_MODIFY_BOOT_CONFIG  = $0020;

  {$EXTERNALSYM SC_MANAGER_ALL_ACCESS}
  SC_MANAGER_ALL_ACCESS          = (STANDARD_RIGHTS_REQUIRED or
                                    SC_MANAGER_CONNECT or
                                    SC_MANAGER_CREATE_SERVICE or
                                    SC_MANAGER_ENUMERATE_SERVICE or
                                    SC_MANAGER_LOCK or
                                    SC_MANAGER_QUERY_LOCK_STATUS or
                                    SC_MANAGER_MODIFY_BOOT_CONFIG);

//
// Service object specific access type
//
  SERVICE_STOP                   = $0020;
  SERVICE_QUERY_STATUS           = $0004;
  SERVICE_ENUMERATE_DEPENDENTS   = $0008;
//
// Service State -- for CurrentState
//
  {$EXTERNALSYM SERVICE_STOPPED}
  SERVICE_STOPPED                = $00000001;
  {$EXTERNALSYM SERVICE_START_PENDING}
  SERVICE_START_PENDING          = $00000002;
  {$EXTERNALSYM SERVICE_STOP_PENDING}
  SERVICE_STOP_PENDING           = $00000003;
  {$EXTERNALSYM SERVICE_RUNNING}
  SERVICE_RUNNING                = $00000004;
  {$EXTERNALSYM SERVICE_CONTINUE_PENDING}
  SERVICE_CONTINUE_PENDING       = $00000005;
  {$EXTERNALSYM SERVICE_PAUSE_PENDING}
  SERVICE_PAUSE_PENDING          = $00000006;
  {$EXTERNALSYM SERVICE_PAUSED}
  SERVICE_PAUSED                 = $00000007;
//
// Controls
//
  {$EXTERNALSYM SERVICE_CONTROL_STOP}
  SERVICE_CONTROL_STOP           = $00000001;
  {$EXTERNALSYM SERVICE_CONTROL_PAUSE}
  SERVICE_CONTROL_PAUSE          = $00000002;
  {$EXTERNALSYM SERVICE_CONTROL_CONTINUE}
  SERVICE_CONTROL_CONTINUE       = $00000003;
  {$EXTERNALSYM SERVICE_CONTROL_INTERROGATE}
  SERVICE_CONTROL_INTERROGATE    = $00000004;
  {$EXTERNALSYM SERVICE_CONTROL_SHUTDOWN}
  SERVICE_CONTROL_SHUTDOWN       = $00000005;

function OpenSCManagerA(lpMachineName: LPCWSTR; lpDatabaseName: LPCSTR; dwDesiredAccess: DWORD): SC_HANDLE; stdcall;
function OpenSCManagerW(lpMachineName: LPCWSTR; lpDatabaseName: LPCWSTR; dwDesiredAccess: DWORD): SC_HANDLE; stdcall;
function OpenSCManager(lpMachineName: LPCWSTR; lpDatabaseName: LPCSTR; dwDesiredAccess: DWORD): SC_HANDLE; stdcall;

function OpenServiceA(hSCManager: SC_HANDLE; lpServiceName: LPCSTR; dwDesiredAccess: DWORD): SC_HANDLE; stdcall;
function OpenServiceW(hSCManager: SC_HANDLE; lpServiceName: LPCWSTR; dwDesiredAccess: DWORD): SC_HANDLE; stdcall;
function OpenService(hSCManager: SC_HANDLE; lpServiceName: LPCSTR; dwDesiredAccess: DWORD): SC_HANDLE; stdcall;

function CloseServiceHandle(hSCObject: SC_HANDLE): BOOL; stdcall;

function QueryServiceStatusEx(hService: SC_HANDLE; InfoLevel: SC_STATUS_TYPE; lpBuffer: PByte; cbBufSize: DWORD; var pcbBytesNeeded: DWORD): BOOL; stdcall;

function ControlService(hService: SC_HANDLE; dwControl: DWORD; var lpServiceStatus: TServiceStatusProcess): BOOL; stdcall;

function EnumDependentServicesA(hService: SC_HANDLE; dwServiceState: DWORD; lpServices: LPENUM_SERVICE_STATUSA; cbBufSize: DWORD; var pcbBytesNeeded, lpServicesReturned: DWORD): BOOL; stdcall;
function EnumDependentServicesW(hService: SC_HANDLE; dwServiceState: DWORD; lpServices: LPENUM_SERVICE_STATUSW; cbBufSize: DWORD; var pcbBytesNeeded, lpServicesReturned: DWORD): BOOL; stdcall;
function EnumDependentServices(hService: SC_HANDLE; dwServiceState: DWORD; lpServices: LPENUM_SERVICE_STATUSA; cbBufSize: DWORD; var pcbBytesNeeded, lpServicesReturned: DWORD): BOOL; stdcall;

implementation

function OpenSCManagerA; external advapi32 name 'OpenSCManagerA';
function OpenSCManagerW; external advapi32 name 'OpenSCManagerW';
function OpenSCManager; external advapi32 name 'OpenSCManagerA';

function OpenServiceA; external advapi32 name 'OpenServiceA';
function OpenServiceW; external advapi32 name 'OpenServiceW';
function OpenService; external advapi32 name 'OpenServiceA';

function CloseServiceHandle; external advapi32 name 'CloseServiceHandle';

function QueryServiceStatusEx; external advapi32 name 'QueryServiceStatusEx';

function ControlService; external advapi32 name 'ControlService';

function EnumDependentServicesA; external advapi32 name 'EnumDependentServicesA';
function EnumDependentServices; external advapi32 name 'EnumDependentServicesW';
function EnumDependentServicesW; external advapi32 name 'EnumDependentServicesA';

end.
