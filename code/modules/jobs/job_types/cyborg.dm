/datum/job/cyborg
	title = JOB_CYBORG
	description = "Assist the crew, follow your laws, obey your AI."
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = FACTION_STATION
	total_positions = 3	// SKYRAT EDIT: Original value (0)
	spawn_positions = 3
	supervisors = "your laws and the AI" //Nodrak
	spawn_type = /mob/living/silicon/robot
	minimal_player_age = 21
	exp_requirements = 120
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CYBORG"

	display_order = JOB_DISPLAY_ORDER_CYBORG

	departments_list = list(
		/datum/job_department/silicon,
		)
	random_spawns_possible = FALSE
	job_flags = JOB_NEW_PLAYER_JOINABLE | JOB_EQUIP_RANK | JOB_CANNOT_OPEN_SLOTS


/datum/job/cyborg/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!iscyborg(spawned))
		return
	var/mob/living/silicon/robot/robot_spawn = spawned
	robot_spawn.notify_ai(AI_NOTIFICATION_NEW_BORG)
	if(player_client)
		robot_spawn.set_gender(player_client)
	//SPLURT ADDITION START
	if(robot_spawn.is_security_cyborg_role())
		robot_spawn.set_connected_ai(null)
		robot_spawn.lawupdate = FALSE
		robot_spawn.laws = new /datum/ai_laws/security_cyborg()
		robot_spawn.laws.associate(robot_spawn)
		robot_spawn.show_laws()
		robot_spawn.log_current_laws()
		return
	//SPLURT ADDITION END
	//SKYRAT EDIT START
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
	//SKYRAT EDIT END
	if(!robot_spawn.connected_ai) // Only log if there's no Master AI
		robot_spawn.log_current_laws()

/datum/job/cyborg/get_radio_information()
	return "<b>Prefix your message with :b to speak with other cyborgs and AI.</b>"

/datum/job/cyborg/on_respawn(mob/new_character)
	new_character.Robotize(TRUE)

/datum/job/cyborg/get_lobby_icon()
	return icon('icons/mob/huds/hud.dmi', "hudcyborg")

//SPLURT ADDITION START - Security Cyborg Job
/datum/job/cyborg/security
	title = JOB_SECURITY_CYBORG
	job_spawn_title = JOB_SECURITY_OFFICER
	description = "Assist Security and the station, follow your laws."
	alt_titles = list(JOB_SECURITY_CYBORG)
	total_positions = 2
	spawn_positions = 2
	config_tag = "SECURITY_CYBORG"
	display_order = JOB_DISPLAY_ORDER_SECURITY_CYBORG
	antagonist_restricted = TRUE
	restricted_antagonists = list("ALL")

/datum/job/cyborg/security/get_job_ban_check_roles()
	. = ..()
	. |= JOB_CYBORG

	var/datum/job_department/security/security_department = SSjob.get_department_type(/datum/job_department/security)
	if(!security_department)
		. |= JOB_SECURITY_OFFICER
		return

	for(var/datum/job/security_job as anything in security_department.get_jobban_jobs())
		. |= security_job.title

/datum/job/cyborg/security/after_spawn(mob/living/spawned, client/player_client)
	return ..()

/datum/job/cyborg/security/get_lobby_icon()
	return icon('icons/mob/huds/hud.dmi', "hudcyborg")
//SPLURT ADDITION END
