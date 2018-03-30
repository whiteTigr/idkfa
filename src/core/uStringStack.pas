unit uStringStack;

interface

uses SysUtils;

type
  TStringStack = class
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    function Pop: string;
    function Top: string;
    procedure Push(value: string);
  private
    values: array of string;
    index: integer;
  end;

implementation

{ TStringStack }

procedure TStringStack.Clear;
begin
  index := 0;
  SetLength(values, 0);
end;

constructor TStringStack.Create;
begin
  inherited;
  index := 0;
end;

destructor TStringStack.Destroy;
begin
  Clear();
  inherited;
end;

function TStringStack.Pop: string;
begin
  if index > 0 then
  begin
    dec(index);
    Result := values[index];
  end
  else
  begin
    index := 0;
    Result := '';
  end;
end;

procedure TStringStack.Push(value: string);
begin
  value := StringReplace(value, '/', '\', [rfReplaceAll]);
  value := ExtractFilePath(value);

  inc(index);
  if index > Length(values) then
  begin
    SetLength(values, index);
  end;
  values[index - 1] := value;
end;

function TStringStack.Top: string;
begin
  if index > 0 then
    Result := values[index - 1]
  else
    Result := '';
end;

end.
