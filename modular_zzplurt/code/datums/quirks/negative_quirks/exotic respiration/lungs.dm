// defines a number of additional respiration types and their associated lungs for the purposes of the exotic respiration quirk
// see code/modules/surgery/organs/internal/lungs/_lungs.dm for a more exhaustive explanation of the code being repurposed here

#define RESPIRATION_BZ (1 << 3)
#define RESPIRATION_NITROUS (1 << 4)
#define RESPIRATION_CARBON (1 << 5)

/obj/item/organ/lungs
	var/safe_bz_min = 0
	var/safe_n2o_min = 0
	var/safe_co2_min = 0

/obj/item/organ/lungs/Initialize(mapload)
	. = ..()
	if(safe_bz_min)
		respiration_type |= RESPIRATION_BZ
		add_gas_reaction(/datum/gas/bz, always = PROC_REF(breathe_bz))
	if(safe_n2o_min)
		respiration_type |= RESPIRATION_NITROUS
		add_gas_reaction(/datum/gas/nitrous_oxide, always = PROC_REF(breathe_n2o))
	if(safe_co2_min)
		respiration_type |= RESPIRATION_CARBON
		add_gas_reaction(/datum/gas/carbon_dioxide, always = PROC_REF(breathe_co2))

// BZ is exchanged with CO2 just like oxygen
/obj/item/organ/lungs/proc/breathe_bz(mob/living/carbon/breather, datum/gas_mixture/breath, bz_pp, old_bz_pp)
	if(bz_pp < safe_bz_min && !HAS_TRAIT(breather, TRAIT_NO_BREATHLESS_DAMAGE))
		if(!HAS_TRAIT(breather, TRAIT_ANOSMIA))
			breather.throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
		var/gas_breathed = handle_suffocation(breather, bz_pp, safe_bz_min, breath.gases[/datum/gas/bz][MOLES])
		if(bz_pp)
			breathe_gas_volume(breath, /datum/gas/bz, /datum/gas/carbon_dioxide, volume = gas_breathed)
		return
	if(old_bz_pp < safe_bz_min)
		breather.failed_last_breath = FALSE
		breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
	breathe_gas_volume(breath, /datum/gas/bz, /datum/gas/carbon_dioxide)
	if(breather.health >= breather.crit_threshold && breather.oxyloss)
		breather.adjust_oxy_loss(-5)

// ditto line 20 but for N2O
/obj/item/organ/lungs/proc/breathe_n2o(mob/living/carbon/breather, datum/gas_mixture/breath, n2o_pp, old_n2o_pp)
	if(n2o_pp < safe_n2o_min && !HAS_TRAIT(breather, TRAIT_NO_BREATHLESS_DAMAGE))
		if(!HAS_TRAIT(breather, TRAIT_ANOSMIA))
			breather.throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
		var/gas_breathed = handle_suffocation(breather, n2o_pp, safe_n2o_min, breath.gases[/datum/gas/nitrous_oxide][MOLES])
		if(n2o_pp)
			breathe_gas_volume(breath, /datum/gas/nitrous_oxide, /datum/gas/carbon_dioxide, volume = gas_breathed)
		return
	if(old_n2o_pp < safe_n2o_min)
		breather.failed_last_breath = FALSE
		breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
	breathe_gas_volume(breath, /datum/gas/nitrous_oxide, /datum/gas/carbon_dioxide)
	if(breather.health >= breather.crit_threshold && breather.oxyloss)
		breather.adjust_oxy_loss(-5)

// CO2 is exchanged for... OXYGEN?! how can this be
/obj/item/organ/lungs/proc/breathe_co2(mob/living/carbon/breather, datum/gas_mixture/breath, co2_pp, old_co2_pp)
	if(co2_pp < safe_co2_min && !HAS_TRAIT(breather, TRAIT_NO_BREATHLESS_DAMAGE))
		if(!HAS_TRAIT(breather, TRAIT_ANOSMIA))
			breather.throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
		var/gas_breathed = handle_suffocation(breather, co2_pp, safe_co2_min, breath.gases[/datum/gas/carbon_dioxide][MOLES])
		if(co2_pp)
			breathe_gas_volume(breath, /datum/gas/carbon_dioxide, /datum/gas/oxygen, volume = gas_breathed)
		return
	if(old_co2_pp < safe_co2_min)
		breather.failed_last_breath = FALSE
		breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
	breathe_gas_volume(breath, /datum/gas/carbon_dioxide, /datum/gas/oxygen)
	if(breather.health >= breather.crit_threshold && breather.oxyloss)
		breather.adjust_oxy_loss(-5)

/obj/item/organ/lungs/exotic // parent type for exotic lungs
	name= "exotic lungs"
	desc = "Something about these lungs feels... poorly coded."
	safe_oxygen_min = 0
	safe_oxygen_max = 2
	oxy_damage_type = TOX // you take toxin damage rather than oxyloss, same as n2 breathers
	oxy_breath_dam_min = 6
	oxy_breath_dam_max = 20

/obj/item/organ/lungs/exotic/bz
	name = "BZ lungs"
	desc = "A set of lungs for breathing BZ."
	safe_bz_min = 16 // he needs hallucinogens to live
	BZ_trip_balls_min = 1e30
	BZ_brain_damage_min = 1e30

/obj/item/organ/lungs/exotic/n2o
	name = "nitrous oxide lungs"
	desc = "A set of lungs for breathing nitrous oxide."
	safe_n2o_min = 16
	n2o_detect_min = 1e30 // it would suck if your breathing gas put up a constant warning in the alert box
	n2o_para_min = 1e30 // or paralyzed you
	n2o_sleep_min = 1e30 // or knocked you out

/obj/item/organ/lungs/exotic/co2
	name = "carbon dioxide lungs"
	desc = "A set of lungs for breathing carbon dioxide."
	safe_co2_min = 16
	safe_co2_max = 0
