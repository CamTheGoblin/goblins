extends GutTest


func test_new_character_starts_at_full_hp() -> void:
	var character: Character = Character.new(20)
	assert_eq(character.max_hp, 20, "max_hp should be set from constructor")
	assert_eq(character.current_hp, 20, "current_hp should start at max_hp")


func test_take_damage_reduces_current_hp_by_amount() -> void:
	var character: Character = Character.new(20)
	character.take_damage(6)
	assert_eq(character.current_hp, 14, "take_damage should subtract amount from current_hp")


func test_take_damage_clamps_current_hp_at_zero() -> void:
	var character: Character = Character.new(10)
	character.take_damage(25)
	assert_eq(character.current_hp, 0, "current_hp should not drop below zero")
