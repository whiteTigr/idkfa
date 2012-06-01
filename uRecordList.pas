unit uRecordList;

interface

uses Windows, SysUtils, Dialogs;

type
  TRecordList = class
  private
    FItemsArray: pointer;
    FItemLength: integer;
    FSizeMax: integer;
    FSizeMin: integer;
    FSize: integer;
    FMinAllocateStep: integer;
    FFreePercent: real;

    procedure Reallocate(currentSize: integer = -1);
    procedure SetItemLength(newValue: integer);
    procedure SetSize(newValue: integer);
    procedure IndexIsValid(index: integer);
    procedure CalcNewMinMaxIndex;
    function isNeedRealloc: boolean;

    procedure SetMinAllocateStep(value: integer);
    procedure SetFreePercent(value: real);
  public

    property ItemLength: integer read FItemLength write SetItemLength;
    property Size: integer read FSize write SetSize;
    property MinAllocateStep: integer read FMinAllocateStep write SetMinAllocateStep;
    property FreePercent: real read FFreePercent write SetFreePercent;

    constructor Create(itemLength: integer = 0);
    destructor Destroy; override;
    procedure Add(value: pointer);
    function  Item(i: integer): pointer;
    procedure Edit(i: integer; value: pointer);
    property Atom[i: integer]: pointer read Item write Edit; default;
    procedure Delete(index: integer);
    procedure Clear;
  end;

  TStack = class(TRecordList)
  private
    FStackTop: integer;

    procedure SetSize(newValue: integer);
  public

    {$WARNINGS OFF}
    // Сделано сознательно.
    // При изменении размера необходимо сбрасывать указатель вершины стека в ноль.
    // Поэтому и необходимо переопределисть свойство Size
    property Size: integer read FSize write SetSize;
    {$WARNINGS ON}
    constructor Create(itemLength: integer = 0; size: integer = 0);
    property Top: integer read FStackTop;
    procedure Reset;
    procedure Push(p: pointer);
    function Pop: pointer;
    function ReadTop: pointer;
  end;

  PStackInt = ^TStackInt;
  TStackInt = class(TStack)
  public

    constructor Create(size: integer = 0);
    procedure Push(int: integer);
    function  Pop: integer;
    function ReadTop: integer;
  end;

const
  WRONG_INDEX = 'Неверный индекс';
  STACK_OVERFLOW = 'Переполнение стека';
  STACK_UNDERFLOW = 'Исчерпание стека';
  DefaultMinAllocateStep: integer = 10;
  DefaultFreePercent: real = 0.1;

implementation

procedure FreeAndNilPointer(var p: pointer);
begin
  FreeMemory(p);
  p := nil;
end;

{ TRecordList }

procedure TRecordList.Add(value: pointer);
var
  cellToWritePointer: pointer;
begin
  inc(FSize);
  cellToWritePointer := Item(FSize-1);
  Move(value^, cellToWritePointer^, FItemLength);
  Reallocate;
end;

procedure TRecordList.Clear;
begin
  if FItemsArray <> nil then
    FreeAndNilPointer(FItemsArray);
  FSize := 0;
  FSizeMax := 0;
  FSizeMin := 0;
  Reallocate;
end;

constructor TRecordList.Create(itemLength: integer = 0);
begin
  inherited Create;
  FItemLength := itemLength;
  FMinAllocateStep := DefaultMinAllocateStep;
  FFreePercent := DefaultFreePercent;
  Clear;
end;

procedure TRecordList.Delete(index: integer);
var
  secondPartPointer: pointer;
  secondPartSize: integer;
  dest: pointer;
begin
  IndexIsValid(index);

  secondPartSize := FItemLength * (FSize - index - 1);
  secondPartPointer := Item(index + 1);
  dest := Item(index);
  Move(secondPartPointer^, dest^, secondPartSize);
  dec(FSize);

  Reallocate;
end;

destructor TRecordList.Destroy;
begin
  Clear;
  inherited;
end;

procedure TRecordList.Edit(i: integer; value: pointer);
begin
  Move(value^, Item(i)^, FItemLength);
end;

function TRecordList.Item(i: integer): pointer;
begin
  IndexIsValid(i);
  Result := pointer(integer(FItemsArray) + i * FItemLength);
end;

procedure TRecordList.Reallocate(currentSize: integer = -1);
var
  OldItemsArray: pointer;
  OldItemsArraySize: integer;
begin
  if not isNeedRealloc then
    Exit;

  CalcNewMinMaxIndex;

  OldItemsArray := FItemsArray;
  if currentSize = -1 then
    OldItemsArraySize := FSize
  else
    OldItemsArraySize := currentSize;

  FItemsArray := AllocMem(FItemLength * FSizeMax);
  if (OldItemsArray <> nil) and (FItemsArray <> nil) then
    Move(OldItemsArray^, FItemsArray^, FItemLength * OldItemsArraySize);
  FreeAndNilPointer(OldItemsArray);
end;

procedure TRecordList.SetSize(newValue: integer);
var
  storeSize: integer;
begin
  storeSize := FSize;
  FSize := newValue;
  Reallocate(storeSize);
end;

procedure TRecordList.SetItemLength(newValue: integer);
begin
  Clear;
  FItemLength := newValue;
  Reallocate(0);
end;

procedure TRecordList.IndexIsValid(index: integer);
begin
  if (index < 0) or (index >= FSize) then
    raise Exception.Create(WRONG_INDEX);
end;

function TRecordList.isNeedRealloc: boolean;
begin
  Result := (FSize <= FSizeMin) or (FSize >= FSizeMax);
end;

procedure TRecordList.CalcNewMinMaxIndex;
var
  freeAmaunt: integer;
begin
  freeAmaunt := round(FSize * FFreePercent);
  if freeAmaunt < FMinAllocateStep then
    freeAmaunt := FMinAllocateStep;

  FSizeMin := FSize - freeAmaunt;
  if FSizeMin < 0 then
    FSizeMin := 0;

  FSizeMax := FSize + freeAmaunt;
end;

procedure TRecordList.SetFreePercent(value: real);
begin
  FFreePercent := value;
  Reallocate;
end;

procedure TRecordList.SetMinAllocateStep(value: integer);
begin
  FMinAllocateStep := value;
  Reallocate;
end;

{ TStack }

constructor TStack.Create(itemLength: integer = 0; size: integer = 0);
begin
  inherited Create(itemLength);
  FStackTop := 0;
  FMinAllocateStep := 0;
  FFreePercent := 0;
  self.Size := size;
end;

function TStack.Pop: pointer;
begin
  if FStackTop = 0 then
    raise Exception.Create(STACK_UNDERFLOW);
  FStackTop := FStackTop - 1;
  Result := Item(FStackTop);
end;

procedure TStack.Push(p: pointer);
begin
  Edit(FStackTop, p);
  FStackTop := FStackTop + 1;
  if FStackTop >= FSize then
    raise Exception.Create(STACK_OVERFLOW);
end;

function TStack.ReadTop: pointer;
begin
  if FStackTop = 0 then
    raise Exception.Create(STACK_UNDERFLOW);
  Result := Item(FStackTop - 1);
end;

procedure TStack.Reset;
begin
  FStackTop := 0;
end;

procedure TStack.SetSize(newValue: integer);
begin
  inherited;
  Reset;
end;

{ TStackInt }

constructor TStackInt.Create(size: integer = 0);
begin
  inherited Create(sizeof(integer), size);
end;

function TStackInt.Pop: integer;
begin
  Result := integer(inherited Pop^);
end;

procedure TStackInt.Push(int: integer);
begin
  inherited Push(@int);
end;

function TStackInt.ReadTop: integer;
begin
  Result := integer(inherited ReadTop^);
end;

{ module test}

var
  testRecord: TRecordList;

procedure TestCreateRecord;
begin
  testRecord := TRecordList.Create(sizeof(integer));
end;

procedure TestDestroyRecord;
begin
  testRecord.Free;
end;

procedure TestAddItem(int: integer);
begin
  testRecord.Add(@int);
end;

function TestGetItem(index: integer): integer;
begin
  Result := integer(testRecord.Item(index)^);
end;

procedure TestAddSomeItems;
begin
  TestAddItem(1);
  TestAddItem(2);
  TestAddItem(3);
end;

procedure TestSetSizeMinAllocate;
begin
  TestCreateRecord;

  testRecord.MinAllocateStep := 5;
  testRecord.SetSize(10);

  Assert(testRecord.Size = 10);
  Assert(testRecord.FSizeMax = 15);
  Assert(testRecord.FSizeMin = 5);
  Assert(testRecord.FItemsArray <> nil);

  TestDestroyRecord;
end;

procedure TestSetSizeFreeAmaunt;
begin
  TestCreateRecord;

  testRecord.MinAllocateStep := 1;
  testRecord.FreePercent := 0.1;
  testRecord.SetSize(100);

  Assert(testRecord.Size = 100);
  Assert(testRecord.FSizeMax = 110);
  Assert(testRecord.FSizeMin = 90);
  Assert(testRecord.FItemsArray <> nil);

  TestDestroyRecord;
end;

procedure TestAdd;
begin
  TestCreateRecord;
  TestAddSomeItems;

  Assert(testRecord.Size = 3);
  Assert(TestGetItem(0) = 1);
  Assert(TestGetItem(1) = 2);
  Assert(TestGetItem(2) = 3);

  TestDestroyRecord;
end;

procedure TestDelete;
begin
  TestCreateRecord;
  TestAddSomeItems;

  testRecord.Delete(0);

  Assert(testRecord.Size = 2);
  Assert(TestGetItem(0) = 2);
  Assert(TestGetItem(1) = 3);

  TestDestroyRecord;
end;

procedure TestEdit;
var
  value: integer;
begin
  TestCreateRecord;
  TestAddSomeItems;

  value := 777;
  testRecord.Edit(1, @value);

  Assert(testRecord.Size = 3);
  Assert(TestGetItem(0) = 1);
  Assert(TestGetItem(1) = 777);
  Assert(TestGetItem(2) = 3);

  TestDestroyRecord;
end;

procedure TestClear;
begin
  TestCreateRecord;
  TestAddSomeItems;

  testRecord.Clear;

  Assert(testRecord.Size = 0);

  TestDestroyRecord;
end;

procedure TestWrongItem;
begin
  TestCreateRecord;
  TestAddSomeItems;

  try
    TestGetItem(3);
  except
    on E: Exception do
      Assert(E.Message = WRONG_INDEX);
  end;

  TestDestroyRecord;
end;

procedure TestSetItemLength;
var
  newItemLength: integer;
begin
  TestCreateRecord;
  TestAddSomeItems;

  newItemLength := sizeof(double);
  testRecord.SetItemLength(newItemLength);

  Assert(testRecord.Size = 0);
  Assert(testRecord.ItemLength = newItemLength);

  TestDestroyRecord;
end;

procedure TestAddAndReallocMinStep;
const
  AmauntItemsToAdd = 10;
var
  i: integer;
begin
  TestCreateRecord;

  testRecord.MinAllocateStep := 10;

  for i := 0 to AmauntItemsToAdd-1 do
    TestAddItem(i);

  Assert(testRecord.Size = 10);
  Assert(testRecord.FSizeMax = 20);

  TestDestroyRecord;
end;

procedure TestAddAndReallocFreeAmaunt;
const
  AmauntItemsToAdd = 10;
var
  i: integer;
begin
  TestCreateRecord;

  testRecord.FreePercent := 0.1;
  testRecord.SetSize(100);

  for i := 0 to AmauntItemsToAdd-1 do
    TestAddItem(i);

  Assert(testRecord.Size = 110);
  Assert(testRecord.FSizeMax = 121);
  Assert(testRecord.FSizeMin = 99);

  TestDestroyRecord;
end;

procedure TestDeleteAndReallocMinStep;
const
  AmauntItemsToDelete = 10;
var
  i: integer;
begin
  TestCreateRecord;

  testRecord.MinAllocateStep := 10;
  testRecord.SetSize(20);

  for i := 0 to AmauntItemsToDelete-1 do
    testRecord.Delete(0);

  Assert(testRecord.Size = 10);
  Assert(testRecord.FSizeMax = 20);
  Assert(testRecord.FSizeMin = 0);

  TestDestroyRecord;
end;

procedure TestDeleteAndReallocFreeAmaunt;
const
  AmauntItemsToDelete = 10;
var
  i: integer;
begin
  TestCreateRecord;

  testRecord.MinAllocateStep := 5;
  testRecord.FreePercent := 0.1;
  testRecord.SetSize(100);

  for i := 0 to AmauntItemsToDelete-1 do
    testRecord.Delete(0);

  Assert(testRecord.Size = 90);
  Assert(testRecord.FSizeMax = 99);
  Assert(testRecord.FSizeMin = 81);

  TestDestroyRecord;
end;

procedure TestCopyOldArrayAfterRealloc;
const
  AmauntItemsToAdd = 10;
var
  i: integer;
begin
  TestCreateRecord;

  testRecord.MinAllocateStep := 10;
  for i := 0 to AmauntItemsToAdd-1 do
    TestAddItem(i);

  for i := 0 to testRecord.Size-1 do
    Assert(TestGetItem(i) = i);

  TestDestroyRecord;
end;

procedure RecordListTest;
begin
  TestSetSizeMinAllocate;
  TestSetSizeFreeAmaunt;
  TestClear;
  TestAdd;
  TestDelete;
  TestEdit;
  TestWrongItem;
  TestSetItemLength;
  TestAddAndReallocMinStep;
  TestAddAndReallocFreeAmaunt;
  TestDeleteAndReallocMinStep;
  TestDeleteAndReallocFreeAmaunt;
  TestCopyOldArrayAfterRealloc;
end;

var
  testStack: TStack;

procedure TestStackSetSize;
begin
  testStack := TStack.Create(sizeof(integer), 10);

  testStack.Size := 20;
  Assert(testStack.Size = 20);

  testStack.Destroy;
end;

procedure TestOverflow;
var
  i: integer;
  AddedItem: integer;
begin
  testStack := TStack.Create(sizeof(integer), 10);

  try
    AddedItem := 777;
    for i := 0 to 99 do
      testStack.Push(@AddedItem);
  except
    on E: Exception do
      Assert(E.Message = STACK_OVERFLOW);
  end;

  testStack.Destroy;
end;

procedure TestUnderflow;
var
  i: integer;
begin
  testStack := TStack.Create(sizeof(integer), 10);

  try
    for i := 0 to 99 do
      testStack.Pop;
  except
    on E: Exception do
      Assert(E.Message = STACK_UNDERFLOW);
  end;

  testStack.Destroy;
end;

procedure StackTest;
begin
  TestStackSetSize;
  TestOverflow;
  TestUnderflow;
end;

initialization
//  RecordListTest;
//  StackTest;
end.
