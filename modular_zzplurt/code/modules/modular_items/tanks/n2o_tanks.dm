/*
 * N2O tanks for N2O breathers.
 */

/obj/item/tank/internals/n2o
	name = "N2O tank"
	desc = "A small tank of N2O, for crew who don't breathe the standard air mix."
	icon_state = "oxygen_fr"
	force = 10
	distribute_pressure = 16

/obj/item/tank/internals/n2o/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrous_oxide)
	air_contents.gases[/datum/gas/nitrous_oxide][MOLES] = (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/n2o/full/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrous_oxide)
	air_contents.gases[/datum/gas/nitrous_oxide][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/n2o/belt
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

/obj/item/tank/internals/n2o/belt/full/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrous_oxide)
	air_contents.gases[/datum/gas/nitrous_oxide][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/tank/internals/n2o/belt/emergency
	name = "emergency N2O tank"
	desc = "Used for emergencies. Contains very little N2O, so try to conserve it until you actually need it."
	icon_state = "nitrogen"
	worn_icon_state = "nitrogen_extended"
	volume = 3

/obj/item/tank/internals/n2o/belt/emergency/populate_gas()
	air_contents.assert_gas(/datum/gas/nitrous_oxide)
	air_contents.gases[/datum/gas/nitrous_oxide][MOLES] = (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)
