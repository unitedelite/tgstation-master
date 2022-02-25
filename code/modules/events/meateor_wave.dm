/datum/round_event_control/meteor_wave/meaty
	name = "Meteor Wave: Meaty"
	typepath = /datum/round_event/meteor_wave/meaty
	weight = 2
	max_occurrences = 1

/datum/round_event/meteor_wave/meaty
	wave_name = "meaty"

/datum/round_event/meteor_wave/meaty/announce(fake)
	priority_announce("Meaty ores have been detected on collision course with the station.", "Oh crap, get the mop.", ANNOUNCER_METEORS)

/datum/round_event_control/meteor_wave/meaty/small
	name = "Meteor Wave: Small Meaty"
	typepath = /datum/round_event/meteor_wave/meaty/small
	min_players = 12

/datum/round_event/meteor_wave/meaty/small
	strength = 2


/datum/round_event_control/meteor_wave/meaty/tiny
	name = "Meteor Wave: Tiny Meaty"
	min_players = 9
	typepath = /datum/round_event/meteor_wave/meaty/tiny


/datum/round_event/meteor_wave/meaty/tiny
	strength = 1
