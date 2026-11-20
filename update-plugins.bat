@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
set "UPDATER_VERSION=0.1.6"
title GOG Galaxy 64-Bit Plugin Manager v%UPDATER_VERSION%

rem =================================================================
rem  update-plugins.bat  -  GOG Galaxy v2.1+ Plugin Manager & Updater
rem =================================================================

rem ---------------------------------------------------------------
rem  ANSI-Farbcodes initialisieren
rem ---------------------------------------------------------------
for /F %%a in ('echo prompt $E^|cmd') do set "ESC=%%a"
set "C_RED=%ESC%[91m"
set "C_GREEN=%ESC%[92m"
set "C_YELLOW=%ESC%[93m"
set "C_CYAN=%ESC%[96m"
set "C_MAGENTA=%ESC%[95m"
set "C_BLUE=%ESC%[94m"
set "C_WHITE=%ESC%[97m"
set "C_GRAY=%ESC%[90m"
set "C_RESET=%ESC%[0m"
set "C_BOLD=%ESC%[1m"

rem ---------------------------------------------------------------
rem  Pfade und Verzeichnisse
rem ---------------------------------------------------------------
set "ROOT=%~dp0"
set "PS1=%ROOT%scripts\update-plugins-helpers.ps1"
set "SELF_UPDATE_PS1=%ROOT%scripts\update-plugins-self-update.ps1"
if not "%~1"=="" (
    set "PLUGINS_DIR=%~1"
) else if not defined PLUGINS_DIR (
    set "PLUGINS_DIR=%LOCALAPPDATA%\GOG.com\Galaxy\plugins\installed"
)
:STRIP_PLUGINS_DIR
if defined PLUGINS_DIR (
    if "%PLUGINS_DIR:~-1%"==" " (
        set "PLUGINS_DIR=%PLUGINS_DIR:~0,-1%"
        goto STRIP_PLUGINS_DIR
    )
    if "%PLUGINS_DIR:~-1%"=="\" (
        set "PLUGINS_DIR=%PLUGINS_DIR:~0,-1%"
        goto STRIP_PLUGINS_DIR
    )
    if "%PLUGINS_DIR:~-1%"=="/" (
        set "PLUGINS_DIR=%PLUGINS_DIR:~0,-1%"
        goto STRIP_PLUGINS_DIR
    )
)
set "STEAM_PLUGIN_DIR=steam_ca27391f-2675-49b1-92c0-896d43afa4f8"
set "BACKUP_DIR=%ROOT%backups"
set "LOG_DIR=%ROOT%logs"
set "RETENTION_DAYS=60"
set "LANG=DE"
set "YESKEY=J"

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" >nul 2>&1
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1

rem ---------------------------------------------------------------
rem  PowerShell-Pfad auflösen
rem ---------------------------------------------------------------
set "PWSH_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -InputFormat None"
if not exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" set "PWSH_EXE=powershell -InputFormat None"

for /f %%i in ('%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -Command "Get-Date -Format yyyyMMdd_HHmmss" ^<nul') do set "TS=%%i"
set "LOGFILE=%LOG_DIR%\update_%TS%.log"
set "SCANFILE=%LOG_DIR%\_scan_%TS%.tmp"

if not exist "%PS1%" (
    echo %C_RED%[FEHLER] update-plugins-helpers.ps1 wurde nicht im scripts-Ordner gefunden.%C_RESET%
    pause
    exit /b 1
)

if not exist "%SELF_UPDATE_PS1%" (
    echo %C_RED%[FEHLER] update-plugins-self-update.ps1 fehlt im scripts-Ordner.%C_RESET%
    pause
    exit /b 1
)

if not exist "%ROOT%scripts\update-plugins-recycle.cs" (
    echo %C_RED%[FEHLER] update-plugins-recycle.cs fehlt im scripts-Ordner.%C_RESET%
    pause
    exit /b 1
)

%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action RecycleTransient -LogDir "%LOG_DIR%" <nul >nul 2>&1

rem ---------------------------------------------------------------
rem  Automatischer Updater-Versionscheck (im Hintergrund)
rem ---------------------------------------------------------------
set "NEW_UPDATER_VERSION="
if not defined SELF_UPDATE_CHECKED (
    set "SELF_UPDATE_CHECKED=1"
    for /f "usebackq tokens=1,2 delims=|" %%a in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%SELF_UPDATE_PS1%" -Mode Check -Root "%ROOT%." -CurrentVersion "%UPDATER_VERSION%" -Lang "DE" ^<nul`) do (
        if /i "%%a"=="UPDATE" set "NEW_UPDATER_VERSION=%%b"
    )
)

rem ---------------------------------------------------------------
rem  Texte und Meldungen (Deutsch mit echten Umlauten)
rem ---------------------------------------------------------------
set "MSG_TITLE=GOG Galaxy v2.1+ Plugin Manager (64-Bit) v%UPDATER_VERSION%"
set "MSG_SCANNING=Installierte Plugins werden analysiert..."
set "MSG_TABLE_HEAD=  Status     Integration                          Version / Details"
set "MSG_VALID=OK (melcom 64-Bit)"
set "MSG_INVALID=Nicht von diesem Updater verwaltet"
set "MSG_NOMANIFEST=AUSGESCHLOSSEN (keine manifest.json)"
set "MSG_BADJSON=AUSGESCHLOSSEN (manifest.json unlesbar)"
set "MSG_LEGACY=ALT (unvollständiges Manifest)"
set "MSG_LEGACY_TITLE=Alte melcom-Integration gefunden"
set "MSG_LEGACY_NOTICE=Das Manifest ist unvollständig. Es handelt sich vermutlich um ein älteres Plugin."
set "MSG_LEGACY_RECOMMEND=Empfehlung: Mit der aktuellen 64-Bit-Integration ersetzen?"
set "MSG_LEGACY_YES=[j] Ja, sichern und ersetzen"
set "MSG_LEGACY_NO=[n] Nein, dieses Plugin behalten"
set "MSG_LEGACY_UNKNOWN=Für diesen Ordner ist keine aktuelle Integration verfügbar:"
set "MSG_SAN_TITLE=Steam Achievement Notifier"
set "MSG_SAN_ADD_Q=Hast du den Steam Achievement Notifier installiert?"
set "MSG_SAN_ADD_EXPLAIN=Falls ja, kann automatisch Start-Code in deine plugin.py eingefügt werden, damit der Notifier beim Start eines Steam-Spiels aus GOG Galaxy automatisch geöffnet wird."
set "MSG_SAN_ADD_HINT=Nicht installiert oder kein Interesse? Wähle [n]. Bereits installiert und gewünscht? Wähle [j]."
set "MSG_SAN_DETECTED=In deinem Steam-Plugin ist der Autostart-Code für den Steam Achievement Notifier bereits enthalten."
set "MSG_SAN_KEEP_Q=Möchtest du ihn beibehalten?"
set "MSG_SAN_YES=[j] Ja"
set "MSG_SAN_NO=[n] Nein"
set "MSG_SAN_KEPT=Steam Achievement Notifier Integration beibehalten."
set "MSG_SAN_REMOVED=Steam Achievement Notifier Integration entfernt."
set "MSG_SAN_STRIP_FAIL=Steam Achievement Notifier Integration konnte nicht entfernt werden:"
set "MSG_SAN_ADDED=Steam Achievement Notifier Integration hinzugefügt."
set "MSG_SAN_ADD_FAIL=Steam Achievement Notifier Integration konnte nicht hinzugefügt werden:"
set "MSG_NONE_VALID=Keine unterstützten melcom-Plugins gefunden."
set "MSG_INSTALL_TITLE=Integrationen installieren"
set "MSG_INSTALL_INTRO=Wähle eine Integration zur Installation:"
set "MSG_INSTALL_ALL=Alle verfügbaren Integrationen installieren"
set "MSG_INSTALL_UPDATES=Zurück zur Übersicht"
set "MSG_INSTALL_BACK=Zurück zur Übersicht"
set "MSG_INSTALL_EXIT=Beenden"
set "MSG_INSTALL_PROMPT=Auswahl: "
set "MSG_INSTALL_INVALID=Ungültige Eingabe. Bitte Nummer, a, z oder x wählen."
set "MSG_INSTALLING=Download und Installation laufen..."
set "MSG_INSTALL_OK=Erfolgreich installiert."
set "MSG_INSTALL_FAIL=Installation FEHLGESCHLAGEN:"
set "MSG_INSTALL_EXISTS=Bereits installiert - übersprungen."
set "MSG_INSTALLED=INSTALLIERT"
set "MSG_MORE_OF=von"
set "MSG_MORE_TITLE=Weitere Integrationen"
set "MSG_MORE_STATUS=melcom-Integrationen sind installiert."
set "MSG_MORE_ASK=Möchtest du weitere Integrationen installieren?"
set "MSG_MORE_YES=[j] Ja, verfügbare Integrationen anzeigen"
set "MSG_MORE_NO=[n] Nein, mit Updates fortfahren"
set "MSG_MORE_INVALID=Ungültige Eingabe. Nur j oder n sind erlaubt."
set "MSG_INSTALL_SUMMARY=Installations-Zusammenfassung"
set "MSG_DONE_INSTALLED=installiert"
set "MSG_CONFIRM_Q=Aktionen:"
set "MSG_CONFIRM_YES=[U] Installierte Plugins auf Updates prüfen"
set "MSG_CONFIRM_MORE=[I] Weitere Integrationen installieren"
set "MSG_CONFIRM_EXIT=[X] Beenden"
set "MSG_CONFIRM_PROMPT=Auswahl [U]: "
set "MSG_INVALID_INPUT=Ungültige Eingabe. Bitte U, I oder X wählen."
set "MSG_ABORTED=Vom Benutzer beendet. Es wurden keine Änderungen vorgenommen."
set "MSG_CHECKING=Update wird geprüft..."
set "MSG_UPTODATE=Bereits aktuell."
set "MSG_LOCAL_AHEAD=Lokal installierte Version ist neuer als die neueste Online-Version."
set "MSG_UPDATE_FOUND=Update verfügbar:"
set "MSG_CHECK_ERROR=Update-Prüfung fehlgeschlagen:"
set "MSG_BACKUP_START=Sicherung wird erstellt..."
set "MSG_BACKUP_OK=Sicherung erstellt."
set "MSG_BACKUP_FAIL=Sicherung FEHLGESCHLAGEN - Plugin wird zur Sicherheit übersprungen."
set "MSG_DOWNLOADING=Update wird heruntergeladen und installiert..."
set "MSG_UPDATE_OK=Update erfolgreich installiert."
set "MSG_UPDATE_FAIL=Update FEHLGESCHLAGEN. Die Sicherung liegt im backups-Ordner."
set "MSG_GALAXY_RUNNING=GOG Galaxy läuft noch. Bitte beende den Client vollständig (inkl. System-Tray) und starte den Updater erneut. Aktive Prozesse:"
set "MSG_GALAXY_CHECK_FAIL=Es konnte nicht sicher festgestellt werden, ob GOG Galaxy läuft:"
set "MSG_YN_PROMPT=[J/N]: "
set "MSG_YN_INVALID=Ungültige Eingabe. Nur j oder n sind erlaubt."
set "MSG_SUMMARY=Zusammenfassung"
set "MSG_DONE_UPDATED=aktualisiert"
set "MSG_DONE_SKIPPED=übersprungen / bereits aktuell"
set "MSG_DONE_FAILED=fehlgeschlagen"
set "MSG_LOG_SAVED=Logdatei gespeichert unter:"
set "MSG_PRESS_KEY=Beliebige Taste zum Beenden drücken..."
set "MSG_PLUGINSDIR_MISSING=Plugin-Ordner nicht gefunden:"
set "MSG_PLUGINSDIR_CREATED=Plugin-Ordner erstellt:"
set "MSG_CLEANUP_TITLE=Bereinigung"
set "MSG_CLEANUP_INTRO=Prüfe auf Sicherungen oder Logs älter als %RETENTION_DAYS% Tage..."
set "MSG_OLDLOGS_TITLE=Alte Logdateien"
set "MSG_OLDLOGS_Q=Logdatei(en) sind älter als %RETENTION_DAYS% Tage. Löschen?"
set "MSG_OLDLOGS_DELETED=alte Logdatei(en) gelöscht."
set "MSG_OLDLOGS_FAIL=Alte Logdateien konnten nicht gelöscht werden:"
set "MSG_OLDFILE_DELETED_LOG=Gelöscht:"
set "MSG_OLDBACKUPS_TITLE=Alte Sicherungen"
set "MSG_OLDBACKUPS_Q=Sicherungsdatei(en) sind älter als %RETENTION_DAYS% Tage. Löschen?"
set "MSG_OLDBACKUPS_DELETED=alte Sicherungsdatei(en) gelöscht."
set "MSG_OLDBACKUPS_FAIL=Alte Sicherungen konnten nicht gelöscht werden:"

if not exist "%PLUGINS_DIR%" (
    mkdir "%PLUGINS_DIR%" >nul 2>&1
    if not exist "%PLUGINS_DIR%" (
        call :SAY "%C_RED%" "%MSG_PLUGINSDIR_MISSING% %PLUGINS_DIR%"
        goto FINISH
    )
    call :SAY "%C_YELLOW%" "%MSG_PLUGINSDIR_CREATED% %PLUGINS_DIR%"
)

rem ===================================================================
rem  Hauptmaske: Direkt zur Plugins-Übersicht
rem ===================================================================
:OVERVIEW
call :ScanInstalledPlugins
call :LOAD_INSTALL_CATALOG

set /a ANYVALID=0
for /l %%i in (1,1,!N!) do (
    if "!VALID[%%i]!"=="1" set /a ANYVALID+=1
    if "!VALID[%%i]!"=="2" set /a ANYVALID+=1
)

:OVERVIEW_REDRAW
call :DRAW_TABLE SAY
call :DRAW_MENU SAY
goto OVERVIEW_INPUT

:OVERVIEW_INVALID_INPUT
call :DRAW_TABLE ECHO2
call :DRAW_MENU ECHO2
call :ECHO2 "%C_YELLOW%" "  %MSG_INVALID_INPUT%"
call :ECHO2 "" ""

:OVERVIEW_INPUT
set "CHOICE="
set /p "CHOICE=%MSG_CONFIRM_PROMPT%"
if defined CHOICE (
    set "CHOICE=!CHOICE:"=!"
    set "CHOICE=!CHOICE: =!"
)
if "!CHOICE!"=="" set "CHOICE=U"
if /i "!CHOICE!"=="U" goto PROCEED_UPDATES
if /i "!CHOICE!"=="J" goto PROCEED_UPDATES
if /i "!CHOICE!"=="Y" goto PROCEED_UPDATES
if /i "!CHOICE!"=="1" goto PROCEED_UPDATES
if /i "!CHOICE!"=="I" goto INSTALL_CATALOG
if /i "!CHOICE!"=="2" goto INSTALL_CATALOG
if /i "!CHOICE!"=="X" goto EXIT_NOW
if /i "!CHOICE!"=="0" goto EXIT_NOW
goto OVERVIEW_INVALID_INPUT

rem ===================================================================
rem  Updates für installierte Plugins ausführen
rem ===================================================================
:PROCEED_UPDATES
call :CleanupOldFiles
if !ANYVALID! equ 0 (
    call :SAY "" ""
    call :SAY "%C_YELLOW%" "  %MSG_NONE_VALID%"
    call :SAY "%C_CYAN%" "  Öffne den Katalog zur Installation verfügbarer Integrationen..."
    ping -n 2 127.0.0.1 >nul
    goto INSTALL_CATALOG
)

for /l %%i in (1,1,!N!) do (
    if "!VALID[%%i]!"=="2" call :HandleLegacyPlugin "%%i"
)

set /a CNT_UPDATED=0
set /a CNT_SKIPPED=0
set /a CNT_FAILED=0

call :SAY "" ""
call :SAY "%C_BOLD%%C_CYAN%" "==============================================================================="
call :SAY "%C_BOLD%%C_MAGENTA%" "  🔄 Starte Überprüfung auf Plugin-Updates"
call :SAY "%C_BOLD%%C_CYAN%" "==============================================================================="
call :SAY "" ""

for /l %%i in (1,1,!N!) do (
    if "!VALID[%%i]!"=="1" (
        call :ProcessPlugin "%%i"
    )
)

goto SUMMARY

rem ===================================================================
rem  Installationskatalog für zusätzliche Integrationen
rem ===================================================================
:INSTALL_CATALOG
if !CATALOG_COUNT! equ 0 call :LOAD_INSTALL_CATALOG

:INSTALL_MENU
call :REFRESH_AVAILABLE
if !AVAILABLE_COUNT! equ 0 (
    call :SAY "" ""
    call :SAY "%C_GREEN%" "  Alle verfügbaren Integrationen sind bereits installiert."
    echo.
    pause
    goto OVERVIEW
)
call :DRAW_INSTALL_MENU SAY
goto INSTALL_INPUT

:INSTALL_REDRAW
call :DRAW_INSTALL_MENU ECHO2
call :ECHO2 "%C_YELLOW%" "  %MSG_INSTALL_INVALID%"
call :ECHO2 "" ""

:INSTALL_INPUT
set "INSTALL_CHOICE="
set /p "INSTALL_CHOICE=%MSG_INSTALL_PROMPT%"
if defined INSTALL_CHOICE (
    set "INSTALL_CHOICE=!INSTALL_CHOICE:"=!"
    set "INSTALL_CHOICE=!INSTALL_CHOICE: =!"
)
if "!INSTALL_CHOICE!"=="" goto INSTALL_REDRAW
if /i "!INSTALL_CHOICE!"=="A" goto INSTALL_ALL
if /i "!INSTALL_CHOICE!"=="Z" goto OVERVIEW
if /i "!INSTALL_CHOICE!"=="B" goto OVERVIEW
if /i "!INSTALL_CHOICE!"=="0" goto EXIT_NOW
if /i "!INSTALL_CHOICE!"=="X" goto EXIT_NOW

set "AVAILABLE_INDEX="
for /l %%i in (1,1,!AVAILABLE_COUNT!) do (
    if "!INSTALL_CHOICE!"=="%%i" set "AVAILABLE_INDEX=%%i"
)
if not defined AVAILABLE_INDEX goto INSTALL_REDRAW
call :InstallCatalogPlugin "%AVAILABLE_INDEX%"
goto INSTALL_MENU

:INSTALL_ALL
for /l %%i in (1,1,!AVAILABLE_COUNT!) do call :InstallCatalogPlugin "%%i"
goto INSTALL_MENU

rem ===================================================================
rem  Hilfsfunktionen: Plugins scannen und Katalog laden
rem ===================================================================
:ScanInstalledPlugins
%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action ScanPlugins -PluginsDir "%PLUGINS_DIR%" <nul > "%SCANFILE%"
set /a N=0
for /f "usebackq tokens=1-9 delims=|" %%a in ("%SCANFILE%") do (
    set /a N+=1
    set "DIRNAME[!N!]=%%a"
    set "VALID[!N!]=%%b"
    set "PNAME[!N!]=%%c"
    set "PLATFORM[!N!]=%%d"
    set "PGUID[!N!]=%%e"
    set "PVERSION[!N!]=%%f"
    set "PREPO[!N!]=%%g"
    set "PAPI[!N!]=%%h"
    set "PPATTERN[!N!]=%%i"
)
goto :eof

:LOAD_INSTALL_CATALOG
set /a CATALOG_COUNT=0
for /f "usebackq tokens=1-5 delims=|" %%a in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action GetInstallCatalog ^<nul`) do (
    set /a CATALOG_COUNT+=1
    set "CAT_DIR[!CATALOG_COUNT!]=%%a"
    set "CAT_NAME[!CATALOG_COUNT!]=%%b"
    set "CAT_REPO[!CATALOG_COUNT!]=%%c"
    set "CAT_API[!CATALOG_COUNT!]=%%d"
    set "CAT_PATTERN[!CATALOG_COUNT!]=%%e"
)
call :REFRESH_AVAILABLE
goto :eof

:REFRESH_AVAILABLE
set /a AVAILABLE_COUNT=0
for /l %%i in (1,1,!CATALOG_COUNT!) do (
    if not exist "%PLUGINS_DIR%\!CAT_DIR[%%i]!" (
        set /a AVAILABLE_COUNT+=1
        set "AVAILABLE_DIR[!AVAILABLE_COUNT!]=!CAT_DIR[%%i]!"
        set "AVAILABLE_NAME[!AVAILABLE_COUNT!]=!CAT_NAME[%%i]!"
        set "AVAILABLE_REPO[!AVAILABLE_COUNT!]=!CAT_REPO[%%i]!"
        set "AVAILABLE_API[!AVAILABLE_COUNT!]=!CAT_API[%%i]!"
        set "AVAILABLE_PATTERN[!AVAILABLE_COUNT!]=!CAT_PATTERN[%%i]!"
    )
)
goto :eof

rem ===================================================================
rem  Legacy-Plugin Behandlung
rem ===================================================================
:HandleLegacyPlugin
set "LEGACY_INDEX=%~1"
set "LEGACY_DIR=!DIRNAME[%LEGACY_INDEX%]!"
set "LEGACY_CATALOG_INDEX="
for /l %%i in (1,1,!CATALOG_COUNT!) do (
    if /i "!LEGACY_DIR!"=="!CAT_DIR[%%i]!" set "LEGACY_CATALOG_INDEX=%%i"
)

if not defined LEGACY_CATALOG_INDEX (
    call :SAY "%C_YELLOW%" "  %MSG_LEGACY_UNKNOWN% !LEGACY_DIR!"
    goto :eof
)

call :AskYesNo DRAW_LEGACY_PROMPT
if /i "!ASKYN_RESULT!"=="Y" goto LEGACY_REPLACE
goto :eof

:DRAW_LEGACY_PROMPT
call :%~1 "" ""
call :%~1 "%C_BOLD%%C_YELLOW%" "-------------------------------------------------------------------------------"
call :%~1 "%C_BOLD%" "  %MSG_LEGACY_TITLE%"
call :%~1 "%C_GRAY%" "  !PNAME[%LEGACY_INDEX%]! - !LEGACY_DIR!"
call :%~1 "%C_BOLD%%C_YELLOW%" "-------------------------------------------------------------------------------"
call :%~1 "%C_YELLOW%" "  %MSG_LEGACY_NOTICE%"
call :%~1 "%C_BOLD%" "  %MSG_LEGACY_RECOMMEND%"
call :%~1 "" "    %MSG_LEGACY_YES%"
call :%~1 "" "    %MSG_LEGACY_NO%"
call :%~1 "" ""
goto :eof

:LEGACY_REPLACE
set "VALID[%LEGACY_INDEX%]=1"
set "PREPO[%LEGACY_INDEX%]=!CAT_REPO[%LEGACY_CATALOG_INDEX%]!"
set "PAPI[%LEGACY_INDEX%]=!CAT_API[%LEGACY_CATALOG_INDEX%]!"
set "PPATTERN[%LEGACY_INDEX%]=!CAT_PATTERN[%LEGACY_CATALOG_INDEX%]!"
set "PVERSION[%LEGACY_INDEX%]=0"
call :ProcessPlugin "%LEGACY_INDEX%"
goto :eof

rem ===================================================================
rem  Steam Achievement Notifier Behandlung
rem ===================================================================
:SanCheckCurrentAndPrompt
if /i not "%~1"=="%STEAM_PLUGIN_DIR%" goto :eof
set "SANCHECK="
for /f "usebackq delims=" %%R in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CheckSanMarker -PluginsDir "%PLUGINS_DIR%" -PluginDirName "%~1"`) do set "SANCHECK=%%R"
set "SAN_CURRENT_STATE=NOTPRESENT"
for /f "tokens=1 delims=|" %%a in ("!SANCHECK!") do set "SAN_CURRENT_STATE=%%a"
call :HandleSanIntegration "%~1" "!SAN_CURRENT_STATE!"
goto :eof

:HandleSanIntegration
set "SAN_TARGET_DIR=%~1"
set "SAN_STATE=%~2"
if /i not "%SAN_TARGET_DIR%"=="%STEAM_PLUGIN_DIR%" goto :eof
if /i "%SAN_STATE%"=="PRESENT" (
    set "SAN_QUESTION=%MSG_SAN_KEEP_Q%"
    set "SAN_YES_LABEL=%MSG_SAN_YES%"
    set "SAN_NO_LABEL=%MSG_SAN_NO%"
    call :AskYesNo DRAW_SAN_PROMPT
    if /i "!ASKYN_RESULT!"=="Y" goto SAN_KEEP
    goto SAN_STRIP
)
set "SAN_QUESTION=%MSG_SAN_ADD_Q%"
set "SAN_YES_LABEL=%MSG_SAN_YES%"
set "SAN_NO_LABEL=%MSG_SAN_NO%"
call :AskYesNo DRAW_SAN_PROMPT
if /i "!ASKYN_RESULT!"=="Y" goto SAN_INSERT
goto SAN_NO

:DRAW_SAN_PROMPT
call :%~1 "" ""
call :%~1 "%C_BOLD%%C_CYAN%" "-------------------------------------------------------------------------------"
call :%~1 "%C_BOLD%" "  %MSG_SAN_TITLE%"
call :%~1 "%C_BOLD%%C_CYAN%" "-------------------------------------------------------------------------------"
if /i "%SAN_STATE%"=="PRESENT" (
    call :%~1 "%C_CYAN%" "  %MSG_SAN_DETECTED%"
) else (
    call :%~1 "%C_CYAN%" "  %MSG_SAN_ADD_EXPLAIN%"
    call :%~1 "%C_GRAY%" "  %MSG_SAN_ADD_HINT%"
)
call :%~1 "" ""
call :%~1 "%C_BOLD%" "  !SAN_QUESTION!"
call :%~1 "" "    !SAN_YES_LABEL!"
call :%~1 "" "    !SAN_NO_LABEL!"
call :%~1 "" ""
goto :eof

:SAN_YES
goto :eof

:SAN_NO
goto :eof

:SAN_KEEP
call :SAY "%C_GREEN%" "  %MSG_SAN_KEPT%"
goto :eof

:SAN_STRIP
set "STRIPRESULT="
for /f "usebackq delims=" %%R in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action RemoveSan -PluginsDir "%PLUGINS_DIR%" -PluginDirName "%SAN_TARGET_DIR%"`) do set "STRIPRESULT=%%R"
set "STRIP_STATUS=ERROR"
set "STRIP_MSG=NO_HELPER_RESPONSE"
for /f "tokens=1,* delims=|" %%a in ("!STRIPRESULT!") do (set "STRIP_STATUS=%%a" & set "STRIP_MSG=%%b")
if /i "!STRIP_STATUS!"=="OK" (
    call :SAY "%C_GREEN%" "  %MSG_SAN_REMOVED%"
) else (
    call :SAY "%C_RED%" "  %MSG_SAN_STRIP_FAIL% !STRIP_MSG!"
)
goto :eof

:SAN_INSERT
set "INSRESULT="
for /f "usebackq delims=" %%R in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action InjectSan -PluginsDir "%PLUGINS_DIR%" -PluginDirName "%SAN_TARGET_DIR%"`) do set "INSRESULT=%%R"
set "INS_STATUS=ERROR"
set "INS_MSG=NO_HELPER_RESPONSE"
for /f "tokens=1,* delims=|" %%a in ("!INSRESULT!") do (set "INS_STATUS=%%a" & set "INS_MSG=%%b")
if /i "!INS_STATUS!"=="OK" (
    call :SAY "%C_GREEN%" "  %MSG_SAN_ADDED%"
) else (
    call :SAY "%C_RED%" "  %MSG_SAN_ADD_FAIL% !INS_MSG!"
)
goto :eof

rem ===================================================================
rem  Alte Logs & Backups aufräumen
rem ===================================================================
:CleanupOldFiles
set "CL_LOGS_COUNT=0"
for /f "usebackq tokens=1,2 delims=|" %%a in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CountOldLogs -LogDir "%LOG_DIR%" -Days %RETENTION_DAYS%`) do (
    if /i "%%a"=="COUNT" set "CL_LOGS_COUNT=%%b"
)
if !CL_LOGS_COUNT! gtr 0 (
    set "OL_VALUE=!CL_LOGS_COUNT!"
    call :AskYesNo DRAW_OLDLOGS_PROMPT
    if /i "!ASKYN_RESULT!"=="Y" (
        for /f "usebackq tokens=1,* delims=|" %%a in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action DeleteOldLogs -LogDir "%LOG_DIR%" -Days %RETENTION_DAYS%`) do (
            if /i "%%a"=="DELETED" call :SAY "%C_GRAY%" "  %MSG_OLDFILE_DELETED_LOG% %%b"
            if /i "%%a"=="COUNT" call :SAY "%C_GREEN%" "  %%b %MSG_OLDLOGS_DELETED%"
            if /i "%%a"=="ERROR" call :SAY "%C_RED%" "  %MSG_OLDLOGS_FAIL% %%b"
        )
    )
)
set "CL_BACKUPS_COUNT=0"
for /f "usebackq tokens=1,2 delims=|" %%a in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CountOldBackups -BackupDir "%BACKUP_DIR%" -Days %RETENTION_DAYS%`) do (
    if /i "%%a"=="COUNT" set "CL_BACKUPS_COUNT=%%b"
)
if !CL_BACKUPS_COUNT! gtr 0 (
    set "OB_VALUE=!CL_BACKUPS_COUNT!"
    call :AskYesNo DRAW_OLDBACKUPS_PROMPT
    if /i "!ASKYN_RESULT!"=="Y" (
        for /f "usebackq tokens=1,* delims=|" %%a in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action DeleteOldBackups -BackupDir "%BACKUP_DIR%" -Days %RETENTION_DAYS%`) do (
            if /i "%%a"=="DELETED" call :SAY "%C_GRAY%" "  %MSG_OLDFILE_DELETED_LOG% %%b"
            if /i "%%a"=="COUNT" call :SAY "%C_GREEN%" "  %%b %MSG_OLDBACKUPS_DELETED%"
            if /i "%%a"=="ERROR" call :SAY "%C_RED%" "  %MSG_OLDBACKUPS_FAIL% %%b"
        )
    )
)
goto :eof

:DRAW_OLDLOGS_PROMPT
call :%~1 "" ""
call :%~1 "%C_BOLD%%C_YELLOW%" "-------------------------------------------------------------------------------"
call :%~1 "%C_BOLD%" "  %MSG_OLDLOGS_TITLE%"
call :%~1 "%C_BOLD%%C_YELLOW%" "-------------------------------------------------------------------------------"
call :%~1 "%C_YELLOW%" "  !OL_VALUE! %MSG_OLDLOGS_Q%"
call :%~1 "" ""
goto :eof

:DRAW_OLDBACKUPS_PROMPT
call :%~1 "" ""
call :%~1 "%C_BOLD%%C_YELLOW%" "-------------------------------------------------------------------------------"
call :%~1 "%C_BOLD%" "  %MSG_OLDBACKUPS_TITLE%"
call :%~1 "%C_BOLD%%C_YELLOW%" "-------------------------------------------------------------------------------"
call :%~1 "%C_YELLOW%" "  !OB_VALUE! %MSG_OLDBACKUPS_Q%"
call :%~1 "" ""
goto :eof

rem ===================================================================
rem  Ja/Nein-Abfrage Routine
rem ===================================================================
:AskYesNo
set "ASKYN_DRAW=%~1"
set "ASKYN_INVALID_SHOWN="
if defined ASKYN_DRAW call :%ASKYN_DRAW% SAY
goto AskYesNo_Input

:AskYesNo_Input
set "ASKYN_INPUT="
set /p "ASKYN_INPUT=%MSG_YN_PROMPT%"
if /i "!ASKYN_INPUT!"=="!YESKEY!" (
    set "ASKYN_RESULT=Y"
    goto :eof
)
if /i "!ASKYN_INPUT!"=="Y" (
    set "ASKYN_RESULT=Y"
    goto :eof
)
if /i "!ASKYN_INPUT!"=="N" (
    set "ASKYN_RESULT=N"
    goto :eof
)
<nul set /p "=%ESC%[1A%ESC%[2K"
if not defined ASKYN_INVALID_SHOWN (
    call :ECHO2 "%C_YELLOW%" "  %MSG_YN_INVALID%"
    call :ECHO2 "" ""
    set "ASKYN_INVALID_SHOWN=1"
)
goto AskYesNo_Input

rem ===================================================================
rem  Plugin aus Katalog installieren
rem ===================================================================
:InstallCatalogPlugin
setlocal EnableDelayedExpansion
set "IDX=%~1"
set "DN=!AVAILABLE_DIR[%IDX%]!"
set "PN=!AVAILABLE_NAME[%IDX%]!"
set "RP=!AVAILABLE_REPO[%IDX%]!"
set "API=!AVAILABLE_API[%IDX%]!"
set "PAT=!AVAILABLE_PATTERN[%IDX%]!"

call :SAY "" ""
call :SAY "%C_BOLD%%C_CYAN%" "-------------------------------------------------------------------------------"
call :SAY "%C_BOLD%" "  !PN!"
call :SAY "%C_BOLD%%C_CYAN%" "-------------------------------------------------------------------------------"
call :SAY "%C_CYAN%" "  %MSG_CHECKING%"

if exist "%PLUGINS_DIR%\!DN!" (
    call :SAY "%C_GRAY%" "  %MSG_INSTALL_EXISTS%"
    endlocal & goto :eof
)

call :EnsureGalaxyStopped
if "!GALAXY_STOPPED!"=="0" (
    endlocal & goto :eof
)

call :SAY "%C_CYAN%" "  %MSG_INSTALLING%"
set "U_STATUS=ERROR"
set "U_TAG=NO_HELPER_RESPONSE"
set "U_URL="
set "RESULT="
for /f "usebackq delims=" %%R in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CheckUpdate -Repo "!RP!" -LatestApi "!API!" -AssetPattern "!PAT!" -LocalVersion "0"`) do set "RESULT=%%R"
for /f "tokens=1-3 delims=|" %%a in ("!RESULT!") do (
    set "U_STATUS=%%a"
    set "U_TAG=%%b"
    set "U_URL=%%c"
)

if not "!U_STATUS!"=="UPDATE" (
    call :SAY "%C_RED%" "  %MSG_INSTALL_FAIL% !U_TAG!"
    endlocal & goto :eof
)

set "I_STATUS=ERROR"
set "I_PATH=NO_HELPER_RESPONSE"
set "IRESULT="
for /f "usebackq delims=" %%R in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action DoUpdate -PluginsDir "%PLUGINS_DIR%" -PluginDirName "!DN!" -DownloadUrl "!U_URL!" -ExpectedRepo "!RP!" -ExpectedVersion "!U_TAG!"`) do set "IRESULT=%%R"
for /f "tokens=1,2 delims=|" %%a in ("!IRESULT!") do (set "I_STATUS=%%a" & set "I_PATH=%%b")

if not "!I_STATUS!"=="OK" (
    call :SAY "%C_RED%" "  %MSG_INSTALL_FAIL% !I_PATH!"
    endlocal & goto :eof
)

call :SAY "%C_GREEN%" "  %MSG_INSTALL_OK% (!U_TAG!)"
if /i "!DN!"=="%STEAM_PLUGIN_DIR%" call :HandleSanIntegration "!DN!" "NOTPRESENT"
call :SAY "" ""
endlocal & goto :eof

rem ===================================================================
rem  Plugin aktualisieren
rem ===================================================================
:ProcessPlugin
setlocal EnableDelayedExpansion
set "IDX=%~1"
set "DN=!DIRNAME[%IDX%]!"
set "PN=!PNAME[%IDX%]!"
set "LV=!PVERSION[%IDX%]!"
set "RP=!PREPO[%IDX%]!"
set "API=!PAPI[%IDX%]!"
set "PAT=!PPATTERN[%IDX%]!"

call :SAY "" ""
call :SAY "%C_BOLD%%C_CYAN%" "-------------------------------------------------------------------------------"
call :SAY "%C_BOLD%" "  !PN! (Aktuell: !LV!)"
call :SAY "%C_BOLD%%C_CYAN%" "-------------------------------------------------------------------------------"
call :SAY "%C_CYAN%" "  %MSG_CHECKING%"

ping -n 2 127.0.0.1 >nul

set "U_STATUS=ERROR"
set "U_TAG=NO_HELPER_RESPONSE"
set "U_URL="
set "RESULT="
for /f "usebackq delims=" %%R in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CheckUpdate -Repo "!RP!" -LatestApi "!API!" -AssetPattern "!PAT!" -LocalVersion "!LV!"`) do set "RESULT=%%R"

for /f "tokens=1-3 delims=|" %%a in ("!RESULT!") do (
    set "U_STATUS=%%a"
    set "U_TAG=%%b"
    set "U_URL=%%c"
)

if "!U_STATUS!"=="ERROR" (
    call :SAY "%C_RED%" "  %MSG_CHECK_ERROR% !U_TAG!"
    endlocal & set /a CNT_FAILED+=1 & goto :eof
)
if "!U_STATUS!"=="UPTODATE" (
    call :SAY "%C_GREEN%" "  %MSG_UPTODATE% (!U_TAG!)"
    call :SanCheckCurrentAndPrompt "!DN!"
    endlocal & set /a CNT_SKIPPED+=1 & goto :eof
)
if "!U_STATUS!"=="AHEAD" (
    call :SAY "%C_GRAY%" "  %MSG_LOCAL_AHEAD% (!U_TAG!)"
    call :SanCheckCurrentAndPrompt "!DN!"
    endlocal & set /a CNT_SKIPPED+=1 & goto :eof
)

if not "!U_STATUS!"=="UPDATE" (
    call :SAY "%C_RED%" "  %MSG_CHECK_ERROR% INVALID_HELPER_RESPONSE"
    endlocal & set /a CNT_FAILED+=1 & goto :eof
)
call :SAY "%C_YELLOW%" "  %MSG_UPDATE_FOUND% !U_TAG!"

call :EnsureGalaxyStopped
if "!GALAXY_STOPPED!"=="0" (
    endlocal & set /a CNT_FAILED+=1 & goto :eof
)

set "SAN_OLDSTATE=NOTPRESENT"
if /i "!DN!"=="%STEAM_PLUGIN_DIR%" (
    set "SANCHECK="
    for /f "usebackq delims=" %%R in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CheckSanMarker -PluginsDir "%PLUGINS_DIR%" -PluginDirName "!DN!"`) do set "SANCHECK=%%R"
    for /f "tokens=1 delims=|" %%a in ("!SANCHECK!") do set "SAN_OLDSTATE=%%a"
)

call :SAY "%C_CYAN%" "  %MSG_BACKUP_START%"
set "B_STATUS=ERROR"
set "B_PATH=NO_HELPER_RESPONSE"
set "BRESULT="
for /f "usebackq delims=" %%R in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action BackupPlugin -PluginsDir "%PLUGINS_DIR%" -BackupDir "%BACKUP_DIR%" -PluginDirName "!DN!"`) do set "BRESULT=%%R"
for /f "tokens=1,2 delims=|" %%a in ("!BRESULT!") do (set "B_STATUS=%%a" & set "B_PATH=%%b")

if not "!B_STATUS!"=="OK" (
    call :SAY "%C_RED%" "  %MSG_BACKUP_FAIL%"
    endlocal & set /a CNT_FAILED+=1 & goto :eof
)
call :SAY "%C_GREEN%" "  %MSG_BACKUP_OK%"

call :SAY "%C_CYAN%" "  %MSG_DOWNLOADING%"
set "UP_STATUS=ERROR"
set "UP_PATH=NO_HELPER_RESPONSE"
set "URESULT="
for /f "usebackq delims=" %%R in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action DoUpdate -PluginsDir "%PLUGINS_DIR%" -PluginDirName "!DN!" -DownloadUrl "!U_URL!" -ExpectedRepo "!RP!" -ExpectedVersion "!U_TAG!"`) do set "URESULT=%%R"
for /f "tokens=1,2 delims=|" %%a in ("!URESULT!") do (set "UP_STATUS=%%a" & set "UP_PATH=%%b")

if not "!UP_STATUS!"=="OK" (
    call :SAY "%C_RED%" "  %MSG_UPDATE_FAIL% !UP_PATH!"
    endlocal & set /a CNT_FAILED+=1 & goto :eof
)
call :SAY "%C_GREEN%" "  %MSG_UPDATE_OK%"
call :HandleSanIntegration "!DN!" "!SAN_OLDSTATE!"

call :SAY "" ""
endlocal & set /a CNT_UPDATED+=1 & goto :eof

rem ===================================================================
rem  GOG Galaxy Prozess-Prüfung
rem ===================================================================
:EnsureGalaxyStopped
set "GALAXY_STOPPED=0"
set "GALAXY_CHECK_STATUS=ERROR"
set "GALAXY_CHECK_DETAIL=NO_HELPER_RESPONSE"
set "GALAXY_CHECK_RESULT="
for /f "usebackq delims=" %%R in (`%PWSH_EXE% -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CheckGalaxyRunning`) do set "GALAXY_CHECK_RESULT=%%R"
for /f "tokens=1,* delims=|" %%a in ("!GALAXY_CHECK_RESULT!") do (
    set "GALAXY_CHECK_STATUS=%%a"
    set "GALAXY_CHECK_DETAIL=%%b"
)
if /i "!GALAXY_CHECK_STATUS!"=="STOPPED" (
    set "GALAXY_STOPPED=1"
    goto :eof
)
if /i "!GALAXY_CHECK_STATUS!"=="RUNNING" (
    call :SAY "%C_RED%" "  %MSG_GALAXY_RUNNING% !GALAXY_CHECK_DETAIL!"
    goto :eof
)
call :SAY "%C_RED%" "  %MSG_GALAXY_CHECK_FAIL% !GALAXY_CHECK_DETAIL!"
goto :eof

rem ===================================================================
rem  Zusammenfassung
rem ===================================================================
:SUMMARY
call :SAY "" ""
call :SAY "%C_BOLD%%C_CYAN%" "==============================================================================="
call :SAY "%C_BOLD%%C_MAGENTA%" "  📊 %MSG_SUMMARY%"
call :SAY "%C_BOLD%%C_CYAN%" "==============================================================================="
call :SAY "%C_GREEN%" "  ✓ !CNT_UPDATED! %MSG_DONE_UPDATED%"
call :SAY "%C_YELLOW%" "  – !CNT_SKIPPED! %MSG_DONE_SKIPPED%"
call :SAY "%C_RED%" "  ✗ !CNT_FAILED! %MSG_DONE_FAILED%"
call :SAY "%C_BOLD%%C_CYAN%" "==============================================================================="
call :SAY "" ""
call :SAY "%C_GRAY%" "%MSG_LOG_SAVED% %LOGFILE%"
call :SAY "" ""
echo %C_BOLD%Optionen:%C_RESET%
echo   %C_CYAN%[1 / Z]%C_RESET%  Zurück zur Plugins-Übersicht
echo   %C_CYAN%[X]%C_RESET%      Beenden
echo.
set "SUM_CHOICE="
set /p "SUM_CHOICE=Auswahl [X]: "
if "!SUM_CHOICE!"=="" goto FINISH
if "!SUM_CHOICE!"=="0" goto FINISH
if /i "!SUM_CHOICE!"=="X" goto FINISH
if "!SUM_CHOICE!"=="1" goto OVERVIEW
if /i "!SUM_CHOICE!"=="Z" goto OVERVIEW
goto FINISH

:EXIT_NOW
if exist "%SCANFILE%" del /f /q "%SCANFILE%" >nul 2>&1
endlocal
exit /b 0

:FINISH
if defined SKIP_LOG (
    if exist "%LOGFILE%" del /f /q "%LOGFILE%" >nul 2>&1
)
if exist "%SCANFILE%" del /f /q "%SCANFILE%" >nul 2>&1
endlocal
exit /b 0

rem ===================================================================
rem  Ausgabe-Routinen
rem ===================================================================
:SAY
echo(%~1%~2%C_RESET%
>>"%LOGFILE%" echo(%~2
goto :eof

:ECHO2
echo(%~1%~2%C_RESET%
goto :eof

rem ===================================================================
rem  Tabellen- und Menü-Darstellung
rem ===================================================================
:DRAW_TABLE
cls
call :%~1 "%C_BOLD%%C_CYAN%" "==============================================================================="
call :%~1 "%C_BOLD%%C_MAGENTA%" "  %MSG_TITLE%"
if defined NEW_UPDATER_VERSION (
    echo %C_BOLD%%C_RED%   ^>^>  Neue Updater-Version verfügbar: !NEW_UPDATER_VERSION!  ^<^<%C_RESET%
    if "%~1"=="SAY" >>"%LOGFILE%" echo    ^>^>  Neue Updater-Version verfügbar: !NEW_UPDATER_VERSION!  ^<^<
)
call :%~1 "%C_BOLD%%C_CYAN%" "==============================================================================="
call :%~1 "%C_GRAY%" "Plugin-Verzeichnis: %PLUGINS_DIR%"
call :%~1 "%C_BOLD%%C_CYAN%" "-------------------------------------------------------------------------------"
call :%~1 "%C_BOLD%" "%MSG_TABLE_HEAD%"
call :%~1 "%C_GRAY%" "-------------------------------------------------------------------------------"
if !N! equ 0 (
    call :%~1 "%C_YELLOW%" "  (Keine Plugins im Plugin-Verzeichnis installiert)"
) else (
    for /l %%i in (1,1,!N!) do (
        set "PADNAME=!PNAME[%%i]!                                   "
        set "PADNAME=!PADNAME:~0,32!"
        if "!VALID[%%i]!"=="1" (
            call :%~1 "%C_GREEN%" "  [✓ OK]     !PADNAME!  !PVERSION[%%i]! (melcom 64-Bit)"
        ) else if "!VALID[%%i]!"=="2" (
            call :%~1 "%C_YELLOW%" "  [⚠ ALT]    !PADNAME!  !PVERSION[%%i]! (%MSG_LEGACY%)"
        ) else (
            if "!PNAME[%%i]!"=="NOMANIFEST" (
                call :%~1 "%C_GRAY%" "  [– EXCL]   !PADNAME!  %MSG_NOMANIFEST%"
            ) else if "!PNAME[%%i]!"=="BADJSON" (
                call :%~1 "%C_GRAY%" "  [– EXCL]   !PADNAME!  %MSG_BADJSON%"
            ) else (
                call :%~1 "%C_GRAY%" "  [– EXCL]   !PADNAME!  !PVERSION[%%i]! (%MSG_INVALID%)"
            )
        )
    )
)
call :%~1 "%C_BOLD%%C_CYAN%" "-------------------------------------------------------------------------------"
call :%~1 "" ""
goto :eof

:DRAW_MENU
call :%~1 "%C_BOLD%" "%MSG_CONFIRM_Q%"
if !ANYVALID! gtr 0 (
    call :%~1 "" "  %C_CYAN%[U]%C_RESET%          Installierte Plugins auf Updates prüfen"
)
if !AVAILABLE_COUNT! gtr 0 (
    call :%~1 "" "  %C_CYAN%[I]%C_RESET%          Weitere Integrationen installieren (%C_GREEN%!AVAILABLE_COUNT! verfügbar%C_RESET%)"
) else (
    call :%~1 "" "  %C_CYAN%[I]%C_RESET%          Integrationen-Katalog anzeigen"
)
call :%~1 "" "  %C_CYAN%[X]%C_RESET%          Beenden"
call :%~1 "" ""
goto :eof

:DRAW_INSTALL_MENU
cls
call :%~1 "%C_BOLD%%C_CYAN%" "==============================================================================="
call :%~1 "%C_BOLD%%C_MAGENTA%" "  📦 GOG Galaxy 64-Bit Integrationen installieren"
call :%~1 "%C_BOLD%%C_CYAN%" "==============================================================================="
call :%~1 "%C_GRAY%" "Plugin-Verzeichnis: %PLUGINS_DIR%"
call :%~1 "%C_BOLD%%C_CYAN%" "-------------------------------------------------------------------------------"
call :%~1 "%C_BOLD%" "%MSG_INSTALL_INTRO%"
call :%~1 "" ""
for /l %%i in (1,1,!AVAILABLE_COUNT!) do (
    set "NUMPAD=  %%i"
    set "NUMPAD=!NUMPAD:~-2!"
    call :%~1 "%C_CYAN%" "  [!NUMPAD!] !AVAILABLE_NAME[%%i]!"
)
call :%~1 "" ""
call :%~1 "%C_BOLD%%C_CYAN%" "-------------------------------------------------------------------------------"
call :%~1 "%C_BOLD%" "Optionen:"
call :%~1 "" "  %C_CYAN%[A]%C_RESET%      %MSG_INSTALL_ALL%"
call :%~1 "" "  %C_CYAN%[Z]%C_RESET%      %MSG_INSTALL_BACK%"
call :%~1 "" "  %C_CYAN%[X]%C_RESET%      %MSG_INSTALL_EXIT%"
call :%~1 "" ""
goto :eof
