GLOBAL_VAR_INIT(ipod_last_upload, 0) //last time of the last upload, to prevent multiple uploads within seconds of eachother
GLOBAL_VAR_INIT(ipod_last_play, 0) //last time of the last played track, to prevent spamming clients too often with play/stop

/obj/item/clothing/ears/ipod
	name = "\improper iZune Spaceman Headphones"
	desc = "An aftermarket Nanotrasen personal portable music player. This thing only supports OGG vorbis playback, rad!"
	icon = 'modular_skyrat/master_files/icons/obj/clothing/accessories.dmi'
	worn_icon = 'modular_skyrat/master_files/icons/mob/clothing/ears.dmi'
	icon_state = "headphones"
	inhand_icon_state = "headphones"
	slot_flags = ITEM_SLOT_EARS | ITEM_SLOT_HEAD | ITEM_SLOT_NECK		//Fluff item, put it whereever you want!
	actions_types = list(/datum/action/item_action/upload_ipod, /datum/action/item_action/toggle_ipod)
	custom_price = 60

	/// The current file path
	var/curfile
	/// Playing state
	var/playing = FALSE
	/// Time of the last upload
	var/lastfilechange = 0
	/// Time of the last upload attempt
	var/uploadattempt  = 0
	/// Current volume
	var/curvol = 100
	/// Currently worn
	var/is_worn = FALSE
	/// Shared listening mode
	var/datum/weakref/other_ipod_ref = null
	/// What actually plays music to us
	var/datum/jukebox/single_mob/music_player

/obj/item/clothing/ears/ipod/Initialize(mapload)
	. = ..()
	update_icon()
	AddElement(/datum/element/update_icon_updates_onmob)
	music_player = new(src)
	music_player.sound_loops = TRUE

/obj/item/clothing/ears/ipod/Destroy()
	if(playing && !isnull(music_player.active_song_sound))
		music_player.unlisten_all()
	playing = FALSE
	is_worn = FALSE
	stop_other_headphones(TRUE)
	QDEL_NULL(music_player)
	return ..()

/obj/item/clothing/ears/ipod/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)]_[playing? "on" : "off"]"
	inhand_icon_state = "[initial(inhand_icon_state)]_[playing? "on" : "off"]"

/obj/item/clothing/ears/ipod/examine(mob/user)
	. = ..()
	if(!other_ipod_ref)
		. += "Tapping this on another headphone will put it into shared listening mode!"
	else
		. += "This headphones is currently in shared listening mode!"

/obj/item/clothing/ears/ipod/proc/upload(owner)
	var/mob/user = owner
	if(user.stat != CONSCIOUS)
		to_chat(user, span_warning("You can't do that right now."))
		return
	if(loc != user)
		return
	if(!user.ckey)
		return
	if(playing)
		playing = FALSE
		if(!isnull(music_player.active_song_sound))
			music_player.unlisten_all()
	if(lastfilechange)
		if(world.time < lastfilechange + 3 MINUTES)
			say("You've uploaded a new track too recently, try again later!")
			return

	uploadattempt = world.time
	playsound(loc, 'sound/misc/menu/ui_select1.ogg', 100, FALSE, -1)
	var/infile = input(user, "CHOOSE A NEW SONG", src) as null|file

	if(world.time > uploadattempt + 30 SECONDS) // automatically cancel any attempt to upload if taken more than 30 seconds
		say("Your connect was timed out, try uploading again!")
		return

	if(world.time < GLOB.ipod_last_upload + 30 SECONDS)
		say("Another user has uploaded a new track recently, try again soon!")
		return

	if(loc != user)
		return
	if(playing)
		return
	if(isnull(infile))
		return
	if(!is_worn)
		return

	if(LOWER_TEXT(copytext("[infile]", -4)) != ".ogg")
		to_chat(user, span_warning("Filename must end in '.ogg': [infile]"))
		return
	if(length(infile) > 6485760)
		to_chat(user, span_warning("TOO BIG. 6MB OR LESS."))
		return

	if(fexists("data/ipodupload/[user.ckey]/upload.ogg"))
		fdel("data/ipodupload/[user.ckey]/upload.ogg")
	if(!fcopy(infile, "data/ipodupload/[user.ckey]/upload.ogg"))
		to_chat(user, span_warning("Could not upload song."))
		return
	curfile = file("data/ipodupload/[user.ckey]/upload.ogg")

	lastfilechange = world.time
	GLOB.ipod_last_upload = world.time

/obj/item/clothing/ears/ipod/proc/toggle(owner)
	var/mob/user = owner
	if(user.stat != CONSCIOUS)
		to_chat(user, span_warning("You can't do that right now."))
		return
	if(!playing)
		if(curfile)
			if(world.time < GLOB.ipod_last_play + 10 SECONDS)
				to_chat(user, span_warning("Headphones are buffering..."))
				return
			GLOB.ipod_last_play = world.time
			playing = TRUE
			music_player.selection.song_path = curfile
			music_player.selection.song_length = 12000 // 20 minutes to force a loop. File size determines server load, not audio length. Low bitrate .ogg files can run long and have their uses as ambient sound.
			music_player.start_music(user)
			play_other_headphones()
		else
			to_chat(user, span_warning("No track is currently uploaded."))
			return
	else
		playing = FALSE
		if(!isnull(music_player.active_song_sound))
			music_player.unlisten_all()
		stop_other_headphones()
	update_icon()
	to_chat(user, span_notice("You turn the music [playing? "on. Untz Untz Untz!" : "off."]"))

/obj/item/clothing/ears/ipod/proc/stop_other_headphones(do_unlink = FALSE)
	if(!other_ipod_ref)
		return
	var/obj/item/clothing/ears/ipod/other_ipod = other_ipod_ref.resolve()
	if(!QDELETED(other_ipod) && istype(other_ipod)) // other headphones ref is valid
		if(other_ipod.playing && !isnull(other_ipod.music_player.active_song_sound))
			other_ipod.music_player.unlisten_all()
		other_ipod.playing = FALSE
		other_ipod.update_icon()
		if(do_unlink)
			other_ipod.other_ipod_ref = null
	if(do_unlink)
		other_ipod_ref = null

/obj/item/clothing/ears/ipod/proc/play_other_headphones()
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
	if(other_ipod.playing && !isnull(other_ipod.music_player.active_song_sound))
		other_ipod.music_player.unlisten_all()
	GLOB.ipod_last_play = world.time
	other_ipod.playing = TRUE
	other_ipod.music_player.selection.song_path = other_ipod.curfile = curfile
	other_ipod.music_player.selection.song_length = 12000 // 20 minutes to force a loop. File size determines server load, not audio length. Low bitrate .ogg files can run long and have their uses as ambient sound.
	other_ipod.music_player.start_music(wearer)
	other_ipod.update_icon()

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
		other_ipod.other_ipod_ref = null
	other_ipod_ref = null

/obj/item/clothing/ears/ipod/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/clothing/ears/ipod))
		var/obj/item/clothing/ears/ipod/other_ipod
		if(other_ipod_ref) // if there exists a linked headphones, unlink it
			other_ipod = other_ipod_ref.resolve()
			if(!QDELETED(other_ipod) && istype(other_ipod)) // other headphones is valid
				other_ipod.unlink_refs()
		other_ipod = attacking_item
		other_ipod.unlink_refs()
		other_ipod_ref = WEAKREF(other_ipod)
		other_ipod.other_ipod_ref = WEAKREF(src)
		balloon_alert(user, "successfully linked headphones")
		return TRUE
	return ..()

/obj/item/clothing/ears/ipod/equipped(mob/living/user, slot)
	. = ..()
	is_worn = slot_flags & slot

/obj/item/clothing/ears/ipod/dropped(mob/living/carbon/human/user)
	. = ..()
	if(playing)
		playing = FALSE
		if(!isnull(music_player.active_song_sound))
			music_player.unlisten_all()
		update_icon()
		to_chat(user, span_notice("The headphones turn off and go into standby mode."))
	is_worn = FALSE

/datum/action/item_action/upload_ipod
	name = "Upload Track"
	desc = "Upload a track to your headphones"

/datum/action/item_action/toggle_ipod
	name = "Toggle Headphones"
	desc = "UNTZ UNTZ UNTZ"

/datum/action/item_action/upload_ipod/Trigger(trigger_flags)
	var/obj/item/clothing/ears/ipod/H = target
	if(istype(H) && !QDELETED(owner) && istype(owner))
		H.upload(owner)

/datum/action/item_action/toggle_ipod/Trigger(trigger_flags)
	var/obj/item/clothing/ears/ipod/H = target
	if(istype(H) && !QDELETED(owner) && istype(owner))
		H.toggle(owner)
