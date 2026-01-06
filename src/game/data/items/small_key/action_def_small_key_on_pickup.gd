extends Resource
class_name OnItemPickupActionDef


func execute (item:SimpleItemDef):
	EventBus.player_collected_item.emit(item)
	print("%s picked up" %item.display_name)
