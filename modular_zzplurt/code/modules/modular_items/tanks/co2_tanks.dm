/*
 * CO2 tanks for CO2 breathers.
 */

/obj/item/tank/internals/co2
	name = "CO2 tank"
	desc = "A small tank of CO2, for crew who don't breathe the standard air mix."
	icon_state = "oxygen_fr"
	force = 10
	distribute_pressure = 8

/obj/item/tank/internals/co2/populate_gas()
	air_contents.assert_gas(/datum/gas/carbon_dioxide)
	air_contents.gases[/datum/gas/carbon_dioxide][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/co2/full/populate_gas()
	air_contents.assert_gas(/datum/gas/carbon_dioxide)
	air_contents.gases[/datum/gas/carbon_dioxide][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/co2/belt
	icon = 'modular_skyrat/master_files/icons/obj/tank.dmi'
	worn_icon = 'modular_skyrat/master_files/icons/mob/clothing/species/vox/belt.dmi'
	lefthand_file = 'modular_skyrat/master_files/icons/mob/inhands/equipment/tanks_lefthand.dmi'
	righthand_file = 'modular_skyrat/master_files/icons/mob/inhands/equipment/tanks_righthand.dmi'
	icon_state = "nitrogen_extended"
	inhand_icon_state = "nitrogen"
	slot_flags = ITEM_SLOT_BELT
	force = 5
	volume = 12
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tank/internals/co2/belt/full/populate_gas()
	air_contents.assert_gas(/datum/gas/carbon_dioxide)
	air_contents.gases[/datum/gas/carbon_dioxide][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/co2/belt/emergency
	name = "emergency CO2 tank"
	desc = "Used for emergencies. Contains very little CO2, so try to conserve it until you actually need it."
	icon_state = "nitrogen"
	worn_icon_state = "nitrogen_extended"
	volume = 3

/obj/item/tank/internals/co2/belt/emergency/populate_gas()
	air_contents.assert_gas(/datum/gas/carbon_dioxide)
	air_contents.gases[/datum/gas/carbon_dioxide][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
