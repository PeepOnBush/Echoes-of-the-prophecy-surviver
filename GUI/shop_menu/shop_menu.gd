extends CanvasLayer

signal shown
signal hidden

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

const ERROR = preload("res://GUI/shop_menu/Audio/error.wav")
const OPEN_SHOP = preload("res://GUI/shop_menu/Audio/open_shop.wav")
const PURCHASE = preload("res://GUI/shop_menu/Audio/purchase.wav")
const SHOP_ITEM_BUTTON = preload("res://GUI/shop_menu/shop_item_button.tscn")
const SHOP_ITEM = preload("res://Interactables/Shopkeeper/Shopkeeper.tscn")
const MENU_FOCUS = preload("res://Menu/menu_focus.wav")
const MENU_SELECT = preload("res://Menu/menu_select.wav")

@onready var close_button: Button = %CloseButton
@onready var shop_items_container: VBoxContainer = %ShopItemsContainer
@onready var currency_label: Label = %Currency
@onready var animation_player: AnimationPlayer = $Control/CurrencyPanel/AnimationPlayer

@onready var item_image: TextureRect = %ItemImage
@onready var item_name: Label = %ItemName
@onready var item_description: Label = %ItemDescription
@onready var price: Label = %Price
@onready var item_count: Label = %ItemCount


var is_active : bool = false
var currency : ItemData = preload("res://Items/currency.tres")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hideMenu()
	close_button.pressed.connect(hideMenu)
	pass

func _unhandled_input(event: InputEvent) -> void:
	if is_active == false:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		hideMenu()



func showMenu(items : Array[ItemData],dialog_triggered : bool = true) -> void:
	if items.size() != 0:
		print(items,items.size())
		if dialog_triggered:
			await DialogSystem.finished
		enabledMenu()
		populateItemList(items)
		updateCurrency()
		shop_items_container.get_child(0).grab_focus()
		playAudio(OPEN_SHOP)
		shown.emit()
	else:
		return
	pass

func hideMenu() -> void:
	enabledMenu(false)
	clearItemList()
	hidden.emit()
	pass

func enabledMenu(_enabled : bool = true) -> void:
	get_tree().paused = _enabled
	visible = _enabled
	is_active = _enabled
	pass

func clearItemList() -> void:
	for c in shop_items_container.get_children():
		c.queue_free()
	pass

func populateItemList(items : Array[ItemData]) -> void:
	for item in items:
		var shop_item : ShopItemButton = SHOP_ITEM_BUTTON.instantiate()
		shop_item.setupItem(item) 
		shop_items_container.add_child(shop_item)
		shop_item.focus_entered.connect(updateItemDetail.bind(item))
		shop_item.pressed.connect(purchaseItem.bind(item))
		pass
	pass

func playAudio(_audio : AudioStream) -> void:
	audio.stream = _audio
	audio.play()
	pass

func updateCurrency() -> void:
	currency_label.text = str(getItemCount(currency))
	pass

func getItemCount(item : ItemData) -> int:
	return PlayerManager.INVENTORY_DATA.getItemHeldCount(item)

func focusItemChanged(item : ItemData) -> void:
	playAudio(MENU_FOCUS)
	if item:
		updateItemDetail(item)
	pass

func updateItemDetail(item : ItemData ) -> void:
	item_image.texture = item.texture
	item_name.text = item.name
	item_description.text = item.description
	price.text = str(item.cost)
	item_count.text = str(getItemCount(item))
	pass

func purchaseItem(item : ItemData ) -> void:
	var canPurchase : bool = getItemCount(currency) >= item.cost
	
	if canPurchase:
		playAudio(PURCHASE)
		animation_player.play("enough_currency")
		var inventory : InventoryData = PlayerManager.INVENTORY_DATA
		inventory.add_item(item)
		inventory.useItem(currency,item.cost)
		updateCurrency()
		updateItemDetail(item)
		pass
	else:
		playAudio(ERROR)
		animation_player.play("not_enough_currency")
		animation_player.seek(0)
	pass
