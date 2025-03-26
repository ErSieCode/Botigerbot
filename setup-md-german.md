# Kryptowährungs-Trading-Bot: Installations- und Betriebsanleitung

## Inhaltsverzeichnis
1. [Einführung](#einführung)
2. [Systemvoraussetzungen](#systemvoraussetzungen)
3. [Installation auf Windows](#installation-auf-windows)
4. [Installation auf macOS](#installation-auf-macos)
5. [Konfiguration](#konfiguration)
6. [Starten der Anwendung](#starten-der-anwendung)
7. [Nutzung der Anwendung](#nutzung-der-anwendung)
8. [Fehlerbehebung](#fehlerbehebung)
9. [Sicherheitshinweise](#sicherheitshinweise)

## Einführung

Diese Anleitung führt Sie durch die Installation und Konfiguration des Kryptowährungs-Trading-Bots, einer automatisierten Handelsplattform bestehend aus einem Elixir-Backend und einer Svelte-Frontend-Anwendung. Das System ermöglicht die automatisierte Ausführung von Handelsstrategien auf verschiedenen Kryptowährungsbörsen.

## Systemvoraussetzungen

### Für beide Betriebssysteme
- Docker Desktop
- Mindestens 4 GB RAM
- Mindestens 10 GB freier Festplattenspeicher
- Internetverbindung
- API-Schlüssel für die gewünschte Kryptowährungsbörse (Bitget, Binance, etc.)

### Für Windows
- Windows 10/11 (64-bit)
- WSL 2 (Windows Subsystem für Linux)

### Für macOS
- macOS Catalina (10.15) oder neuer
- Intel oder Apple Silicon Prozessor

## Installation auf Windows

### 1. Docker Desktop installieren
1. Besuchen Sie die [Docker Desktop-Website](https://www.docker.com/products/docker-desktop) und laden Sie den Installer für Windows herunter.
2. Führen Sie den Installer aus und folgen Sie den Anweisungen auf dem Bildschirm.
3. Starten Sie Ihren Computer neu, wenn Sie dazu aufgefordert werden.
4. Stellen Sie sicher, dass Docker Desktop erfolgreich läuft, indem Sie das Programm starten und warten, bis der Status "Docker Desktop läuft" angezeigt wird.

### 2. WSL 2 aktivieren (falls noch nicht geschehen)
1. Öffnen Sie PowerShell als Administrator.
2. Führen Sie den folgenden Befehl aus:
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   ```
3. Aktivieren Sie die Virtual Machine Platform:
   ```powershell
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```
4. Starten Sie Ihren Computer neu.
5. Laden Sie das [WSL 2 Linux-Kernel-Update](https://aka.ms/wsl2kernel) herunter und installieren Sie es.
6. Legen Sie WSL 2 als Standardversion fest:
   ```powershell
   wsl --set-default-version 2
   ```

### 3. Projekt-Repository klonen
1. Installieren Sie Git für Windows von [git-scm.com](https://git-scm.com/download/win).
2. Öffnen Sie die Eingabeaufforderung oder PowerShell.
3. Wechseln Sie zu dem Verzeichnis, in dem Sie das Projekt speichern möchten.
4. Klonen Sie das Repository (oder laden Sie es als ZIP-Datei herunter und extrahieren Sie es):
   ```bash
   git clone https://github.com/ihr-benutzername/cryptotrading-bot.git
   cd cryptotrading-bot
   ```

### 4. Setup-Skript ausführen
1. Öffnen Sie PowerShell im Projektverzeichnis.
2. Führen Sie das Setup-Skript aus:
   ```powershell
   ./setup.sh
   ```
   Falls die Ausführung des Skripts nicht möglich ist, können Sie die Docker-Compose-Datei direkt verwenden:
   ```powershell
   docker-compose up -d
   ```

## Installation auf macOS

### 1. Docker Desktop installieren
1. Besuchen Sie die [Docker Desktop-Website](https://www.docker.com/products/docker-desktop) und laden Sie den Installer für macOS herunter.
2. Folgen Sie den Installationsanweisungen für Intel-Chip oder Apple Silicon, je nach Ihrem Mac-Modell.
3. Starten Sie Docker Desktop nach der Installation.
4. Warten Sie, bis der Status "Docker Desktop ist einsatzbereit" angezeigt wird.

### 2. Homebrew installieren (optional, aber empfohlen)
1. Öffnen Sie das Terminal.
2. Führen Sie den folgenden Befehl aus:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Folgen Sie den Anweisungen auf dem Bildschirm.

### 3. Git installieren (falls noch nicht vorhanden)
1. Öffnen Sie das Terminal.
2. Wenn Sie Homebrew installiert haben, führen Sie aus:
   ```bash
   brew install git
   ```
   Alternativ wird Git möglicherweise mit den Command Line Tools installiert:
   ```bash
   xcode-select --install
   ```

### 4. Projekt-Repository klonen
1. Öffnen Sie das Terminal.
2. Wechseln Sie zu dem Verzeichnis, in dem Sie das Projekt speichern möchten.
3. Klonen Sie das Repository:
   ```bash
   git clone https://github.com/ihr-benutzername/cryptotrading-bot.git
   cd cryptotrading-bot
   ```

### 5. Setup-Skript ausführen
1. Öffnen Sie das Terminal im Projektverzeichnis.
2. Machen Sie das Skript ausführbar und führen Sie es aus:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```
   Falls die Ausführung des Skripts nicht möglich ist, können Sie die Docker-Compose-Datei direkt verwenden:
   ```bash
   docker-compose up -d
   ```

## Konfiguration

### Umgebungsvariablen einrichten
1. Im Projektverzeichnis finden Sie eine Datei namens `.env.example`. Kopieren Sie diese und benennen Sie die Kopie in `.env` um:
   - Unter Windows (PowerShell):
     ```powershell
     Copy-Item .env.example .env
     ```
   - Unter macOS (Terminal):
     ```bash
     cp .env.example .env
     ```

2. Öffnen Sie die `.env`-Datei mit einem Texteditor Ihrer Wahl und passen Sie die folgenden Einstellungen an:
   - Datenbankeinstellungen (falls notwendig)
   - API-Schlüssel für Ihre Kryptowährungsbörse
   - Sicherheitsschlüssel (es wird empfohlen, die Standard-Schlüssel zu ändern)

### Börsen-API-Schlüssel generieren
1. Melden Sie sich bei Ihrer gewählten Kryptowährungsbörse an (z.B. Bitget, Binance).
2. Navigieren Sie zum Bereich für API-Schlüssel (meist unter Sicherheitseinstellungen oder Entwickleroptionen).
3. Erstellen Sie einen neuen API-Schlüssel mit Handelsberechtigungen.
4. Notieren Sie sich den API-Schlüssel, das Secret und das Passwort (falls erforderlich).
5. Fügen Sie diese Daten in das Anwendungsformular ein (nicht in die .env-Datei für erhöhte Sicherheit).

## Starten der Anwendung

### Mit Docker Compose
1. Öffnen Sie ein Terminal/PowerShell-Fenster im Projektverzeichnis.
2. Führen Sie den folgenden Befehl aus:
   ```bash
   docker-compose up -d
   ```
   Der Parameter `-d` startet die Dienste im Hintergrund.

3. Um zu überprüfen, ob alle Dienste laufen, führen Sie aus:
   ```bash
   docker-compose ps
   ```

### Auf die Anwendung zugreifen
1. Öffnen Sie einen Webbrowser Ihrer Wahl.
2. Navigieren Sie zu `http://localhost:3000`.
3. Melden Sie sich mit den Standardanmeldedaten an:
   - Benutzername: `admin`
   - Passwort: `admin123`
   
   **Wichtig**: Ändern Sie das Passwort nach der ersten Anmeldung über den Einstellungsbereich.

## Nutzung der Anwendung

### Dashboard
Das Dashboard bietet einen Überblick über:
- Aktuelle Handelsaktivitäten
- Offene Positionen
- Gewinn-/Verluststatistiken
- Markttrends

### Handelseinstellungen konfigurieren
1. Navigieren Sie zum Bereich "Trading".
2. Geben Sie Ihre API-Schlüssel für die Börse ein.
3. Wählen Sie die Kryptowährungen aus, die Sie handeln möchten.
4. Konfigurieren Sie die Handelsstrategie-Parameter:
   - RSI-Periode und Schwellenwerte
   - SMA-Perioden (kurz und lang)
   - Stop-Loss- und Take-Profit-Prozentsätze
   - Hebelwirkung (falls verwendet)

### Handel starten
1. Überprüfen Sie Ihre Konfiguration.
2. Klicken Sie auf "Trading starten".
3. Überwachen Sie die Aktivitäten auf dem Dashboard.
4. Der Bot wird nun basierend auf den konfigurierten Parametern automatisch handeln.

### Handel stoppen
1. Navigieren Sie zum Dashboard oder Trading-Bereich.
2. Klicken Sie auf "Trading stoppen".
3. Der Bot beendet alle laufenden Handelsprozesse, behält aber offene Positionen bei.

## Fehlerbehebung

### Docker-bezogene Probleme

#### Docker-Dienste starten nicht
1. Überprüfen Sie, ob Docker läuft:
   ```bash
   docker info
   ```
2. Stoppen Sie alle Container und starten Sie neu:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

#### Zugriff auf das Frontend nicht möglich
1. Überprüfen Sie, ob die Container laufen:
   ```bash
   docker-compose ps
   ```
2. Überprüfen Sie die Logs:
   ```bash
   docker-compose logs frontend
   ```
3. Stellen Sie sicher, dass Port 3000 nicht von einem anderen Prozess verwendet wird.

#### Zugriff auf das Backend nicht möglich
1. Überprüfen Sie die Backend-Logs:
   ```bash
   docker-compose logs backend
   ```
2. Stellen Sie sicher, dass die Datenbank korrekt eingerichtet ist:
   ```bash
   docker-compose logs db
   ```

### Anwendungsbezogene Probleme

#### Anmeldung nicht möglich
1. Überprüfen Sie, ob Sie die korrekten Anmeldedaten verwenden.
2. Setzen Sie das Passwort zurück, indem Sie die Datenbank zurücksetzen:
   ```bash
   docker-compose down
   docker volume rm cryptotrading-bot_postgres_data
   docker-compose up -d
   ```
   **Hinweis**: Dies löscht alle gespeicherten Daten.

#### Börsenfehler
1. Überprüfen Sie, ob Ihre API-Schlüssel korrekt sind.
2. Stellen Sie sicher, dass die API-Schlüssel Handelsberechtigungen haben.
3. Überprüfen Sie die Backend-Logs auf spezifische Fehlermeldungen.

## Sicherheitshinweise

### Wichtige Vorsichtsmaßnahmen
1. Verwenden Sie niemals Ihre Haupt-Börsenkonto-API-Schlüssel. Erstellen Sie separate Schlüssel mit begrenzten Berechtigungen.
2. Beschränken Sie die Handelsberechtigungen auf bestimmte Kryptowährungen und Limits.
3. Aktivieren Sie IP-Beschränkungen für Ihre API-Schlüssel, wenn möglich.
4. Verwenden Sie eine starke Authentifizierung für den Zugriff auf den Bot.
5. Betreiben Sie den Bot in einer sicheren Netzwerkumgebung.
6. Ändern Sie die Standard-Anmeldedaten sofort nach der ersten Installation.

### Backup-Vorgehensweise
1. Sichern Sie Ihre Konfiguration regelmäßig:
   ```bash
   docker-compose exec db pg_dump -U crypto_user crypto_bot > backup.sql
   ```
2. Speichern Sie Ihre API-Schlüssel und andere wichtige Informationen an einem sicheren Ort.
3. Dokumentieren Sie Ihre individuellen Strategie-Einstellungen.

### Risikohinweis
Der Handel mit Kryptowährungen birgt erhebliche Risiken, auch bei Verwendung automatisierter Systeme. Beginnen Sie mit kleinen Beträgen und verstehen Sie die Funktionsweise des Systems vollständig, bevor Sie signifikante Summen investieren. Dieser Bot ist ein Werkzeug und keine Garantie für Gewinne.

---

Bei weiteren Fragen wenden Sie sich bitte an den Support oder konsultieren Sie die ausführliche Dokumentation im Verzeichnis `docs/`.
