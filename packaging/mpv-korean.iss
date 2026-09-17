; mpv 한국어판 설치 프로그램 (Inno Setup)
;
; 빌드는 GitHub Actions 의 package-korean.yml 이 한다. 로컬에서 만들려면
; payload 폴더를 채운 뒤 아래처럼 부른다.
;
;   iscc /DMpvVersion=20260917-abc1234 packaging\mpv-korean.iss
;
;
; ── 설치 위치를 Program Files 로 하지 않는 이유 ──────────────────────
;
; 설정을 프로그램 폴더 옆(portable_config)에 두는 구조라, Program Files 에
; 깔면 일반 사용자 권한으로 그 파일을 쓸 수 없다. 우클릭 메뉴에서 화질을
; 바꿔도 저장이 안 되고 다음에 켜면 되돌아간다.
;
; %LOCALAPPDATA%\Programs 에 사용자 단위로 깔면
;   - 쓰기가 되고 (화질 선택이 유지된다)
;   - UAC 창이 안 뜬다 (서명 없는 빌드라 경고가 이미 하나 뜬다. 두 개는 과하다)
;
; PrivilegesRequired=lowest 를 주면 {autopf} 가 그 경로로 해석된다.

#ifndef MpvVersion
  #define MpvVersion "dev"
#endif

#define AppName "mpv 한국어판"
#define AppNameEn "mpv-korean"
#define Publisher "DREAMURL"
#define AppUrl "https://dreamurl.biz"

[Setup]
; 이 GUID 는 업그레이드 시 같은 프로그램으로 인식되게 하는 열쇠다. 바꾸면
; 기존 설치본이 지워지지 않고 두 벌이 깔린다. 절대 바꾸지 말 것.
AppId={{8F3A1C62-5D47-4E9B-A0F1-7C2E9B4D6A83}
AppName={#AppName}
AppVersion={#MpvVersion}
AppVerName={#AppName} {#MpvVersion}
AppPublisher={#Publisher}
AppPublisherURL={#AppUrl}
AppSupportURL={#AppUrl}
VersionInfoVersion=1.0.0.0
VersionInfoDescription={#AppName} 설치 프로그램

DefaultDirName={autopf}\{#AppNameEn}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
DisableDirPage=no
AllowNoIcons=yes

PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

OutputDir=..\dist
OutputBaseFilename=mpv-korean-setup-{#MpvVersion}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\mpv.exe

; 아이콘을 넣으려면 packaging\mpv-korean.ico 를 두면 자동으로 쓰인다.
; 없으면 Inno 기본 아이콘으로 나간다 — 파일이 없을 때 빌드가 깨지지 않게
; 존재 여부를 보고 결정한다. mpv 자체 아이콘을 그대로 쓰지는 않는다(상표).
#if FileExists(AddBackslash(SourcePath) + "mpv-korean.ico")
SetupIconFile=mpv-korean.ico
#endif
UninstallDisplayName={#AppName}

[Languages]
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"

[Tasks]
Name: "desktopicon"; Description: "바탕화면에 바로가기 만들기"; GroupDescription: "추가 작업:"
Name: "openwith";    Description: "동영상 파일 우클릭 → [연결 프로그램] 목록에 넣기"; GroupDescription: "추가 작업:"

[Files]
; payload 폴더 통째로. mpv.exe 와 portable_config 가 여기 들어 있다.
Source: "..\payload\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}";                  Filename: "{app}\mpv.exe"
Name: "{group}\설정 폴더 열기";               Filename: "{app}\portable_config"
Name: "{group}\{#AppName} 제거";              Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}";            Filename: "{app}\mpv.exe"; Tasks: desktopicon

[Registry]
; 파일 연결을 강제로 뺏지 않는다. 윈도우 10 이후로는 설치 프로그램이 기본
; 프로그램을 바꿔치기하는 것을 OS 가 막고, 억지로 하면 경고가 뜬다. 대신
; "이 프로그램도 동영상을 열 수 있다"고 등록만 해서 [연결 프로그램] 목록에
; 나오게 한다. 기본으로 삼을지는 사용자가 설정에서 정한다.
Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe"; ValueType: string; ValueName: "FriendlyAppName"; ValueData: "{#AppName}"; Flags: uninsdeletekey; Tasks: openwith
Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe\shell\open\command"; ValueType: string; ValueData: """{app}\mpv.exe"" ""%1"""; Flags: uninsdeletekey; Tasks: openwith

Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe\SupportedTypes"; ValueType: string; ValueName: ".mkv"; ValueData: ""; Flags: uninsdeletekey; Tasks: openwith
Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe\SupportedTypes"; ValueType: string; ValueName: ".mp4"; ValueData: ""; Tasks: openwith
Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe\SupportedTypes"; ValueType: string; ValueName: ".avi"; ValueData: ""; Tasks: openwith
Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe\SupportedTypes"; ValueType: string; ValueName: ".wmv"; ValueData: ""; Tasks: openwith
Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe\SupportedTypes"; ValueType: string; ValueName: ".mov"; ValueData: ""; Tasks: openwith
Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe\SupportedTypes"; ValueType: string; ValueName: ".webm"; ValueData: ""; Tasks: openwith
Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe\SupportedTypes"; ValueType: string; ValueName: ".ts"; ValueData: ""; Tasks: openwith
Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe\SupportedTypes"; ValueType: string; ValueName: ".m2ts"; ValueData: ""; Tasks: openwith
Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe\SupportedTypes"; ValueType: string; ValueName: ".flv"; ValueData: ""; Tasks: openwith
Root: HKCU; Subkey: "Software\Classes\Applications\mpv.exe\SupportedTypes"; ValueType: string; ValueName: ".mpg"; ValueData: ""; Tasks: openwith

[Run]
Filename: "{app}\mpv.exe"; Description: "지금 실행하기"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; 재생 위치 기록·화질 선택 등 실행 중에 생기는 파일들. [Files] 에 없으므로
; 제거할 때 자동으로 지워지지 않아 빈 폴더가 남는다.
Type: filesandordirs; Name: "{app}\portable_config\watch_later"
Type: files;          Name: "{app}\portable_config\quality-state.conf"
Type: dirifempty;     Name: "{app}\portable_config"
Type: dirifempty;     Name: "{app}"


[Code]
var
  GpuPage: TInputOptionWizardPage;

procedure InitializeWizard;
begin
  GpuPage := CreateInputOptionPage(wpSelectTasks,
    '그래픽카드 성능',
    '화질 보정을 얼마나 세게 걸지 정합니다.',
    '애니메이션을 또렷하게 만드는 보정 기능이 들어 있습니다. 그래픽카드를 쓰기 때문에' + #13#10 +
    '성능에 맞게 골라야 끊기지 않습니다.' + #13#10 + #13#10 +
    '잘 모르시겠으면 가운데(보통)를 그대로 두세요.' + #13#10 +
    '설치한 뒤에도 재생 화면에서 우클릭 → [화질] → [내 PC 성능] 에서 언제든 바꿀 수 있습니다.',
    True, False);

  GpuPage.Add('내장 그래픽 — 그래픽카드가 따로 없는 노트북·사무용 PC' + #13#10 +
              '        (보정을 꺼 둔 채로 시작합니다. 나중에 켜 볼 수 있습니다)');
  GpuPage.Add('보통 — GTX 1060 · RX 570 급' + #13#10 +
              '        (대부분의 게임용 PC가 여기 해당합니다)');
  GpuPage.Add('고성능 — RTX 3060 · GTX 1080 급 이상' + #13#10 +
              '        (보정을 가장 세게 겁니다)');

  GpuPage.SelectedValueIndex := 1;
end;

function TierKey: String;
begin
  case GpuPage.SelectedValueIndex of
    0: Result := 'low';
    2: Result := 'high';
  else
    Result := 'std';
  end;
end;

// 내장 그래픽은 업스케일을 감당하기 어렵다. 켠 채로 시작하면 "받자마자
// 버벅이는 프로그램"이 되므로 꺼 둔 상태로 시작한다.
function ModeKey: String;
begin
  if GpuPage.SelectedValueIndex = 0 then
    Result := 'off'
  else
    Result := 'a';
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  Path: String;
  Lines: TArrayOfString;
begin
  if CurStep <> ssPostInstall then
    Exit;

  // 고른 값을 기록한다. 그 뒤로는 scripts/tier.lua 가 이 파일을 읽고 쓴다.
  Path := ExpandConstant('{app}\portable_config\quality-state.conf');

  SetArrayLength(Lines, 6);
  Lines[0] := '# 화질 설정. 재생 화면에서 우클릭 → [화질] 로 바꾸면 여기에 기록됩니다.';
  Lines[1] := '#   tier : low(내장 그래픽) / std(보통) / high(고성능)';
  Lines[2] := '#   mode : a / b / c / aa / bb / ca / off';
  Lines[3] := '';
  Lines[4] := 'tier = ' + TierKey;
  Lines[5] := 'mode = ' + ModeKey;

  // 실패해도 설치를 멈추지 않는다. 파일이 없으면 tier.lua 가 기본값(std/a)으로
  // 시작하고, 사용자가 메뉴에서 한 번 고르면 그때 새로 만들어진다.
  SaveStringsToUTF8File(Path, Lines, False);
end;
