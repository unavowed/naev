
--[[
-- music will get called with a string parameter indicating status
-- valid parameters:
--    load - game is loading
--    land - player landed
--    takeoff - player took off
--    combat - player just got a hostile onscreen
--    idle - current playing music ran out
]]--
last = "idle"
function choose( str )
   -- Stores all the available sound types and their functions
   choose_table = {
      ["load"]    = choose_load,
      ["intro"]   = choose_intro,
      ["credits"] = choose_credits,
      ["land"]    = choose_land,
      ["takeoff"] = choose_takeoff,
      ["ambient"] = choose_ambient,
      ["combat"]  = choose_combat
   }

   -- Means to only change song if needed
   if str == nil then
      str = "ambient"
   end

   -- If we are over idling then we do weird stuff
   local changed = false
   if str == "idle" and last ~= "idle" then

      -- We'll play the same as last unless it was takeoff
      if last == "takeoff" then
         changed = choose_ambient()
      else
         changed = choose(last)
      end

   -- Normal case
   else
      changed = choose_table[ str ]()
   end

   if changed and str ~= "idle" then
      last = str -- save the last string so we can use it
   end
end


--[[
-- @brief Checks to see if a song is being played, if it is it stops it.
--
--    @return true if music is playing.
--]]
function checkIfPlayingOrStop( song )
   if music.isPlaying() then
      if music.current() ~= song then
         music.stop()
      end
      return true
   end
   return false
end


--[[
-- @brief Chooses Loading songs.
--]]
function choose_load ()
   load_song = "machina"
   -- Don't play again if needed
   if checkIfPlayingOrStop( load_song ) then
      return true
   end
   music.load( load_song )
   music.play()
   return true
end


--[[
-- @brief Chooses Intro songs.
--]]
function choose_intro ()
   intro_song = "intro"
   -- Don't play again if needed
   if checkIfPlayingOrStop( intro_song ) then
      return true
   end
   music.load( intro_song )
   music.play()
   return true
end


--[[
-- @brief Chooses Credit songs.
--]]
function choose_credits ()
   credits_song = "empire1"
   -- Don't play again if needed
   if checkIfPlayingOrStop( credits_song ) then
      return true
   end
   music.load( credits_song )
   music.play()
   return true
end


--[[
-- @brief Chooses landing songs.
--]]
function choose_land ()
   local pnt   = planet.get()
   local class = pnt:class()

   if class == "M" then
      mus = { "agriculture" }
   elseif class == "O" then
      mus = { "ocean" }
   elseif class == "P" then
      mus = { "snow" }
   else
      if pnt:services()["inhabited"] then
         mus = { "cosmostation", "upbeat" }
      else
         mus = { "agriculture" }
      end
   end

   music.load( mus[ rnd.rnd(1, #mus) ] )
   music.play()
   return true
end


-- Takeoff songs
function choose_takeoff ()
   -- No need to restart
   if last == "takeoff" and music.isPlaying() then
      return true
   end
   takeoff = { "liftoff", "launch2", "launch3chatstart" }
   music.load( takeoff[ rnd.rnd(1,#takeoff) ])
   music.play()
   return true
end


-- Save old data
last_sysFaction  = nil
last_sysNebuDens = nil
last_sysNebuVol  = nil
ambient_neutral  = { "ambient2", "mission",
      "peace1", "peace2", "peace4", "peace6",
      "void_sensor", "ambiphonic" }
--[[
-- @brief Chooses ambient songs.
--]]
function choose_ambient ()
   local force = true

   -- Check to see if we want to update
   if music.isPlaying() then
      if last == "takeoff" then
         return true
      elseif last == "ambient" then
         force = false
      end

      -- Get music information.
      local songname, songpos = music.current()

      -- Do not change songs so soon
      if songpos < 10. then
         music.delay( "ambient", 10. - songpos )
         return false
      end
   end

   -- Get information about the current system
   local sys                  = system.get()
   local factions             = sys:faction()
   local nebu_dens, nebu_vol  = sys:nebula()

   -- Check to see if changing faction zone
   if not factions[last_sysFaction] then

      -- Table must not be empty
      if next(factions) ~= nil then
         force = true
      end

      if force then
         -- Give first value to last faction
         for k,v in pairs(factions) do
            last_sysFaction = k
            break
         end
      end
   end

   -- Check to see if entering nebula
   local nebu = nebu_dens > 0
   if nebu ~= last_sysNebuDens then
      force = true
      last_sysNebuDens = nebu
   end
 
   -- Must be forced
   if force then
      -- Choose the music, bias by faction first
      local add_neutral = false
      if factions["Collective"] then
         ambient = { "collective1", "collective2", "automat" }
      elseif factions["Empire"] then
         ambient = { "empire2", "empire2", "empire2",
               "empire1", "empire1", "empire1" }
         add_neutral = true
      elseif nebu then
         ambient = { "ambient1", "ambient1", "ambient1",
               "ambient3", "ambient3", "ambient3" }
         add_neutral = true
      else
         ambient = ambient_neutral
      end

      -- Check if needs to append neutral ambient songs
      if add_neutral then
         for k,v in pairs(ambient_neutral) do
            table.insert(ambient, v)
         end
      end

      -- Make sure it's not already in the list or that we have to stop the
      -- currently playing song.
      if music.isPlaying() then
         local cur = music.current()
         for k,v in pairs(ambient) do
            if cur == v then
               return false
            end
         end

         music.stop()
         return true
      end

      -- Load music and play
      music.load( ambient[ rnd.rnd(1,#ambient) ] )
      music.play()
      return true
   end

   return false
end


--[[
-- @brief Chooses battle songs.
--]]
function choose_combat ()
   -- Get some data about the system
   local sys                  = system.get()
   local nebu_dens, nebu_vol  = sys:nebula()

   local nebu = nebu_dens > 0
   if nebu then
      combat = { "nebu_battle1", "nebu_battle2", "battlesomething1", "battlesomething2" }
   else
      combat = { "galacticbattle", "flf_battle1", "battlesomething1", "battlesomething2" }
   end

   -- Make sure it's not already in the list or that we have to stop the
   -- currently playing song.
   if music.isPlaying() then
      local cur = music.current()
      for k,v in pairs(combat) do
         if cur == v then
            return false
         end
      end

      music.stop()
      return true
   end

   music.load( combat[ rnd.rnd(1,#combat) ] )
   music.play()
   return true
end

