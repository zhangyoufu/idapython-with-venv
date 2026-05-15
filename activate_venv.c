#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

// idasdk diskio.hpp
extern const char * get_user_idadir(void);

__attribute__((constructor))
static void activate_venv(void) {
    char path[PATH_MAX];
    snprintf(path, sizeof path, "%s/venv/bin/python3", get_user_idadir());
    setenv("__PYVENV_LAUNCHER__", path, 1);
}
