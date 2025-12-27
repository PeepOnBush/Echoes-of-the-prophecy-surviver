extends CanvasLayer

signal shown
signal hidden

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

const ERROR = preload("res://GUI/shop_menu/Audio/error.wav")
const OPEN_SHOP = preload("res://GUI/shop_menu/Audio/open_shop.wav")
const PURCHASE = preload("res://GUI/shop_menu/Audio/purchase.wav")
const SHOP_ITEM_BUTTON = preload("res://GUI/shop_menu/shop_item_button.tscn")
const MENU_FOCUS = preload("res://Menu/menu_focus.wav")
# const MENU_SELECT = preload("res://Menu/menu_select.wav") # Not used currently

@onready var close_button: Button = %CloseButton
@onready var shop_items_container: VBoxContainer = %ShopItemsContainer
@onready var currency_label: Label = %Currency
@onready var animation_player: AnimationPlayer = $Control/CurrencyPanel/AnimationPlayer

# Details Panel
@onready var item_image: TextureRect = %ItemImage
@onready var item_name: Label = %ItemName
@onready var item_description: Label = %ItemDescription
@onready var price: Label = %Price
@onready var item_count: Label = %ItemCount

var is_active : bool = false
var currency : ItemData = preload("res://Items/currency.tres")

# NEW: We need to remember what this specific shopkeeper sells
# so we can re-populate the list after buying a unique buff.
var current_shop_items : Array[ItemData] = []

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

func showMenu(items : Array[ItemData], dialog_triggered : bool = true) -> void:
	if items.size() == 0:
		return
		
	print(items, items.size())
	if dialog_triggered:
		await DialogSystem.finished
	
	# 1. Save the list so we can refresh it later
	current_shop_items = items
	
	enabledMenu()
	populateItemList() # No argument needed, uses the class variable
	updateCurrency()
	
	# 2. Check if the shop is actually empty (e.g., we bought all buffs)
	if shop_items_container.get_child_count() > 0:
		shop_items_container.get_child(0).grab_focus()
		playAudio(OPEN_SHOP)
		shown.emit()
	else:
		# If the filtered list is empty, don't show the menu (or show "Sold Out" message)
		hideMenu()
		# Optional: Play a "Empty" or "Huh?" sound here
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

# Updated: Uses 'current_shop_items' variable
func populateItemList() -> void:
	clearItemList() # Ensure list is clean before building
	
	for item in current_shop_items:
		# --- CONDITION CHECK: Filter out owned Buffs ---
		if item is BuffUnlockItemData:
			if PlayerManager.has_unlocked(item.upgrade_to_unlock):
				continue # Skip adding this button
		# -----------------------------------------------
		
		var shop_item : ShopItemButton = SHOP_ITEM_BUTTON.instantiate()
		shop_item.setupItem(item) 
		shop_items_container.add_child(shop_item)
		shop_item.focus_entered.connect(updateItemDetail.bind(item))
		shop_item.pressed.connect(purchaseItem.bind(item))
	pass

func purchaseItem(item : ItemData ) -> void:
	var canPurchase : bool = getItemCount(currency) >= item.cost
	
	if canPurchase:
		# --- LOGIC START: Buying a Buff ---
		if item is BuffUnlockItemData:
			# Double safety check
			if PlayerManager.has_unlocked(item.upgrade_to_unlock):
				playAudio(ERROR)
				return
				
			# 1. Unlock logic
			PlayerManager.unlock_new_upgrade(item.upgrade_to_unlock)
			PlayerManager.INVENTORY_DATA.useItem(currency, item.cost)
			
			playAudio(PURCHASE)
			animation_player.play("enough_currency")
			updateCurrency()
			
			# 2. REFRESH THE SHOP! 
			# This rebuilds the list, and because we own the buff now, 
			# the filter in populateItemList will remove the button.
			refresh_shop_after_purchase()
			return
		# --- LOGIC END ---

		# Logic: Buying a normal item
		playAudio(PURCHASE)
		animation_player.play("enough_currency")
		var inventory : InventoryData = PlayerManager.INVENTORY_DATA
		inventory.add_item(item)
		inventory.useItem(currency,item.cost)
		updateCurrency()
		updateItemDetail(item) # Update count in details panel
	else:
		playAudio(ERROR)
		animation_player.play("not_enough_currency")
		animation_player.seek(0)
	pass

# Helper to remove the button you just clicked and update focus
func refresh_shop_after_purchase() -> void:
	# 1. Rebuild list (Owned buff disappears)
	populateItemList()
	
	# 2. Handle Focus / Details Panel
	if shop_items_container.get_child_count() > 0:
		# Focus the first item available
		var first_item_button = shop_items_container.get_child(0)
		first_item_button.grab_focus()
		# Update details to match new focus
		updateItemDetail(first_item_button.item) 
	else:
		# If shop is now empty, clear details
		clearItemDetail()
		# Optional: Auto-close shop?
		# hideMenu()

func updateItemDetail(item : ItemData ) -> void:
	item_image.texture = item.texture
	item_name.text = item.name
	item_description.text = item.description
	price.text = str(item.cost)
	item_count.text = str(getItemCount(item))
	pass

func clearItemDetail() -> void:
	item_image.texture = null
	item_name.text = ""
	item_description.text = ""
	price.text = ""
	item_count.text = ""

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

func playAudio(_audio : AudioStream) -> void:
	audio.stream = _audio
	audio.play()
	pass
