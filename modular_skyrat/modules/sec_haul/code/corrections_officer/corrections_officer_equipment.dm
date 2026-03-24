/obj/item/clothing/under/rank/security/corrections_officer
	desc = "A white satin shirt with some bronze rank pins at the neck."
	name = "corrections officer's suit"
	icon = 'modular_skyrat/master_files/icons/obj/clothing/under/security.dmi'
	worn_icon = 'modular_skyrat/master_files/icons/mob/clothing/under/security.dmi'
	icon_state = "corrections_officer"
	armor_type = /datum/armor/clothing_under/security_corrections_officer
	can_adjust = FALSE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/datum/armor/clothing_under/security_corrections_officer
	melee = 10

/obj/item/clothing/under/rank/security/corrections_officer/skirt
	desc = "A white satin shirt with some bronze rank pins at the neck."
	name = "corrections officer's skirt"
	icon_state = "corrections_officerw"

/obj/item/clothing/under/rank/security/corrections_officer/sweater
	desc = "A black combat sweater thrown over the standard issue shirt, perfect for wake up calls."
	name = "corrections officer's sweater"
	icon_state = "corrections_officer_sweat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/corrections_officer/sweater/skirt
	icon_state = "corrections_officer_sweatw"

/obj/item/radio/headset/corrections_officer
	name = "\proper corrections officer's headset"
	icon_state = "sec_headset"
	keyslot = new /obj/item/encryptionkey/headset_sec

/obj/item/clothing/suit/armor/vest/secjacket/corrections_officer //SPLURT EDIT, ORIGINAL: /obj/item/clothing/suit/toggle/jacket/corrections_officer
	name = "corrections officer's suit jacket"
	desc = "A pressed and ironed suit jacket, it has light armor against stabbings. There's some rank badges on the right breast."
	icon = 'modular_skyrat/master_files/icons/obj/clothing/suits.dmi'
	worn_icon = 'modular_skyrat/master_files/icons/mob/clothing/suit.dmi'
	icon_state = "co_coat"

//SPLURT ADDITION START
/obj/item/clothing/suit/armor/vest/secjacket/corrections_officer/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, mutant_styles = NONE)
	// Keep co_coat visuals while using an emissive state that actually exists.
	. = list()
	if(blocks_emissive != EMISSIVE_BLOCK_NONE)
		. += emissive_blocker(standing.icon, standing.icon_state, src)
	SEND_SIGNAL(src, COMSIG_ITEM_GET_WORN_OVERLAYS, ., standing, isinhands, icon_file)

	if(!isinhands)
		. += emissive_appearance('icons/mob/clothing/suits/armor.dmi', "secjacket-emissive", src, alpha = src.alpha, effect_type = EMISSIVE_SPECULAR)

	if(isinhands)
		return

	if(damaged_clothes)
		var/damagefile2use = (mutant_styles & STYLE_TAUR_ALL) ? 'modular_skyrat/master_files/icons/mob/64x32_item_damage.dmi' : 'icons/effects/item_damage.dmi'
		. += mutable_appearance(damagefile2use, "damaged[blood_overlay_type]")
	if(GET_ATOM_BLOOD_DNA_LENGTH(src))
		var/bloodfile2use = (mutant_styles & STYLE_TAUR_ALL) ? 'modular_skyrat/master_files/icons/mob/64x32_blood.dmi' : 'icons/effects/blood.dmi'
		. += mutable_appearance(bloodfile2use, "[blood_overlay_type]blood")

	var/mob/living/carbon/human/wearer = loc
	if(!ishuman(wearer) || !wearer.w_uniform)
		return
	var/obj/item/clothing/under/undershirt = wearer.w_uniform
	if(!istype(undershirt) || !LAZYLEN(undershirt.attached_accessories))
		return

	var/obj/item/clothing/accessory/displayed = undershirt.attached_accessories[1]
	if(displayed.above_suit && undershirt.accessory_overlay)
		. += undershirt.accessory_overlay
//SPLURT ADDITION END

// LOCKER
/*SPLURT DELETION START
/datum/armor/jacket_corrections_officer
	melee = 10
	melee = 10
SPLURT DELETION END */
/obj/structure/closet/secure_closet/corrections_officer
	name = "corrections officer riot gear"
	icon = 'modular_skyrat/master_files/icons/obj/closet.dmi'
	icon_state = "riot"
	door_anim_time = 0 //Somebody resprite or remove this 'riot' locker. It's evil.

/obj/structure/closet/secure_closet/corrections_officer/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/riot(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/clothing/shoes/jackboots/peacekeeper(src)
	new /obj/item/clothing/head/helmet/toggleable/riot(src)
	new /obj/item/shield/riot(src)
	new /obj/item/clothing/under/rank/security/corrections_officer(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src) //SPLURT ADDITION
