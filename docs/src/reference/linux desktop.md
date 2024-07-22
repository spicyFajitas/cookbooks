# Linux Desktop

## Application Shortcuts

Application shortcuts are stored in `/usr/local/share/applications/` or `/usr/share/applications/`. 

You can create a sortcut by creating a file such as `/usr/share/applications/steam.desktop` and ensuring it has the following contents:

```txt
[Desktop Entry]
Type=Application
Terminal=false
Name=unmount-mount
Icon=/home/adam/Pictures/steam.png
Exec=/usr/games/steam/steam.sh
```

## Rotating Desktop Wallpaper (ubuntu)

Shotwell > import photos > select all photos to rotate > File > Set as Desktop Background
