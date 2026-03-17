/obj/item/gun/ballistic/automatic/mps5
	name = "\improper MP-S5 VIG"
	desc = "A Nanotrasen security submachine gun, the MP-S5 was manufactured by Nanotrasen specifically to be \
		a rugged workhorse for station security. Though long since surpassed by other manufacturers, the VIG \
		remains a reliable standby in auxiliary armories and is still favored by veteran officers who trust \
		its no-nonsense performance. Chambered in 9x17mm."
	icon = 'modular_zzplurt/icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "mp5"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "arg"
	accepted_magazine_type = /obj/item/ammo_box/magazine/mps5
	fire_sound = 'modular_zzplurt/sound/items/weapons/gun/mp5_shot.ogg'
	burst_delay = 2
	can_suppress = FALSE
	burst_size = 1
	actions_types = list()
	mag_display = TRUE

/obj/item/gun/ballistic/automatic/mps5/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.23 SECONDS)

/obj/item/gun/ballistic/automatic/mps5/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/automatic/mps5/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 18, \
		overlay_y = 12)

/obj/item/gun/ballistic/automatic/wt458
	name = "\improper WT-458 Bullpup Rifle"
	desc = "Recalled by Nanotrasen due to public backlash around heat distribution resulting in unintended discombobulation. \
		This outcry was fabricated through various Syndicate-backed misinformation operations to force Nanotrasen to abandon \
		its ballistics weapon program, cornering them into the energy weapons market. Most often found today in the hands of pirates, \
		underfunded security personnel, cargo technicians, theoretical physicists, and gang bangers out on the rim. \
		Light-weight and fully automatic. Uses 4.6x30mm rounds."
	icon_state = "wt550"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "arg"
	accepted_magazine_type = /obj/item/ammo_box/magazine/wt550m9
	burst_delay = 2
	can_suppress = FALSE
	burst_size = 2
	fire_delay = 3.3
	actions_types = list()
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_indicator = TRUE

/obj/item/gun/ballistic/automatic/wt458/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/automatic/wt458/add_bayonet_point()
	AddComponent(/datum/component/bayonet_attachable, offset_x = 25, offset_y = 12)

/obj/item/gun/ballistic/automatic/wt458/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 18, \
		overlay_y = 12)
