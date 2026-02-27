// Makes Ore Silos fire- and acid-proof, and increases their durability. //
/obj/machinery/ore_silo
	desc = "An all-in-one bluespace storage and transmission system for the station's mineral distribution needs. It appears to be extremely robust."
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 500

/obj/machinery/ore_silo/away
	var/network_id = null
	/// Whether this silo should auto-link to machines on its z-level
	var/auto_link_same_z = FALSE

	/// Types that are allowed to auto-link
	var/list/auto_link_types = list(
	/obj/machinery/rnd/production/protolathe,
	/obj/machinery/rnd/production/circuit_imprinter,
	/obj/machinery/rnd/production/techfab
	)

	/// How often to rescan (in deciseconds)
	var/auto_link_interval = 50

/obj/machinery/ore_silo/away/Initialize(mapload)
	. = ..()

	if(network_id)
		addtimer(CALLBACK(src, PROC_REF(link_network)), 1)

	if(mapload)
		GLOB.ore_silo_default = src

/obj/machinery/ore_silo/away/proc/link_network()
	var/list/network = GLOB.ore_silo_networks[network_id]
	if(!network)
		return

	for(var/datum/component/remote_materials/R as anything in network)
		if(!R.silo && R.parent)
			connect_receptacle(R, R.parent)

/datum/component/remote_materials/networked
	var/network_id = null

/datum/component/remote_materials/networked/Initialize(...)
	. = ..()

	if(network_id)
		if(!GLOB.ore_silo_networks[network_id])
			GLOB.ore_silo_networks[network_id] = list()

		GLOB.ore_silo_networks[network_id] += src

		try_link_to_silo()

/datum/component/remote_materials/networked/proc/try_link_to_silo()
	for(var/obj/machinery/ore_silo/away/S in world)
		if(S.network_id == network_id)
			if(!src.silo && src.parent)
				S.connect_receptacle(src, src.parent)

/datum/component/remote_materials/networked/Destroy()
	if(network_id && GLOB.ore_silo_networks[network_id])
		GLOB.ore_silo_networks[network_id] -= src

	return ..()

/obj/machinery/ore_silo/away/shuttle
	name = "shuttle ore silo"
	desc = "An all-in-one bluespace storage and transmission system for the station's mineral distribution needs. Configured to automatically link with onboard fabrication equipment. It appears to be extremely robust."

	auto_link_same_z = TRUE
	ID_required = FALSE
