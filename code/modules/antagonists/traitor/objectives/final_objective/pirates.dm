#define MIN_GHOSTS_FOR_PIRATES 2

/datum/traitor_objective/final/hack_comm_console_pirates
	name = "Hack a communication console to send the station coordinates to a nearby pirate ship."
	description = "Right click on a communication console to begin the hacking process. Once started, \
	the AI will know that you are hacking a communication console, so be ready to run or have yourself \
	disguised to prevent being caught. The pirates are not aware of your presence on the station."

/datum/traitor_objective/final/hack_comm_console_pirates/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!can_take_final_objective())
		return
	if(SStraitor.get_taken_count(/datum/traitor_objective/final/hack_comm_console_pirates) > 0)
		return FALSE
	// Check how many observers + ghosts (dead players) we have.
	// If there's not a ton of observers and ghosts to populate the battlecruiser,
	// We won't bother giving the objective out.
	var/num_ghosts = length(GLOB.current_observers_list) + length(GLOB.dead_player_list)
	if(num_ghosts < MIN_GHOSTS_FOR_PIRATES)
		return FALSE
	AddComponent(/datum/component/traitor_objective_mind_tracker, generating_for, \
		signals = list(COMSIG_HUMAN_EARLY_UNARMED_ATTACK = .proc/on_unarmed_attack))
	RegisterSignal(generating_for, COMSIG_GLOB_TRAITOR_OBJECTIVE_COMPLETED, .proc/on_global_obj_completed)
	return TRUE

/datum/traitor_objective/final/hack_comm_console_pirates/proc/on_global_obj_completed(datum/source, datum/traitor_objective/objective)
	SIGNAL_HANDLER
	if(istype(objective, /datum/traitor_objective/final/hack_comm_console_pirates))
		fail_objective()

/datum/traitor_objective/final/hack_comm_console_pirates/proc/on_unarmed_attack(mob/user, obj/machinery/computer/communications/target, proximity_flag, modifiers)
	SIGNAL_HANDLER
	if(!proximity_flag)
		return
	if(!modifiers[RIGHT_CLICK])
		return
	if(!istype(target))
		return
	INVOKE_ASYNC(src, .proc/begin_hack, user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/traitor_objective/final/hack_comm_console_pirates/proc/begin_hack(mob/user, obj/machinery/computer/communications/target)
	target.AI_notify_hack()
	if(!do_after(user, 30 SECONDS, target))
		return
	succeed_objective()
	target.hack_console_custom(user, list(HACK_PIRATE))

#undef MIN_GHOSTS_FOR_PIRATES