//For managing designs for splurt borg upgrades
/datum/techweb_node/augmentation/New()
	. = ..()
	// Removes the shrink and expander from the pool of designs the crew can print, used so there's only one option to use for resizing rather than commenting out those lines of code
	design_ids -= list(
		"borg_upgrade_expand",
		"borg_upgrade_shrink"
	)
	// Adds the borg_upgrade_resize to the design pool.
	design_ids += list(
		"borg_upgrade_resize",
		"hypnoticmodule", //This one isn't actually related to the resizer but this
	)
