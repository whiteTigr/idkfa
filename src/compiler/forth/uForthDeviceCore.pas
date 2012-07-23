unit uForthDeviceCore;

interface

uses Windows, Messages, Sysutils, DateUtils, Grids,
  uRecordList, uGlobal;

const
  DStackSize = 32;
  RStackSize = 32;
  LStackSize = 32;

  MaxPeriferal = 32;
  defaultMaxWaitingTime = 10; // сек

  cmdFROMR = 17;
  cmdTOR = 65;
  cmdRET = $20;

type

  PForthDevice = ^TForthDevice;
  TForthDevice = class(TDebuger)
  public
    DStack: TStackInt;
    RStack: TStackInt;
    LStack: TStack;
    FCPU_Temp: integer;

    constructor Create;
    destructor Destroy; override;
  end;

  TPeriferalComponent = record
    startAddr: integer;
    endAddr: integer;
    Inport: function(addr: integer): integer;
    Outport: procedure(addr, data: integer);
  end;

implementation

{ TForthDevice }

constructor TForthDevice.Create;
begin
  inherited;

  DStack := TStackInt.Create(DStackSize);
  RStack := TStackInt.Create(RStackSize);
  LStack := TStack.Create(sizeof(TLoopCell), LStackSize);
end;

destructor TForthDevice.Destroy;
begin
  DStack.Destroy;
  RStack.Destroy;
  LStack.Destroy;
  inherited;
end;

end.
