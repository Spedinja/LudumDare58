extends Control

@export var rarities: Array[String]
# function that defines the weight for each rarity dependent on player progress from 0-100
@export var weightFunction: String = "exp(-pow(rarity - (x/100)*(rarity_count-1), 2)/(2*spread*spread))"
# function that defines the budget for each rarity 
@export var budgetFunction: String = "parameterCount + (rarity * (rarity + 3) * parameterCount) / 8"
#@export var parameterCount: float
# controls how quickly flat the weight curves are: the higher the smoother and more overlap, the lower the sharper the peaks
@export var spread: float = 1
@export var itemlist: Array[item]
@export var failsafe: item



func _ready() -> void:
	pass
	
#func _process(_delta: float) -> void:
	#pass
	
func debugInput():
	var items = select_items(3,spells,0)
	for i in items:
		print(i.itemName)
		print(i.rarity)
		var total = 0
		for key in i.budgetStats:
			var value = i.budgetStats[key]
			total += value
			var convertValue = str(value)
			print(key + ": " + convertValue)
		print("total: " + str(total))
		pass
	items =select_items(4,artifacts,50)
	for i in items:
		print(i.itemName)
		pass
	items =select_items(6,artifacts,100)
	for i in items:
		print(i.itemName)
		pass

func calcBudget(itemtype:item):
	var budgets: Array[int]
	var expr = Expression.new()
	expr.parse(budgetFunction, ["rarity", "parameterCount"])
	# calculate budget for each rarity
	for rarity in rarities.size():
		budgets.append(expr.execute([rarity, itemtype.budgetStats.size()]))
	return budgets


func calcRarityWeights(playerProgress:float):
	var rarityPercentages: Array[float]
	var rarityCount = rarities.size()
	var total = 0
	# calculate rarity weights
	for rarity in rarityCount:
		var expr = Expression.new()
		expr.parse(weightFunction, ["rarity", "x", "rarity_count", "spread"])
		var rawWeight = expr.execute([float(rarity) ,playerProgress, rarityCount, spread])
		total += rawWeight
		rarityPercentages.append(rawWeight)
	# normalize weights to make the total become 1
	for i in rarityPercentages:
		rarityPercentages[i] = rarityPercentages[i]/total * 1
	return rarityPercentages	
		
func rollItem(rarityPercentages, type):
	var diceRoll = randf_range(0,1)
	var targetRarity
	var checkValue = 0
	for weight in rarityPercentages.size():
		checkValue += rarityPercentages[weight]
		if diceRoll < checkValue:
			targetRarity = rarities[weight]
			break
	#print(type.get_class())
	#print(targetRarity)
	var filteredList = itemlist.filter(func(i): return is_instance_of(i,type) && (i.rarity == targetRarity || i.budgetStats.size() != 0))
	if(filteredList.size() == 0):
		print("FAILED TO FIND ITEM, RARITY: " + targetRarity)
		return failsafe.duplicate(true)
	var selectedItem = filteredList[randi_range(0, filteredList.size() -1)]
	if selectedItem.rarity == null:
		selectedItem.rarity = targetRarity
	return selectedItem.duplicate(true)
		
func assignBudget(newItem:item):
	var total = 0
	var budgets: Array[float] = []
	var budget = calcBudget(newItem)[rarities.find(newItem.rarity)]
	for i in newItem.budgetStats.size():
		budgets.append(-log(randf_range(0,1)))
		total += budgets[i]
	#var index = 0
	for index in budgets.size():
		# dunno if the find option can be replaced by somehow saving the rarities in the items only as numbers and then translating them later somehow?
		budgets[index] = budgets[index] / total * budget
	# make sure everything is an integer and assing leftover to highest fractals
	var floorValues: Array[float] = []
	var leftOverFractions: Array[float] = []
	var flooredTotal = 0
	for i in budgets:
		floorValues.append(floor(i))
		flooredTotal += floorValues.back()
		leftOverFractions.append(i-floorValues.back())
	var leftover = budget - flooredTotal
	for i in leftover:
		var targetIndex = leftOverFractions.find(leftOverFractions.max())
		floorValues[targetIndex] += 1
		leftOverFractions[targetIndex] = 0
	# assign budget to stats
	var index = 0
	for key in newItem.budgetStats:
		# dunno if the find option can be replaced by somehow saving the rarities in the items only as numbers and then translating them later somehow?
		#budgets[index] = budgets[index] / total * budget[rarities.find(newItem.rarity)]
		newItem.budgetStats[key] = floorValues[index]
		index += 1

	return newItem
	
func select_items(amount, type, playerProgress: float):
	var returnItems: Array[item]
	var rarityPercentages = calcRarityWeights(playerProgress)
	
	for i in amount:
		var currentRoll = rollItem(rarityPercentages, type)
		if(currentRoll.budgetStats.size() != 0):
			assignBudget(currentRoll)
		returnItems.append(currentRoll)
		
	return returnItems
