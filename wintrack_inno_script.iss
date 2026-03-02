#define MyAppName "WinTrack"
#define MyAppVersion "0.0.3"
#define MyAppPublisher "Srikanth"
#define MyAppURL "https://github.com/sr1k7nth/WinTrack"
#define MyAppExeName "WinTrack.exe"

[Setup]
AppId={{2B60F0B7-89BF-4D53-ADC6-17697FB85253}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}

OutputDir=.
OutputBaseFilename=WinTrack_Installer
SetupIconFile=media\setup_logo.ico

DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

DisableDirPage=yes
CloseApplications=yes
RestartApplications=yes

Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Files]
Source: "dist\WinTrack\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"