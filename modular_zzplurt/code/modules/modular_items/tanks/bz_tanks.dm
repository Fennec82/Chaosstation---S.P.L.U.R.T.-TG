// BZ tanks for BZ breathers, mainly for exotic respiration

/obj/item/tank/internals/bz
	name = "BZ tank"
	desc = "A small tank of BZ, for crew who don't breathe the standard air mix."
	icon = 'modular_zzplurt/icons/obj/canisters.dmi'
	icon_state = "bz"
	force = 10
	distribute_pressure = 16

/obj/item/tank/internals/bz/populate_gas()
	air_contents.assert_gas(/datum/gas/bz)
	air_contents.gases[/datum/gas/bz][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/bz/full/populate_gas()
	air_contents.assert_gas(/datum/gas/bz)
	air_contents.gases[/datum/gas/bz][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/bz/belt
	icon = 'modular_zzplurt/icons/obj/canisters.dmi'
	worn_icon = 'modular_skyrat/master_files/icons/mob/clothing/species/vox/belt.dmi'
	lefthand_file = 'modular_skyrat/master_files/icons/mob/inhands/equipment/tanks_lefthand.dmi'
	righthand_file = 'modular_skyrat/master_files/icons/mob/inhands/equipment/tanks_righthand.dmi'
	icon_state = "bz_extended"
	inhand_icon_state = "nitrogen"
	slot_flags = ITEM_SLOT_BELT
	force = 5
	volume = 12
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tank/internals/bz/belt/full/populate_gas()
	air_contents.assert_gas(/datum/gas/bz)
	air_contents.gases[/datum/gas/bz][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/bz/belt/emergency
	name = "emergency BZ tank"
	desc = "Used for emergencies. Contains very little BZ, so try to conserve it until you actually need it."
	icon_state = "bz"
	worn_icon_state = "nitrogen_extended"
	volume = 3

/obj/item/tank/internals/bz/belt/emergency/populate_gas()
	air_contents.assert_gas(/datum/gas/bz)
	air_contents.gases[/datum/gas/bz][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
