#ifndef SCOPE_H
#define SCOPE_H

#include <stdio.h>
#include "splash_helper.h"

Scope *scope_create(char *name);
void scope_add_action(Scope *scope, Action *action);
void scope_output(Scope *scope, FILE *output);
void scope_clear_last_uuid(Scope *scope);

#endif  /* SCOPE_H */
