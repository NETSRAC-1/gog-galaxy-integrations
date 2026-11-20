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

  ℹ️ **Hinweis:** Forked from [melcom-creations/galaxy-integrations-64bit](https://github.com/melcom-creations/galaxy-integrations-64bit)

</div>

---

## 🔄 64-Bit GOG Galaxy Client beziehen

Diese Integrationen setzen die native 64-Bit-Version von GOG Galaxy ab Version 2.1 voraus. Wer noch eine ältere 32-Bit-Installation nutzt, kann den aktuellen 64-Bit-Client von der [offiziellen GOG Galaxy Website](https://www.gog.com/galaxy) herunterladen.

---

## 🚀 Status der 64-Bit Community-Integrationen

| Integration         | Betreuer      | Status           | Erfolge (Achievements) | Spielzeit | Download                                                                     |
|:------------------- |:------------- |:----------------:|:----------------------:|:---------:|:---------------------------------------------------------------------------- |
| **Amazon Games**    | **melcom**    | ✅ Veröffentlicht | ❌                      | ✅         | [Download](https://github.com/melcom-creations/galaxy-integration-amazon)    |
| **Battle.net**      | **melcom**    | ✅ Veröffentlicht | ❌                      | ✅         | [Download](https://github.com/melcom-creations/galaxy-integration-battlenet) |
| **Humble Bundle**   | **melcom**    | ✅ Veröffentlicht | ❌                      | ✅         | [Download](https://github.com/melcom-creations/galaxy-integration-humble)    |
| **itch.io**         | **melcom**    | ✅ Veröffentlicht | ❌                      | ✅         | [Download](https://github.com/melcom-creations/galaxy-integration-itch)      |
| **Steam**           | **melcom**    | ✅ Veröffentlicht | ✅                      | ✅         | [Download](https://github.com/melcom-creations/galaxy-integration-steam)     |
| **Ubisoft Connect** | **melcom**    | ✅ Veröffentlicht | ❌                      | ✅         | [Download](https://github.com/melcom-creations/galaxy-integration-uplay)     |
| **EA app**          | **melcom**    | ✅ Veröffentlicht | ✅                      | ✅         | [Download](https://github.com/melcom-creations/galaxy-integration-ea)        |
| **Rockstar Games**  | **melcom**    | ✅ Veröffentlicht | ✅                      | ✅         | [Download](https://github.com/melcom-creations/galaxy-integration-rockstar)  |
| **IndieGala**       | **melcom**    | ✅ Veröffentlicht | ❌                      | ✅         | [Download](https://github.com/melcom-creations/galaxy-integration-indiegala) |
| **Legacy Games**    | **pippo-san** | ✅ Veröffentlicht | ❌                      | ✅         | [Download](https://github.com/pippo-san/galaxy-integration-legacy-games)     |

> 📌 **Wichtig:**
> Bei Fragen oder Problemen zu einzelnen Plugins bitte direkt an den in der Tabelle genannten Betreuer wenden.
>
> Entwickler, die eigene Plugins hier listen möchten, wenden sich an das Original-Repository von melcom. Es werden nur aktiv gepflegte Plugins aufgenommen, deren Autoren auch Anwender-Support bieten.

Legende: ✅ Unterstützt · ❌ Nicht unterstützt · ⏳ Geplant oder in Entwicklung

---

## 📦 Installation

### 🔄 Automatische Installation mit dem Plugin Manager

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

---

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

---

## 🤝 Support & Feedback

* **Original-Repository:** [melcom-creations/galaxy-integrations-64bit](https://github.com/melcom-creations/galaxy-integrations-64bit)
* **GOG-Profil des Autors:** [melcom auf GOG.com](https://www.gog.com/u/melcom)
* **Discord des Autors:** `.melcom` (der führende Punkt gehört zum Benutzernamen)

## **☕ Optional support for [melcom-creations (melcom)](https://github.com/melcom-creations)**

The integrations I maintain are free and will remain free. If you'd like to support my work, you're welcome to [☕ buy me a coffee through PayPal](https://paypal.me/melcom2630). Support is entirely optional and always appreciated.
