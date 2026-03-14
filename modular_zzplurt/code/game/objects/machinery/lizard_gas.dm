/obj/item/circuitboard/machine/lizard_gas_colonial
	name = "Colonial Marine Resequencer"
	build_path = /obj/machinery/biogenerator/lizard_gas_colonial
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/servo = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/machinery/biogenerator/lizard_gas_colonial
	name = "Colonial Marine Resequencer"
	desc = "A derivative of the Type 34 'Colonial Supply Core,' colloquially known as the 'Gencrate/CSC'. \
		The Gencrate is at its core a matter resequencer, a highly specialized subtype of biogenerator which performs a sort of transmutation using organic \
		compounds; normally from large-scale crops or waste product. This one has been heavily modified to focus on making clothing, accessories, and also \
		a variety, of materials to make up for the unreliable rate of deliveries to Lizard's Gas, at the cost of not being able to make the other items it \
		is well known for producing."
	icon = 'icons/obj/machines/biogenerator.dmi'
	circuit = /obj/machinery/biogenerator/lizard_gas_colonial
	anchored = FALSE
	efficiency = 1
	productivity = 1
	max_items = 35
	show_categories = list(
		RND_CATEGORY_CMR_APPAREL,
		RND_CATEGORY_CMR_EQUIPMENT,
		RND_CATEGORY_CMR_MATERIALS,
	)

/obj/item/circuitboard/machine/lizard_gas_medvendor
	name = "DeForest Brand Bio-Regenerator"
	build_path = /obj/machinery/biogenerator/lizard_gas_medvendor
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/servo = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/machinery/biogenerator/lizard_gas_medvendor
	name = "DeForest Brand Bio-Regenerator"
	desc = "An advanced machine seen in frontier outposts and colonies capable of turning organic plant matter into \
		various emergency medical supplies and injectors. This one has been customized to provide for the harsh needs \
		of lavaland, mostly in the hopes of being able to sell the products to those who travel through it."
	icon = 'icons/obj/machines/biogenerator.dmi'
	circuit = /obj/machinery/biogenerator/lizard_gas_medvendor
	anchored = FALSE
	efficiency = 1
	productivity = 1
	max_items = 35
	show_categories = list(
		RND_CATEGORY_DFBBR_MEDICAL,
		RND_CATEGORY_DFBBR_MEDICINE,
		RND_CATEGORY_DFBBR_INJECTORS,
		RND_CATEGORY_DEFOREST_BLOOD,
	)

/obj/item/circuitboard/machine/lizard_gas_smartfridge
	name = "SmartFridge Organic Fabricator"
	build_path = /obj/machinery/biogenerator/lizard_gas_smartfridge
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/servo = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/machinery/biogenerator/lizard_gas_smartfridge
	name = "SmartFridge Organic Fabricator"
	desc = "An advanced machine seen in frontier outposts and colonies capable of turning organic plant matter into \
		various foods or ingredients. The best friend of a chef where deliveries are inconsistent or simply don't exist. \
		This model has been customized for the day-to-day operations of a gas station, it contains an expanded stock of \
		items, and ready to cook ingredients for serving customers on the spot, gas station quality guaranteed."
	icon = 'icons/obj/machines/biogenerator.dmi'
	circuit = /obj/machinery/biogenerator/lizard_gas_smartfridge
	anchored = FALSE
	efficiency = 1
	productivity = 1
	max_items = 35
	show_categories = list(
		RND_CATEGORY_SFOF_INGREDIENT,
		RND_CATEGORY_SFOF_CONDIMENTS,
		RND_CATEGORY_SFOF_CONSUMABLES,
		RND_CATEGORY_SFOF_LUXURIES,
		RND_CATEGORY_AKHTER_FOODRICATOR_UTENSILS,
	)
