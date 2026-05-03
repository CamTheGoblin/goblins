extends GutTest


func test_strike_tres_loads_with_expected_fields() -> void:
	var card: CardData = load("res://content/cards/strike.tres") as CardData
	assert_not_null(card, "Strike resource should load as CardData")
	assert_eq(card.name, "Strike", "Strike should be named 'Strike'")
	assert_eq(card.cost, 1, "Strike should cost 1 energy")
	assert_eq(card.target_type, TargetType.ENEMY, "Strike should target ENEMY")
	assert_eq(card.effects.size(), 1, "Strike should bundle a single effect")
	var damage: DamageEffect = card.effects[0] as DamageEffect
	assert_not_null(damage, "Strike's effect should be a DamageEffect")
	assert_eq(damage.amount, 6, "Strike should deal 6 damage")
	assert_eq(damage.affects, TargetScope.SELECTED_TARGET, "Strike's damage should target the selected target")
	assert_eq(card.description, "Deal 6 damage.", "Strike should carry a player-facing description")


func test_defend_tres_loads_as_a_self_targeted_one_cost_card() -> void:
	var card: CardData = load("res://content/cards/defend.tres") as CardData
	assert_not_null(card, "Defend resource should load as CardData")
	assert_eq(card.name, "Defend", "Defend should be named 'Defend'")
	assert_eq(card.cost, 1, "Defend should cost 1 energy")
	assert_eq(card.target_type, TargetType.SELF, "Defend should target SELF")
	assert_true(card.description.contains("shield"), "Defend's description should mention shield")
