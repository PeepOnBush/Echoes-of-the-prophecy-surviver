class_name UpgradeData extends Resource

enum UpgradeType { 
HEAL, 
ATTACK, 
DEFENSE, 
SPEED, 
ARROW, 
BOMB, 
ORBIT, 
RAGE, 
RICOCHET  ,
ELEMENT_FIRE, 
ELEMENT_ICE,
ORCISH_VITALITY,
KNOCKBACK_FORCE,
BERSERK,
ORBIT_SPEED,
ORBIT_RANGE,
ORBIT_SIZE,
EXPLOSIVE_ARROW,
ATTACK_SPEED,
CRIT_DAMAGE,
CRIT_CHANCE,
INVINCIBILITY_UP 
}

@export var title : String = "Upgrade Name"
@export_multiline var description : String = "Description of what it does."
@export var icon : Texture2D
@export var buff : UpgradeType = UpgradeType.ATTACK
@export var value : float = 1.0 # How much to add (e.g. +1 Attack)
