unit UnitFunctions;

{
  Observações:
  - Os comentários descrevem o comportamento atual de cada função.
  - As funções Encript/Decript/Cript não devem ser usadas como criptografia segura.
}


interface

const
  UltimoDoMes: array [1 .. 12] of integer = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

  // --PARAMETROS TIPO MODAL-----------------------------------------------------
  MODAL_TEXT = 0;
  MODAL_ALERT = 1;
  MODAL_SUCCESS = 2;
  MODAL_ERROR = 3;
  MODAL_INFO = 4;
  MODAL_CONFIRM = 5;
  MODAL_SN = 6;
  MODAL_BAR = 7;
  MODAL_ERROR_NA = 8;
  MODAL_ALERT_NA = 9;

  // --PARAMETROS TIPO TOAST-----------------------------------------------------
  TOAST_TEXT = 0;
  TOAST_ALERT = 1;
  TOAST_SUCCESS = 2;
  TOAST_ERROR = 3;
  TOAST_INFO = 4;

type
  GridAuxiliar = class(TStringGrid);

  TCheckListOperacao = (osMarcarTodos, osDesmarcarTodos, osInverter);

  TObjectId = class(TComponent)
  public
    Id: integer;
  end;

  TTravaFinanceiro = (tfNaoTrava, tfConciliacao, tfDataServidor,
    tfConciliacaoAdiantada);
  THackTextControl = class(TControl);

  TSpecialValue = class(TObject)
  public
    Value: string;
    Contagem: boolean;
    constructor Create;
  end;

  THackButtonControl = class(TButtonControl)
  public
    property Checked;
  end;

  TSGSortCompareProc = function(SG: TStringGrid;
    Col, Row1, Row2: integer): integer;

  TDefValue = class(TComponent)
  public
    FieldName: string;
    Value: Variant;
    OnlyNullSource: boolean;
    constructor Create(AOwner: TComponent; AFieldName: string; AValue: Variant;
      AOnlyNullSource: boolean = false); reintroduce;
  end;

  TRGBArray = array [Word] of TRGBTriple;
  pRGBArray = ^TRGBArray;

// Desabilita ou habilita recursivamente os controles visuais dentro de um container e, quando possível, altera a cor deles.

procedure DisableWinControlsRecursive(Container: TControl; aEnabled: boolean; aColor: TColor = clWindow);

implementation

constructor TDefValue.Create(AOwner: TComponent; AFieldName: string; AValue: Variant;
  AOnlyNullSource: boolean = false);
begin
  FieldName := AFieldName;
  Value := AValue;
  OnlyNullSource := AOnlyNullSource;
  inherited Create(AOwner);
end;

constructor TSpecialValue.Create;
begin
  Contagem := false;
end;

// Desabilita ou habilita recursivamente os controles visuais dentro de um container e, quando possível, altera a cor deles.

procedure DisableWinControlsRecursive(Container: TControl; aEnabled: boolean; aColor: TColor = clWindow);
var
  I: integer;
  WC: TWinControl;
  function Test: boolean;
  begin
    Result := (not(Container is TLabel)) and
              (not(Container is TTabSheet)) and
              (not(Container is TGroupBox)) and
              (not(Container is TFrame)) and
              (not(Container is TPageControl)) and
              (not(Container is TPanel)) and
              (not(Container is TForm));
  end;

begin
  if (Test) then
  begin
    Container.Enabled := aEnabled;
    if (IsPublishedProp(Container, 'Color')) and (not(Container is TCheckBox)) then
      SetPropValue(Container, 'Color', aColor);
  end;
  if (Container is TWinControl) then
  begin
    WC := (Container as TWinControl);
    for I := 0 to WC.ControlCount - 1 do
    begin
      DisableWinControlsRecursive(WC.Controls[I], aEnabled, aColor);
    end;
  end;
end;


// Converte uma string em número decimal, removendo o separador de milhares. Retorna zero quando o texto está vazio.
function StrToFloatEx(S: string): Extended;
var
  I: integer;
  Temp: string;
begin
  if (Trim(S) <> '') then
  begin
    for I := 1 to Length(S) do
      if (S[I] <> FormatSettings.ThousandSeparator) then
        Temp := Temp + S[I];
    Result := StrToFloat(Temp);
  end
  else
  begin
    Result := 0;
  end;
end;

// Retorna a quantidade de caracteres existentes depois da vírgula decimal.
function ContaDecimais(S: string): Integer;
begin
  if (Trim(S) <> '') then
  begin
    Result := Length(S)-Pos(',',S);
  end
  else
  begin
    Result := 0;
  end;
end;


// Converte uma string em número decimal. Se a conversão falhar ou o texto estiver vazio, retorna o valor padrão informado.
function StrToFloatForce(S: string; Force: Extended = 0): Extended;
var
  I: integer;
  e: Extended;
  Temp: string;
begin
  if (Trim(S) <> '') then
  begin
    for I := 1 to Length(S) do
      if (S[I] <> FormatSettings.ThousandSeparator) then
        Temp := Temp + S[I];
    if (TryStrToFloat(Temp, e)) then
    begin
      Result := e;
    end
    else
    begin
      Result := Force;
    end;
  end
  else
  begin
    Result := Force;
  end;
end;

// Converte uma string em Variant numérico ou retorna Null quando o texto está vazio.
function StrToVarFloatEx(S: string): Variant;
begin
  if(Trim(S)='')then
  begin
    Result := NULL;
  end else
  begin
    Result := StrToFloatEx(S);
  end;
end;

// Converte uma string em inteiro, removendo o separador de milhares. Retorna zero quando o texto está vazio.
function StrToIntEx(S: string): integer;
var
  I: integer;
  Temp: string;
begin
  if (Trim(S) = '') then
  begin
    Result := 0;
  end else
  begin
    for I := 1 to Length(S) do
      if (S[I] <> FormatSettings.ThousandSeparator) then
        Temp := Temp + S[I];
    Result := StrToInt(Temp);
  end;
end;

// Converte uma string em inteiro. Em caso de falha, retorna o valor padrão informado.
function StrToIntForce(S: string; Force: integer = 0): integer;
var
  I: integer;
  Temp: string;
begin
  if (Trim(S) = '') then
  begin
    Result := Force;
  end
  else
  begin
    for I := 1 to Length(S) do
      if (S[I] <> FormatSettings.ThousandSeparator) then
        Temp := Temp + S[I];
    if (TryStrToInt(Temp, I)) then
      Result := I
    else
      Result := Force;
  end;
end;

// Converte uma string em data e hora ou retorna Null quando o texto está vazio.
function StrToDateTimeNull(S: string): Variant;
begin
  if(S='')then
  begin
    Result := NULL;
  end else
  begin
    Result := StrToDateTime(S);
  end;
end;

// Localiza o texto no array de strings e retorna o inteiro correspondente. Retorna -1 quando não encontra.
function StrToIntEnum(const Value: string; const AString: array of string;
  const AInteger: array of Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(AString) to High(AString) do
    if SameText(Value, AString[I]) then
      Exit(AInteger[I]);
end;

// Localiza o inteiro no array numérico e retorna a string correspondente. Retorna texto vazio quando não encontra.
function IntToStrEnum(const Value: Integer; const AInteger: array of Integer;
  const AString: array of string): string;
var
  I: Integer;
begin
  Result := '';
  for I := Low(AInteger) to High(AInteger) do
    if AInteger[I] = Value then
      Exit(AString[I]);
end;

// Converte uma string em inteiro e lança uma exceção com a mensagem informada quando a conversão falhar.
function StrToIntMessage(S: string; Msg: string): integer;
var
  I: integer;
  Temp: string;
begin
  if (Trim(S) = '') then
  begin
    raise Exception.Create(Msg);
  end
  else
  begin
    for I := 1 to Length(S) do
      if (S[I] <> FormatSettings.ThousandSeparator) then
        Temp := Temp + S[I];
    if (TryStrToInt(Temp, I)) then
      Result := I
    else
      raise Exception.Create(Msg);
  end;
end;

// Executa uma transformação simples de codificação ou decodificação em pares de caracteres. Não deve ser considerada criptografia segura.
function Cript(mCad, mOp: AnsiString): AnsiString;
var
  I, ate, x1, x2: integer;
  r1, r2: AnsiChar;
begin
  Result := '';
  if Odd(Length(mCad)) then
    mCad := mCad + ' ';
  ate := Length(mCad) div 2;
  for I := 1 to ate do
  begin
    x1 := Ord(mCad[((I - 1) * 2) + 1]);
    x2 := ord(mCad[((I - 1) * 2) + 2]);
    if mOp = 'DESCRIPT' then
    begin
      r2 := AnsiChar((-x2 + x1 + 90) div 2);
      r1 := AnsiChar(x1 - ((-x2 + x1 + 90) div 2));
    end
    else
    begin
      r2 := AnsiChar(x1 + 90 - x2);
      r1 := AnsiChar(x1 + x2);
    end;
    Result := Result + r1 + r2;
  end;

  if(Result<>'')and(Result[Length(Result)]=' ')then
  begin
    Result := Copy(Result,1,Length(Result)-1);
  end;
end;

// Codifica uma string usando uma chave fixa e operações XOR. Não é indicada para proteger dados sensíveis.
function Encript(Src: String):String;
var
  KeyLen,KeyPos,OffSet,SrcPos,SrcAsc,TmpSrcAsc: Integer;
  Dest, Key : String;
begin
  try
    if (Src = '') then
      exit('');

    Key      := 'ESIW';
    Dest     := '';
    KeyLen   := 4;
    KeyPos   := 0;
    SrcAsc   := 0;
    OffSet   := 1;
    Dest     := Format('%1.2x',[1]);

    for SrcPos := 1 to Length(Src) do
    begin
      Application.ProcessMessages;
      SrcAsc := (Ord(Src[SrcPos]) + OffSet) Mod 255;

      if (KeyPos < KeyLen) then
        KeyPos := KeyPos + 1
      else
        KeyPos := 1;

      SrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
      Dest   := Dest + Format('%1.2x',[SrcAsc]);
      OffSet := SrcAsc;
    end;

    Result:= Dest;
  except
    exit('');
  end;
end;

// Decodifica uma string produzida pela função Encript.
function Decript(Src: String):String;
var
  KeyLen,KeyPos,OffSet,SrcPos,SrcAsc,TmpSrcAsc,Range: Integer;
  Dest, Key : String;
begin
  if (Src = '') then
    exit('');

  try
    Key      := 'ESIW';
    Dest     := '';
    KeyLen   := 4;
    KeyPos   := 0;
    SrcAsc   := 0;

    OffSet := StrToInt('$' + copy(Src,1,2));
    SrcPos := 3;
    repeat
      SrcAsc := StrToInt('$' + copy(Src,SrcPos,2));
      if (KeyPos < KeyLen) then
        KeyPos := KeyPos + 1
      else
        KeyPos := 1;

      TmpSrcAsc := SrcAsc Xor Ord(Key[KeyPos]);

      if (TmpSrcAsc <= OffSet) then
        TmpSrcAsc := (255 + TmpSrcAsc - OffSet)
      else
        TmpSrcAsc := TmpSrcAsc - OffSet;

      Dest   := (Dest + Chr(TmpSrcAsc));
      OffSet := SrcAsc;
      SrcPos := SrcPos + 2;
    until (SrcPos >= Length(Src));

    Result:= Dest;
  except
    exit('');
  end;
end;

// Gera o hash MD5 de um texto..
function MD5(const texto:string):string;
var
  md5: TIdHashMessageDigest5;
begin
  md5:= TIdHashMessageDigest5.Create;
  try
    result:= md5.HashStringAsHex(texto);
  finally
    md5.Free;
  end;
end;

// Lê uma string de um stream, considerando que os quatro primeiros bytes armazenam o tamanho do texto.
function LoadStringFromStream(Stream: TStream): ansistring;
var
  I, Size: integer;
  C: ansichar;
begin
  try
    Stream.ReadBuffer(Size, 4);
    Result := '';
    if (Size > 0) then
      for I := 1 to Size do
      begin
        Stream.ReadBuffer(C, 1);
        Result := Result + C;
      end;
  except
    on EReadError do
      raise Exception.Create('LoadStringFromStream(): Stream.EReadError');
  end;
end;

// Lê todos os bytes restantes de um TMemoryStream e os converte em uma string ANSI.
function LoadStringFromMemoryStream(Stream: TMemoryStream): ansistring;
var
  I: integer;
  C: ansichar;
begin
  try
    Result := '';
    if (Stream.Size > 0) then
      for I := 1 to Stream.Size do
      begin
        Stream.ReadBuffer(C, 1);
        Result := Result + C;
      end;
  except
    on EReadError do
      raise Exception.Create('LoadStringFromStream(): Stream.EReadError');
  end;
end;

// Grava o tamanho e o conteúdo de uma string ANSI em um stream.
procedure SaveStringToStream(S: AnsiString; Stream: TStream);
var
  I, Size: integer;
begin
  try
    Size := Length(S);
    Stream.WriteBuffer(Size, 4);
    if (Size > 0) then
      for I := 1 to Size do
        Stream.WriteBuffer(AnsiChar(S[I]), 1);
  except
    on EWriteError do
      raise Exception.Create('SaveStringToStream(): Stream.EWriteError');
  end;
end;

// Limpa um ClientDataSet ativo ou cria sua estrutura quando ele ainda está inativo.
procedure CreateDataSet(pcds: TClientDataSet);
begin
  if (pcds.Active) then
    pcds.EmptyDataSet
  else
    pcds.CreateDataSet;
end;

// Procura um texto parcial em um campo do DataSet, preservando a posição original do registro.
function LocateLike(DataSet: TDataSet; const Field: string;
  const Value: String): boolean;
var
  SavePlace: TBookmark;
begin
  Result := false;
  SavePlace := DataSet.GetBookmark;
  try
    DataSet.First;
    while (not DataSet.Eof) and (DataSet.RecordCount > 1) do
    begin
      if (Pos(UpperCase(Value),UpperCase(DataSet.FieldByName(Field).AsString))>0) then
      begin
        Result := true;
        Break;
      end;
      DataSet.Next;
    end;
  except
    DataSet.GotoBookmark(SavePlace);
    DataSet.FreeBookmark(SavePlace);
    raise;
  end;
  if (not Result) then
  begin
    DataSet.GotoBookmark(SavePlace);
  end;
  DataSet.FreeBookmark(SavePlace);
end;

// Procura um valor exato em um campo do DataSet, preservando a posição original do registro.
function TurboLocate(DataSet: TDataSet; const KeyFields: string;
  const KeyValues: Variant): boolean;
var
  SavePlace: TBookmark;
begin
  Result := false;
  SavePlace := DataSet.GetBookmark;
  try
    DataSet.First;
    while (not DataSet.Eof) and (DataSet.RecordCount > 1) do
    begin
      if (DataSet.FieldByName(KeyFields).Value = KeyValues) then
      begin
        Result := true;
        Break;
      end;
      DataSet.Next;
    end;
  except
    DataSet.GotoBookmark(SavePlace);
    DataSet.FreeBookmark(SavePlace);
    raise;
  end;
  if (not Result) then
  begin
    DataSet.GotoBookmark(SavePlace);
  end;
  DataSet.FreeBookmark(SavePlace);
end;

// Centraliza um formulário na tela ou reposiciona-o somente quando estiver fora da área visível.
procedure CentralizaForm(pForm: TForm; IFNeed: boolean = false);
var
  wndHandle: THandle;
  rct: TRect;
  DesktopClienteHeight: integer;
  _top, _left, _width, _height, _sw, _sh: integer;
begin
  if (not IFNeed) then // centralizando incondicionalmente
  begin
    wndHandle := GetDesktopWindow;
    GetWindowRect(wndHandle, rct);
    DesktopClienteHeight := rct.Bottom - TaskBarHeight;
    pForm.Left := (rct.Right - pForm.Width) div 2;
    pForm.Top := (DesktopClienteHeight - pForm.Height) div 2;
  end
  else // centralizando somente se o form estiver fora da tela
  begin
    _sw := Screen.Width;
    _sh := Screen.Height;
    _top := pForm.Top;
    _left := pForm.Left;
    _width := pForm.Width;
    _height := pForm.Height;
    if (_top < 0) or (_left < 0) or ((_top + _height) > _sh) or
      ((_left + _width) > _sw) then
    begin
      pForm.Top := (_sh div 2) - (pForm.Height div 2);
      pForm.Left := (_sw div 2) - (pForm.Width div 2);
    end
  end;
end;

// Retorna a altura aproximada da barra de tarefas do Windows.
function TaskBarHeight: integer;
var
  wndHandle: THandle;
  wndClass: array [0 .. 50] of char;
  rct: TRect;
begin
  StrPCopy(@wndClass[0], 'Shell_TrayWnd');
  wndHandle := FindWindow(@wndClass[0], nil);
  GetWindowRect(wndHandle, rct);
  Result := rct.Bottom - rct.Top;
end;

// ------------------------------------------------------------------------------
// Converte Boolean para inteiro usando -1 para True e 0 para False.
function BoolToInt(B: boolean): integer;
begin
  if (B) then
    Result := -1
  else
    Result := 0;
end;

// ------------------------------------------------------------------------------
// Converte Boolean para inteiro usando 1 para True e 0 para False.
function BoolToU(B: boolean): integer;
begin
  if (B) then
    Result := 1
  else
    Result := 0;
end;

// ------------------------------------------------------------------------------
// Converte um inteiro para Boolean. Qualquer valor diferente de zero resulta em True.
function IntToBool(I: integer): boolean;
begin
  if (I <> 0) then
    Result := true
  else
    Result := false;
end;

// ------------------------------------------------------------------------------
// Converte um Variant para Boolean, considerando Null como True.
function IntToBool_NullTrue(I: Variant): boolean;
begin
  if (I = Null) then
    Result := true
  else if (I <> 0) then
    Result := true
  else
    Result := false;
end;

// ------------------------------------------------------------------------------
// Converte um Variant para Boolean, considerando Null como False.
function IntToBool_NullFalse(I: Variant): boolean;
begin
  if (I = Null) then
    Result := false
  else if (I <> 0) then
    Result := true
  else
    Result := false;
end;

// ------------------------------------------------------------------------------
// Converte uma data e hora para a quantidade de segundos baseada no dia, hora, minuto e segundo informados.
function DateTimeToITimeStamp(D: TDateTime): integer;
var
  AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond: Word;
begin
  DecodeDateTime(D, AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond);
  Result := (ADay * 86400) + (AHour * 3600) + (AMinute * 60) + (ASecond);
end;

// Formata uma data e hora no padrão compacto YYYYMMDDHHNNSS.

function FormatTimeStamp(D: TDateTime): string;
begin
  Result := FormatDateTime('yyyymmddhhnnss', D);
end;

// ------------------------------------------------------------------------------
// Remove barras e dois-pontos de uma data e hora formatada.
function TiraMascaraDataHora(Num: string): String;
var
  S: String;
  P: integer;
begin
  S := Num;
  P := Pos('/', S);
  while (P > 0) do
  begin
    Delete(S, P, 1);
    P := Pos('/', S);
  end;
  P := Pos(':', S);
  while (P > 0) do
  begin
    Delete(S, P, 1);
    P := Pos(':', S);
  end;
  Result := Trim(S);
end;

// ------------------------------------------------------------------------------
// Remove barras de uma data formatada.
function TiraMascaraData(Num: string): String;
var
  S: String;
  P: integer;
begin
  S := Num;
  P := Pos('/', S);
  while (P > 0) do
  begin
    Delete(S, P, 1);
    P := Pos('/', S);
  end;
  Result := Trim(S);
end;

// ------------------------------------------------------------------------------
// Remove dois-pontos de uma hora formatada.
function TiraMascaraHora(Num: string): String;
var
  S: String;
  P: integer;
begin
  S := Num;
  P := Pos(':', S);
  while (P > 0) do
  begin
    Delete(S, P, 1);
    P := Pos(':', S);
  end;
  Result := Trim(S);
end;

// ------------------------------------------------------------------------------
// Substitui caracteres acentuados por seus equivalentes sem acento.
function TiraAcentos(const S: string): string;
const
  accent: string   = 'ãàáäâèéëêìíïîõòóöôùúüûçÃÀÁÄÂÈÉËÊÌÍÏÎÕÒÓÖÔÙÚÜÛÇ¹²³';
  noaccent: string = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC123';
var
  I: integer;
begin
  Result := S;
  for I := 1 to Length(accent) do
    while Pos(accent[I], Result) > 0 do
      Result[Pos(accent[I], Result)] := noaccent[I];
end;
//-------------------------------------------------------------------------------
// Remove caracteres especiais, mantendo letras, números e espaços.
function RemoveCaracteresEspeciais(const s: string): string;
var
  i: Integer;
  c: Char;
begin
  Result := '';
  for i := 1 to Length(s) do
  begin
    c := s[i];
    if (c in ['A'..'Z', 'a'..'z', '0'..'9']) or (c = ' ') then
      Result := Result + c;
  end;
end;

// ------------------------------------------------------------------------------
// Retorna somente os caracteres numéricos presentes na string.
function SomenteDigitos(S: string): string;
var
  I: integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    if (CharInSet(S[I],['0'..'9']))then
      Result := Result + S[I];
end;

// ------------------------------------------------------------------------------
// Remove todos os números da string e retorna o texto sem espaços nas extremidades.
function RetiraNumeros(S: string): string;
var
  I: integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    if not(CharInSet(S[I],['0'..'9']))then
      Result := Result + S[I];
  Result := Trim(Result);
end;

// ------------------------------------------------------------------------------
// Remove todas as ocorrências de um caractere específico da string.
function RemoveChar(S: string; C: char): string;
var
  P: integer;
begin
  P := Pos(C, S);
  while (P > 0) do
  begin
    Delete(S, P, 1);
    P := Pos(C, S);
  end;
  Result := Trim(S);
end;

// ------------------------------------------------------------------------------
// Remove pontos, hífens e barras de um documento ou número formatado.
function TiraMascaraCPF(Num: String): String;
var
  S: String;
  P: integer;
begin
  S := Num;
  P := Pos('.', S);
  while (P > 0) do
  begin
    Delete(S, P, 1);
    P := Pos('.', S);
  end;
  P := Pos('-', S);
  while (P > 0) do
  begin
    Delete(S, P, 1);
    P := Pos('-', S);
  end;
  P := Pos('/', S);
  while (P > 0) do
  begin
    Delete(S, P, 1);
    P := Pos('/', S);
  end;
  Result := Trim(S);
end;

// Verifica se uma string pode ser convertida para uma data válida.
function ValidaData(aStrData:String):Boolean;
begin
  try
    StrToDate(aStrData);
    Result := True;
  except
    Result := False;
  end;
end;

// ------------------------------------------------------------------------------
// Valida um CPF ou CNPJ. No código original, texto vazio é considerado válido.
function Valida_CPF_CNPJ(Num: String): boolean;
var
  S: String;
begin
  S := TiraMascaraCPF(Num);
  IF (Trim(S) = '') THEN
    Result := true
  ELSE
    Result := (ValidaCPF(Trim(S)) or ValidaCNPJ(Trim(S)));
end;

// ------------------------------------------------------------------------------
// Valida os dígitos verificadores de um CPF com 11 caracteres.
function ValidaCPF(Num: String): boolean;
var
  n1, n2, n3, n4, n5, n6, n7, n8, n9: integer;
  d1, d2: integer;
  digitado, calculado: String;
begin
  if (Length(Num) <> 11) then
  begin
    Result := false
  end
  else
  begin
    n1 := StrToInt(Num[1]);
    n2 := StrToInt(Num[2]);
    n3 := StrToInt(Num[3]);
    n4 := StrToInt(Num[4]);
    n5 := StrToInt(Num[5]);
    n6 := StrToInt(Num[6]);
    n7 := StrToInt(Num[7]);
    n8 := StrToInt(Num[8]);
    n9 := StrToInt(Num[9]);
    d1 := n9 * 2 + n8 * 3 + n7 * 4 + n6 * 5 + n5 * 6 + n4 * 7 + n3 * 8 + n2 *
      9 + n1 * 10;
    d1 := 11 - (d1 mod 11);
    if (d1 >= 10) then
    begin
      d1 := 0;
    end;
    d2 := d1 * 2 + n9 * 3 + n8 * 4 + n7 * 5 + n6 * 6 + n5 * 7 + n4 * 8 + n3 * 9
      + n2 * 10 + n1 * 11;
    d2 := 11 - (d2 mod 11);
    if (d2 >= 10) then
    begin
      d2 := 0;
    end;
    calculado := inttostr(d1) + inttostr(d2);
    digitado := Num[10] + Num[11];
    if (calculado = digitado) then
    begin
      Result := true
    end
    else
      Result := false;
  end;
end;

// ------------------------------------------------------------------------------
// Valida os dígitos verificadores de um CNPJ com 14 caracteres.
function ValidaCNPJ(Num: String): boolean;
var
  n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12: integer;
  d1, d2: integer;
  digitado, calculado: string;
begin
  Num := TiraMascaraCPF(Num);
  if (Length(Num) <> 14) then
  begin
    Result := false;
    Exit;
  end;
  n1 := StrToInt(Num[1]);
  n2 := StrToInt(Num[2]);
  n3 := StrToInt(Num[3]);
  n4 := StrToInt(Num[4]); // Retira cada numero do Edit, e joda p/ variavel
  n5 := StrToInt(Num[5]);
  n6 := StrToInt(Num[6]);
  n7 := StrToInt(Num[7]);
  n8 := StrToInt(Num[8]);
  n9 := StrToInt(Num[9]);
  n10 := StrToInt(Num[10]);
  n11 := StrToInt(Num[11]);
  n12 := StrToInt(Num[12]);
  d1 := n12 * 2 + n11 * 3 + n10 * 4 + n9 * 5 + n8 * 6 + n7 * 7 + n6 * 8 + n5 * 9
    + n4 * 2 + n3 * 3 + n2 * 4 + n1 * 5;
  d1 := 11 - (d1 mod 11);
  if d1 >= 10 then
    d1 := 0;
  d2 := d1 * 2 + n12 * 3 + n11 * 4 + n10 * 5 + n9 * 6 + n8 * 7 + n7 * 8 + n6 * 9
    + n5 * 2 + n4 * 3 + n3 * 4 + n2 * 5 + n1 * 6;
  d2 := 11 - (d2 mod 11);
  if d2 >= 10 then
    d2 := 0;
  calculado := inttostr(d1) + inttostr(d2);
  digitado := Num[13] + Num[14];
  if calculado = digitado then
    Result := true
  else
    Result := false;
end;

// ------------------------------------------------------------------------------
// Monta uma máscara de formatação decimal com a quantidade de casas solicitada.
function MakeStringDecimal(NumeroCasas: integer; Thousands: boolean = true;
  MascaraDecimal: string = '0'): string;
var
  I: integer;
  S: String;
begin
  if (NumeroCasas > 0) then
  begin
    if (Thousands) then
      S := '#,###,###,##0.'
    else
      S := '0.';
    for I := 0 to NumeroCasas - 1 do
      S := S + MascaraDecimal;
  end
  else
  begin
    if (Thousands) then
      S := '#,###,###,##0'
    else
      S := '0';
  end;
  Result := S;
end;

// Converte um TFieldType do Delphi para um código inteiro definido pela aplicação.

function DataTypeToInt(DataType: TFieldType): integer;
begin
  case DataType of
    ftUnknown:
      Result := 1;
    ftString:
      Result := 2;
    ftSmallint:
      Result := 3;
    ftInteger,ftLongWord:
      Result := 4;
    ftWord:
      Result := 5;
    ftBoolean:
      Result := 6;
    ftFloat:
      Result := 7;
    ftCurrency:
      Result := 8;
    ftBCD:
      Result := 9;
    ftDate:
      Result := 10;
    ftTime:
      Result := 11;
    ftDateTime:
      Result := 12;
    ftBytes:
      Result := 13;
    ftVarBytes:
      Result := 14;
    ftAutoInc:
      Result := 15;
    ftBlob:
      Result := 16;
    ftMemo:
      Result := 17;
    ftGraphic:
      Result := 18;
    ftFmtMemo:
      Result := 19;
    ftParadoxOle:
      Result := 20;
    ftDBaseOle:
      Result := 21;
    ftTypedBinary:
      Result := 22;
    ftCursor:
      Result := 23;
    ftFixedChar:
      Result := 24;
    ftWideString:
      Result := 25;
    ftLargeint:
      Result := 26;
    ftADT:
      Result := 27;
    ftArray:
      Result := 28;
    ftReference:
      Result := 29;
    ftDataSet:
      Result := 30;
    ftOraBlob:
      Result := 31;
    ftOraClob:
      Result := 32;
    ftVariant:
      Result := 33;
    ftInterface:
      Result := 34;
    ftIDispatch:
      Result := 35;
    ftGuid:
      Result := 36;
    ftTimeStamp:
      Result := 37;
    ftFMTBcd:
      Result := 38;
  else
    Result := 1; // Unknown
  end;
end;

// Lê o texto de um controle visual e converte seu conteúdo para número decimal.

function TextControlToFloat(Control: TControl): double;
var
  Text: string;
begin
  Result := 0;
  if (Control is TMaskEdit) then
  begin
    Text := TMaskEdit(Control).Text;
  end
  else
  begin
    Text := THackTextControl(Control).Text;
  end;
  try
    Result := StrToFloatEx(Text);
  except
    if (Control is TWinControl) then
    begin
      if ((Control as TWinControl).CanFocus) then
        SetFocusEx(Control as TWinControl);
      raise Exception.Create(QuotedStr(Text) +
        ' não é um valor numérico válido');
    end;
  end;
end;

// Lê o texto de um controle visual e converte seu conteúdo para inteiro.

function TextControlToInt(Control: TControl): integer;
var
  Text: string;
begin
  Result := 0;
  if (Control is TMaskEdit) then
  begin
    Text := TMaskEdit(Control).Text;
  end
  else
  begin
    Text := THackTextControl(Control).Text;
  end;
  try
    Result := StrToIntEx(Text);
  except
    if (Control is TWinControl) then
    begin
      if ((Control as TWinControl).CanFocus) then
        SetFocusEx(Control as TWinControl);
      raise Exception.Create(QuotedStr(Text) +
        ' não é um valor numérico válido');
    end;
  end;
end;

// Lê o texto de um controle visual e converte seu conteúdo para data.
function TextControlToDate(Control: TControl): TDateTime;
var
  Text: string;
begin
  Result := 0;
  if (Control is TMaskEdit) then
  begin
    Text := TMaskEdit(Control).Text;
  end
  else
  begin
    Text := THackTextControl(Control).Text;
  end;
  try
    if(Text<>'  /  /    ')and(Text<>'  /    ')then
    begin
      if(Pos('VAL',UPPERCASE(Control.Name))>0)and(GlobalEstoqueValidadeMesAno)then
      begin
        Result := StrToDate('01/'+Text);
      end else
      begin
        Result := StrToDate(Text);
      end;
    end else
    begin
      Result := 0;
    end;
  except
    if (Control is TWinControl) then
    begin
      if ((Control as TWinControl).CanFocus) then
        SetFocusEx(Control as TWinControl);
      raise Exception.Create(QuotedStr(Text) + ' não é uma data válida');
    end;
  end;
end;

// Lê o texto de um controle visual e converte seu conteúdo para horário.
function TextControlToTime(Control: TControl): TDateTime;
var
  Text: string;
begin
  Result := 0;
  if (Control is TMaskEdit) then
  begin
    Text := TMaskEdit(Control).Text;
  end
  else
  begin
    Text := THackTextControl(Control).Text;
  end;
  try
    Result := StrToTime(Text);
  except
    if (Control is TWinControl) then
    begin
      if ((Control as TWinControl).CanFocus) then
        SetFocusEx(Control as TWinControl);
      raise Exception.Create(QuotedStr(Text) + ' não é uma hora válida');
    end;
  end;
end;

end.
