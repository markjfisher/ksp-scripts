# ksp-scripts

My collection of ksp kos scripts.

Influenced very heavily by [Cheers Kevin](https://www.youtube.com/user/gisikw)

Launch script adapted from [Mike Aben](https://www.youtube.com/c/MikeAben)

## usage in game in case i forget

### copying the scripts

As KSP is pretty much windows based, there's a copy.bat file in the root dir used to
create the compressed ks files and copy them to the ksp install folder.

Due to stuff, I used perl in msys64 to easily run perl in windows, so you have to install
msys64 to c:\msys64 (default dir, don't panic).
Finally, choose an install location for this repo. If it's somewhere other than d:\dev\kos\ksp1
then you'll have to adjust copy.bat. Some time maybe i'll make it a var so you edit that kind
of stuff at the top of the script. however right now it's saturday evening and i want to play
some ksp on my new PC (oscar). Hello future me.

### using the scripts

Open a kos terminal on launchpad

```kos
runpath("0:/boot/your-script-here").
```
