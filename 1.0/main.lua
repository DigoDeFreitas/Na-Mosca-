---------------------------------------------------------------------------Projeto DK3-----------------------------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )--Esconder a barra de status
--Inicialização de variáveis
local background
local title
local fruit
local start_fly
local bonus_line
local score = 0
local level = 0
local over = false
local sfx_game_over
local chrono = 0
local time_text
local chrono_triggered = false
local level = 1
local level_vars = 0
local fly_speed = 0.05
local fly_table = {}
local bonus = 0
local spawn_height = 10

--Sons
sfx_pancada = audio.loadSound("over.wav")
sfx_karate = audio.loadSound("estalo.wav")
bolero = audio.loadSound("clock.wav")

--Grupos de display
local bg_group = display.newGroup()
local ui_group = display.newGroup()
local front_group = display.newGroup()

--Configurações de imagens

--Linhas de bônus
--bonus_line_1 = display.newLine(ui_group, 0, display.contentCenterY, display.contentWidth, display.contentCenterY)--abaixo dessa linha ganha bônus

fruit = display.newImageRect(front_group, "fruit.png", 500, 200)
fruit.x = display.contentCenterX + 10
fruit.y = display.contentHeight - 10
fruit.type = "fruit"

floor = display.newImageRect(front_group, "floor.png", display.contentWidth, 60)
floor.x = display.contentCenterX
floor.y = display.contentHeight + 85

start_fly = display.newImageRect(front_group, "fly1.png", 500, 150)
start_fly.x = display.contentCenterX + 25
start_fly.y = display.contentCenterY + 50


--Texto
title = display.newText(ui_group, "Na mosca!", display.contentCenterX, display.contentCenterY-100, native.systemFont, 60)
author_text = display.newText(ui_group, "Mucura Produções 2023", 110, display.contentCenterY-50, native.systemFont, 15)
score_text = display.newText(ui_group, score, 50, 20, native.systemFont,35)
level_text = display.newText(ui_group, level, 50, 55, native.systemFont,35)
local function update_text()
	score_text.text = score
	level_text.text = level
end

--Configurações de física
physics.start()

physics.addBody(fruit, "static", {radius = 20})
fruit.type = "fruit"

physics.addBody(start_fly, "static", {isSensor = true})
start_fly.type = "UI"

--Delete automático de moscas
local function clean()
	for i = 1, #fly_table do
		physics.removeBody(fly_table[i])
		display.remove(fly_table[i])
		table.remove(fly_table, i)
	end
	giga_charge = false
end

--Função de game over
local function game_over()
	if over == false then
		display.newText(front_group, "GAME OVER", display.contentCenterX, display.contentCenterY, native.systemFont, 35)
		audio.play(sfx_pancada)
		score = score + (bonus * 100)
		while fly_table[1] do--Se o 1° item não existe não há moscas
			clean()
		end
		over = true
	end
end

--Power-ups
local function sum_power_up ()
	power_up = display.newImageRect("somador.png", 200, 100)
	power_up.x = display.contentCenterX
	power_up.y = -100
	physics.addBody(power_up, "dinamic", {radius = 90, isSensor = true})
	power_up.gravityScale = 0.05
	
	local function benefit()
		score = score + 1000
		display.remove(power_up)
		physics.removeBody(power_up)
	end
	power_up:addEventListener("tap", benefit)
	table.insert(fly_table, power_up)
end

--Flya
local function spawn_flya(x,y)
	event = math.random(100)--Para os Detalhezinhos
	local score_gain = 100
	local flya = display.newImageRect("flya.png", 100, 50)--adicionar, talvez, caminho
	
	local function die()

		dead = true
		physics.removeBody(flya)
		display.remove(flya)
		if flya.y >= display.contentCenterY then
			score_gain = 500
			bonus = bonus + 1
		end
		score = score + score_gain
		update_text()
		audio.play(sfx_karate)
	end
	
	flya.x = x
	flya.y = y
	physics.addBody(flya, "dinamic", {radius = 75, isSensor = true})
	flya.type = "enemy"
	flya.gravityScale = fly_speed
	flya:addEventListener("tap", die)
	table.insert(fly_table, flya)
	--Detalhezinhos
	if event == 1 then
		flya:applyTorque(50)
	elseif event == 2 then
		flya.width = 200
		flya.radius = 180
		score_gain = 200
		hp = 2
	elseif event == 3 then
		flya.height = 100
		flya.radius = 180
		score_gain = 200
	end
	
end


--Colisão
local function collision_detection( event )

	if (event.object1.type == "enemy" and event.object2.type == "fruit") or (event.object1.type == "fruit" and event.object2.type == "enemy") then
		game_over()
	end
	
end
Runtime:addEventListener( "collision", collision_detection )

--Tempo
local function chrono_trigger()

	time_text = display.newText(chrono, 50, 90, native.systemFont, 35)
	
	local function inc_time()
		if over == false then
			time_text.text = chrono
			chrono = chrono + 1
			spawn_flya(math.random(50, 300), math.random(-50, spawn_height))
		end
	end
	timer.performWithDelay(1000, inc_time, 0)
	chrono_triggered = true

end

---------------Loop principal---------------

local function loop_main()

	if chrono_triggered == false then
		chrono_trigger()
	end
	
	start_fly.bodyType = "dinamic"
	
	update_text()
	
	if chrono >= 60 then --Passou de fase
	
		giga_charge = true
		chrono = 0
		level = level + 1
		level_vars = level_vars + 1
		if level_vars == 2 then
			level_vars = 1
		end
		level_text.text = level
		sum_power_up()
		
		if level_vars == 1 then
			if fly_speed < 0.75 then
				fly_speed = fly_speed + 0.1
			end
		elseif level_vars == 2 then
			if spawn_height < display.contentCenterY then
				spawn_height = spawn_height + 10
			end
		end
		
	end
	
end

local function loop_start()
	audio.play(bolero, {loops=-1})
	display.remove(author_text)
	display.remove(title)
	loop_timer = timer.performWithDelay(16.667, loop_main, 0)--delay mínimo para 60 fps
end

start_fly:addEventListener("tap", loop_start)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
