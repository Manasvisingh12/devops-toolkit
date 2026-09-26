# DevOps Toolkit

### Bash automation for backups, cleanup, log rotation, signal handling, cron scheduling, and error alerting

A Bash script built to practice core operational DevOps patterns — safe backups, log/backup cleanup, graceful shutdown handling, and cron-based scheduling with error alerting. It's a single-host toolkit run from one script (`main.sh`), not a distributed monitoring system — see [Limitations](#limitations) for what that means in practice.

---

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Project Structure](#project-structure)
- [Features](#features)
- [Installation](#installation)
- [Example Output](#example-output)
- [Screenshots](#screenshots)
- [What This Project Demonstrates](#what-this-project-demonstrates)
- [Limitations](#limitations)
- [Roadmap](#roadmap)
- [License](#license)

---

## Overview

- Security-conscious script execution — root enforcement, strict Bash mode, absolute command paths, restricted file permissions
- Automated, timestamped, compressed backups
- Log rotation and cleanup of old backups
- Signal handling for a graceful shutdown on `Ctrl+C` or `SIGTERM`
- Cron-ready scheduling
- Optional alerting via Slack webhook, email, or curl-based integrations, triggered on error log entries

---

## How It Works

```text
+--------------------------------------------------------+
|                         TRIGGER                        |
|              Cron schedule  |  Manual run               |
+--------------------------------------------------------+
                              |
                              v
+--------------------------------------------------------+
|                    PRE-FLIGHT CHECKS                    |
|        Root check -> Strict mode -> Signal traps        |
+--------------------------------------------------------+
                              |
                              v
+--------------------------------------------------------+
|                          BACKUP                          |
|          Create timestamped, compressed backup           |
+--------------------------------------------------------+
                              |
                              v
+--------------------------------------------------------+
|                         CLEANUP                          |
|            Delete backups older than 30 days             |
+--------------------------------------------------------+
                              |
                              v
+--------------------------------------------------------+
|                         LOGGING                          |
|               Write result to toolkit.log                |
+--------------------------------------------------------+
                              |
                              v
              Error logged during the run?
             Yes                            No
              |                             |
              v                             v
+-------------------------+    +------------------------+
|   ALERTING (optional)   |    |       COMPLETED        |
| Slack / Email / webhook |    |   Logged as success    |
+-------------------------+    +------------------------+
```

Every run goes through pre-flight checks, then backup, then cleanup, with each step logged. If an error was logged anywhere along the way, the optional alert integration fires; otherwise the run just logs as completed.

---

## Project Structure

```text
devops-toolkit/
├── main.sh
├── README.md
├── .gitignore
├── backups/
├── important_data/
└── toolkit.log
```

---

## Features

### Security Hardening

- Enforces that the script runs as root (so it has the permissions its operations need, and so that's an explicit, visible requirement rather than a silent assumption)
- Strict Bash mode to fail fast instead of continuing on an error
- Absolute paths for the commands it calls, rather than relying on `$PATH`
- Locks down file permissions with `chmod 700`

The strict-mode and absolute-path pattern looks like this (illustrative, not a literal dump of the script):

```bash
#!/usr/bin/env bash
set -euo pipefail   # exit on error, unset variable, or failed pipe

TAR_BIN="/usr/bin/tar"
DATE_BIN="/usr/bin/date"
```

### Backup Automation

- Timestamped, compressed backups
- Automatic creation of the backup directory if it doesn't exist
- Errors during backup are logged rather than failing silently
- Basic file lifecycle management (create, retain, expire)

### Cleanup & Log Rotation

- Deletes backups older than 30 days
- Validates paths before deleting anything
- Can optionally list files before deletion, as a safety check

### Signal Handling

Traps `SIGINT` (Ctrl+C) and `SIGTERM` so an interrupted run shuts down cleanly and logs what happened, instead of leaving a backup half-written. The general pattern:

```bash
graceful_shutdown() {
    log "WARN" "Received shutdown signal - cleaning up before exit"
    exit 1
}
trap graceful_shutdown SIGINT SIGTERM
```

### Cron Automation

```
0 2 * * * /absolute/path/main.sh >> cron.log 2>&1
```

Runs the toolkit on a schedule and appends output to a log file for later review.

### Alerting (Optional)

Supports Slack webhooks, email via the `mail` command, and curl-based integrations, triggered when an `ERROR` line is logged. Treat this as a feature you wire up and verify yourself — see [Limitations](#limitations).

---

## Installation

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/devops-toolkit.git
cd devops-toolkit
```

Make it executable:

```bash
chmod 700 main.sh
```

Run it:

```bash
sudo ./main.sh
```

---

## Example Output

```
2026-03-02 12:30:01 [INFO] ===== DevOps Toolkit Started =====
2026-03-02 12:30:01 [INFO] Starting backup process
2026-03-02 12:30:02 [INFO] Backup created successfully
2026-03-02 12:30:02 [INFO] Old backup files deleted
2026-03-02 12:30:02 [INFO] ===== Completed Successfully =====
```

---

## Screenshots

Not included yet — a terminal recording or a screenshot of a real cron run (including a triggered alert) would make this section much more convincing than log text alone. Suggested captures:

- A full `sudo ./main.sh` run in a terminal
- A `toolkit.log` excerpt showing an error and the resulting alert
- The Slack/email alert itself, if you have the integration wired up

```markdown
![Terminal run](docs/screenshots/terminal-run.png)
![Alert notification](docs/screenshots/alert-example.png)
```

---

## What This Project Demonstrates

- Defensive Bash scripting (`set -euo pipefail`, absolute paths, path validation before destructive operations)
- Structured error handling and logging
- Signal handling for graceful shutdown
- Basic log/file lifecycle management
- Cron-based scheduling
- The operational habits (not the scale) of real DevOps automation work

---

## Limitations

This is a single Bash script run on one host — worth being explicit about the current scope before treating it as more than that:

- "Monitoring" in the framing refers to error-triggered alerting, not live system monitoring — disk usage checks and service health checks are still on the [Roadmap](#roadmap), not implemented yet.
- No automated tests (unit or integration) currently cover the script.
- No CLI argument parsing or config file support yet — behavior is controlled by editing the script directly (both are roadmap items).
- No CI/CD pipeline validates changes before they land (also on the roadmap).
- Requires running as root (`sudo ./main.sh`) — a real operational trade-off, not just a hardening checkbox.
- The alert integrations (Slack/email/webhook) are described as ready to use — confirm end-to-end that a real webhook or mail setup actually fires before relying on it instead of manual checks.
- Backup and cleanup logic target a fixed, hardcoded scope rather than being configurable per environment.

*(Update this list as these gaps close — it reflects the project as described here, not a live audit of the current script.)*

---

## Roadmap

- [ ] Disk usage monitoring
- [ ] Service health checks
- [ ] Config file support
- [ ] CLI argument parsing
- [ ] Docker container version
- [ ] CI/CD pipeline integration

---

## License

MIT License

---

## Author

**[@Manasvisingh12](https://github.com/Manasvisingh12)**

Built as a hands-on exercise in writing safer, more disciplined Bash.
