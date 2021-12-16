extends "res://castagne/engine/functions/CastagneFunctions.gd"

# Big ugly menu I stole from the Kronian Titans demo and changed a bit.
# Will be updated at a later date.

var hpRedRatio = {"p1":1.0, "p2":1.0}
var hpRedTarget = {"p1":10000, "p2":10000}
var hpRedTargetDelay = {"p1":10000, "p2":10000}

var isTrainingMode = false

func InitTool(engine, battleInitData):
	isTrainingMode = battleInitData["mode"] == "Training"
	
	get_node("L/Rounds/1/Active").set_visible(battleInitData["p1Points"] > 0)
	get_node("L/Rounds/2/Active").hide()
	get_node("R/Rounds/1/Active").set_visible(battleInitData["p2Points"] > 0)
	get_node("R/Rounds/2/Active").hide()



func UpdateGraphics(state, _engine):
	UpdatePlayer(state, "p1", "L")
	UpdatePlayer(state, "p2", "R")
	
	var timerRoot = get_node("C/Timer")
	if(isTrainingMode):
		timerRoot.get_node("Label").set_text("Timer\nInfinite")
	else:
		var currentTimer = state["Timer"]/60
		currentTimer = int(clamp(currentTimer, 0, 99))
		
		var leftNumber = currentTimer / 10
		var rightNumber = currentTimer % 10
		timerRoot.get_node("Label").set_text("Timer\n"+str(currentTimer))
	
	var middleText = get_node("C/Text")
	middleText.hide()
	
	if(state["WhoHasWon"] != 0):
		var whw = state["WhoHasWon"]
		if(whw == 2):
			middleText.get_node("Label").set_text("Draw")
		else:
			middleText.get_node("Label").set_text("Down!")
		
		middleText.show()
	
	if(state.has("STARTFRAMES")):
		if(state["STARTFRAMES"] > 0):
			middleText.get_node("Label").set_text("Ready?")
			middleText.show()
		elif(state["STARTFRAMES"] > -50):
			middleText.get_node("Label").set_text("Fight!")
			middleText.show()

func UpdatePlayer(gameState, playerID, uiSide):
	var hpMax = gameState[playerID]["HPMax"]
	var hp = gameState[playerID]["HP"]
	var hpRatio = float(hp)/float(hpMax)
	hpRatio = clamp(hpRatio, 0.0, 1.0)
	
	if(!Castagne.HasFlag("Hitstun", playerID, gameState)):
		hpRedTarget[playerID] = hpRedTargetDelay[playerID]
		hpRedTargetDelay[playerID] = hp
	
	var hpRedRatioTarget = float(hpRedTarget[playerID])/float(hpMax)
	hpRedRatioTarget = clamp(hpRedRatioTarget, 0.0, 1.0)
	hpRedRatio[playerID] = move_toward(hpRedRatio[playerID], hpRedRatioTarget, 0.006)
	
	get_node(uiSide+"/HPBar/Handle").set_scale(Vector2(hpRatio, 1.0))
	get_node(uiSide+"/HPBar/HandleRed").set_scale(Vector2(hpRedRatio[playerID], 1.0))
