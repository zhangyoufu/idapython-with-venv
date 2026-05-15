# IDAPython with venv

- IDAPython `idapython_plugin_t::init()`
  - IDAPython `ext_api_t::load(...)`
    - IDAPython `ext_api_t::locate_libpython(...)`
      - IDAPython `ext_api_t::find_libpython_registry()`
        - IDAPython `ext_api_t::load_libpython()`
          - `dlopen(lib_path.c_str(), RTLD_NOW | RTLD_GLOBAL)`
            - `libpython_with_venv.dylib` `activate_venv()` *(we are here)*
              - `get_user_idadir()`
              - `setenv("__PYVENV_LAUNCHER__", "${IDAUSR}/venv", 1)`
          - `dlsym(...)`
  - `libpython3.dylib` `Py_InitializeEx(0)`

`libpython_with_venv.dylib` is a shim between IDAPython and real `libpython3.dylib`. It set `__PYVENV_LAUNCHER__` environment variable before Python interpreter was initialized. That's all.

I don't want to name every Python symbols used by IDAPython, so I make use of `LC_REEXPORT_DYLIB` to re-export all symbols from real `libpython3.dylib`. This project is **macOS only** at its current form.

## usage

- run `install.sh` from terminal, the script does the following things:
   - ask you to choose IDA
   - ask you to choose libpython dylib
   - build `libpython_with_venv.dylib`
   - run `idapyswitch` to do the switch
- prepare a venv at `${IDAUSR}/venv` (usually defaults to `~/.idapro/venv`)
   - `python3 -m venv ~/.idapro/venv` or
   - `uv venv ~/.idapro/venv`
- kickstart IDA, check whether IDAPython loads properly
- install your favorite packages in the venv and have fun

## result

```
Python> sys._base_executable
'/Applications/IDA Professional 9.3.app/Contents/MacOS/ida'

Python> sys.base_prefix
'/Users/xxx/.local/share/uv/python/cpython-3.13.13-macos-aarch64-none'

Python> sys.base_exec_prefix
'/Users/xxx/.local/share/uv/python/cpython-3.13-macos-aarch64-none'

Python> sys.executable
'/Users/xxx/.idapro/venv/bin/python3'

Python> sys.prefix
'/Users/xxx/.idapro/venv'

Python> sys.exec_prefix
'/Users/xxx/.idapro/venv'

Python> print(json.dumps(sys.path, indent=2))
[
  "/Applications/IDA Professional 9.3.app/Contents/MacOS/python",
  "/Applications/IDA Professional 9.3.app/Contents/MacOS/python/lib-dynload",
  "/Users/xxx/.local/share/uv/python/cpython-3.13.13-macos-aarch64-none/lib/python313.zip",
  "/Users/xxx/.local/share/uv/python/cpython-3.13.13-macos-aarch64-none/lib/python3.13",
  "/Users/xxx/.local/share/uv/python/cpython-3.13-macos-aarch64-none/lib/python3.13/lib-dynload",
  "/Users/xxx/.idapro/venv/lib/python3.13/site-packages",
  "/Applications/IDA Professional 9.3.app/Contents/MacOS/python",
  "/Applications/IDA Professional 9.3.app/Contents/MacOS/python",
  "/Users/xxx/.idapro/plugins",
]

Python> print(json.dumps(sysconfig.get_paths(), indent=2))
{
  "include": "/Users/xxx/.local/share/uv/python/cpython-3.13.13-macos-aarch64-none/include/python3.13",
  "stdlib": "/Users/xxx/.local/share/uv/python/cpython-3.13.13-macos-aarch64-none/lib/python3.13",
  "platinclude": "/Users/xxx/.local/share/uv/python/cpython-3.13-macos-aarch64-none/include/python3.13",
  "platstdlib": "/Users/xxx/.idapro/venv/lib/python3.13",
  "platlib": "/Users/xxx/.idapro/venv/lib/python3.13/site-packages",
  "purelib": "/Users/xxx/.idapro/venv/lib/python3.13/site-packages",
  "scripts": "/Users/xxx/.idapro/venv/bin",
  "data": "/Users/xxx/.idapro/venv"
}
```

## note

- Due to compatibility issue, Python 3.13 is recommended, until Hex-Rays catch up.
- You really should use `uv`/`pyenv` managed python, so that `brew upgrade` won't break your IDAPython again.
- Besides `__PYVENV_LAUNCHER__`, there is `IDAPYTHON_VENV_EXECUTABLE` [here](https://github.com/HexRaysSA/ida-sdk/blob/a3a4198cda429119972d677ad0874d6699ee89db/src/plugins/idapython/idapython.cpp#L920-L944) and [there](https://github.com/HexRaysSA/ida-sdk/blob/a3a4198cda429119972d677ad0874d6699ee89db/src/plugins/idapython/idapython.cpp#L1173-L1183). I'm good without this hack.
- There are many other solutions on the Internet:
  - https://www.williballenthin.com/post/using-a-virtualenv-for-idapython/
  - https://github.com/eset/ipyida/blob/master/README.virtualenv.adoc
  - https://ret0.dev/posts/using-venv-with-ida/
  - https://github.com/kerrigan29a/idapython_virtualenv
  - https://github.com/Skwteinopteros/ida-venv
