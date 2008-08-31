/*
 * See Licensing and Copyright notice in naev.h
 */


#ifndef NLUA_PILOT_H
#  define NLUA_PILOT_H


#include "lua.h"

#include "pilot.h"


#define PILOT_METATABLE   "Pilot"


/*
 * Lua wrappers.
 */
typedef struct LuaPilot_s {
   unsigned int pilot;
} LuaPilot;


/* 
 * Library loading
 */
int lua_loadPilot( lua_State *L, int readonly );

/*
 * Pilot operations
 */
LuaPilot* lua_topilot( lua_State *L, int ind );
LuaPilot* lua_pushpilot( lua_State *L, LuaPilot pilot );
int lua_ispilot( lua_State *L, int ind );


#endif /* NLUA_PILOT_H */

