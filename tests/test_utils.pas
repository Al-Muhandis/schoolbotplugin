program test_utils;

{$mode objfpc}{$H+}

uses
  fpcunit, testutils, testregistry, schoolbotplugin;

type
  TUtilsTest = class(TTestCase)
  published
    procedure TestGetDataFromLine;
    procedure TestCaptionFromLangCode;
  end;

procedure TUtilsTest.TestGetDataFromLine;
begin
  AssertEquals('param1 param2', GetDataFromLine('cmd param1 param2'));
  AssertEquals('', GetDataFromLine('single'));
end;

procedure TUtilsTest.TestCaptionFromLangCode;
begin
  AssertEquals(lng_English, CaptionFromLangCode('en'));
  AssertEquals(lng_Russian, CaptionFromLangCode('ru'));
  AssertEquals('', CaptionFromLangCode('unknown'));
end;

begin
  RegisterTest(TUtilsTest);
  RunRegisteredTests;
end.
