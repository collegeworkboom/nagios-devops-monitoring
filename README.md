# Nagios Core: Linux, Windows & Kubernetes Monitoring

A DevOps mini-project demonstrating centralized infrastructure monitoring with Nagios Core. The project configuration covers a Linux web server, a Linux database server, a Windows client using NSClient++, and a Kubernetes Nginx deployment health check.

> **Status note:** The configuration examples are based on the project troubleshooting performed during implementation. Validate and adapt host addresses, plugin paths, credentials, and command definitions to your own lab. The Windows Print Spooler and Kubernetes checks require end-to-end verification from the Nagios dashboard before being presented as fully working.

## Project objectives

- Centralize host and service status in Nagios Core.
- Monitor basic Linux host reachability and services.
- Connect a Windows host using NSClient++ / NRPE.
- Check the HTTP endpoint and desired-versus-ready replicas for a Kubernetes deployment.
- Validate Nagios configuration before reload and demonstrate OK/WARNING/CRITICAL/UNKNOWN states.

## Architecture

```text
                   +-----------------------------+
                   | Ubuntu/Linux: Nagios Core   |
                   | Web dashboard + plugins     |
                   +--------------+--------------+
                                  |
                +-----------------+-------------------+
                |                 |                   |
        +-------v------+  +-------v------+    +-------v--------+
        | Linux Web    |  | Linux DB     |    | Windows Client |
        | NRPE/plugins |  | NRPE/plugins |    | NSClient++     |
        +--------------+  +--------------+    +----------------+
                                  |
                          +-------v----------------+
                          | Kubernetes / Nginx     |
                          | HTTP + replica health  |
                          +------------------------+
```

## Repository layout

```text
nagios-devops-monitoring/
├── README.md
├── .gitignore
├── LICENSE
├── nagios/
│   ├── nagios.cfg.example
│   └── objects/
│       ├── commands.cfg
│       ├── contacts.cfg.example
│       ├── linux-web-server.cfg
│       ├── linux-db-server.cfg
│       ├── windows-client-1.cfg
│       └── kubernetes.cfg
├── scripts/
│   └── windows/
│       └── k8s-health.ps1
└── docs/
    └── screenshots/
        └── README.md
```

## Prerequisites

- Ubuntu/Linux VM for Nagios Core and Nagios Plugins.
- NRPE configured on Linux monitored hosts if you want remote Linux checks.
- Windows machine with NSClient++ configured to allow only the required NRPE commands from the Nagios server.
- Kubernetes cluster with `kubectl` available on the machine running the health script.
- Network routes/firewall rules that permit the selected monitoring ports.
- Nagios Core installed according to the official installation guide.

## Setup

1. Install Nagios Core and Nagios Plugins on the monitoring server.
2. Copy/adapt the example object files into your Nagios object configuration directory, commonly `/usr/local/nagios/etc/objects/`.
3. Edit `nagios.cfg` and include each object file with `cfg_file=...` entries. Do not replace your working configuration blindly.
4. Update IP addresses, host names, command paths and contacts for your environment.
5. Configure Linux NRPE and Windows NSClient++ separately. Ensure remote commands are explicitly allow-listed.
6. For the Kubernetes check, install the PowerShell script on the Windows host that has access to the target cluster, configure NSClient++ to run it, and test the exact command through NRPE.
7. Validate configuration, then reload/restart Nagios only if validation succeeds.

Example validation:

```bash
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```

If the configuration reports warnings, review them; if it reports errors, do not reload until fixed. The project lab previously reported **0 errors and 2 warnings** relating to default contacts/contact groups for `kubernetes-nginx` and `windows-client-1`. Add suitable contacts to remove these warnings.

## Checks represented

| Target | Example checks | Notes |
|---|---|---|
| Linux web server | Host reachability; HTTP/service checks | Add NRPE checks appropriate to installed services |
| Linux database server | Host reachability; database/service checks | Do not expose database ports publicly |
| Windows client | Ping, CPU, memory, disk, Print Spooler | NSClient++ command aliases must match Nagios command definitions |
| Kubernetes Nginx | HTTP endpoint and deployment replica readiness | Validate network path and NRPE execution from Nagios |

## Kubernetes health script

`scripts/windows/k8s-health.ps1` checks whether the `nginx-demo` deployment's ready replica count meets its desired replica count. Edit the `kubectl` executable path and deployment name for your environment. Run locally first:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\windows\k8s-health.ps1
```

Expected healthy output is similar to `OK - Kubernetes replicas ready: 3/3`. A successful local run does **not** prove that Nagios can execute it remotely. Test through NSClient++/NRPE and confirm the service status in the Nagios dashboard.

## Evidence / screenshots

Place screenshots in `docs/screenshots/` and update this README with Markdown image links. Recommended evidence:
1. Nagios dashboard showing configured hosts and services.
2. `nagios -v` output with zero errors.
3. Windows NSClient++/NRPE test for the Print Spooler.
4. Kubernetes deployment and pods (`kubectl get deployment,pods`).
5. Nagios dashboard showing the Kubernetes check result.

Do not commit passwords, API tokens, private keys, personal information, or unredacted configuration files.

## Known limitations / next steps

- Replace all example IP addresses and host names with your own lab values.
- Confirm the `check_nrpe`, `check_http`, `check_ping`, and other plugin command paths on your installation.
- Add a valid contact and contact group for each host/service.
- Confirm Windows Print Spooler checks work via the actual NRPE command.
- Fix and verify the Kubernetes remote execution path before claiming the check is fully integrated.
- Add alert delivery (email or another approved channel), thresholds, and a documented failure/recovery test.

## Report link

After creating the GitHub repository, replace the `Deployed link` field in the project report with the repository URL, for example `https://github.com/<your-username>/nagios-devops-monitoring`. A GitHub repository is source-code hosting, **not** a live deployment of the Nagios dashboard. Do not publish a private monitoring dashboard or expose monitoring ports to the public internet.

## References

- Nagios Core documentation: https://www.nagios.org/documentation/
- Nagios Exchange plugins: https://exchange.nagios.org/
- NSClient++ documentation: https://docs.nsclient.org/
- Kubernetes documentation: https://kubernetes.io/docs/
