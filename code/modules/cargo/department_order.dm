
///cooldown for each department, assoc type 2 cooldown. global, so rebuilding the console doesn't refresh the cd
GLOBAL_LIST_INIT(department_order_cooldowns, list(
	/obj/machinery/computer/department_orders/service = 0,
	/obj/machinery/computer/department_orders/engineering = 0,
	/obj/machinery/computer/department_orders/science = 0,
	/obj/machinery/computer/department_orders/security = 0,
	/obj/machinery/computer/department_orders/medical = 0,
))

/obj/machinery/computer/department_orders
	name = "department order console"
	desc = "Used to order supplies for a department. Crates ordered this way will be locked until they reach their destination."
	icon_screen = "supply"
	light_color = COLOR_BRIGHT_ORANGE
	///reference to the order we've made UNTIL it gets sent on the supply shuttle. this is so heads can cancel it
	var/datum/supply_order/department_order
	///access required to override an order - this should be a head of staff for the department
	var/override_access
	///where this computer expects deliveries to need to go, passed onto orders. it will see if the FIRST one exists, then try a fallback. if no fallbacks it throws an error
	var/list/department_delivery_areas = list()
	///which groups this computer can order from
	var/list/dep_groups = list()
	var/department_destination_name = NONE

/obj/machinery/computer/department_orders/Initialize(mapload, obj/item/circuitboard/board)
	. = ..()

/obj/machinery/computer/department_orders/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DepartmentOrders")
		ui.open()

/obj/machinery/computer/department_orders/ui_data(mob/user)
	var/list/data = list()
	var/cooldown = GLOB.department_order_cooldowns[type] - world.time
	if(cooldown < 0)
		data["time_left"] = 0
	else
		data["time_left"] = DisplayTimeText(cooldown, 1)
	data["can_override"] = department_order ? TRUE : FALSE
	return data

/obj/machinery/computer/department_orders/ui_static_data(mob/user)
	var/list/data = list()
	var/list/supply_data = list() //each item in this needs to be a Category
	for(var/pack_key in SSshuttle.supply_packs)
		var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_key]
		//skip groups we do not offer
		if(!(pack.group in dep_groups))
			continue
		//find which group this belongs to, make the group if it doesn't exist
		var/list/target_group
		for(var/list/possible_group in supply_data)
			if(possible_group["name"] == pack.group)
				target_group = possible_group
				break
		if(!target_group)
			target_group = list(
				"name" = pack.group,
				"packs" = list(),
			)
			supply_data += list(target_group)
		//skip packs we should not show, even if we should show the group
		if((pack.hidden && !(obj_flags & EMAGGED)) || (pack.special && !pack.special_enabled) || pack.DropPodOnly || pack.goody)
			continue
		//finally the pack data itself
		target_group["packs"] += list(list(
			"name" = pack.name,
			"cost" = pack.get_cost(),
			"id" = pack.id,
			"desc" = pack.desc || pack.name, // If there is a description, use it. Otherwise use the pack's name.
		))
	data["supplies"] = supply_data
	return data

/obj/machinery/computer/department_orders/ui_act(action, list/params)
	. = ..()

	if(!isliving(usr))
		return
	var/mob/living/orderer = usr

	var/obj/item/card/id/id_card = orderer.get_idcard(hand_first = TRUE)

	//needs to come BEFORE preventing actions!
	if(action == "override_order")
		if(!(override_access in id_card.GetAccess()))
			balloon_alert(usr, "requires head of staff access!")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
			return

		if(department_order && (department_order in SSshuttle.shoppinglist))
			GLOB.department_order_cooldowns[type] = 0
			SSshuttle.shoppinglist -= department_order
			department_order = null
			UnregisterSignal(SSshuttle, COMSIG_SUPPLY_SHUTTLE_BUY)
		return TRUE

	if(GLOB.department_order_cooldowns[type] > world.time)
		return

	if(!check_access(id_card))
		balloon_alert(usr, "access denied!")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		return

	. = TRUE
	var/id = text2path(params["id"])
	var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
	if(!pack)
		say("Something went wrong!")
		CRASH("requested supply pack id \"[id]\" not found!")
	var/name = "*None Provided*"
	var/rank = "*None Provided*"
	var/ckey = usr.ckey
	if(ishuman(usr))
		var/mob/living/carbon/human/human_orderer = usr
		name = human_orderer.get_authentification_name()
		rank = human_orderer.get_assignment(hand_first = TRUE)
	else if(issilicon(usr))
		name = usr.real_name
		rank = "Silicon"
	//already have a signal to finalize the order
	var/already_signalled = department_order ? TRUE : FALSE
	department_order = new(pack, name, rank, ckey, "", null, department_delivery_areas, null, department_destination_name=department_destination_name)
	SSshuttle.shoppinglist += department_order
	if(!already_signalled)
		RegisterSignal(SSshuttle, COMSIG_SUPPLY_SHUTTLE_BUY, .proc/finalize_department_order)
	say("Order processed. Cargo will deliver the crate when it comes in on their shuttle. NOTICE: Heads of staff may override the order.")
	calculate_cooldown(pack.cost)

///signal when the supply shuttle begins to spawn orders. we forget the current order preventing it from being overridden (since it's already past the point of no return on undoing the order)
/obj/machinery/computer/department_orders/proc/finalize_department_order(datum/subsystem)
	SIGNAL_HANDLER
	if(department_order && (department_order in SSshuttle.shoppinglist))
		department_order = null
	UnregisterSignal(subsystem, COMSIG_SUPPLY_SHUTTLE_BUY)

/obj/machinery/computer/department_orders/proc/calculate_cooldown(credits)
	//minimum almost the lowest value of a crate
	var/min = CARGO_CRATE_VALUE * 1.6
	//maximum fairly expensive crate at 3000
	var/max = CARGO_CRATE_VALUE * 15
	credits = clamp(credits, min, max)
	var/time_y = (credits - min)/(max - min) + 1 //convert to between 1 and 2
	time_y = 10 MINUTES * time_y
	GLOB.department_order_cooldowns[type] = world.time + time_y

/obj/machinery/computer/department_orders/service
	name = "service order console"
	circuit = /obj/item/circuitboard/computer/service_orders
	department_delivery_areas = list(
		/area/hallway/secondary/service, 
		/area/service,
		/area/service/kitchen,
		/area/service/kitchen/coldroom,
		/area/service/kitchen/diner,
		/area/service/kitchen/abandoned,
		/area/service/bar,
		/area/service/bar/atrium,
		/area/service/electronic_marketing_den,
		/area/service/abandoned_gambling_den,
		/area/service/abandoned_gambling_den/secondary,
		/area/service/abandoned_gambling_den/gaming,
		/area/service/theater,
		/area/service/library,
		/area/service/library/lounge,
		/area/service/library/artgallery,
		/area/service/library/private,
		/area/service/library/upper,
		/area/service/library/printer,
		/area/service/chapel,
		/area/service/chapel/monastery,
		/area/service/chapel/office,
		/area/service/chapel/asteroid,
		/area/service/chapel/asteroid/monastery,
		/area/service/chapel/dock,
		/area/service/janitor,
		/area/service/hydroponics,
		/area/service/hydroponics/upper,
		/area/service/hydroponics/garden,
		/area/service/hydroponics/garden/abandoned,
		/area/service/hydroponics/garden/monastery,
		/area/command/heads_quarters/hop
	)
	department_destination_name = "Service"
	override_access = ACCESS_HOP
	req_one_access = list(ACCESS_KITCHEN, ACCESS_BAR, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_THEATRE)
	dep_groups = list("Service", "Food & Hydroponics", "Livestock", "Costumes & Toys")

/obj/machinery/computer/department_orders/engineering
	name = "engineering order console"
	circuit = /obj/item/circuitboard/computer/engineering_orders
	department_delivery_areas = list(
		/area/engineering,
		/area/engineering/engine_smes,
		/area/engineering/main,
		/area/engineering/atmos,
		/area/engineering/atmos/upper,
		/area/engineering/atmos/project,
		/area/engineering/atmospherics_engine,
		/area/engineering/supermatter,
		/area/engineering/supermatter/room,
		/area/engineering/gravity_generator,
		/area/engineering/storage,
		/area/engineering/storage_shared,
		/area/engineering/transit_tube,
		/area/engineering/storage/tech,
		/area/engineering/storage/tcomms,
		/area/command/heads_quarters/ce
	)
	department_destination_name = "Engineering"
	override_access = ACCESS_CE
	req_one_access = REGION_ACCESS_ENGINEERING
	dep_groups = list("Engineering", "Engine Construction", "Canisters & Materials")

/obj/machinery/computer/department_orders/science
	name = "science order console"
	circuit = /obj/item/circuitboard/computer/science_orders
	department_delivery_areas = list(/area/science,
		/area/science/lab,
		/area/science/xenobiology,
		/area/science/cytology,
		/area/science/storage,
		/area/science/test_area,
		/area/science/mixing,
		/area/science/mixing/chamber,
		/area/science/genetics,
		/area/science/misc_lab,
		/area/science/misc_lab/range,
		/area/science/server,
		/area/science/explab,
		/area/science/robotics,
		/area/science/robotics/lab,
		/area/science/research,
		/area/command/heads_quarters/rd
	)
	department_destination_name = "Science"
	override_access = ACCESS_RD
	req_one_access = REGION_ACCESS_RESEARCH
	dep_groups = list("Science", "Livestock")

/obj/machinery/computer/department_orders/security
	name = "security order console"
	circuit = /obj/item/circuitboard/computer/security_orders
	department_delivery_areas = list(/area/security,
		/area/security/office,
		/area/security/brig,
		/area/security/brig/upper,
		/area/security/processing/cremation,
		/area/security/interrogation,
		/area/security/warden,
		/area/security/detectives_office,
		/area/security/range,
		/area/security/execution,
		/area/security/execution/transfer,
		/area/security/execution/education,
		/area/ai_monitored/security/armory,
		/area/ai_monitored/security/armory/upper,
		/area/command/heads_quarters/hos
	)
	department_destination_name = "Security"
	override_access = ACCESS_HOS
	req_one_access = REGION_ACCESS_SECURITY
	dep_groups = list("Security", "Armory")

/obj/machinery/computer/department_orders/medical
	name = "medical order console"
	circuit = /obj/item/circuitboard/computer/medical_orders
	department_delivery_areas = list(/area/medical,
		/area/medical/abandoned,
		/area/medical/medbay/central,
		/area/medical/medbay/zone2,
		/area/medical/medbay/aft,
		/area/medical/storage,
		/area/medical/paramedic,
		/area/medical/office,
		/area/medical/surgery/room_c,
		/area/medical/surgery/room_d,
		/area/medical/coldroom,
		/area/medical/virology,
		/area/medical/morgue,
		/area/medical/chemistry,
		/area/medical/pharmacy,
		/area/medical/surgery,
		/area/medical/surgery/room_b,
		/area/medical/cryo,
		/area/medical/exam_room,
		/area/medical/treatment_center,
		/area/medical/psychology,
		/area/command/heads_quarters/cmo
	)
	department_destination_name = "Medbay"
	override_access = ACCESS_CMO
	req_one_access = REGION_ACCESS_MEDBAY
	dep_groups = list("Medical")
