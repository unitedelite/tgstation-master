/obj/structure/closet/crate/syndicate
	var/frequency
	var/detonate_code
	var/ping_code
	var/obj/item/radio/radio //The crate radio to indicate it's position to syndicate agents

/obj/structure/closet/crate/syndicate/Initialize(mapload)
	. = ..()
	frequency = return_unused_frequency()
	ping_code = rand(1,50)
	detonate_code = rand(51,99)
	SSradio.add_object(src, frequency, RADIO_SIGNALER)

	radio = new/obj/item/radio(src)
	radio.keyslot = new /obj/item/encryptionkey/syndicate

	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, .proc/ping_crate_pod_drop)

/obj/structure/closet/crate/syndicate/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/structure/closet/crate/syndicate/receive_signal(datum/signal/signal)
	if(!signal)
		return
	if(signal.data["code"] == ping_code)
		ping_crate()
	if(signal.data["code"] == detonate_code)
		detonate_crate()

/obj/structure/closet/crate/syndicate/proc/ping_crate_pod_drop()
	if(istype(get_area(src), /area/centcom/supplypod/supplypod_temp_holding))
		return
	UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
	ping_crate()

/obj/structure/closet/crate/syndicate/proc/ping_crate()
	var/turf/T = get_turf(src)
	radio.set_frequency(FREQ_SYNDICATE)
	radio.talk_into(src, "Crate with frequency [frequency/10] Hz, ping code [ping_code] and detonation code [detonate_code] at [T.x],[T.y],[T.z] in [get_area(src)].", FREQ_SYNDICATE)

/obj/structure/closet/crate/syndicate/proc/detonate_crate()
	explosion(src, devastation_range = 0, heavy_impact_range = 1, light_impact_range = 3, flame_range = 3, flash_range = 3)


/obj/structure/closet/crate/syndicate/after_open(mob/living/user, force)
	. = ..()
	var/turf/T = get_turf(src)
	radio.set_frequency(FREQ_SYNDICATE)
	radio.talk_into(src, "Crate with frequency [frequency/10] Hz opened at [T.x],[T.y],[T.z] in [get_area(src)].", FREQ_SYNDICATE)
