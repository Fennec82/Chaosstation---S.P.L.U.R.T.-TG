/datum/techweb_node/augmentation/New()
	var/list/extra_design_ids = list(
		"hypnoticmodule",
	)
	LAZYADD(design_ids, extra_design_ids)
	. = ..()
