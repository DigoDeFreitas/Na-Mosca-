local composer = require( "composer" )

local scene = composer.newScene()--Inicializa uma cena da API Composer

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

--Configuração de física
physics = require("physics")
physics.start()

--Inicialização de variáveis
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
local bonus = 0
local spawn_height = 10
local markiplier = 1
local level_benefit = false
local restart = false
local high_score = io.read("*a hi.txt")
print(high_score)
local bg_group--	Upvalues dos
local ui_group--	grupos
local front_group-- de display

--Função para saber se é inteiro (boa para eventos periódicos)
local function is_int(x)
	if math.floor(x) == x then
		return true
	else
		return false
	end
end

--Sons
sfx_game_over = audio.loadSound("barulhinho_chato.wav")
sfx_pancada = audio.loadSound("pancada_chaves.wav")
sfx_karate = audio.loadSound("karate_chop.wav")
sfx_boing = audio.loadSound("boing.wav")
sfx_boom = audio.loadSound("street.wav")
bolero = audio.loadStream("Bolero - Ravel.mp3")
toreador = audio.loadStream("toreador.mp3")

--Função de atualizar texto
local function update_text()
	score_text.text = score
	level_text.text = level
end

--Função de reset
local function reset()
	restart = true
	composer.gotoScene("main")
end

--Função de game over
local function game_over()
	if over == false then
		display.newText(front_group, "GAME OVER", display.contentCenterX, display.contentCenterY, native.systemFont, 35)
		audio.play(sfx_pancada)
		score = score + (bonus * 100)
		--Botão de restart
		restart_button = display.newText(ui_group, "Restart", display.contentCenterX, display.contentCenterY-150, native.systemFont, 40)
		restart_button:addEventListener("tap", reset)
		physics.pause()
		over = true--variável talvez útil
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
		if level_benefit == false then
			level_benefit = true
			score = score + 1000
			display.remove(power_up)
			physics.removeBody(power_up)
		end
	end
	power_up:addEventListener("tap", benefit)
end

--Flya
local function spawn_flya(x,y)
	
	local rolled = false
	event = math.random(100)--Para os Detalhezinhos
	rand = math.random(50, 80)
	local dead = false
	local score_gain = 100
	local flya = display.newImageRect("flya.png", 100, 50)
	flya.x = x
	flya.y = y
	physics.addBody(flya, "dynamic", {radius = 70, isSensor = true})
	flya.type = "enemy"
	flya.gravityScale = fly_speed
	--Explosão
	local explosion = display.newImageRect("explosion.png", rand, rand)
	explosion.isVisible = false
	explosion.x = flya.x
	explosion.y = flya.y
	
	local function fim()
		explosion.isVisible = false
	end

	local function die()
		
		if not over then
			explosion.isVisible = true
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
		
	end

	flya:addEventListener("tap", die)
	
	--Funções de movimentação
	local function jump()
		flya:applyLinearImpulse(0, -0.75, flya.x, flya.y)
		audio.play(sfx_boing)
	end

	
	local function roll(dir)
		flya:applyLinearImpulse(dir, 0, flya.x, flya.y)
		flya:applyTorque(500)
		rolled = true
	end
	
	local function frame()
	
		if not dead and over then
			display.remove(flya)
			if framer then timer.cancel(framer) end
		end

		if not dead and not over and flya.y >= display.contentHeight then
			flya.x = display.contentCenterX
			flya.y = display.contentCenterY - 100
			flya:applyTorque(1000)
		end
		--Animação da explosão
		if not dead then
			explosion.x = flya.x
			explosion.y = flya.y
		else
			timer.performWithDelay(500, fim, 1)
		end
		
	end

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
	elseif event == 4 then
		if level >= 5 then
			jump()
			score_gain = 200
		end
	end
	local framer = timer.performWithDelay(16.667, frame, 0)--eu sabo muito
end

--Colisão
local function collision_detection( event )
	if (event.object1.type == "enemy" and event.object2.type == "fruit") or (event.object1.type == "fruit" and event.object2.type == "enemy") then
		game_over()
	end
	
end

--Tempo
local function chrono_trigger()

	time_text = display.newText(chrono, 50, 110, native.systemFont, 35)
	
	local function inc_time()
		if over == false then
			time_text.text = chrono
			chrono = chrono + 1
			print(chrono)
			if over == false then
				spawn_flya(math.random(50, 300), math.random(-50, spawn_height))
			end
		end
	end
	sec_timer = timer.performWithDelay(1000, inc_time, 0)
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
		
		level_benefit = false
		giga_charge = true
		chrono = 0
		level = level + 1
		level_vars = level_vars + 1
		if level_vars == 2 then
			level_vars = 1
		end
		print(level)
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
	
	if is_int(level/5) and bee_spawned == false then spawn_bee() end
	
end

local function loop_start()
	restart = false
	audio.play(bolero)
	display.remove(author_text)
	display.remove(title)--apaga o texto do título
	loop_timer = timer.performWithDelay(16.667, loop_main, 0)--delay mínimo para 60 fps
end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause()--ainda não tem nada na tela
	--Grupos de display
	bg_group = display.newGroup()
	sceneGroup:insert(bg_group)
	ui_group = display.newGroup()
	sceneGroup:insert(ui_group)
	front_group = display.newGroup()
	sceneGroup:insert(front_group)
	
	--Configurações de imagens
	
	--Linha de bônus
	bonus_line = display.newLine(ui_group, 0, display.contentCenterY, display.contentWidth, display.contentCenterY)--abaixo dessa linha ganha bônus
	
	fruit = display.newImageRect(front_group, "fruit.png", 150, 150)
	fruit.x = display.contentCenterX
	fruit.y = display.contentHeight - 10
	fruit.type = "fruit"
	
	floor = display.newImageRect(front_group, "jorge.png", display.contentWidth, 60)
	floor.x = display.contentCenterX
	floor.y = display.contentHeight + 85
	
	start_fly = display.newImageRect(front_group, "fly1.png", 100, 100)
	start_fly.x = display.contentCenterX
	start_fly.y = display.contentCenterY + 50
 
	--Texto
	title = display.newText(ui_group, "Na mosca!", display.contentCenterX, display.contentCenterY-100, native.systemFont, 60)
	author_text = display.newText(ui_group, "Mucura Produções 2023", 110, display.contentCenterY-50, native.systemFont, 15)
	score_text = display.newText(ui_group, score, 50, 30, native.systemFont,35)
	level_text = display.newText(ui_group, level, 50, 70, native.systemFont,35)
	
	--Física dos objetos iniciais
	physics.addBody(fruit, "static", {radius = 20})
	fruit.type = "fruit"
	
	physics.addBody(start_fly, "static", {isSensor = true})
	start_fly.type = "UI"
	
	start_fly:addEventListener("tap", loop_start)-- e é aí que a diversão começa

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener( "collision", collision_detection )

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		physics.pause()
		Runtime:removeEventListener( "collision", collision_detection )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
