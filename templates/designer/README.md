# webMethods Service Designer Container

This Docker image provides a browser-accessible webMethods Service Designer environment using noVNC for remote desktop access.

## Overview

The container runs webMethods Service Designer in a lightweight desktop environment (LXQt + Openbox) accessible through a web browser via noVNC. This eliminates the need for local installation and provides a consistent development environment.

## Features

- **Browser-based Access**: Access Service Designer through any modern web browser via noVNC
- **Ubuntu 24.04 Base**: Built on the latest Ubuntu LTS release
- **Pre-installed Tools**:
  - Firefox ESR browser
  - kubectl (Kubernetes CLI)
  - Helm (Kubernetes package manager)
  - Git, wget, curl, Python 3
- **Desktop Environment**: LXQt with Openbox window manager
- **VNC Access**: X11VNC server with password protection
- **Non-root User**: Runs as `sagadmin` user (UID 1724) for security

## Prerequisites

- Docker installed on your system
- `wMServiceDesigner.tar.gz` file in the build context. Download from: https://www.ibm.com/resources/mrs/assets/DownloadList?source=WMS_Designers&lang=en_US (wMServiceDesigner-11.1-R03-unix-x64-JDK.tar.gz). You will need a valid IBM id to download the file.

## Building the Image

```bash
podman build -t wm-service-designer:latest .
```

## Running the Container

### Basic Usage

```bash
podman run -d \
  --name service-designer \
  -p 6080:6080 \
  wm-service-designer:latest
```

### With Volume Mounts

```bash
podman run -d \
  --name service-designer \
  -p 6080:6080 \
  -v $(pwd)/workspace:/home/sagadmin/workspace \
  wm-service-designer:latest
```

## Accessing the Environment

1. Open your web browser
2. Navigate to: `http://localhost:6080`
3. Enter VNC password: `1234` (default)
4. Double-click the "Designer" icon on the desktop to launch Service Designer

## Default Credentials

- **User**: `sagadmin`
- **Password**: `sagadmin`
- **VNC Password**: `1234`

> **Security Note**: Change these default passwords in production environments by modifying the Dockerfile.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DISPLAY` | `:1` | X11 display number |
| `USER` | `sagadmin` | Username |
| `HOME` | `/home/sagadmin` | User home directory |
| `SHELL` | `/bin/bash` | Default shell |

## Ports

| Port | Service | Description |
|------|---------|-------------|
| 6080 | noVNC | Web-based VNC client |

## Directory Structure

```
/opt/softwareag/wMServiceDesigner/  # Service Designer installation
/opt/novnc/                         # noVNC web client
/home/sagadmin/                     # User home directory
/home/sagadmin/Desktop/             # Desktop with launcher icons
```

## Customization

### Changing VNC Password

Modify the Dockerfile line:

```dockerfile
RUN x11vnc -storepasswd YOUR_PASSWORD /home/sagadmin/.vnc/passwd
```

### Custom Desktop Configuration

The desktop launcher is defined in `designer.desktop`. Modify this file to customize the Service Designer launch behavior.

### Custom noVNC Styling

The container includes custom CSS (`custom-novnc.css`) and HTML (`webmethods-vnc.html`) for branding the noVNC interface.

## Troubleshooting

### Container won't start

Check logs:
```bash
podman logs service-designer
```

### Can't connect to noVNC

Verify the port mapping:
```bash
podman ps | grep service-designer
```

### Display issues

The container uses Xvfb (X virtual framebuffer). Check the supervisor logs inside the container:
```bash
podman exec service-designer cat /var/log/supervisor/supervisord.log
```

## Architecture

The image uses a multi-stage build:

1. **Stage 1 (SERVICE_DESIGNER)**: Extracts the Service Designer archive
2. **Stage 2 (Final)**: 
   - Installs desktop environment and tools
   - Configures VNC and noVNC
   - Copies Service Designer from stage 1
   - Sets up non-root user and permissions

## Supervisor Services

The container runs multiple services managed by supervisord:

- Xvfb (virtual display)
- x11vnc (VNC server)
- noVNC (web-based VNC client)
- LXQt desktop environment

Configuration: `/etc/supervisor/conf.d/supervisord.conf`

## Security Considerations

- Runs as non-root user (`sagadmin`)
- Change default passwords before production use
- Consider using HTTPS for noVNC in production
- Limit network exposure using Docker networks
- Use secrets management for sensitive credentials