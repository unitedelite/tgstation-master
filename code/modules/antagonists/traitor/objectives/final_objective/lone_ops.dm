/// The minimum number of ghosts and observers needed before handing out battlecruiser objectives.
#define MIN_GHOSTS_FOR_LONE 1

/datum/traitor_objective/final/lone_ops
	name = "Set beacons for a lone ops drop"
	description = "Insert special beacons card to two of the solar panel's trackers to \
	allow a syndicate operative drop. You may want to make your syndicate status known to \
	him when he arrive - your goal will then be to destroy the station."

	/// Checks whether we have sent the card to the traitor yet.
	var/sent_accesscard = FALSE

/datum/traitor_objective/final/lone_ops/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!can_take_final_objective())
		return FALSE
	// Check how many observers + ghosts (dead players) we have.
	// If there's not a ton of observers and ghosts to populate the battlecruiser,
	// We won't bother giving the objective out.
	var/num_ghosts = length(GLOB.current_observers_list) + length(GLOB.dead_player_list)
	if(num_ghosts < MIN_GHOSTS_FOR_LONE)
		return FALSE
	return TRUE

/datum/traitor_objective/final/lone_ops/on_objective_taken(mob/user)
	. = ..()


/datum/traitor_objective/final/lone_ops/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_accesscard)
		buttons += add_ui_button("", "Pressing this will materialize beacons, that you can use on solar panel's trackers.", "phone", "card")
	return buttons

/datum/traitor_objective/final/lone_ops/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("card")
			if(sent_accesscard)
				return
			sent_accesscard = TRUE
			var/obj/item/card/emag/lone_ops_obj/emag_card = new()
			podspawn(list(
				"target" = get_turf(user),
				"style" = STYLE_SYNDICATE,
				"spawn" = emag_card,
			))



/datum/antagonist/nukeop/lone/ally
	always_new_team = FALSE

/datum/antagonist/nukeop/lone/ally/on_gain()
	forge_objectives()
	memorize_code()
	add_team_hud(owner.current, /datum/antagonist/nukeop)

/obj/item/card/emag/lone_ops_obj
	name = "lone ops beacon emag card"
	desc = "An ominous card that contains the location of the station, and when applied to a solar panel array tracker the ability to stealthly start a syndicate lone operative drop."
	icon_state = "bug"
	icon_state = "battlecruisercaller"
	worn_icon_state = "battlecruisercaller"
	///whether we have called the battlecruiser
	var/used = 0

/obj/item/card/emag/lone_ops_obj/proc/use_charge(mob/user)
	used = used + 1
	if (used<2)
		to_chat(user, span_boldwarning("One solar panel array subverted. We need to subvert another one."))
	if (used == 2)
		start_mission(user)
		qdel(src)

/obj/item/card/emag/lone_ops_obj/examine(mob/user)
	. = ..()
	. += span_notice("It can only be used on the solar panel trackers.")

/obj/item/card/emag/lone_ops_obj/can_emag(atom/target, mob/user)
	if(!istype(target, /obj/machinery/power/tracker))
		to_chat(user, span_warning("[src] is unable to interface with this. It only seems to interface with solar array's solar tracker."))
		return FALSE
	return TRUE

/obj/item/card/emag/lone_ops_obj/proc/start_mission(mob/user)
	to_chat(user, span_boldwarning("Station found. Stealth drop pod in final aproach."))
	var/nukie_drop_success = spawn_ops()
	user.mind.add_antag_datum(/datum/antagonist/nukeop/lone/ally)
	if(nukie_drop_success)
		to_chat(user, span_boldwarning("The operation is a go! Time to join with the dropped operative and get that nuke disk."))
	else
		to_chat(user, span_boldwarning("The drop was a failure! The operative in probably dead or incapacited. You have be given 10 aditional TC. Try to cause the self destruction of the station alone."))
		user.mind.find_syndicate_uplink().add_telecrystals(10)
	
/obj/item/card/emag/lone_ops_obj/proc/spawn_ops()
	var/list/candidates = poll_ghost_candidates("Do you wish to be considered for the special role of Lone Operative'?", ROLE_OPERATIVE)

	if(!candidates.len)
		return FALSE
	shuffle_inplace(candidates)

	var/mob/dead/selected = pick_n_take(candidates)

	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
		spawn_locs += L.loc
	if(!spawn_locs.len)
		return FALSE

	var/mob/living/carbon/human/operative = new(pick(spawn_locs))
	operative.randomize_human_appearance(~RANDOMIZE_SPECIES)
	operative.dna.update_dna_identity()
	var/datum/mind/Mind = new /datum/mind(selected.key)
	Mind.set_assigned_role(SSjob.GetJobType(/datum/job/lone_operative))
	Mind.special_role = ROLE_LONE_OPERATIVE
	Mind.active = TRUE
	Mind.transfer_to(operative)
	Mind.add_antag_datum(/datum/antagonist/nukeop/lone)

	message_admins("[ADMIN_LOOKUPFLW(operative)] has been made into lone operative by a mission.")
	log_game("[key_name(operative)] was spawned as a lone operative by a mission.")
	return TRUE
#undef MIN_GHOSTS_FOR_LONE
