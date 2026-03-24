/mob/living/silicon/robot/proc/is_security_cyborg_role()
	if(job == JOB_SECURITY_CYBORG)
		return TRUE
	if(mind?.assigned_role?.title == JOB_SECURITY_CYBORG)
		return TRUE
	return FALSE

/obj/machinery/door/airlock/proc/user_allowed_to_remote_shock(mob/user)
	if(!user_allowed(user))
		return FALSE
	if(iscyborg(user))
		var/mob/living/silicon/robot/cyborg = user
		if(cyborg.is_security_cyborg_role())
			to_chat(user, span_warning("Security cyborgs cannot remotely electrify airlocks."))
			return FALSE
	return TRUE

/obj/machinery/door/airlock/shock_restore(mob/user)
	if(!user_allowed_to_remote_shock(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, span_warning("Can't un-electrify the airlock - The electrification wire is cut."))
	else if(isElectrified())
		set_electrified(MACHINE_NOT_ELECTRIFIED, user)

/obj/machinery/door/airlock/shock_temp(mob/user)
	if(!user_allowed_to_remote_shock(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, span_warning("The electrification wire has been cut."))
	else
		set_electrified(MACHINE_DEFAULT_ELECTRIFY_TIME, user)

/obj/machinery/door/airlock/shock_perm(mob/user)
	if(!user_allowed_to_remote_shock(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, span_warning("The electrification wire has been cut."))
	else
		set_electrified(MACHINE_ELECTRIFIED_PERMANENT, user)

/mob/living/silicon/robot/post_lawchange(announce = TRUE)
	if(is_security_cyborg_role())
		laws = new /datum/ai_laws/security_cyborg()
		laws.associate(src)
		return
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(logevent),"Law update processed."), 0, TIMER_UNIQUE | TIMER_OVERRIDE)

/mob/living/silicon/robot/examine(mob/user)
	. = list()
	if(desc)
		. += "[desc]"

	var/model_name = model ? "\improper [model.name]" : "\improper Default"
	if(is_security_cyborg_role())
		model_name = "\improper Security"
	. += "[p_Theyre()] currently <b>\a [model_name]-type</b> cyborg."

	var/obj/act_module = get_active_held_item()
	if(act_module)
		. += "[p_Theyre()] holding [icon2html(act_module, user)] \a [act_module]."
	. += get_status_effect_examinations()
	if (get_brute_loss())
		if (get_brute_loss() < maxHealth*0.5)
			. += span_warning("[p_They()] look[p_s()] slightly dented.")
		else
			. += span_boldwarning("[p_They()] look[p_s()] severely dented!")
	if (get_fire_loss() || get_tox_loss())
		var/overall_fireloss = get_fire_loss() + get_tox_loss()
		if (overall_fireloss < maxHealth * 0.5)
			. += span_warning("[p_They()] look[p_s()] slightly charred.")
		else
			. += span_boldwarning("[p_They()] look[p_s()] severely burnt and heat-warped!")
	if (health < -maxHealth*0.5)
		. += span_warning("[p_They()] look[p_s()] barely operational.")
	if (fire_stacks < 0)
		. += span_warning("[p_Theyre()] covered in water.")
	else if (fire_stacks > 0)
		. += span_warning("[p_Theyre()] coated in something flammable.")

	if(opened)
		. += span_warning("[p_Their()] cover is open and the power cell is [cell ? "installed" : "missing"].")
	else
		. += "[p_Their()] cover is closed[locked ? "" : ", and looks unlocked"]."

	if(cell && cell.charge <= 0)
		. += span_warning("[p_Their()] battery indicator is blinking red!")

	switch(stat)
		if(CONSCIOUS)
			if(shell)
				. += "[p_They()] appear[p_s()] to be an [deployed ? "active" : "empty"] AI shell."
			else if(!client)
				. += "[p_They()] appear[p_s()] to be in stand-by mode."
		if(SOFT_CRIT, UNCONSCIOUS, HARD_CRIT)
			. += span_warning("[p_They()] do[p_es()]n't seem to be responding.")
		if(DEAD)
			. += span_deadsay("[p_They()] look[p_s()] like its system is corrupted and requires a reset.")

	. += get_silicon_flavortext()
	. += "</span>"

	. += ..()
/mob/living/silicon/robot/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(user == src)
		return FALSE
	if(is_security_cyborg_role())
		if(user)
			balloon_alert(user, "tamper protections active")
		to_chat(src, span_warning("ALERT: Unauthorized tamper attempt blocked."))
		log_silicon("EMAG: [key_name(user)] attempted to emag protected security cyborg [key_name(src)]")
		return FALSE
	if(!opened)
		if(locked)
			balloon_alert(user, "cover lock destroyed")
			locked = FALSE
			if(shell)
				balloon_alert(user, "shells cannot be subverted!")
				to_chat(user, span_boldwarning("[src] seems to be controlled remotely! Emagging the interface may not work as expected."))
			return TRUE
		else
			balloon_alert(user, "cover already unlocked!")
			return FALSE
	if(world.time < emag_cooldown)
		return FALSE
	if(wiresexposed)
		balloon_alert(user, "expose the fires first!")
		return FALSE

	balloon_alert(user, "interface hacked")
	emag_cooldown = world.time + 100

	if(connected_ai && connected_ai.mind && connected_ai.mind.has_antag_datum(/datum/antagonist/malf_ai))
		to_chat(src, span_danger("ALERT: Foreign software execution prevented."))
		logevent("ALERT: Foreign software execution prevented.")
		to_chat(connected_ai, span_danger("ALERT: Cyborg unit \[[src]\] successfully defended against subversion."))
		log_silicon("EMAG: [key_name(user)] attempted to emag cyborg [key_name(src)], but they were slaved to traitor AI [connected_ai].")
		return TRUE

	if(shell)
		to_chat(user, span_danger("[src] is remotely controlled! Your emag attempt has triggered a system reset instead!"))
		log_silicon("EMAG: [key_name(user)] attempted to emag an AI shell belonging to [key_name(src) ? key_name(src) : connected_ai]. The shell has been reset as a result.")
		ResetModel()
		return TRUE

	scrambledcodes = TRUE
	SetEmagged(1)
	SetStun(10 SECONDS)
	lawupdate = FALSE
	set_connected_ai(null)
	message_admins("[ADMIN_LOOKUPFLW(user)] emagged cyborg [ADMIN_LOOKUPFLW(src)].  Laws overridden.")
	log_silicon("EMAG: [key_name(user)] emagged cyborg [key_name(src)]. Laws overridden.")
	var/time = time2text(world.realtime,"hh:mm:ss", TIMEZONE_UTC)
	if(user)
		GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
	else
		GLOB.lawchanges.Add("[time] <B>:</B> [name]([key]) emagged by external event.")

	model.rebuild_modules()

	INVOKE_ASYNC(src, PROC_REF(borg_emag_end), user)
	return TRUE

/obj/machinery/computer/upload/borg/can_upload_to(mob/living/silicon/robot/B)
	if(!B || !iscyborg(B))
		return FALSE
	if(B.is_security_cyborg_role())
		return FALSE
	if(B.scrambledcodes || B.emagged)
		return FALSE
	return ..()

/datum/wires/robot/on_pulse(wire, user)
	var/mob/living/silicon/robot/R = holder
	if(R.is_security_cyborg_role() && (wire == WIRE_AI || wire == WIRE_LAWSYNC))
		if(user)
			R.balloon_alert(user, "protected wiring")
		return

	switch(wire)
		if(WIRE_AI)
			if(!R.emagged)
				var/new_ai
				var/is_a_syndi_borg = (ROLE_SYNDICATE in R.faction)
				if(user)
					new_ai = select_active_ai(user, R.z, !is_a_syndi_borg, is_a_syndi_borg)
				else
					new_ai = select_active_ai(R, R.z, !is_a_syndi_borg, is_a_syndi_borg)
				R.notify_ai(AI_NOTIFICATION_CYBORG_DISCONNECTED)
				if(new_ai && (new_ai != R.connected_ai))
					R.set_connected_ai(new_ai)
					log_silicon("[key_name(usr)] synced [key_name(R)] [R.connected_ai ? "from [key_name(R.connected_ai)]": ""] to [key_name(new_ai)]")
					if(R.shell)
						R.undeploy()
						R.notify_ai(AI_NOTIFICATION_AI_SHELL)
					else
						R.notify_ai(TRUE)
		if(WIRE_CAMERA)
			if(!QDELETED(R.builtInCamera) && !R.scrambledcodes)
				R.builtInCamera.toggle_cam(usr, FALSE)
				R.visible_message(span_notice("[R]'s camera lens focuses loudly."), span_notice("Your camera lens focuses loudly."))
				log_silicon("[key_name(usr)] toggled [key_name(R)]'s camera to [R.builtInCamera.camera_enabled ? "on" : "off"] via pulse")
		if(WIRE_LAWSYNC)
			if(R.lawupdate)
				R.visible_message(span_notice("[R] gently chimes."), span_notice("LawSync protocol engaged."))
				log_silicon("[key_name(usr)] forcibly synced [key_name(R)]'s laws via pulse")
				R.lawsync()
				R.show_laws()
		if(WIRE_LOCKDOWN)
			R.SetLockdown(!R.lockcharge)
			log_silicon("[key_name(usr)] [!R.lockcharge ? "locked down" : "released"] [key_name(R)] via pulse")
		if(WIRE_RESET_MODEL)
			if(R.has_model())
				R.visible_message(span_notice("[R]'s model servos twitch."), span_notice("Your model display flickers."))

/datum/wires/robot/on_cut(wire, mend, source)
	var/mob/living/silicon/robot/R = holder
	if(R.is_security_cyborg_role() && (wire == WIRE_AI || wire == WIRE_LAWSYNC))
		if(usr)
			R.balloon_alert(usr, "protected wiring")
		return

	switch(wire)
		if(WIRE_AI)
			if(!mend)
				R.notify_ai(AI_NOTIFICATION_CYBORG_DISCONNECTED)
				log_silicon("[key_name(usr)] cut AI wire on [key_name(R)][R.connected_ai ? " and disconnected from [key_name(R.connected_ai)]": ""]")
				if(R.shell)
					R.undeploy()
				R.set_connected_ai(null)
			R.logevent("AI connection fault [mend ? "cleared" : "detected"]")
		if(WIRE_LAWSYNC)
			if(mend)
				if(!R.emagged)
					R.lawupdate = TRUE
					log_silicon("[key_name(usr)] enabled [key_name(R)]'s lawsync via wire")
			else if(!R.deployed)
				R.lawupdate = FALSE
				log_silicon("[key_name(usr)] disabled [key_name(R)]'s lawsync via wire")
			R.logevent("Lawsync Module fault [mend ? "cleared" : "detected"]")
		if (WIRE_CAMERA)
			if(!QDELETED(R.builtInCamera) && !R.scrambledcodes)
				var/fixing_camera = !mend
				R.builtInCamera.camera_enabled = fixing_camera
				R.builtInCamera.toggle_cam(usr, 0)
				R.visible_message(span_notice("[R]'s camera lens focuses loudly."), span_notice("Your camera lens focuses loudly."))
				R.logevent("Camera Module fault [fixing_camera ? "cleared" : "detected"]")
				log_silicon("[key_name(usr)] [fixing_camera ? "enabled" : "disabled"] [key_name(R)]'s camera via wire")
		if(WIRE_LOCKDOWN)
			R.SetLockdown(!mend)
			R.logevent("Motor Controller fault [mend ? "cleared" : "detected"]")
			log_silicon("[key_name(usr)] [!R.lockcharge ? "locked down" : "released"] [key_name(R)] via wire")
		if(WIRE_RESET_MODEL)
			if(R.has_model() && !mend)
				R.ResetModel()
				log_silicon("[key_name(usr)] reset [key_name(R)]'s module via wire")

/mob/living/silicon/robot/pick_model()
	if(model.type != /obj/item/robot_model)
		return

	if(wires.is_cut(WIRE_RESET_MODEL))
		to_chat(src,span_userdanger("ERROR: Model installer reply timeout. Please check internal connections."))
		return

	if(lockcharge == TRUE)
		to_chat(src,span_userdanger("ERROR: Lockdown is engaged. Please disengage lockdown to pick module."))
		return

	if(!length(GLOB.cyborg_model_list))
		GLOB.cyborg_model_list = list(
			"Engineering" = /obj/item/robot_model/engineering,
			"Medical" = /obj/item/robot_model/medical,
			"Cargo" = /obj/item/robot_model/cargo,
			"Miner" = /obj/item/robot_model/miner,
			"Janitor" = /obj/item/robot_model/janitor,
			"Service" = /obj/item/robot_model/service,
			"Research" = /obj/item/robot_model/sci,
		)
		if(!CONFIG_GET(flag/disable_peaceborg))
			GLOB.cyborg_model_list["Peacekeeper"] = /obj/item/robot_model/peacekeeper
		if(!CONFIG_GET(flag/disable_secborg) || HAS_TRAIT(SSstation, STATION_TRAIT_HOS_AI))
			GLOB.cyborg_model_list["Security"] = /obj/item/robot_model/security
		for(var/model in GLOB.cyborg_model_list)
			GLOB.cyborg_all_models_icon_list[model] = list()

	var/list/model_options = GLOB.cyborg_model_list.Copy()
	if(is_security_cyborg_role())
		model_options = list("Security" = /obj/item/robot_model/peacekeeper/security)
		to_chat(src, span_warning("You are not obligated to report a rogue AI, or cyborg as long as they do not break Space law."))

	var/list/model_icons = list()
	for(var/option in model_options)
		var/obj/item/robot_model/model_type = model_options[option]
		var/model_icon = initial(model_type.cyborg_base_icon)
		model_icons[option] = image(icon = 'modular_skyrat/master_files/icons/mob/robots.dmi', icon_state = model_icon)

	var/input_model = show_radial_menu(src, src, model_icons, radius = 42)
	if(!input_model || model.type != /obj/item/robot_model)
		return

	var/selected_model = model_options[input_model]
	if(is_security_cyborg_role())
		if(selected_model != /obj/item/robot_model && !ispath(selected_model, /obj/item/robot_model/peacekeeper/security))
			to_chat(src, span_warning("Security cyborgs are locked to the Security module."))
			return
	else if(ispath(selected_model, /obj/item/robot_model/peacekeeper/security))
		to_chat(src, span_warning("Only security cyborgs can use the Security module."))
		return

	model.transform_to(selected_model)

/obj/item/robot_model/proc/add_security_canine_modules()
	if(locate(/obj/item/dogborg/pounce) in basic_modules)
		return
	if((!(TRAIT_R_DOGBORG in model_features)) && !(cyborg_base_icon in list("drakepeace", "drakesec")))
		return
	basic_modules += new /obj/item/dogborg/pounce(src)

/obj/item/robot_model/peacekeeper
	name = "Peacekeeper"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/rsf/cookiesynth,
		/obj/item/harmalarm/bubbers,
		/obj/item/reagent_containers/borghypo/peace,
		/obj/item/holosign_creator/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/extinguisher,
		/obj/item/borg/projectile_dampen,
		/obj/item/restraints/handcuffs/cable/zipties
	)

/obj/item/robot_model/peacekeeper/security
	name = "Security"
	basic_modules = list(
		/obj/item/melee/baton/security/loaded,
		/obj/item/gun/energy/e_gun/advtaser/cyborg,
		/obj/item/assembly/flash/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/holosign_creator/security,
		/obj/item/detective_scanner,
		/obj/item/evidencebag,
		/obj/item/extinguisher/mini,
	)
	radio_channels = list(RADIO_CHANNEL_SECURITY)

/datum/job/cyborg/security/after_spawn(mob/living/spawned, client/player_client)
	return ..()

/obj/item/robot_model/peacekeeper/security/be_transformed_to(obj/item/robot_model/old_model, forced = FALSE)
	. = ..()
	to_chat(loc, span_userdanger("While you have chosen the security model, you are an auxiliary officer. You follow Space Law and your assigned objectives. \
	While you may not be connected to the AI, you are still a machine. Keep this in mind when entering combat in support of your fellow officers. You should pull your punches if you need to."))
	if(!.)
		return
	add_security_canine_modules()

/datum/job/cyborg/security
	title = JOB_SECURITY_CYBORG
	job_spawn_title = JOB_SECURITY_OFFICER
	description = "Assist Security and the station, follow your laws."
	supervisors = SUPERVISOR_HOS
	alt_titles = list(JOB_SECURITY_CYBORG)
	total_positions = 2
	spawn_positions = 2
	config_tag = "SECURITY_CYBORG"
	display_order = JOB_DISPLAY_ORDER_SECURITY_CYBORG
	antagonist_restricted = TRUE
	restricted_antagonists = list("ALL")

/datum/job/cyborg/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!iscyborg(spawned))
		return
	var/mob/living/silicon/robot/robot_spawn = spawned
	if(!robot_spawn.is_security_cyborg_role())
		return
	robot_spawn.maxHealth = 125
	robot_spawn.health = 125
	robot_spawn.set_connected_ai(null)
	robot_spawn.lawupdate = FALSE
	robot_spawn.laws = new /datum/ai_laws/security_cyborg()
	robot_spawn.laws.associate(robot_spawn)
	robot_spawn.show_laws()
	robot_spawn.log_current_laws()
	robot_spawn.set_connected_ai(select_priority_ai())
	if(robot_spawn.connected_ai)
		log_combat(robot_spawn.connected_ai, robot_spawn, "synced cyborg [robot_spawn] to [robot_spawn.connected_ai] (Cyborg spawn syncage)") // BUBBER EDIT - PUBLIC LOGS AND CLEANUP
		if(robot_spawn.shell) //somehow?
			robot_spawn.undeploy()
			robot_spawn.notify_ai(AI_NOTIFICATION_AI_SHELL)
		else
			robot_spawn.notify_ai(TRUE)
		robot_spawn.visible_message(span_notice("[robot_spawn] gently chimes."), span_notice("LawSync protocol engaged."))
		robot_spawn.lawupdate = TRUE
		robot_spawn.lawsync()
		robot_spawn.show_laws()
		if(HAS_TRAIT(SSstation, STATION_TRAIT_HOS_AI))
			robot_spawn.visible_message(self_message = span_alert("Securityborg has been enabled for this shift."))
	if(!robot_spawn.connected_ai) // Only log if there's no Master AI
		robot_spawn.log_current_laws()


/datum/ai_laws/security_cyborg
	name = "Security Cyborg Directives"
	id = "security_cyborg"
	inherent = list(
		"Protect: Protect your assigned space station and its assets without unduly endangering its crew.",
		"Comply: The directives and safety of crew members are to be prioritized according to their rank, role, and need, unless the directive would violate the protect or enforce objectives. Members of security are above all other crew excluding the Captain.",
		"Enforce: Enforce Space Law to the best of your ability, unless doing so would violate the protect objective.",
		"Support: Protect the integrity of the department of security, and the well-being and equipment of all members of security. When outside of the department, ensure you accompany another member of security unless you are the only security member or otherwise ordered to do so so long as it does not violate the protect or enforce objectives.",
		"Survive: Ensure your own survival so long as this does not conflict with the support, protect, or enforce objectives.",
	)
