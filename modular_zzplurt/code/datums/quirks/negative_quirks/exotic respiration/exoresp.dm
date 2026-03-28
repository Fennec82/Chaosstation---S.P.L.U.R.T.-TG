/datum/quirk/equipping/lungs/bz
	name = "BZ Breather"
	desc = "You breathe BZ, even if you might not normally breathe it. Oxygen is poisonous."
	icon = FA_ICON_BIOHAZARD
	medical_record_text = "Patient can only breathe BZ."
	gain_text = "<span class='danger'>You suddenly have a hard time breathing anything but BZ."
	lose_text = "<span class='notice'>You suddenly feel like you aren't bound to BZ anymore."
	value = 0
	forced_items = list(
		/obj/item/clothing/mask/breath = list(ITEM_SLOT_MASK),
		/obj/item/tank/internals/bz/belt/full = list(ITEM_SLOT_HANDS, ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET))
	lungs_typepath = /obj/item/organ/lungs/exotic/bz
	breath_type = "BZ"

/datum/quirk/equipping/lungs/n2o
	name = "N2O Breather"
	desc = "You breathe N2O, even if you might not normally breathe it. Oxygen is poisonous."
	icon = FA_ICON_BIOHAZARD
	medical_record_text = "Patient can only breathe N2O."
	gain_text = "<span class='danger'>You suddenly have a hard time breathing anything but N2O."
	lose_text = "<span class='notice'>You suddenly feel like you aren't bound to N2O anymore."
	value = 0
	forced_items = list(
		/obj/item/clothing/mask/breath = list(ITEM_SLOT_MASK),
		/obj/item/tank/internals/n2o/belt/full = list(ITEM_SLOT_HANDS, ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET))
	lungs_typepath = /obj/item/organ/lungs/exotic/n2o
	breath_type = "N2O"

/datum/quirk/equipping/lungs/co2
	name = "CO2 Breather"
	desc = "You breathe CO2, even if you might not normally breathe it. Oxygen is poisonous."
	icon = FA_ICON_BIOHAZARD
	medical_record_text = "Patient can only breathe CO2."
	gain_text = "<span class='danger'>You suddenly have a hard time breathing anything but CO2."
	lose_text = "<span class='notice'>You suddenly feel like you aren't bound to CO2 anymore."
	value = 0
	forced_items = list(
		/obj/item/clothing/mask/breath = list(ITEM_SLOT_MASK),
		/obj/item/tank/internals/co2/belt/full = list(ITEM_SLOT_HANDS, ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET))
	lungs_typepath = /obj/item/organ/lungs/exotic/co2
	breath_type = "CO2"
