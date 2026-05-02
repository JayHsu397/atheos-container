# Atheos Container Image

Unofficial container image of [Atheos](https://github.com/Atheos/Atheos).

Powered by [Atheos IDE](https://github.com/Atheos)

## 1. Features

This container image packages Atheos on top of `docker.io/php:7.4-apache`.

What it does:

- Builds an Apache and PHP environment required by Atheos.
- Provides an optional permission adjustment by setting `LAZY_PERMISSION` to `true`.
- Provides guidance for configuration file persistence.

## 2. Startup

Pull the container image:

```bash
podman pull ghcr.io/jayhsu397/atheos:latest
```

### 2-1. Command Line

Minimal startup command  
Visit the Web IDE at `http://127.0.0.1:8000`

```bash
podman run -p 8000:80 \
  -v /path/to/your-project:/var/www/html/workspace:z \
  ghcr.io/jayhsu397/atheos:latest
```

This is the simplest way to start the container.

Notes:

- If you didn't set `LAZY_PERMISSION` as true, you need to manage the permission your self, or the IDE won't fuction properly.
- Your code directory should be mounted into `/var/www/html/workspace` for persistence.
- Without an additional mount for the configuration directory, user initialization will be required every time you restart the container.

Recommended startup command with persistent configurations, and permission adjustment in case the Web IDE does not have permission to write to your directory:

```bash
podman run -p your-port:80 \
  -v PATH/TO/YOUR/PROJECT:/var/www/html/workspace:z \
  -v VOLUME_NAME_FOR_DATA:/var/www/html/data:Z \
  -v VOLUME_NAME_FOR_PLUGINS:/var/www/html/plugins:Z \
  -v VOLUME_NAME_FOR_THEME:/var/www/html/theme:Z \
  -e LAZY_PERMISSION=true \
  ghcr.io/jayhsu397/atheos:latest
```

This is a more practical setup for normal self-hosting use.

Notes:

- In the command above, `workspace` uses a `bind mount`, which means mounting a directory from the host filesystem into the container.

- On the other hand, `data`, `plugins`, and `theme` use `named volumes`, which means mounting named volumes into the container.

- Simply mounting a host directory over these paths hides the existing files in the image, while mounting a `named volume` copies the existing files into the volume automatically, which helps ensure the container functions properly.
  - Remember to create the volumes you need before starting the container.

  ```bash
  podman volume create VOLUME_NAME
  ```

- `LAZY_PERMISSION` is used to adjust the permission and owner of `/var/www/html` and its contents, and should be set to `true` or `false` (`false` by default).

### 2-2. Quadlet

If you use systemd as your init system and want the container to start on boot, `Quadlet` may satisfy your needs.

Example placed in `$HOME/.config/containers/systemd/atheos.container`

```ini
[Unit]
Description=Atheos Web IDE
Wants=network.target
After=network.target

[Container]
Image=ghcr.io/jayhsu397/atheos:latest
PublishPort=YOUR_PORT:80
Volume=PATH/TO/YOUR/PROJECT:/var/www/html/workspace:z
Volume=VOLUME_NAME_FOR_DATA:/var/www/html/data:Z
Volume=VOLUME_NAME_FOR_PLUGINS:/var/www/html/plugins:Z
Volume=VOLUME_NAME_FOR_THEME:/var/www/html/theme:Z
Environment=LAZY_PERMISSION=true
AutoUpdate=registry
LogDriver=journald

[Service]
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

Remember to run the commands below after configuring your Quadlet file:

```bash
loginctl enable-linger $USER
systemctl --user daemon-reload
systemctl --user start atheos
```

## 3. Environment Variables

| Name | Description |
| - | - |
| `LAZY_PERMISSION` | Adjust permissions at runtime, visit [`start.sh`](https://github.com/JayHsu397/atheos-container/blob/main/start.sh) to know how it works|

Additional notes:

- Boolean variables must use `true` or `false`.

## 4. Volumes

| Path inside container | Purpose |
| - | - |
| `/var/www/html/workspace` | Stores your coding project |
| `/var/www/html/data` | Stores preference settings and user info |
| `/var/www/html/plugins` | Stores installed plugins |
| `/var/www/html/theme` | Stores IDE themes |

Notes:

- Mounting `workspace` is normally required if you want the code you edit to live outside the container.
- Mounting `data` is strongly recommended if you want your user and preference data to persist across container recreation or restart.
- Mounting `plugins` is required if you want to keep installed plugins.
- On SELinux-enabled systems, keep the `:z` or `:Z` suffix on bind mounts.

## 5. Extended Features and Configurations

This image provides a basic environment based on the official project, and does not provide any IDE customization.

If you need more customized features, please visit [the source repo of Atheos](https://github.com/Atheos/Atheos).

## 6. License

This repository is a packaging project.

- My original packaging files, including `Containerfile` and `start.sh`, are licensed under MIT.
