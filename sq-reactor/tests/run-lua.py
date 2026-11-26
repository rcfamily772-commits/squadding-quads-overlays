"""Run the Lua harness using an installed Lua 5.4 shared library (no pip packages)."""
import ctypes
import ctypes.util
import sys

lib = ctypes.CDLL(ctypes.util.find_library("lua5.4"))
lib.luaL_newstate.restype = ctypes.c_void_p
lib.luaL_openlibs.argtypes = [ctypes.c_void_p]
lib.luaL_loadfilex.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
lib.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
lib.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lib.lua_tolstring.restype = ctypes.c_char_p
lib.lua_close.argtypes = [ctypes.c_void_p]
state = lib.luaL_newstate()
lib.luaL_openlibs(state)
result = lib.luaL_loadfilex(state, (sys.argv[1] if len(sys.argv)>1 else "sq-reactor/tests/apex.lua").encode(), None)
if not result:
    result = lib.lua_pcallk(state, 0, -1, 0, 0, None)
if result:
    print(lib.lua_tolstring(state, -1, None).decode(), file=sys.stderr)
lib.lua_close(state)
sys.exit(bool(result))
