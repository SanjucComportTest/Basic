

{*******************************************************************************

History
   -2009.10.27 :: Basic Functions Make & Copy
   -2009.11.17 :: Added KillTaskApp & RunTaskApp Functions

Creator : Sanjuc@paran.com 

*******************************************************************************}

Unit uCommon;

   Interface

   Uses
      Forms, Windows, Messages, Classes, SysUtils, DateUtils, Tlhelp32, ShellApi, Winsock;

      Procedure   Pause(MessageS:String);
      Function    PauseYN(MessageS:String):LongInt;
      Function    Evaluate(EvaluateCondition:Boolean;TrueValue,FalseValue:Variant):Variant;                       // Evaluate and get result as Variant
      Function    MidStr_(OrgS:String;StartC:Integer;LenC:Integer=-1):String;                                     // Equal Copy Function
      Function    AppPath:String;                                                                                 // ���������� ���丮 ��ġ
      Function    ConvertStrToDatetime(AStringDateTime: String): TDateTime;                                       // ���ڿ��� TDATETIME������ ��ȯ
      Function    CheckWideChar(AChar: Char) : Boolean;                                                           // 2����Ʈ ���� ����
      Function    GetWindowsVersion : String;                                                                     // ������ ���� �˾Ƴ���
      Function    GetCurrentFileVersion : String;                                                                 // ���� ���� �˾Ƴ���
      Procedure   StringParseDelimited(StrList : TStrings; Value, Delimiter : String);                            // Ư�����ڿ� �������� �߶󳻱�
      Function    DivWithExcept(A,B:Integer):Integer;                                                             // Div �Լ��� Ȯ����� (����ó��)
      Function    KillTaskApp (AExeFileName : String): Integer;                                                   // ���μ��� ���� ���� (For Win98/Win2000/WinXp From Torry.net)
      Function    RunTaskApp  (AExeFileFullName : String): Integer;                                               // ���μ��� ���� ����
      Function    GetMemoryStatus (var ATotalMemorySize: Integer; var AFreeMemorySize: Integer): Boolean;
      Function    Convert_32BitTo16Bit (ASourceValue : Word) : String;
      Procedure   DoSleep(AWaitMilliSecond: Int64);
      Function    GetClientIPAddr : String;
      Procedure   Process32List(Slist: TStrings);      


Implementation

//------------------------------------------------------------------------------------------------------------------
// Pause : Ư�� �޽����� �����ָ鼭 ���α׷��� ���ߴ� �Լ�
//------------------------------------------------------------------------------------------------------------------
   Procedure Pause(MessageS:String);
      Begin
         Windows.MessageBoxEx(0,PChar(MessageS),'DONGWOO',MB_OK+MB_ICONEXCLAMATION+MB_DEFBUTTON1+MB_TASKMODAL+MB_SETFOREGROUND+MB_TOPMOST,LANG_KOREAN);
      End;

//------------------------------------------------------------------------------------------------------------------
// PauseYN : Ư�� �޽����� �����ָ鼭 Y/N �� ���� �Լ�
//------------------------------------------------------------------------------------------------------------------
   Function PauseYN(MessageS:String):LongInt;
      Begin
         Result := Windows.MessageBoxEx(0,PChar(MessageS),'DONGWOO',MB_YESNO+MB_ICONQUESTION+MB_DEFBUTTON1+MB_TASKMODAL+MB_SETFOREGROUND+MB_TOPMOST,LANG_KOREAN);
      End;

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Evaluate : ���Ǻ� ����
//--------------------------------------------------------------------------------------------------------------------------------------------------------
   Function Evaluate(EvaluateCondition:Boolean;TrueValue,FalseValue:Variant):Variant;
      Begin
         If EvaluateCondition Then Result := TrueValue
                              Else Result := FalseValue;
      End;

//------------------------------------------------------------------------------------------------------------------
// MidStr : Copy�Լ��� ������ ���
//------------------------------------------------------------------------------------------------------------------
   Function MidStr_(OrgS:String;StartC:Integer;LenC:Integer=-1):String;
      Var
         I : Integer;
         R : String;
      Begin
         R := '';
         If LenC=-1 Then LenC := Length(OrgS)-StartC+1;
         If (StartC>0) And (LenC>0) Then
         Begin
            For I:=StartC To StartC+LenC-1 Do
            Begin
               If I>Length(OrgS) Then Break;
               R := R + OrgS[I];
            End;
         End;
         Result := R;
      End;

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// AppPath : ���������� ��ġ
//--------------------------------------------------------------------------------------------------------------------------------------------------------
   Function AppPath:String;
      Begin
         Result := ExtractFilePath(Application.ExeName);
      End;


//--------------------------------------------------------------------------------------------------------------------------------------------------------
// ConvertStrToDatetime : ���ڿ��� Datetime������ ��ȯ
// ���� String --> 2009-01-02 12:35:46
//--------------------------------------------------------------------------------------------------------------------------------------------------------
   Function ConvertStrToDatetime(AStringDateTime: String): TDateTime;
      Begin
         Result := EncodeDateTime(1900,1,1,0,0,0,0);
         //
         Try
            If Length(AStringDateTime)=19 Then
            Begin
               Result := EncodeDateTime(  StrToIntDef(MidStr_(AStringDateTime, 1,4), 2008),
                                          StrToIntDef(MidStr_(AStringDateTime, 6,2), 01),
                                          StrToIntDef(MidStr_(AStringDateTime, 9,2), 01),
                                          StrToIntDef(MidStr_(AStringDateTime, 12,2), 00),
                                          StrToIntDef(MidStr_(AStringDateTime, 15,2), 00),
                                          StrToIntDef(MidStr_(AStringDateTime, 18,2), 00),
                                          0);
            End;
         Except
            Result := EncodeDateTime(1900,1,1,0,0,0,0);
         End;
      End;

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// CheckWideChar : �ش� ĳ���Ͱ� 2����Ʈ �ڵ����� �Ǵ�
//--------------------------------------------------------------------------------------------------------------------------------------------------------
   Function CheckWideChar(AChar: Char) : Boolean;
      Begin
         Result := Evaluate( ByteType(AChar, 1)=mbLeadByte, True, False );
      End;


//------------------------------------------------------------------------------------------------------------------
// GetWindowsVersion : ������ ���� �˾Ƴ���
//------------------------------------------------------------------------------------------------------------------
   Function GetWindowsVersion : String;
      Var
         OS          : TOSVERSIONINFO;
         WindowsName : String;
      Begin
         WindowsName := 'UNKNOWN';
         OS.dwOSVersionInfoSize := SizeOf(OS);
            If GetVersionEx(OS) Then
            Case OS.dwPlatformId Of
               VER_PLATFORM_WIN32_NT:
                  Begin
                     Case OS.dwMajorVersion of
                        5:
                           Begin
                              Case OS.dwMinorVersion of
                                 0 : WindowsName := 'Win2000'  + IntToStr(OS.dwBuildNumber);
                                 1 : WindowsName := 'WinXP'    + IntToStr(OS.dwBuildNumber);
                                 2 : WIndowsName := 'Win2003'  + IntToStr(OS.dwBuildNumber);
                              End;
                           End;
                        6:
                           Begin
                              WindowsName := 'WinVista' + IntToStr(OS.dwBuildNumber);
                           End;
                        7:
                           Begin
                              WindowsName := 'Win7' + IntToStr(OS.dwBuildNumber);
                           End;
                     End;
                  End;
               VER_PLATFORM_WIN32_WINDOWS:
                  Begin
                  End;
               VER_PLATFORM_WIN32s:
                  Begin
                  End;
            End;
         Result := WindowsName;
      End;

//------------------------------------------------------------------------------------------------------------------
// GetFileVersion : ������Ʈ ���� ���� �˾Ƴ���
//------------------------------------------------------------------------------------------------------------------
   Function GetCurrentFileVersion: String;
      Const
         InfoStr: array[0..9] of string = ('CompanyName', 'FileDescription', 'FileVersion', 'InternalName', 'LegalCopyright', 'LegalTradeMarks', 'OriginalFileName', 'ProductName', 'ProductVersion', 'Comments');
      Var
         ExeName              : string;
         VerInfoSize, Len, i  : DWORD;
         Buf                  : PChar;
         Value                : PChar;
      Begin
         Result := '';
         //
         ExeName     := Application.ExeName;
         VerInfoSize := GetFileVersionInfoSize( PChar(ExeName), VerInfoSize );
         If VerInfoSize > 0 then
         Begin
            Buf := AllocMem(VerInfoSize);
            Try
               GetFileVersionInfo( PChar(ExeName), 0, VerInfoSize, Buf );
               For i := Low( InfoStr ) To High( InfoStr ) Do
                  If VerQueryValue(Buf, PChar( 'StringFileInfo\041203B5\' + InfoStr[i] ), Pointer(Value), Len) Then
                     If i = 2 Then
                        Result := Value;
            Finally
               FreeMem(Buf, VerInfoSize);
            End;
         End;
      End;


//--------------------------------------------------------------------------------------------------------------------------------------------------------
// StringParseDelimited @ From Delmadang :: Ư�� ���ڿ� �������� ©�󳻱�
//--------------------------------------------------------------------------------------------------------------------------------------------------------
   Procedure StringParseDelimited(StrList : TStrings; Value, Delimiter : String);
      Var
        ni, nj : Integer;
        si, sj : String;
      Begin
         nj := Length( Delimiter );
         sj := Value + Delimiter;
         //
         StrList.BeginUpdate;
         StrList.Clear;
         Try
            While Length(sj) > 0 do begin
               ni := Pos(Delimiter , sj);
               si := Copy(sj , 0 , ni-1 );
               StrList.Add(si);
               sj := Copy( sj , ni+nj , MaxInt);
            End;
         Finally
            StrList.EndUpdate;
         end;
      End;


//--------------------------------------------------------------------------------------------------------------------------------------------------------
// DivWithExcept
//--------------------------------------------------------------------------------------------------------------------------------------------------------
   Function DivWithExcept(A,B:Integer):Integer;
      Begin
         Try
            Result := A DIV B;
         Except
            On EDivByZero   do  Result := 0;
            On EZeroDivide  do  Result := 0;
            On EUnderflow   do  Result := 0;
         End;
      End;

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// KillTaskApp :: ���μ��� ���� ����
//
// :: For Win98/Win2000/WinXp
// :: From Torry.net
//--------------------------------------------------------------------------------------------------------------------------------------------------------
   Function KillTaskApp (AExeFileName : String): Integer;                                                   // ���μ��� ���� ���� ()
      Const
         PROCESS_TERMINATE = $0001;
      Var
         ContinueLoop      : BOOL;
         FSnapshotHandle   : THandle;
         FProcessEntry32   : TProcessEntry32;
      Begin
         Result := 0;
         FSnapshotHandle         := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
         FProcessEntry32.dwSize  := SizeOf(FProcessEntry32);
         ContinueLoop            := Process32First(FSnapshotHandle, FProcessEntry32);
         //
         While Integer(ContinueLoop) <> 0 Do
         Begin
            If ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(AExeFileName)) Or
               (UpperCase(FProcessEntry32.szExeFile) = UpperCase(AExeFileName)))                  Then
               Result      := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.th32ProcessID), 0));
            ContinueLoop   := Process32Next(FSnapshotHandle, FProcessEntry32);
         End;
         //
         CloseHandle(FSnapshotHandle);
      End;

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// RunTaskApp :: ���μ��� ���� ����
//--------------------------------------------------------------------------------------------------------------------------------------------------------
   Function RunTaskApp (AExeFileFullName : String): Integer;
      Begin
         Result := ShellExecute(0, 'Open', PChar(AExeFileFullName), Nil, Nil, SW_SHOWNORMAL);
      End;

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// GetMemoryStatus :: �޸� ��뷮 ��ȸ
//--------------------------------------------------------------------------------------------------------------------------------------------------------
   Function GetMemoryStatus (var ATotalMemorySize: Integer; var AFreeMemorySize: Integer): Boolean;
      Var
         MemStat : TMemoryStatus;
      Begin
         ATotalMemorySize  := 0;
         AFreeMemorySize   := 0;
         Result            := False;
         Try
            MemStat.dwLength := sizeof(TMemoryStatus);
            GlobalMemoryStatus(MemStat);
            With MemStat Do
            Begin
               ATotalMemorySize  := dwTotalPhys div 1024;         //KByte
               AFreeMemorySize   := dwAvailPhys div 1024;         //KByte
            End;
            Result := True;
         Except
         End;
      End;

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// GetMemoryStatus :: �޸� ��뷮 ��ȸ
//--------------------------------------------------------------------------------------------------------------------------------------------------------
   Function    Convert_32BitTo16Bit (ASourceValue : Word) : String;
      Begin
         Result := Chr($00) + Chr($00);
         Try
            Result := Chr(ASourceValue And $00FF) + Chr((ASourceValue AND $FF00) Shr 8)
         Except
         End
      End;

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// DoSleep :: 
//--------------------------------------------------------------------------------------------------------------------------------------------------------
   Procedure   DoSleep(AWaitMilliSecond: Int64);
      Var
         AWaitTime : TDatetime;
      Begin
         AWaitTime := IncMilliSecond(Now, AWaitMilliSecond);
         While (AWaitTime > Now) Do
         Begin
            Application.ProcessMessages;
         End;
      End;


   Function GetClientIPAddr : String;
      Type
         Name = array[0..100] of Char;
         PName = ^Name;
      Var
        HEnt     : pHostEnt;
        HName    : PName;
        WSAData  : TWSAData;
        i        : Integer;
        IPaddr   : String;
        WSAErr   : String;
        HostName : String;
      Begin
         IPaddr := '';
         WSAErr := '';
//         Result := False;
         If WSAStartup($0101, WSAData) <> 0 Then
         Begin
            WSAErr := 'Winsock is not responding."';
            Exit;
         End;
         //
         New(HName);
         If GetHostName(HName^, SizeOf(Name)) = 0 Then
         Begin
            HostName := StrPas(HName^);
            HEnt     := GetHostByName(HName^);
            For I := 0 To HEnt^.h_length - 1 Do
               IPaddr := Concat(IPaddr, IntToStr(Ord(HEnt^.h_addr_list^[i])) + '.');
            SetLength(IPaddr, Length(IPaddr) - 1);
            Result := IPAddr
//            Result := True;
         End
         Else
         Begin
            Case WSAGetLastError Of
               WSANOTINITIALISED:WSAErr:='WSANotInitialised';
               WSAENETDOWN      :WSAErr:='WSAENetDown';
               WSAEINPROGRESS   :WSAErr:='WSAEInProgress';
            End;
         End;
         Dispose(HName);
         WSACleanup;
      End;


   //-----------------------------------------------------------------------------------------
   // Process32List
   //-----------------------------------------------------------------------------------------
   Procedure Process32List(Slist: TStrings);
      Var
         Process32: TProcessEntry32;
         SHandle  : THandle;
         Next     : BOOL;
      Begin
         Process32.dwSize := SizeOf(TProcessEntry32);
         SHandle          := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
         if Process32First(SHandle, Process32) then
         begin
            Slist.AddObject(Process32.szExeFile, TObject(Process32.th32ProcessID));          // ����ȭ�ϸ�� process object ����
            repeat
               Next := Process32Next(SHandle, Process32);
               if Next then
                  Slist.AddObject(Process32.szExeFile, TObject(Process32.th32ProcessID));
            until not Next;
         end;
         CloseHandle(SHandle);                                                               // closes an open object handle
      End;      

End.






