unit common;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type



  TGCP=record
    px,py:double;
    img:string;
    pid:string;
  end;

  TGCPList = array of TGCP;




implementation

end.

