# melcoms Galaxy Plugin Scout

Ein Windows-Werkzeug zur Analyse und Aktualisierung der Python-Bibliotheken im `modules`-Ordner von GOG Galaxy Plugins.

**Geltungsbereich:** Ausschließlich melcoms eigene GOG Galaxy Plugins (Amazon Games, Battle.net, EA app, Rockstar, Steam, Ubisoft Connect, Humble Bundle, itch.io) — [alle in einem Repository](https://github.com/melcom-creations/galaxy-integrations-64bit). Drittanbieter-Plugins im selben Ordner werden erkannt und angezeigt, jedoch von der Bearbeitung ausgeschlossen.

## Systemvoraussetzungen

- Windows 10/11 (64-Bit), PowerShell 5.1+
- GOG Galaxy 2.1+
- [Python 3.13 (64-Bit) mit pip](https://www.python.org/downloads/windows/)

## Start

`GalaxyPluginScout.bat` per Doppelklick starten und den Anweisungen auf dem Bildschirm folgen:

1. Sprache auswählen (Deutsch / Englisch).
2. Modus auswählen (siehe unten).
3. Plugin aus der Liste wählen – oder `[a]` für alle Plugins auf einmal.

Die Plugin-Auswahl bietet mit `[b]` die Möglichkeit, zur Modus-Auswahl zurückzukehren. Nach Abschluss eines Durchlaufs kann direkt die nächste Aktion gestartet werden, ohne das Werkzeug neu aufzurufen.

## Betriebsmodi

| Modus | Funktionsweise |
|---|---|
| **[1] Testlauf (Dry-run)** | Reine Vorschau – Bericht über Abhängigkeiten, es wird nichts verändert oder installiert. |
| **[2] Update** | Vollständige Wartung: Backup erstellen, ungenutzte Module entfernen, Bibliotheken via pip installieren oder aktualisieren. |
| **[3] Bibliotheken-Check** | Gleicht installierte Bibliotheken mit PyPI ab und aktualisiert sie nach Bestätigung via pip (wird pro Bibliothek einzeln abgefragt). Erstellt vor der ersten Änderung ein Backup von `modules`. Überspringt das Bereinigen ungenutzter Module aus Modus 2. |

Modus 2 und Modus 3 verändern Dateien – beide erstellen vorher ein Backup des `modules`-Ordners und fordern vor jeder Installation eine Bestätigung an.

**Welcher Modus wird tatsächlich benötigt?**
Wer ein Plugin frisch von GitHub heruntergeladen hat, benötigt Modus 2 in der Regel nicht – dieser Schritt wurde bereits vor der Veröffentlichung durchgeführt, sodass der Abhängigkeitsbaum bereits aufgelöst ist. Modus 3 reicht aus, um die Bibliotheken aktuell zu halten. Modus 2 ist für den Fall gedacht, dass sich der Abhängigkeitsbaum selbst ändert, beispielsweise bei der Portierung eines Plugins von 32-Bit auf 64-Bit, wenn völlig andere Wheels und Abhängigkeiten geladen werden müssen.

## Ausgaben

- `logs\` – Eine Protokolldatei pro Durchlauf (oder eine kombinierte Datei bei Auswahl von `[a]`)
- `plugin-config.txt` – Generierte Updater-Konfiguration, wird direkt neben dem Skript abgelegt

## Weitere Informationen

- Vollständige Versionshistorie: [CHANGELOG.md](CHANGELOG.md)
- Lizenz: MIT, siehe [LICENSE](LICENSE)
