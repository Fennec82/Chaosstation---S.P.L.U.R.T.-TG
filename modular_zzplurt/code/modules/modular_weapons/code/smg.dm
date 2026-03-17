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
	desc = "A 2-rounds burst rifle fielded by Nanotrasen Naval Infantry, it is no longer in use as space combat required higher rate of fire, and this did not meet that demands.\
		leading to this gun being slowly de-serviced. However, this weapon is exceptionally useful in close range and in maintenance tunnel of Nanotrasen\
		Light-weight and can be fired one handed. Uses 4.6x30mm rounds."
	icon = 'modular_zzplurt/icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "wt458"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "arg"
	accepted_magazine_type = /obj/item/ammo_box/magazine/wt550m9
	burst_delay = 2
	can_suppress = FALSE
	burst_size = 2
	fire_delay = 3.3
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_indicator = TRUE
	fire_sound = 'modular_zzplurt/sound/items/weapons/gun/wt458_shot.ogg'
//Gunshot is taken from this  https://github.com/ParadiseSS13/Paradise/tree/master/sound/weapons/gunshots#gunshot_rifle.ogg
//However, I could not find who it was attributed to or where it comes from

/obj/item/gun/ballistic/automatic/wt458/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/examine_lore, \
		lore_hint = span_notice("You can [EXAMINE_HINT("look closer")] to learn a little more about [src]."), \
		lore = "The WT-458 is a one-of-a-kind select fire 2 round bursts firearm chambered in low power cartridges.<br>\
		2-rounds burst was chosen for close quarter combat back when it was common for any particular force to actually occupy and hold any station they captured, rather than destroying it with a nuclear device.\
		<br>\
		This particular design suffered from the same issue as the RTA Prototype CMG, \
		Nanotrasen also struggled to come to terms with the new way of mass-producing ballistic weapons. The precision parts of the Romulus Technology and the Solarian First Expedition Company (its predecessor) were machined by hand out of solid metal. \
		with the other parts made of wood. However, the new method was performed by pressing together thin sheets of steel with a stamping machine that would then weld the parts together as it went\
		Even though the small caliber this uses makes this more of a pistol-caliber carbine than any assault rifle, countless arguments in both the marketing office \
		and the corporate boardroom about the name meant that something had to give; in this case, the RnD team was ruled in favour of rather than against.<br>\
		<br>\
		It's hard to cover up everything about its troubled development, though.<br>\
		<br>\
		Originally in production by Romulus Technology under the name PDW Mk1 right after the success of the CMG. People that were in charge were demanding tolerances from plastic moulding that could really only be achieved by the precision of being carved from solid steel.  \
		This weapon has a straight blowback system and ejects the round vertically down safetly behind the user, unlike the Prototype CMG which ejected casing directly into the shoulder of the user should they be left handed (Although this was addressed by making the rifle a caseless flechette launcher),\
		The CMG does not exist anymore due to the systematic eradication of the company workers, leaving this the few surviving design from those time.\
		Nanotrasen RND Department have been unable to mass-produce proper intermediate cartridges. With any rifle properly chambered in such caliber only reserved for the Military Branch \
		Despite this, the existence of this weapon was a testament to the creativity of the people working for this company." \
	)
	register_context()
//To whom it may concerns, Yes, this lore is essentially just me  venting out my frustration with working on the CMG for TG which was supposed to be done back in 2025
//However the design requirement vs what I actually want got really complicated and we could not finalise it.

/obj/item/gun/ballistic/automatic/wt458/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_NANOTRASEN)

/obj/item/gun/ballistic/automatic/wt458/add_bayonet_point()
	AddComponent(/datum/component/bayonet_attachable, offset_x = 25, offset_y = 2)

/obj/item/gun/ballistic/automatic/wt458/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 22, \
		overlay_y = 12)
