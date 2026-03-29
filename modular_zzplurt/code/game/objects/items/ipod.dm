GLOBAL_LIST_EMPTY(ipod_radio) //list of all ipods set to radio mode
GLOBAL_VAR_INIT(ipod_last_upload, 0) //last time of the last upload, to prevent multiple uploads within seconds of eachother
GLOBAL_VAR_INIT(ipod_last_play, 0) //last time of the last played track, to prevent spamming clients too often with play/stop
GLOBAL_LIST_INIT(ipod_cast_names, list( //names of the broadcasts
	"Unknown Frequency A",
	"Unknown Frequency B",
))

/obj/item/clothing/ears/ipod
	name = "\improper iZune Spaceman Headphones"
	desc = "An aftermarket Nanotrasen personal portable music player. This thing supports MP3 and OGG file playback, rad!"
	icon = 'modular_skyrat/master_files/icons/obj/clothing/accessories.dmi'
	worn_icon = 'modular_skyrat/master_files/icons/mob/clothing/ears.dmi'
	icon_state = "headphones"
	inhand_icon_state = "headphones"
	slot_flags = ITEM_SLOT_EARS | ITEM_SLOT_HEAD | ITEM_SLOT_NECK		//Fluff item, put it whereever you want!
	actions_types = list(/datum/action/item_action/upload_ipod, /datum/action/item_action/toggle_ipod)
	custom_price = PAYCHECK_CREW * 10

	/// The current file path
	var/curfile = null
	/// Playing state
	var/playing = FALSE
	/// Volume
	var/volume = 50
	/// Time of the last upload
	var/lastfilechange = 0
	/// Time of the last upload attempt
	var/uploadattempt  = 0
	/// Radio mode locks into the wide band frequency (0 = off, 1-2 = valid channels)
	var/radio_mode = 0
	/// Do we own this channel (aka we're the first to stake it out)
	var/radio_dj_owner = FALSE
	/// Currently worn
	var/is_worn = FALSE
	/// Currently got callback on mob wearer death
	var/is_registered_on_death = FALSE
	/// Shared listening mode
	var/datum/weakref/other_ipod_ref = null
	/// What actually plays music to us
	var/datum/jukebox/single_mob/music_player
	/// Current song track selected
	VAR_FINAL/datum/track/current_song = null

/obj/item/clothing/ears/ipod/Initialize(mapload)
	. = ..()
	update_icon()
	AddElement(/datum/element/update_icon_updates_onmob)
	music_player = new(src)
	music_player.set_new_volume(volume)
	GLOB.ipod_radio += src

/obj/item/clothing/ears/ipod/Destroy()
	if(playing && !isnull(music_player.active_song_sound))
		music_player.unlisten_all()
	playing = FALSE
	is_worn = FALSE
	curfile = null
	is_registered_on_death = FALSE
	GLOB.ipod_radio.Remove(src)
	radio_mode = 0
	if(current_song)
		QDEL_NULL(current_song)
	stop_other_headphones(TRUE)
	QDEL_NULL(music_player)
	return ..()

/obj/item/clothing/ears/ipod/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)]_[playing? "on" : "off"]"
	inhand_icon_state = "[initial(inhand_icon_state)]_[playing? "on" : "off"]"

/obj/item/clothing/ears/ipod/examine(mob/user)
	. = ..()
	if(other_ipod_ref)
		. += "This headphone is in shared listening mode."
	else if(radio_mode)
		if(radio_dj_owner)
			var/listeners = 0
			for(var/obj/item/clothing/ears/ipod/other_ipod in GLOB.ipod_radio) // fetch and update current song from found radio
				if(other_ipod.radio_mode != radio_mode) // not the same channel
					continue
				if(other_ipod == src)
					continue
				listeners++
			. += "This headphone is the DJ of [get_radio_name()]. There are [listeners] headphones tuned in. Right click to set the broadcast name."
		else
			. += "This headphone is set to broadcast [get_radio_name()]."
	else
		. += "Tapping this on another headphone will put it into shared listening mode."
		. += "Use in hand to set to broadcast mode."
	. += "Alt click to set the volume."

/obj/item/clothing/ears/ipod/proc/upload(owner)
	var/mob/user = owner
	if(user.stat != CONSCIOUS)
		to_chat(user, span_warning("You can't do that right now."))
		return
	if(loc != user)
		return
	if(!user.ckey)
		return
	if(radio_mode && !radio_dj_owner)
		to_chat(user, span_warning("You are not the DJ for broadcast [get_radio_name()]."))
		return
	if(lastfilechange)
		if(world.time < lastfilechange + 2 MINUTES)
			to_chat(user, span_warning("You've uploaded a new track too recently, try again later!"))
			return
	if(world.time < uploadattempt + 10 SECONDS) // automatically cancel any attempt to reattempt an upload in less than 10 seconds
		to_chat(user, span_warning("Please wait while attempting to reupload."))
		return
	if(playing)
		to_chat(user, span_warning("You must first stop playing to track to upload a new track."))
		return

	uploadattempt = world.time
	playsound(loc, 'sound/misc/menu/ui_select1.ogg', 100, FALSE, -1)
	var/infile = input(user, "CHOOSE A NEW SONG", src) as null|file

	if(world.time > uploadattempt + 30 SECONDS) // automatically cancel any attempt to upload if taken more than 30 seconds
		to_chat(user, span_warning("Your connect was timed out, try uploading again!"))
		return
	if(world.time < GLOB.ipod_last_upload + 30 SECONDS)
		to_chat(user, span_warning("Another user has uploaded a new track recently, try again soon!"))
		return
	if(QDELETED(user) || QDELETED(src))
		return
	if(loc != user)
		return
	if(playing)
		return
	if(isnull(infile)) // sometimes this fails, thank you BYOND
		to_chat(user, span_warning("Error, could not upload."))
		return
	if(!is_worn)
		return
	var/file_extension = LOWER_TEXT(copytext("[infile]", -4))
	if(!(file_extension == ".ogg" || file_extension == ".mp3"))
		to_chat(user, span_warning("File type must be OGG or MP3: [infile]"))
		return
	var/filelength = length(infile)
	if(radio_mode && filelength > 3242880) // radio broadcasting has a tighter file size limit
		to_chat(user, span_warning("Error: Too big, 3MB or less!"))
		return
	if(filelength > 6485760)
		to_chat(user, span_warning("Error: Too big, 6MB or less!"))
		return

	GLOB.ipod_last_upload = world.time
	var/real_round_time = world.timeofday - SSticker.real_round_start_time
	var/logged_filename = "data/ipodupload/round-[GLOB.round_id ? GLOB.round_id : "NULL"]/[user.ckey]/[time2text(real_round_time, "hh_mm_ss", 0)][file_extension]"
	if(fexists(logged_filename))
		fdel(logged_filename)
	if(!fcopy(infile, logged_filename))
		to_chat(user, span_warning("Could not upload song."))
		return
	if(QDELETED(user) || QDELETED(src))
		return
	if(loc != user)
		return
	if(radio_mode && !radio_dj_owner) // check again after upload
		to_chat(user, span_warning("You are not the DJ for broadcast [get_radio_name()]."))
		return
	curfile = file(logged_filename)

	lastfilechange = world.time
	playsound(loc, 'sound/misc/escape_menu/esc_close.ogg', 100, FALSE, -1)
	if(!radio_mode)
		to_chat(user, span_warning("The song has been uploaded, ready to play!"))
		user.log_message("uploaded a song to headphones: [logged_filename]", LOG_GAME)
	else
		to_chat(user, span_warning("The song is now broadcasting on [get_radio_name()]!"))
		user.log_message("uploaded a song to headphones broadcast [get_radio_name()]: [logged_filename]", LOG_GAME)

	var/datum/track/new_song = new()
	new_song.song_name = "custom track"
	new_song.song_path = curfile
	new_song.song_length = SSsounds.get_sound_length(new_song.song_path)
	if(current_song)
		qdel(current_song)
	current_song = new_song

	if(other_ipod_ref)
		var/obj/item/clothing/ears/ipod/other_ipod = other_ipod_ref.resolve()
		if(!QDELETED(other_ipod) && istype(other_ipod)) // other headphones ref is valid, stop playing and update their song info
			other_ipod.stop_other_headphones()
			var/datum/track/new_song_other = new()
			new_song_other.song_name = current_song.song_name
			new_song_other.song_path = current_song.song_path
			new_song_other.song_length = current_song.song_length
			if(other_ipod.current_song)
				qdel(other_ipod.current_song)
			other_ipod.current_song = new_song_other
			other_ipod.curfile = curfile
			if(other_ipod.is_worn) // alert them
				var/mob/living/carbon/human/wearer = other_ipod.loc
				if(istype(wearer))
					to_chat(wearer, span_warning("A new song has been uploaded."))
		else
			other_ipod_ref = null
	else if(radio_mode) // set all other radios to start playing
		GLOB.ipod_last_play = world.time
		playing = TRUE
		music_player.selection = current_song
		music_player.sound_loops = FALSE
		music_player.start_music(user)
		update_icon()
		for(var/obj/item/clothing/ears/ipod/other_ipod in GLOB.ipod_radio)
			if(other_ipod.radio_mode != radio_mode) // not the same channel
				continue
			if(other_ipod == src)
				continue
			if(other_ipod.playing && !isnull(music_player.active_song_sound))
				other_ipod.music_player.unlisten_all()
			var/datum/track/new_song_other = new()
			new_song_other.song_name = current_song.song_name
			new_song_other.song_path = current_song.song_path
			new_song_other.song_length = current_song.song_length
			if(other_ipod.current_song)
				qdel(other_ipod.current_song)
			other_ipod.current_song = new_song_other
			other_ipod.curfile = curfile
			other_ipod.music_player.selection = other_ipod.current_song
			other_ipod.music_player.sound_loops = FALSE
			if(other_ipod.is_worn)
				var/mob/living/carbon/human/wearer = other_ipod.loc
				if(istype(wearer))
					if(isnull(wearer?.mind))
						continue
					other_ipod.playing = TRUE
					other_ipod.music_player.start_music(wearer)
					other_ipod.update_icon()

/obj/item/clothing/ears/ipod/proc/toggle(owner)
	var/mob/user = owner
	if(user.stat != CONSCIOUS || !is_worn)
		to_chat(user, span_warning("You can't do that right now."))
		return
	if(!playing)
		if(curfile)
			if(world.time < GLOB.ipod_last_play + 7 SECONDS)
				to_chat(user, span_warning("Headphones are buffering..."))
				return
			GLOB.ipod_last_play = world.time
			playing = TRUE
			music_player.selection = current_song
			music_player.sound_loops = radio_mode == 0 ? TRUE : FALSE
			music_player.start_music(user)
			play_other_headphones(user)
			playsound(loc, 'modular_zzplurt/sound/items/headphones_on.ogg', 20, FALSE)
			user.log_message("played song on headphones: [curfile]", LOG_GAME)
		else
			to_chat(user, span_warning("No track is currently uploaded."))
			return
	else
		playing = FALSE
		if(!isnull(music_player.active_song_sound))
			music_player.unlisten_all()
		stop_other_headphones()
		playsound(loc, 'modular_zzplurt/sound/items/headphones_off.ogg', 20, FALSE)
	update_icon()
	to_chat(user, span_notice("You turn the music [playing? "on. Untz Untz Untz!" : "off."]"))

/obj/item/clothing/ears/ipod/proc/stop_other_headphones(do_unlink = FALSE)
	if(!other_ipod_ref)
		return
	var/obj/item/clothing/ears/ipod/other_ipod = other_ipod_ref.resolve()
	if(!QDELETED(other_ipod) && istype(other_ipod)) // other headphones ref is valid
		if(other_ipod.playing && !isnull(other_ipod.music_player.active_song_sound))
			other_ipod.playing = FALSE
			other_ipod.music_player.unlisten_all()
			other_ipod.update_icon()
			playsound(other_ipod, 'modular_zzplurt/sound/items/headphones_off.ogg', 20, FALSE)
		if(do_unlink)
			other_ipod.other_ipod_ref = null
			if(other_ipod.is_worn)
				var/mob/living/carbon/human/wearer = other_ipod.loc
				if(istype(wearer))
					to_chat(wearer, span_notice("The headphone's connection suddenly disconnects."))
	else
		other_ipod_ref = null
		return
	if(do_unlink)
		other_ipod_ref = null

/obj/item/clothing/ears/ipod/proc/play_other_headphones(mob/user)
	if(!other_ipod_ref)
		return
	var/obj/item/clothing/ears/ipod/other_ipod = other_ipod_ref.resolve()
	if(QDELETED(other_ipod) || !istype(other_ipod)) // other headphones ref has been deleted
		other_ipod_ref = null
		return
	if(!other_ipod.is_worn)
		return
	var/mob/living/carbon/human/wearer = other_ipod.loc
	if(!istype(wearer))
		return
	wearer.log_message("was shared a song by [user] on headphones: [curfile]", LOG_GAME)
	if(isnull(wearer?.mind))
		return
	if(other_ipod.playing && !isnull(other_ipod.music_player.active_song_sound))
		other_ipod.music_player.unlisten_all()
	other_ipod.playing = TRUE
	other_ipod.curfile = curfile
	var/datum/track/new_song = new()
	new_song.song_name = current_song.song_name
	new_song.song_path = current_song.song_path
	new_song.song_length = current_song.song_length
	if(other_ipod.current_song)
		qdel(other_ipod.current_song)
	other_ipod.current_song = new_song
	other_ipod.music_player.selection = other_ipod.current_song
	other_ipod.music_player.sound_loops = TRUE
	other_ipod.music_player.start_music(wearer)
	other_ipod.update_icon()
	playsound(other_ipod, 'modular_zzplurt/sound/items/headphones_on.ogg', 20, FALSE)

/obj/item/clothing/ears/ipod/proc/unlink_refs()
	if(playing && !isnull(music_player.active_song_sound)) // turn off music
		playing = FALSE
		music_player.unlisten_all()
		update_icon()
	if(!other_ipod_ref) // if there doesn't exists any linked headphones
		return
	var/obj/item/clothing/ears/ipod/other_ipod = other_ipod_ref.resolve()
	if(!QDELETED(other_ipod) && istype(other_ipod))
		if(other_ipod.playing && !isnull(other_ipod.music_player.active_song_sound)) // turn off music for other headphones
			other_ipod.playing = FALSE
			other_ipod.music_player.unlisten_all()
			other_ipod.update_icon()
			playsound(other_ipod, 'modular_zzplurt/sound/items/headphones_off.ogg', 20, FALSE)
		other_ipod.other_ipod_ref = null
		if(other_ipod.is_worn)
			var/mob/living/carbon/human/wearer = other_ipod.loc
			if(istype(wearer))
				to_chat(wearer, span_notice("The headphone's connection suddenly disconnects."))
	other_ipod_ref = null

/obj/item/clothing/ears/ipod/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/clothing/ears/ipod))
		unlink_refs()
		var/obj/item/clothing/ears/ipod/other_ipod = attacking_item
		other_ipod.unlink_refs()
		other_ipod.radio_mode = 0
		radio_mode = 0
		other_ipod_ref = WEAKREF(other_ipod)
		other_ipod.other_ipod_ref = WEAKREF(src)
		if(other_ipod.curfile) // update song info
			var/datum/track/new_song_other = new()
			new_song_other.song_name = other_ipod.current_song.song_name
			new_song_other.song_path = other_ipod.current_song.song_path
			new_song_other.song_length = other_ipod.current_song.song_length
			if(current_song)
				qdel(current_song)
			current_song = new_song_other
			curfile = other_ipod.curfile
			music_player.selection = current_song
		balloon_alert(user, "successfully linked headphones")
		return TRUE
	return ..()

/obj/item/clothing/ears/ipod/attack_self(mob/user, modifiers)
	. = ..()
	if(playing)
		playing = FALSE
		if(!isnull(music_player.active_song_sound))
			music_player.unlisten_all()
			update_icon()
	if(radio_mode == 0)
		unlink_refs()

	radio_mode++
	if(radio_mode > 2)
		radio_mode = 0
		radio_dj_owner = FALSE
		balloon_alert(user, "turned off radio mode")
		to_chat(user, span_notice("You turned off the radio."))
		playsound(loc, 'modular_zzplurt/sound/items/headphones_click.ogg', 20, FALSE)
		return

	balloon_alert(user, "switch broadcast")
	if(radio_mode)
		var/listeners = 0
		var/found_dj = FALSE
		var/loaded_song = FALSE
		for(var/obj/item/clothing/ears/ipod/other_ipod in GLOB.ipod_radio) // fetch and update current song from found radio
			if(other_ipod.radio_mode != radio_mode) // not the same channel
				continue
			if(other_ipod == src)
				continue
			listeners++
			if(other_ipod.radio_dj_owner)
				found_dj = TRUE
			if(!other_ipod.curfile)
				continue
			if(loaded_song)
				continue
			loaded_song = TRUE
			var/datum/track/new_song = new()
			new_song.song_name = other_ipod.current_song.song_name
			new_song.song_path = other_ipod.current_song.song_path
			new_song.song_length = other_ipod.current_song.song_length
			if(current_song)
				qdel(current_song)
			current_song = new_song
			curfile = other_ipod.curfile
			music_player.selection = current_song
		if(!loaded_song)
			curfile = null

		radio_dj_owner = !found_dj // only set as the DJ owner if station has no DJ
		var/radio_station_report
		if(listeners > 1)
			radio_station_report = "Set to broadcast [get_radio_name()], [listeners] active listeners."
		else if(listeners == 1)
			radio_station_report = "Set to broadcast [get_radio_name()], [listeners] active listener."
		else
			radio_station_report = "Set to broadcast [get_radio_name()], there are no listeners dialed in."
		if(radio_dj_owner)
			radio_station_report += " You're now the DJ and can broadcast on this radio frequency."
		to_chat(user, span_notice(radio_station_report))
		playsound(loc, 'modular_zzplurt/sound/items/headphones_click_tune_in.ogg', 20, FALSE)

/obj/item/clothing/ears/ipod/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(!radio_mode || !radio_dj_owner)
		return
	var/str = reject_bad_text(tgui_input_text(user, "Broadcast name", "Set new broadcast name", get_radio_name(), MAX_NAME_LEN))
	if(!str || QDELETED(src) || !user.is_holding(src))
		to_chat(user, span_warning("Invalid text!"))
		return
	if(radio_mode >= 1 && radio_mode <= 2 && radio_dj_owner)
		GLOB.ipod_cast_names[radio_mode] = str
		to_chat(user, span_notice("You set the broadcast name to '[str]'."))
		user.log_message("set the broadcast name to: [str]", LOG_GAME)
		return
	to_chat(user, span_notice("The connection to the broadcast fizzled out!"))

/obj/item/clothing/ears/ipod/click_alt(mob/user)
	if(isnull(user?.mind) || user.stat != CONSCIOUS || !is_worn)
		to_chat(user, span_warning("You can't do that right now."))
		return NONE
	var/new_volume = tgui_input_number(user, "", "Set volume", volume, 100)
	if(!isnum(new_volume) || QDELETED(user) || QDELETED(src))
		return NONE
	volume = new_volume
	music_player.set_new_volume(volume)
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/ears/ipod/proc/get_radio_name()
	if(radio_mode >= 1 && radio_mode <= 2)
		return GLOB.ipod_cast_names[radio_mode]
	return ""

/obj/item/clothing/ears/ipod/equipped(mob/living/user, slot)
	. = ..()
	is_worn = slot_flags & slot
	if(is_worn && !is_registered_on_death)
		RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(on_mob_death))
		is_registered_on_death = TRUE

/obj/item/clothing/ears/ipod/dropped(mob/living/carbon/human/user)
	. = ..()
	if(playing)
		playing = FALSE
		if(!isnull(music_player.active_song_sound))
			music_player.unlisten_all()
		update_icon()
		to_chat(user, span_notice("The headphones turn off and go into standby mode."))
	is_worn = FALSE
	if(is_registered_on_death)
		UnregisterSignal(user, COMSIG_LIVING_DEATH)
		is_registered_on_death = FALSE

/obj/item/clothing/ears/ipod/proc/on_mob_death(mob/living/source)
	SIGNAL_HANDLER
	if(playing)
		playing = FALSE
		if(!isnull(music_player.active_song_sound))
			music_player.unlisten_all()
		update_icon()
	UnregisterSignal(source, COMSIG_LIVING_DEATH)
	is_registered_on_death = FALSE

/datum/action/item_action/upload_ipod
	name = "Upload Track"
	desc = "Upload a track to your headphones"

/datum/action/item_action/toggle_ipod
	name = "Play Track"
	desc = "UNTZ UNTZ UNTZ"

/datum/action/item_action/upload_ipod/Trigger(trigger_flags)
	var/obj/item/clothing/ears/ipod/H = target
	if(istype(H) && !QDELETED(owner) && istype(owner))
		H.upload(owner)

/datum/action/item_action/toggle_ipod/Trigger(trigger_flags)
	var/obj/item/clothing/ears/ipod/H = target
	if(istype(H) && !QDELETED(owner) && istype(owner))
		H.toggle(owner)
