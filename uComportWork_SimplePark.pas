
{*******************************************************************************

      Comport Thread-Class For Simple Serial Socket

History
   -2010.02.22 ::
   -2010.02.25 ::


Creator : Sanjuc@lycos.co.kr

*******************************************************************************}

Unit uComportWork_SimplePark;

Interface

   Uses
      CodeSiteLogging,
      uCommon,
      Windows, Classes, Forms, StdCtrls, SysUtils, ExtCtrls, Controls, DateUtils, CPDrv;

   Const
      C_LOGFILE_NAME                      = 'COMM_SIMPLETESET';
      C_STX                               = Chr($82);
      C_ETX                               = Chr($83);
      C_COMMAND_SEXANDDISTANCE            = Chr($47);
      C_COMMAND_WORLD_RECORD              = Chr($48);
      C_COMMAND_KOREA_RECORD              = Chr($4F);
      C_COMMAND_ROLLING_TIME              = Chr($4A);
      C_COMMAND_POWER_ONOFF               = Chr($09);
      C_COMMAND_MIC_ONOFF                 = Chr($4D);
      C_COMMAND_MIC_STATUS                = Chr($43);

   Type
      TComport_FND = Class (TThread)
            FTerminate     : Boolean;
         Private
            FRecvCommData  : String;
            FErrorAlarm    : Boolean;
            FErrorMsg      : String;
            FComm          : TCommPortDriver;
            FCommBusy      : Boolean;
            FLastConnectTM : TDateTime;
            FReEnterance   : Boolean;
            Function    Crc16s(Comm: char; data:PChar; count:Integer):Word;
            Function    CalcCRC_XOR(AData: String): String;
            Procedure   CommReceiveData(Sender: TObject;  DataPtr: Pointer; DataSize: Cardinal);
            Function    SendCommand(ACommand: Char; AData: String): Boolean;
         Protected
            Procedure   Execute; override;
         Public
            //
            Constructor Create(AComNo: Integer; AComSpeed: Integer; AComParity: Char; AComDatabit: Integer; AComStopBit: Integer);
            //
            Function    GetConnection     : Boolean;
            Function    ReConnection      : Boolean;
            //
            Procedure   Send_MicOnOff(AChannel1Value: Boolean;  AChannel2Value: Boolean);
            Procedure   RequestStatus;
            //
      End;

   Var
     crc16tbl : array[0..255] of Word=(
        $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
        $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
        $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
        $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
        $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
        $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
        $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
        $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
        $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
        $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
        $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
        $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
        $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
        $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
        $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
        $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
        $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
        $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
        $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
        $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
        $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
        $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
        $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
        $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
        $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
        $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
        $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
        $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
        $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
        $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
        $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
        $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040);

Implementation

   //------------------------------------------------------------------------------------------------------------------------------------------
   //
   //------------------------------------------------------------------------------------------------------------------------------------------
   Function TComport_FND.Crc16s(Comm: char; data:PChar; coUnt:Integer):Word;
      Var
         i : Integer;
         accum, comb_val : Word;
      Begin
         accum := 0;
         For i:=0 To count-1 Do
         Begin
            If i = 0 Then
            Begin
               comb_val := accum xor Integer(Comm);
               accum := (accum shr 8) xor crc16tbl[comb_val and $00ff];
            End;
            comb_val := accum xor Integer(data[i]);
            accum := (accum shr 8) xor crc16tbl[comb_val and $00ff];
         End;
         Crc16s := accum;
      End;


   //------------------------------------------------------------------------------------------------------------------------------------------
   // OnRxBuf :: Commport로 들어오는 데이터를 저장한다.
   //------------------------------------------------------------------------------------------------------------------------------------------
   Procedure TComport_FND.CommReceiveData(Sender: TObject;  DataPtr: Pointer; DataSize: Cardinal);
      Var
         TempP  : PChar;
         TempS  : String;
         I      : Integer;
         vTempS : String;
      Begin
         TempP := DataPtr;
         TempS := '';
         While DataSize > 0 Do
            Begin
               TempS := TempS + TempP^;
               Inc (TempP);
               Dec (DataSize);
            End;
         FRecvCommData := FRecvCommData + TempS;
         //
         Codesite.Send('[BIN]CommReceiveData', FRecvCommData);
         vTempS := '';
         For I := 1 to Length(FRecvCommData) DO
            vTempS := vTempS + IntToHex(Byte(FRecvCommData[I]), 2) + ' ';
         Codesite.Send('[HEX]CommReceiveData', vTempS);

      End;

   //------------------------------------------------------------------------------------------------------------------------------------------
   // SendCommand ::
   //------------------------------------------------------------------------------------------------------------------------------------------
   Function TComport_FND.SendCommand(ACommand: Char; AData: String): Boolean;
      Var
         vTempSendPrepare  : String;
         vTempSendString   : String;
         vDataLength       : Integer;
//         vCrc_Value        : Integer;
         I      : Integer;
         vTempS : String;
      Begin
         Result           := False;
         vDataLength      := Length(AData);
         vTempSendPrepare := C_STX + ACommand + Chr(vDataLength) + AData;
//         vCrc_Value       := Crc16s(ACommand, Pchar(AData), Length(AData));
         //
         vTempSendString  := vTempSendPrepare + CalcCRC_XOR(vTempSendPrepare) + C_ETX;
         //
         If Not FErrorAlarm Then
         Begin
            If Not FReEnterance Then
            Begin
               FReEnterance := True;                                                         // 재진입 방지
               Try
                  FComm.FlushBuffers(True,True);
                  FRecvCommData := '';
                  CodeSite.Send('[BIN]SEND String',vTempSendString);
                  FComm.SendData(@vTempSendString[1], Length(vTempSendString));
                  //
                  vTempS := '';
                  For I := 1 to Length(vTempSendString) DO
                     vTempS := vTempS + IntToHex(Byte(vTempSendString[I]), 2) + ' ';
                  Codesite.Send('[HEX]SEND String', vTempS);

                  Result := True;
               Except
               End;
               FReEnterance := False;                                                        // 재진입 해제
            End
            Else
            Begin
               CodeSite.Send('SendCommand', 'SENDLOCK!!__LINE BUSY');
            End;
         End;
      End;

   //------------------------------------------------------------------------------------------------------------------------------------------
   // Execute
   //------------------------------------------------------------------------------------------------------------------------------------------
   Procedure TComport_FND.Execute;
      Begin
         While Not Terminated Do
         Begin
            //
            If FTerminate = True then Terminate;
            If (Not GetConnection) And (Now > FLastConnectTM) Then                        // 연결이 안되어 있으면 재접속 시도!!
            Begin
               FLastConnectTM := IncSecond(Now, 10);
               ReConnection;
            End;
            //
            Sleep(10);
         End;
      End;


   //------------------------------------------------------------------------------------------------------------------------------------------
   // Create
   //------------------------------------------------------------------------------------------------------------------------------------------
   Constructor TComport_FND.Create(AComNo: Integer; AComSpeed: Integer; AComParity: Char; AComDatabit: Integer; AComStopBit: Integer);
      Begin
         Inherited Create(True);
         //
         FLastConnectTM    := Now;
         FReEnterance      := False;                                    // 재진입 방지용
         //
         FComm                         := TCommPortDriver.Create(Nil);
         FComm.HwFlow                  := hfNone;
         FComm.SwFlow                  := sfNone;
         FComm.InBufSize               := 4096;
         FComm.OutBufSize              := 4096;
         FComm.OnReceiveData           := CommReceiveData;
         // Port Setting
         FComm.Port := pnCustom;
         FComm.PortName := '\\.\COM' + IntToStr(AComNo);

         // BaudRate Setting
         Case AComSpeed Of
            2400     :  FComm.BaudRate := br2400;
            4800     :  FComm.BaudRate := br4800;
            9600     :  FComm.BaudRate := br9600;
            14400    :  FComm.BaudRate := br14400;
            19200    :  FComm.BaudRate := br19200;
            38400    :  FComm.BaudRate := br38400;
            56000    :  FComm.BaudRate := br56000;
            57600    :  FComm.BaudRate := br57600;
            115200   :  FComm.BaudRate := br115200;
            128000   :  FComm.BaudRate := br128000;
            256000   :  FComm.BaudRate := br256000;
         End;
         // ParityBit Setting
         Case AComParity Of
            'N'   : FComm.Parity := ptNone;
            'E'   : FComm.Parity := ptEven;
            'O'   : FComm.Parity := ptODD;
            'S'   : FComm.Parity := ptSPACE;
            'M'   : FComm.Parity := ptMark;
         End;
         // DataBit Setting
         Case AComDatabit Of
            5 : FComm.DataBits := db5BITS;
            6 : FComm.DataBits := db6BITS;
            7 : FComm.DataBits := db7BITS;
            8 : FComm.DataBits := db8BITS;
         End;
         // StopBit Setting
         Case AComStopBit Of
            1  : FComm.StopBits := sb1BITS;
            2  : FComm.StopBits := sb2BITS;
            3  : FComm.StopBits := sb1HALFBITS;
         End;
         //
         FRecvCommData  := '';
         FErrorAlarm    := False;
         FErrorMsg      := '';
         FCommBusy      := False;
         //
         Resume;
      End;

   //------------------------------------------------------------------------------------------------------------------------------------------
   // GetConnection
   //------------------------------------------------------------------------------------------------------------------------------------------
   Function TComport_FND.GetConnection : Boolean;
      Begin
         Result := FComm.Connected;
      End;

   //------------------------------------------------------------------------------------------------------------------------------------------
   // ReConnection
   //------------------------------------------------------------------------------------------------------------------------------------------
   Function TComport_FND.ReConnection : Boolean;
      Begin
         If FComm.Connected Then FComm.Disconnect;
         Application.ProcessMessages;
         //
         Try
            FComm.Connect;
         Except
//            FLogMng.DisplayLog ('ExceptError CONNECTION' ,   '', $02, '');
         End;
         //
//         If Not FComm.Connected Then FLogMng.DisplayLog ('CAN NOT CONNECT!' ,   '', $02, '')
//                                Else FLogMng.DisplayLog ('CONNECT OK!' ,   '', $02, '');
         Result := FComm.Connected;
      End;


   //------------------------------------------------------------------------------------------------------------------------------------------
   // Send_MicOnOff
   //------------------------------------------------------------------------------------------------------------------------------------------
   Procedure TComport_FND.Send_MicOnOff(AChannel1Value, AChannel2Value: Boolean);
      Var
         vTempData      : String;
      Begin
         If Not FCommBusy Then
         Begin
            FCommBusy := True;                                       // ReEnterance Lock!!!
            //
            vTempData := Evaluate(AChannel1Value, '1', '0');
            vTempData := vTempData + Evaluate(AChannel2Value, '1', '0');
            //
            SendCommand(C_COMMAND_MIC_ONOFF, vTempData);
            CodeSite.Send('Send_MicOnOff', 'MicOnOff');
            //
            FCommBusy := False;                                      // ReEnterance UnLock!!!
         End;
      End;

   //------------------------------------------------------------------------------------------------------------------------------------------
   // CalcCRC_XOR
   //------------------------------------------------------------------------------------------------------------------------------------------
   Function TComport_FND.CalcCRC_XOR(AData: String): String;
      Var
         vTemp : Byte;
         I     : Integer;
      Begin
         vTemp := $00;
         Try
            For I := 1 to Length(AData) Do
            Begin
               vTemp := vTemp Xor Byte(AData[I]);
            End;
         Except
         End;
         Result := Chr(vTemp);
      End;

   //------------------------------------------------------------------------------------------------------------------------------------------
   // RequestStatus
   //------------------------------------------------------------------------------------------------------------------------------------------
   Procedure TComport_FND.RequestStatus;
      Var
         vTempData      : String;
      Begin
         If Not FCommBusy Then
         Begin
            FCommBusy := True;                                       // ReEnterance Lock!!!
            //
            SendCommand(C_COMMAND_MIC_STATUS, '');
            CodeSite.Send('RequestStatus', 'MicStatus');
            //
            FCommBusy := False;                                      // ReEnterance UnLock!!!
         End;
      End;

End.

