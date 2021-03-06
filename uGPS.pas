unit uGPS;

interface

  uses
    Classes, SysUtils, IdIOHandler, idGlobal, uCRC,Math;

  type 
    TOnLoginEvent = procedure(IMEI: string; Serial: word;ip: string);
    TOnLocationEvent = procedure(IMEI: string; Serial: word);

  procedure onRecieve(handler: TIdIOHandler; var s: string; var Terminal: TStringList;ip: string);
  
  procedure write(handler: TIdIOHandler; protocol: byte; information: TIdBytes; serial: word);

  procedure onLogin(event: TOnLoginEvent);
  procedure readLogin(data: TidBytes; serial: word; handler: TIdIOHandler; var Terminal: TStringList;ip: string);
  procedure writeLogin(handler: TIdIOHandler; serial: word);

  procedure onLocation(event: TOnLocationEvent);
  procedure readLocation(data: TidBytes; serial: word; handler: TIdIOHandler;var Terminal: TStringList;ip: string);
//  procedure writeLocation(handler: TIdIOHandler; serial: word);

implementation

uses Unit4;

  const
    StartBit = $7878;
    StopBit = $0D0A;

    pLogin = $01;
    pLocation = $12;
    pStatus = $13;
    pString = $15;
    pAlarm = $16;
    pPhone = $1A;
    pCommand = $80;

  var
    onLoginEvent: TOnLoginEvent;
    onLocationEvent: TOnLocationEvent;

/////////////////////////////////////

function subBytes(bytes: TIdBytes; start, len: integer): TidBytes;
var
  i: Integer;
begin
  setLength(result, len);
  for i := 0 to len - 1 do
    Result[i] := bytes[i + start];
end;

function PosteCardinal(bytes: TIdBytes; start, len: integer): TidBytes;
var
  i: Integer;
begin
  setLength(result, len);
  for i := 0 to len - 1 do
    Result[i] := bytes[i + start];
end;

function crc(len, protocol: byte; information: TIdBytes; serial: word): word;
var data: TidBytes;
    i: Integer;
begin
  SetLength(data, len - 1);
  data[0] := len;
  data[1] := protocol;
  for i := 0 to len - 6 do
    data[i + 2] := information[i];
  data[len - 3] := serial SHR 8;
  data[len - 2] := serial AND $FF;
  result := uCRC.crc(data);
end;

procedure onRecieve(handler: TIdIOHandler; var s: string; var Terminal: TStringList;ip: string);
var
  information: TIdBytes;
  len, protocol: byte;
  start, serial, error, stop: word;
begin
  start := handler.ReadWord;
  len := handler.ReadByte;
  protocol := handler.ReadByte;
  handler.ReadBytes(information, len - 5, false);
  serial := handler.ReadWord;
  error := handler.ReadWord;
  stop := handler.ReadWord;
  if (start = StartBit) and (stop = StopBit) then
    if error = crc(len, protocol, information, serial) then begin
      case protocol of
      pLogin: readLogin(information, serial, handler,Terminal,ip);
      pLocation: readLocation(information, serial, handler,Terminal,ip);
      pStatus: s := 'Status information';
      pString: s := 'String information';
      pAlarm: s := 'Alarm Data';
      pPhone: s := 'GPS by Phone number';
      pCommand: s := 'Server command information';
      end;
      s := s + '(' + IntToStr(serial) + ')';
    end else raise Exception.Create('Data corrupted')
  else raise Exception.Create('Error');
end;

procedure write(handler: TIdIOHandler; protocol: byte; information: TIdBytes; serial: word);
var len: byte;
    error: TIdBytes;
begin
  len := Length(information) + 5;
  handler.Write(StartBit);
  handler.Write(len);
  handler.Write(protocol);
  handler.Write(serial);
  handler.Write(crc(len, protocol, information, serial));
  handler.Write(StopBit);
end;

////////// LOGIN //////////

procedure onLogin(event: TOnLoginEvent);
begin
  onLoginEvent := event;
end;

procedure readLogin(data: TidBytes; serial: word; handler: TIdIOHandler; var Terminal: TStringList;ip: string);
var imei: string;
  i: Integer;
begin
  try
    for i := 0 to length(data) - 1 do
      imei := imei + ByteToHex(data[i]); //352887077921744
    Terminal.Add(ip+'='+imei);
    onLoginEvent(imei, serial,ip);
  finally
    writeLogin(handler, serial)
  end;
end;

procedure writeLogin(handler: TIdIOHandler; serial: word);
begin
  write(handler, pLogin, [], serial);
end;

////////// LOCATION //////////

procedure onLocation(event: TOnLocationEvent);
begin
  onLocationEvent := event;
end;

function bytesToWord(bytes: TidBytes): word; // 2 bytes
begin
  result := bytes[0] * 256 + bytes[1];
end;
function bytesToCardinal(bytes: TidBytes): cardinal; // 4 bytes
begin
  result := bytes[0] * 256*256*256 + bytes[1] * 256*256 + bytes[2] * 256 + bytes[3];
end;

procedure readLocation(data: TidBytes; serial: word; handler: TIdIOHandler;var Terminal: TStringList;ip: string);
var 
  satellites, speed, MNC: byte;
  course, MCC, LAC: word;
  CellID: Cardinal;
  lat, lng: Double;
  DateTimeBuffer, CellIDBuffer,latBuffer,lngBuffer: TIdBytes;
  date,v1,v2,v3,v4,Diclat: string;
  i : integer;
begin
  try
    //0 6 7 11 15 16 18 20 21 23
    Form4.Memo1.Lines.Add(ip+' : '+Terminal.Values[ip]);
    DateTimeBuffer := subBytes(data, 0, 6);
    date := '20'+IntToStr(StrToInt('$'+ByteToHex(DateTimeBuffer[0])));
    date := date + '/'+IntToStr(StrToInt('$'+ByteToHex(DateTimeBuffer[1])));
    date := date + '/'+IntToStr(StrToInt('$'+ByteToHex(DateTimeBuffer[2])));
    date := date + ' '+IntToStr(StrToInt('$'+ByteToHex(DateTimeBuffer[3])));
    date := date + ':'+IntToStr(StrToInt('$'+ByteToHex(DateTimeBuffer[4])));
    date := date + ':'+IntToStr(StrToInt('$'+ByteToHex(DateTimeBuffer[5])));
    {try
          for i := 0 to length(DateTimeBuffer) - 1 do
                  date := date+'/' + IntToStr(StrToInt('$'+ByteToHex(DateTimeBuffer[i])));

                      finally
                            Form4.Memo1.Lines.Add('date on hex : '+date);
                                end;}
    Form4.Memo1.Lines.Add(date);
    satellites := data[6];


    //Diclat := ((StrToInt('$'+v4) * Power(256,3)) + (StrToInt('$'+v3) * Power(256,2)) + (StrToInt('$'+v2) * 256) + (StrToInt('$'+v1)));
    //Form4.Memo1.Lines.Add('int : '+Diclat);
    latBuffer :=  subBytes(data, 7, 4);
    lngBuffer := subBytes(data, 11, 4);

    lat := bytesToCardinal(latBuffer) / 1800000;//BytesToUInt32(subBytes(data, 7, 4)) / 1800000;
    lng := bytesToCardinal(lngBuffer) / 1800000;//BytesToUInt32(subBytes(data, 11, 4)) / 1800000 - 90;

    Form4.Memo1.Lines.Add(stringreplace(lat.ToString, ',', '.',
                          [rfReplaceAll, rfIgnoreCase])+','+stringreplace(lng.ToString, ',', '.',
                          [rfReplaceAll, rfIgnoreCase]));
    speed := data[15];
    course := BytesToUInt16(subBytes(data, 16, 2));
    MCC := BytesToUInt16(subBytes(data, 18, 2));
    MNC := data[20];
    LAC := BytesToUInt16(subBytes(data, 21, 2));
    CellID := BytesToUInt32(subBytes(data, 23, 3))
//    onLoginEvent(imei, serial);
  finally
    writeLogin(handler, serial)
  end;
end;

//procedure writeLogin(handler: TIdIOHandler; serial: word);
//begin
//  write(handler, pLogin, [], serial);
//end;

end.
