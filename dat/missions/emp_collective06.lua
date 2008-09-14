--[[

   Operation Cold Metal

   Seventh and final mission in the Collective Campaign

   Mission Objectives:
      * Assault C-43
      * Final Assault on C-28
         * Kill the Starfire
         * Kill the Trinity (if it got away in Operation Black Metal)

   Stages:
      0) Just started..
      1) Entered C-43.
      2) Cleared C-43.
      3) Entered C-28.
      4) Cleared C-28.
      5) Ran away.

]]--

lang = naev.lang()
if lang == "es" then
   -- not translated atm
else -- default english
   misn_title = "Operation Cold Metal"
   misn_reward = "Fame and Glory"
   misn_desc = {}
   misn_desc[1] = "Neutralize enemy forces in %s."
   misn_desc[2] = "Destroy the Starfire and hostiles in %s."
   misn_desc[3] = "Return to %s in the %s system."
   title = {}
   title[1] = "Bar"
   title[2] = "Operation Cold Metal"
   title[3] = "Mission Success"
   text = {}
   text[1] = [[You see Commodore Keer at a table with a couple other pilots.  She motions you over to sit down.
She begins, "We're going to finally attack the Collective.  We've gotten the Emperor himself to bless the mission and send some of his better pilots.  Would you be interested in joining the destruction of the Collective?"]]
   text[2] = [["The Operation has been dubbed 'Cold Metal'.  Our goal is to head to C-00, we'll take the route of %s, %s then C-00.  Should we encounter the Starfire at any stage our goal will be to destroy it and head back.  We'll also clear each system completely of Collective presence before continuing to the next system.  See you in combat pilots."]]
   text[3] = [[As you do your approach to land on %s you notice big banners placed on the exterior of the station.  They seem to be in celebration of the final defeat of the Collective.  When you do land you are saluted by the welcoming committee in charge of saluting all the returning pilots.
You notice Commodore Keer.  Upon greeting her she says, "You did a good job out there.  No need to worry about the Collective anymore.  Without Welsh the Collective won't stand a chance, since they aren't truly autonomous.  Right now we have some ships cleaning up the last of the Collective, shouldn't take too long to be back to normal."]]
   text[4] = [[She continues, "As a symbol of appreciation you should find a deposit of 500 thousand credits has been made to your account.  There will be a celebration later today in the officer's room if you want to join in."

And such ends the Collective threat...]]
   -- Conversation between pilots
   talk = {}
   talk[1] = "System Cleared: Procede to %s."
   talk[2] = "Mission Success: Return to %s."
   talk[3] = "Mission Failure: Return to %s."
end


-- Creates the mission
function create ()

   -- Intro text
   if tk.yesno( title[1], text[1] )
      then
      misn.accept()

      -- Mission data
      misn_stage = 0
      misn_base, misn_base_sys = space.getPlanet("Omega Station")
      misn_target_sys = space.getSystem("C-43")
      misn_final_sys = space.getSystem("C-28")
      misn.setMarker(misn_target_sys)

      -- Mission details
      misn.setTitle(misn_title)
      misn.setReward( misn_reward )
      misn.setDesc( string.format(misn_desc[1], misn_target_sys:name() ))

      tk.msg( title[2], string.format( text[2],
            misn_target_sys:name(), misn_final_sys:name() ) )

      hook.enter("jump")
      hook.land("land")
   end
end


-- Handles jumping to target system
function jump ()
   sys = space.getSystem()

   if misn_stage == 0 then

      -- Entering target system?
      if sys == misn_target_sys then

         -- Create big battle
         enter_vect = player.pos()
         pilot.clear()
         pilot.toggleSpawn(false)
         -- Empire
         emp_fleets = {}
         emp_fleets[1] = "Empire Sml Attack"
         emp_fleets[2] = "Empire Sml Attack"
         emp_fleets[3] = "Dvaered Goddard" -- They help empire
         for k,v in ipairs(emp_fleets) do
            enter_vect:add( rnd.int(-500,500), rnd.int(-500,500) )
            pilot.add( v, "def", enter_vect )
         end
         -- Collective
         col_fleets = {}
         col_fleets[1] = "Collective Sml Swarm"
         col_fleets[2] = "Collective Sml Swarm"
         col_fleets[3] = "Collective Sml Swarm"
         -- Set up position
         x,y = enter_vect:get()
         enter_vect:set(-x, -y)
         -- Count amount created
         col_alive = 0
         for k,v in ipairs(col_fleets) do
            enter_vect:add( rnd.int(-500,500), rnd.int(-500,500) )
            pilots = pilot.add( v, "def", enter_vect )
            col_alive = col_alive + #pilots
            for k,v in ipairs(pilots) do
               hook.pilot( v, "disable", "col_dead" )
            end
         end

         misn_stage = 1
      end

   elseif misn_stage == 2 then

      -- Entering target system?
      if sys == misn_final_sys then

         -- Create bigger battle
         enter_vect = player.pos()
         pilot.clear()
         pilot.toggleSpawn(false)
         -- Empire
         emp_fleets = {}
         emp_fleets[1] = "Empire Lge Attack"
         emp_fleets[2] = "Empire Med Attack"
         emp_fleets[3] = "Dvaered Goddard" -- They help empire
         for k,v in ipairs(emp_fleets) do
            enter_vect:add( rnd.int(-500,500), rnd.int(-500,500) )
            pilot.add( v, "def", enter_vect )
         end
         -- Collective
         col_fleets = {}
         col_fleets[1] = "Starfire"
         col_fleets[2] = "Collective Lge Swarm"
         col_fleets[3] = "Collective Lge Swarm"
         if var.peek("trinity") == true then
            col_fleets[4] = "Trinity"
         end
         x,y = enter_vect:get()
         enter_vect:set(-x, -y)
         col_alive = 0
         for k,v in ipairs(col_fleets) do
            enter_vect:add( rnd.int(-500,500), rnd.int(-500,500) )
            pilots = pilot.add( v, "def", enter_vect )

            -- Handle special ships
            if v == "Starfire" then
               starfire = pilots[1]
            elseif v == "Trinity" then
               trinity = pilots[1]
            end

            -- Count amount created
            col_alive = col_alive + #pilots
            for k,v in ipairs(pilots) do
               hook.pilot( v, "disable", "col_dead" )
            end
         end
         misn_stage = 3
      end

   elseif misn_stage == 1 or misn_stage == 3 then

      -- Fled from battle - disgraceful
      misn_stage = 5
      player.msg( string.format( talk[3], misn_base_sys:name() ))

   end
end


-- Handles collective death
function col_dead ()
   col_alive = col_alive - 1 -- Another one bites the dust

   -- All dead -> area clear
   if col_alive == 0 then
      if misn_stage == 1 then
         misn.setDesc( string.format(misn_desc[2], misn_final_sys:name() ))
         player.msg( string.format( talk[1], misn_final_sys:name() ))
         misn.setMarker(misn_final_sys)
         misn_stage = 2
      elseif misn_stage == 3 then
         misn.setDesc( string.format(misn_desc[3], misn_base:name(), misn_base_sys:name() ))
         player.msg( string.format( talk[2], misn_base_sys:name() ))
         misn.setMarker(misn_base_sys)
         misn_stage = 4
      end
   end
end


-- Handles arrival back to base
function land ()
   planet = space.getPlanet()

   -- Final landing stage
   if misn_stage == 4 and planet == misn_base then

      tk.msg( title[3], text[3] )

      -- Rewards
      player.modFaction("Empire",5)
      misn.finish(true)
      diff.apply("collective_dead")
      player.pay( 500000 ) -- 500k

      tk.msg( title[3], text[4] )
   end
end
