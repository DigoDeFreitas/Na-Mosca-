local composer = require( "composer" )--Carrega a biblioteca Composer

local scene = composer.newScene()--Cria uma nova cena da API Composer

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local jingle = audio.loadSound("street.wav")
audio.play(jingle)

function scene:create( event )

	local sceneGroup = self.view
	--Introdução
	local logo = display.newImageRect(sceneGroup, "logo.png", display.contentWidth, display.contentHeight)
	logo.x = display.contentCenterX
	logo.y = display.contentCenterY
	-- Code here runs when the scene is first created but has not yet appeared on screen
	timer.performWithDelay(5000, function() composer.gotoScene("game") end, -1)
end


-- show()
function scene:show( event )
end


-- hide()
function scene:hide( event )
end


-- destroy()
function scene:destroy( event )
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