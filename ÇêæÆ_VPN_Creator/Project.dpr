program Project;

{*******************************************************************************
* Project    : AVPN
* Start      : Thursday, Sep 17, 2009
* Copyright  : © 2009-2010 Maksim V.
* E-Mail     : maks1509@inbox.ru
*
* The contents of this file are subject to the Mozilla Public License
* Version 1.1 (the "License"); you may not use this file except in
* compliance with the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS"
* basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
* License for the specific language governing rights and limitations
* under the License.
*
* Version    : 1.0.0.3
* Date       : 03-04-2010
* Description: AVPN is a program for create a VPN connection for AIST users
*******************************************************************************}

{$RESOURCE .\Resources\Bitmap.res}
{$RESOURCE .\Resources\Dialog.res}
{$RESOURCE .\Resources\IconGroup.res}
{$RESOURCE .\Resources\Manifest.res}
{$RESOURCE .\Resources\StringTable.res}
{$RESOURCE .\Resources\VersionInfo.res}

uses
  F_WinMain;

begin

  WinMain(hInstance, System.hPrevInst, System.CmdLine, System.CmdShow);

end.