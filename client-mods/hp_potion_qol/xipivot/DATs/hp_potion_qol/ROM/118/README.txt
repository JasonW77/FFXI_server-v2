Place the patched usable-items DAT here after running:

```powershell
python build/patch_usable_dat.py
```

Expected path (retail English client on this machine):

`ROM/118/107.DAT`

Your client may resolve logical file `0x004A` to a different `ROM/<folder>/<file>.DAT`. The build script copies from your install and writes the overlay using the same relative path XIPivot expects.

Do not edit retail `FINAL FANTASY XI\ROM\` files directly.
