// Normal strength

/datum/round_event_control/meteor_wave
	name = "Meteor Wave: Normal"
	typepath = /datum/round_event/meteor_wave
	weight = 4
	min_players = 14
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/meteor_wave
	startWhen = 15
	endWhen = 45
	announceWhen = 1
	var/strength = 3
	var/list/wave_type
	var/wave_name = "normal"

/datum/round_event/meteor_wave/New()
	..()
	if(!wave_type)
		determine_wave_type()

/datum/round_event/meteor_wave/proc/determine_wave_type()
	if(!wave_name)
		wave_name = pick_weight(list(
			"normal" = 50,
			"threatening" = 40,
			"catastrophic" = 10))
	switch(wave_name)
		if("normal")
			wave_type = GLOB.meteors_normal
		if("threatening")
			wave_type = GLOB.meteors_threatening
		if("catastrophic")
			if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
				wave_type = GLOB.meteorsSPOOKY
			else
				wave_type = GLOB.meteors_catastrophic
		if("meaty")
			wave_type = GLOB.meteorsB
		if("space dust")
			wave_type = GLOB.meteorsC
		if("halloween")
			wave_type = GLOB.meteorsSPOOKY
		else
			WARNING("Wave name of [wave_name] not recognised.")
			kill()

/datum/round_event/meteor_wave/announce(fake)
	priority_announce("A large number of meteors have been detected on collision course with the station. All personnel is required to help prevent life suport faillure. It is recommended to power down the SM.", "Meteor Alert", ANNOUNCER_METEORS)
	if(SSsecurity_level.current_level < SEC_LEVEL_BLUE)
		set_security_level(SEC_LEVEL_BLUE)
	make_maint_all_access()

/datum/round_event/meteor_wave/tick()
	if(ISMULTIPLE(activeFor, 3))
		spawn_meteors(strength, wave_type) //meteor list types defined in gamemode/meteor/meteors.dm

/datum/round_event_control/meteor_wave/threatening
	name = "Meteor Wave: Threatening"
	typepath = /datum/round_event/meteor_wave/threatening
	min_players = 18
	max_occurrences = 1
	earliest_start = 35 MINUTES

/datum/round_event/meteor_wave/threatening
	wave_name = "threatening"

/datum/round_event_control/meteor_wave/catastrophic
	name = "Meteor Wave: Catastrophic"
	typepath = /datum/round_event/meteor_wave/catastrophic
	min_players = 22
	max_occurrences = 1
	earliest_start = 45 MINUTES

/datum/round_event/meteor_wave/catastrophic
	wave_name = "catastrophic"

// Small strength

/datum/round_event_control/meteor_wave/small
	name = "Meteor Wave: Small Normal"
	typepath = /datum/round_event/meteor_wave/small
	weight = 5
	min_players = 12
	max_occurrences = 2
	earliest_start = 20 MINUTES

/datum/round_event/meteor_wave/small
	wave_name = "normal"
	strength = 2

/datum/round_event/meteor_wave/small/announce(fake)
	priority_announce("Meteors have been detected on collision course with the station. It is recommended to power down the SM.", "Meteor Alert", ANNOUNCER_METEORS)
	if(SSsecurity_level.current_level < SEC_LEVEL_BLUE)
		set_security_level(SEC_LEVEL_BLUE)

/datum/round_event_control/meteor_wave/small/threatening
	name = "Meteor Wave: Small Threatening"
	typepath = /datum/round_event/meteor_wave/small/threatening
	min_players = 14
	earliest_start = 30 MINUTES

/datum/round_event/meteor_wave/small/threatening
	wave_name = "threatening"

/datum/round_event_control/meteor_wave/small/catastrophic
	name = "Meteor Wave: Small Catastrophic"
	typepath = /datum/round_event/meteor_wave/small/catastrophic
	min_players = 18
	earliest_start = 40 MINUTES

/datum/round_event/meteor_wave/small/catastrophic
	wave_name = "catastrophic"

// Tiny strength

/datum/round_event_control/meteor_wave/tiny
	name = "Meteor Wave: Tiny Normal"
	typepath = /datum/round_event/meteor_wave/tiny
	weight = 6
	min_players = 9
	max_occurrences = 3
	earliest_start = 10 MINUTES

/datum/round_event/meteor_wave/tiny
	wave_name = "normal"
	strength = 1

/datum/round_event/meteor_wave/tiny/announce(fake)
	priority_announce("A few stray meteors have been detected on collision course with the station.", "Meteor Alert", ANNOUNCER_METEORS)

/datum/round_event_control/meteor_wave/tiny/threatening
	name = "Meteor Wave: Tiny Threatening"
	typepath = /datum/round_event/meteor_wave/tiny/threatening
	min_players = 11
	earliest_start = 20 MINUTES

/datum/round_event/meteor_wave/tiny/threatening
	wave_name = "threatening"

/datum/round_event_control/meteor_wave/tiny/catastrophic
	name = "Meteor Wave: Tiny Catastrophic"
	typepath = /datum/round_event/meteor_wave/tiny/catastrophic
	min_players = 13
	earliest_start = 30 MINUTES

/datum/round_event/meteor_wave/tiny/catastrophic
	wave_name = "catastrophic"