# herbed-tiramisu
tiramisu wrapper(?) for herbe (desktop notification tools)

## for installing
```
make #default install
```

## for uninstallimg
```
make uninstall
```

## make parameters
PREFIX = string : prefix to install (default "/usr/local") <br/>
asroot = string : program that runs as root (default sudo, doas works)

## thanks for
[Sweets](https://github.com/Sweets) for [tiramisu](https://github.com/Sweets/tiramisu) <br/>
[dudik](https://github.com/dudik) for [herbe](https://github.com/dudik/herbe)

## notes
I first tried this in wayland with xwayland, I think It's work well in xwayland.

## Windows

`herbed-tiramisu.ps1` is the port: it needs `tiramisu.exe` (C or Odin port,
branches `port/c-msvc` / `port/odin` of the tiramisu fork) and `herbe.exe`
(`port/windows` of the herbe fork), both on `PATH` or passed explicitly:

```powershell
.\herbed-tiramisu.ps1 -Tiramisu .\tiramisu.exe -Herbe .\herbe.exe -ShowBody
notify-send -t 4000 -a Firefox "Download complete" "photo.png"
```

Fixed on the way (see the comment block in the script): the bash version
executed each tiramisu line as shell code, passed millisecond timeouts to
`timeout` as seconds and failed outright on the default timeout `-1`.
