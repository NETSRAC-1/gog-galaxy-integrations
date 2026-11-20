<div align="center">

# 🎮 GOG Galaxy 64-Bit Integrationen & Plugin Manager

### 64-Bit Community-Integrationen & Portabler Plugin Manager für GOG Galaxy 2.1+

[![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)](#)
[![GOG Galaxy](https://img.shields.io/badge/GOG_Galaxy-2.1+_(64--Bit)-8A2BE2?style=for-the-badge&logo=gog.com&logoColor=white)](#)
[![Design](https://img.shields.io/badge/Design-Zero--Setup_Portable-00C853?style=for-the-badge)](#)
[![Status](https://img.shields.io/badge/Status-Community_Fork-FF6F00?style=for-the-badge)](#)

<p align="center">
  <b>Zentrale Übersicht und komfortabler Manager für 64-Bit Community-Plugins in GOG Galaxy 2.1+.</b><br>
  Enthält den überarbeiteten, portablen Batch/PowerShell Plugin-Manager mit ANSI-Farboberfläche und automatischem Versions-Check.
</p>

> ℹ️ **Hinweis:** Forked from [melcom-creations/galaxy-integrations-64bit](https://github.com/melcom-creations/galaxy-integrations-64bit)

</div>

---

## 🔄 64-Bit GOG Galaxy Client beziehen

Diese Integrationen setzen die native 64-Bit-Version von GOG Galaxy ab Version 2.1 voraus. Wer noch eine ältere 32-Bit-Installation nutzt, kann den aktuellen 64-Bit-Client von der [offiziellen GOG Galaxy Website](https://www.gog.com/galaxy) herunterladen.

---

## 🚀 Status der 64-Bit Community-Integrationen

| Integration | Betreuer | Status | Erfolge (Achievements) | Spielzeit | Download |
|:--- |:--- |:---:|:---:|:---:|:--- |
| **Amazon Games** | **melcom** | ✅ Veröffentlicht | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-amazon) |
| **Battle.net** | **melcom** | ✅ Veröffentlicht | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-battlenet) |
| **Humble Bundle** | **melcom** | ✅ Veröffentlicht | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-humble) |
| **itch.io** | **melcom** | ✅ Veröffentlicht | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-itch) |
| **Steam** | **melcom** | ✅ Veröffentlicht | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-steam) |
| **Ubisoft Connect** | **melcom** | ✅ Veröffentlicht | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-uplay) |
| **EA app** | **melcom** | ✅ Veröffentlicht | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-ea) |
| **Rockstar Games** | **melcom** | ✅ Veröffentlicht | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-rockstar) |
| **IndieGala** | **melcom** | ✅ Veröffentlicht | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-indiegala) |
| **Legacy Games** | **pippo-san** | ✅ Veröffentlicht | ❌ | ✅ | [Download](https://github.com/pippo-san/galaxy-integration-legacy-games) |

> 📌 **Wichtig:**
> Bei Fragen oder Problemen zu einzelnen Plugins bitte direkt an den in der Tabelle genannten Betreuer wenden.
>
> Entwickler, die eigene Plugins hier listen möchten, wenden sich an das Original-Repository von melcom. Es werden nur aktiv gepflegte Plugins aufgenommen, deren Autoren auch Anwender-Support bieten.

Legende: ✅ Unterstützt · ❌ Nicht unterstützt · ⏳ Geplant oder in Entwicklung

---

## 📦 Installation

### 🔄 Automatische Installation mit dem Plugin Manager (Empfohlen)

Die beiliegende `update-plugins.bat` ist das empfohlene Werkzeug unter Windows, um unterstützte Integrationen zu installieren und aktuell zu halten.

1. `update-plugins.bat` per Doppelklick starten.
2. Das Skript zeigt sofort die Übersicht aller im Plugin-Verzeichnis installierten Integrationen und deren Status:
   - `[✓ OK]` Aktuelle 64-Bit-Version
   - `[⚠ ALT]` Ältere 32-Bit-Version (kann direkt ersetzt werden)
   - `[– EXCL]` Nicht vom Manager verwaltetes Plugin
3. Menüoptionen:
   - `[U]` bzw. `Enter`: Installierte Plugins auf Updates prüfen und aktualisieren.
   - `[I]`: Katalog anzeigen, um weitere 64-Bit-Integrationen direkt mit einem Klick zu installieren.
   - `[X]`: Beenden.

### 📂 Manuelle Installation

1. GOG Galaxy vollständig schließen (auch im Windows-Infobereich / System Tray).
2. Das Repository der gewünschten Integration über den Download-Link in der Tabelle oben aufrufen und unter **Releases** das neueste 64-Bit-Archiv herunterladen.
3. Den Plugin-Ordner in das Plugin-Verzeichnis entpacken:
   ```text
   %localappdata%\GOG.com\Galaxy\plugins\installed
   ```
   Die Datei `manifest.json` muss direkt im Stammverzeichnis des jeweiligen Plugin-Ordners liegen, ohne zusätzliche Zwischenordner.
4. GOG Galaxy starten und das entsprechende Konto unter **Einstellungen -> Integrationen** verbinden.

**Hinweis:** Die jeweilige Dokumentation (README) des Plugins beachten. Battle.net und itch.io erfordern eine persönliche Authentifizierungseinrichtung; andere Integrationen fragen eventuell nach Spielepfaden.

Sicherungskopien von Plugin-Ordnern stets außerhalb von `plugins\installed` aufbewahren, da doppelte Ordner beim Laden der Integrationen zu Konflikten führen.

---

## 🧰 Plugin-Wartungswerkzeuge

Die Werkzeuge stehen im Verzeichnis [`/tools/`](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools) bereit.

### 🔄 GOG Galaxy Plugin Manager & Updater

Der Manager ist ein vollständig portables Windows-Werkzeug (Batch + PowerShell). Er erstellt vor jedem Update eine ZIP-Sicherung des bestehenden Plugins sowie ein Protokoll und bietet optionale Unterstützung für Steam Achievement Notifier. Eine separate Python-Installation ist für den Betrieb nicht erforderlich.

Aktuelle Versionen der Battle.net- und itch.io-Plugins speichern persönliche Login-Daten außerhalb des Plugin-Ordners. Plugin-Aktualisierungen überschreiben diese Daten daher nicht.

### 🔬 Galaxy Plugin Scout (Nur für fortgeschrittene Anwender)

Der im Ordner `tools/scout/` enthaltene **Galaxy Plugin Scout** ist ein Entwicklerwerkzeug zur Analyse und Pflege von gebündelten Python-Bibliotheken in den `modules`-Ordnern der Plugins. Er bietet einen Testlauf-Modus (Dry-Run), prüft Bibliotheken auf Aktualisierungen und kann ungenutzte Module entfernen oder fehlende Abhängigkeiten nachinstallieren. Für den Betrieb ist Python 3.13 64-Bit mit `pip` erforderlich.

---

## ⚙️ Technische Kompatibilität

Alle hier gelisteten Integrationen sind für GOG Galaxy ab Version 2.1 (64-Bit) konzipiert, das Python 3.13 für Community-Plugins einsetzt. Sie sind **nicht** kompatibel mit dem alten 32-Bit-Client (GOG Galaxy 2.0).

---

## 🛠️ Fehlerbehebung (Troubleshooting)

Als erster Schritt empfiehlt sich ein Neustart von GOG Galaxy und dem jeweiligen Launcher des Drittanbieters, gefolgt von einem manuellen Synchronisationsversuch. Zudem die Dokumentation des betroffenen Plugins auf bekannte Einschränkungen prüfen.

### 🧪 Frische Diagnose-Logs erstellen

Vor der Kontaktaufnahme mit dem Entwickler empfiehlt sich ein frisches Log, da alte Protokolle veraltete Sitzungsdaten enthalten können:

1. GOG Galaxy vollständig beenden (auch im Infobereich der Taskleiste).
2. Das Log-Verzeichnis im Windows Explorer öffnen:
   ```text
   %ProgramData%\GOG.com\Galaxy\logs
   ```
3. Das Log der betroffenen Integration heraussuchen (der genaue Dateiname steht in der jeweiligen Dokumentation). Das vorhandene Log in einen Sicherungsordner außerhalb verschieben.
4. Den zugehörigen Store-Client und GOG Galaxy starten, das Fehlverhalten reproduzieren und GOG Galaxy anschließend wieder komplett beenden, damit alle Puffer geschrieben werden.
5. Ausschließlich das neu erstellte Log der betroffenen Integration zur Fehleranalyse bereitstellen.

### 🔄 Plugin-Speicher zurücksetzen (Letzter Ausweg)

Falls ein Zurücksetzen unvermeidbar ist, der Dokumentation des betroffenen Plugins folgen und dessen Datenbank zuvor als Sicherung kopieren. Ein Zurücksetzen kann zwischengespeicherte Bibliotheksdaten, lokal erfasste Spielzeiten oder die Anmeldesitzung beeinflussen. Niemals Datenbanken anderer Plugins löschen.

---

## ❤️ Danksagung des Original-Autors (melcom)

> *Ein großes Dankeschön an meinen Freund [Hustlefan](https://www.gog.com/u/Hustlefan) für die moralische Unterstützung, die Geduld bei Discord und das ausgiebige Beta-Testen der Plugins.*
>
> *Ebenso ein herzlicher Dank an meine Freundin [Florence H. (fl0H0815)](https://www.gog.com/u/Florence_Heart) für die Aufmunterungen und die Erinnerung daran, dass es außerhalb des Code-Editors auch noch eine Welt gibt.*

---

## 🤝 Support & Feedback

* **Original-Repository:** [melcom-creations/galaxy-integrations-64bit](https://github.com/melcom-creations/galaxy-integrations-64bit)
* **GOG-Profil des Autors:** [melcom auf GOG.com](https://www.gog.com/u/melcom)
* **Discord des Autors:** `.melcom` (der führende Punkt gehört zum Benutzernamen)
