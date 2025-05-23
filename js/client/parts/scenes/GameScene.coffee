define([
    'pixijs', 'Scene', 'text!./../config.json'
], (PIXI, Scene, config) ->
    config = JSON.parse(config)

    class GameScene extends Scene
        gameFieldSize: 450
        fieldPaddingX: 40
        fieldPaddingY: 40
        xPicMargin: 63
        yPicMargin: 63
        shipSum: 0
        choosenShip: null
        allShips: []
        what2Remove: []
        prepeared4Battle: false
        battleStarted: false
        scaleParams: { x: 1, y: 1 }
        isYourTurn: false
        isEnableFire: false
        dirtySpaceBtwnFlds: 90
        fireSpritesArr: []
        HPBars: {}

        gameXPadding: (isZero) ->
            if !@battleStarted || isZero then return 0
            return @cellSize * 10 + @dirtySpaceBtwnFlds + @xPicMargin

        axisXFieldStartPos: (isZero) ->
            if !@battleStarted || isZero then return @fieldPaddingX + @xPicMargin
            return @fieldPaddingX + @xPicMargin + @gameXPadding(isZero)

        axisYFieldStartPos: () ->
            return @fieldPaddingY + @yPicMargin

        axisXFieldEndPos: () ->
            return @axisXFieldStartPos() + @cellSize * 10

        axisYFieldEndPos: () ->
            return @axisYFieldStartPos() + @cellSize * 10

        cellSize: 60
        shipsMap: [
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        ]
        shootMap: [
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        ]

        constructor: (screen) ->
            super(screen)
            @addBattleField()
            @addShips()
            @addRotatingControl()
            @addStartBtn()
            @onUpdate(() =>
                @checkIsAllShipsValid()
                @updatePreloader()
                @updateCannon()
            )
            @playTheme()

        addXSprite: () ->
            texture = PIXI.Texture.fromImage('./imgs/crosshair.png')
            x = new PIXI.Sprite(texture)
            x.zIndex = 0
            x.anchor.x = 0.5
            x.anchor.y = 0.5
            x.visible = false
            @xSprite = x
            @addChild(x)

        addCannon: () ->
            texture = PIXI.Texture.fromImage('./imgs/cannon.png')
            @cannon = new PIXI.TilingSprite(texture)
            @cannon.width = 110
            @cannon.scale.set(1.8)
            @cannon.tilePosition.x = 0
            @cannon.tilePosition.y = 0
            @cannon.zIndex = 0
            @cannon.anchor.x = 0.5
            @cannon.anchor.y = 0.5
            @cannon.fired = false
            @cannon.position.x = config.originalWidth / @scaleParams.x - 90
            @cannon.position.y = config.originalHeight / @scaleParams.y - 110
            @addChild(@cannon)

        updateCannon: () ->
            if !@cannon
                return
            if @cannon.fired
                @cannon.tilePosition.x += 110
            if @cannon.tilePosition.x > 1400
                @cannon.tilePosition.x = 0
                @cannon.fired = false

        addBattleField: (isInterective, x, y) ->
            x = x || @getPaddingX()
            y = y || @getPaddingY()
            texture = PIXI.Texture.fromImage('./imgs/battlefield.png')
            field = new PIXI.Sprite(texture)
            field.zIndex = 0
            if isInterective
                field.buttonMode = true
                field.interactive = true
                field.mousedown = field.tap = @clickBattleFieldHandler
                field.mousemove = field.touchmove = @moveBattleFieldHandler
            field.position.x = x
            field.position.y = y
            @bf = field
            @addChild(field)

        changeText: (text) ->
            if @text then @text.setText(text)

        getPaddingX: (index = 1) ->
            return @fieldPaddingX * index

        getPaddingY: (index = 1) ->
            return @fieldPaddingY * index

        getGameFieldSize: () ->
            return @gameFieldSize

        clickBattleFieldHandler: (data) =>
            if @battleStarted && @isYourTurn && @isEnableFire
                cells = @getCells({ x: data.global.x / window.game.scenesManager.ratio, y: data.global.y / window.game.scenesManager.ratio }, @cellSize / 2, @cellSize / 2)
                if @shootMap[cells.cellY][cells.cellX] != 0
                    return alert 'You cannot shoot here again!'
                @playSound('./audio/cannon.mp3')
                @isEnableFire = false
                @xSprite.visible = false
                @cannon.fired = true
                @clearTimer()
                setTimeout(() =>
                    @fire({ x: cells.cellX, y: cells.cellY })
                , 1000)

        moveBattleFieldHandler: (data) =>
            if @battleStarted && @isYourTurn && @isEnableFire
                cells = @getCells({ x: data.global.x / window.game.scenesManager.ratio, y: data.global.y / window.game.scenesManager.ratio }, @cellSize / 2, @cellSize / 2)
                if @validateCell(cells.cellX, cells.cellY) && @xSprite
                    @xSprite.visible = true
                    @placeSpriteObject.call(@xSprite, @, cells.cellY, cells.cellX)
                else
                    @xSprite.visible = false if @xSprite

        addShips: () ->
            xPos = config.originalWidth - 140
            @oneShip('./imgs/ship1.png', 65, 65, { x: xPos, y: 500 }, 1)
            @oneShip('./imgs/ship1.png', 65, 65, { x: xPos, y: 500 }, 1)
            @oneShip('./imgs/ship1.png', 65, 65, { x: xPos, y: 500 }, 1)
            @oneShip('./imgs/ship1.png', 65, 65, { x: xPos, y: 500 }, 1)
            @oneShip('./imgs/ship2.png', 123, 65, { x: xPos, y: 400 }, 2)
            @oneShip('./imgs/ship2.png', 123, 65, { x: xPos, y: 400 }, 2)
            @oneShip('./imgs/ship2.png', 123, 65, { x: xPos, y: 400 }, 2)
            @oneShip('./imgs/ship3.png', 175, 65, { x: xPos, y: 300 }, 3)
            @oneShip('./imgs/ship3.png', 175, 65, { x: xPos, y: 300 }, 3)
            @oneShip('./imgs/ship4.png', 240, 65, { x: xPos, y: 200 }, 4)

        oneShip: (src, width, height, position, deckCount) ->
            self = @
            texture = PIXI.Texture.fromImage(src)
            ship = new PIXI.TilingSprite(texture, width, height)
            ship.zIndex = 1
            ship.anchor.x = 0.5
            ship.anchor.y = 0.5
            ship.interactive = true
            ship.position.x = position.x
            ship.position.y = position.y
            ship.deckCount = deckCount
            ship.mousemove = ship.touchmove = (data) ->
                if !self.prepeared4Battle
                    self.shipHandlerMove.call(@, self, data)

            ship.mousedown = ship.touchstart = (data) ->
                if !self.prepeared4Battle
                    self.shipHandlerClickStart.call(@, self)
            ship.mouseup = ship.mouseupoutside = ship.touchend = (data) ->
                if !self.prepeared4Battle
                    self.shipHandlerClickEnd.call(@, self)
            @allShips.push(ship)
            @addChild(ship)

        shipHandlerMove: (classContext, eventData) ->
            if @dragging
                classContext.validateShip.call(@, classContext, eventData)

        updateLayersOrder: () ->
            @children.sort((a, b) ->
                zIndex1 = a.zIndex || 0
                zIndex2 = b.zIndex || 0
                return zIndex1 - zIndex2
            )
            console.log(@children)

        shipHandlerClickStart: (classContext) ->
            @zIndex = 2
            classContext.clearPreviousShipPosition.call(@, classContext)
            classContext.choosenShip = @
            @alpha = 0.8
            @dragging = true

        shipHandlerClickEnd: (classContext) ->
            if @dragging
                @alpha = 1
                @dragging = false
                if @valid
                    console.log('VALID!')
                    classContext.setShipCell.call(@, classContext)

        validateShip: (classContext, eventData) ->
            if eventData
                @position.x = eventData.global.x / window.game.scenesManager.ratio
                @position.y = eventData.global.y / window.game.scenesManager.ratio
            isV = classContext.isValidShipLocation.call(@, classContext, eventData)
            if isV
                @tilePosition.y = @height
                @valid = true
            else
                @valid = false
                @tilePosition.y = @height * 2

        isValidShipLocation: (classContext) ->
            return classContext.isInBattleField.call(@, classContext) && classContext.validateSpaceBeetweenShips.call(@, classContext)

        isInBattleField: (classContext) ->
            xParam = if !@orient then @width else @height
            yParam = if !@orient then @height else @width
            xBorderLeft = classContext.axisXFieldStartPos() + xParam * 0.45
            yBorderUp = classContext.axisYFieldStartPos() + yParam * 0.45
            yBorderRight = classContext.axisXFieldEndPos() - xParam * 0.45
            yBorderDown = classContext.axisYFieldEndPos() - yParam * 0.45
            return @position.x > xBorderLeft && @position.y > yBorderUp && @position.x < yBorderRight && @position.y < yBorderDown

        validateCell: (cellX, cellY) ->
            if cellX > 9 or cellX < 0 or cellY < 0 or cellY > 9
                return false
            return true

        validateSpaceBeetweenShips: (classContext) ->
            cells = classContext.getShipCells.call(@, classContext)
            isValid = true
            count = @deckCount
            while count > 0
                x10 = if classContext.validateCell(cells.cellX - 1, cells.cellY) then classContext.shipsMap[cells.cellY][cells.cellX - 1] else 0
                x11 = if classContext.validateCell(cells.cellX, cells.cellY) then classContext.shipsMap[cells.cellY][cells.cellX] else 0
                x12 = if classContext.validateCell(cells.cellX + 1, cells.cellY) then classContext.shipsMap[cells.cellY][cells.cellX + 1] else 0

                x00 = if classContext.validateCell(cells.cellX - 1, cells.cellY - 1) then classContext.shipsMap[cells.cellY - 1][cells.cellX - 1] else 0
                x01 = if classContext.validateCell(cells.cellX, cells.cellY - 1) then classContext.shipsMap[cells.cellY - 1][cells.cellX] else 0
                x02 = if classContext.validateCell(cells.cellX + 1, cells.cellY - 1) then classContext.shipsMap[cells.cellY - 1][cells.cellX + 1] else 0

                x20 = if classContext.validateCell(cells.cellX - 1, cells.cellY + 1) then classContext.shipsMap[cells.cellY + 1][cells.cellX - 1] else 0
                x21 = if classContext.validateCell(cells.cellX, cells.cellY + 1) then classContext.shipsMap[cells.cellY + 1][cells.cellX] else 0
                x22 = if classContext.validateCell(cells.cellX + 1, cells.cellY + 1) then classContext.shipsMap[cells.cellY + 1][cells.cellX + 1] else 0

                if (
                    x00 == 1 || x01 == 1 || x02 == 1 ||
                    x10 == 1 || x11 == 1 || x12 == 1 ||
                    x20 == 1 || x21 == 1 || x22 == 1
                )
                    isValid = false

                if @orient
                    cells.cellY -= 1
                else
                    cells.cellX -= 1

                count--
            return isValid

        addRotatingControl: () ->
            textureLeft = PIXI.Texture.fromImage('./imgs/rotate-arrow-left.png')
            textureRight = PIXI.Texture.fromImage('./imgs/rotate-arrow-right.png')
            buttonLeft = new PIXI.Sprite(textureLeft)
            buttonRight = new PIXI.Sprite(textureRight)
            buttonLeft.buttonMode = true
            buttonRight.buttonMode = true
            buttonLeft.interactive = true
            buttonRight.interactive = true
            buttonLeft.position.x = config.originalWidth - 200
            buttonLeft.position.y = config.originalHeight - 100
            buttonRight.position.x = config.originalWidth - 60
            buttonRight.position.y = config.originalHeight - 100
            buttonLeft.anchor.x = 0.5
            buttonLeft.anchor.y = 0.5
            buttonRight.anchor.x = 0.5
            buttonRight.anchor.y = 0.5
            buttonRight.click = buttonRight.tap = (data) =>
                @handleRotateRight()

            buttonLeft.click = buttonLeft.tap = (data) =>
                @handleRotateLeft()
            @what2Remove.push(buttonLeft)
            @what2Remove.push(buttonRight)
            @addChild(buttonLeft)
            @addChild(buttonRight)

        addStartBtn: () ->
            self = @
            texture = PIXI.Texture.fromImage('./imgs/battle.png')
            btn = new PIXI.Sprite(texture)
            btn.alpha = 0.6
            btn.disabled = true
            btn.buttonMode = true
            btn.interactive = true
            btn.position.x = config.originalWidth - 140
            btn.position.y = 90
            btn.anchor.x = 0.5
            btn.anchor.y = 0.5
            btn.click = btn.tap = (data) ->
                if !@disabled && !self.prepeared4Battle
                    self.prepeared4Battle = true
                    self.makeNormalShipCollor()
                    self.sendShips(self.shipsMap)
            @startBtn = btn
            @what2Remove.push(@startBtn)
            @addChild(btn)

        handleRotateRight: () ->
            if !@choosenShip
                return
            if @choosenShip.rotation > 4
                @choosenShip.rotation = 0
            else
                @choosenShip.rotation += Math.PI / 2
            setShipOrientation.call(@choosenShip)
            @clearPreviousShipPosition.call(@choosenShip, @)
            @validateShip.call(@choosenShip, @)
            @setShipCell.call(@choosenShip, @)

        handleRotateLeft: () ->
            if !@choosenShip
                return
            if @choosenShip.rotation < -4
                @choosenShip.rotation = 0
            else
                @choosenShip.rotation -= Math.PI / 2
            setShipOrientation.call(@choosenShip)
            @clearPreviousShipPosition.call(@choosenShip, @)
            @validateShip.call(@choosenShip, @)
            @setShipCell.call(@choosenShip, @)

        setShipOrientation = () ->
            rotatetionABS = Math.abs(parseInt(@rotation))
            if rotatetionABS == 1 || rotatetionABS == 4
                @orient = 1
                return
            @orient = 0

        setShipCell: (classContext) ->
            cells = classContext.getShipCells.call(@, classContext)
            classContext.placeSpriteObject.call(@, classContext, cells.cellY, cells.cellX)
            if !@valid
                return
            classContext.setShipInMap.call(@, classContext, cells.cellY, cells.cellX, @deckCount)

        getShipCells: (classContext) ->
            xParam = if !@orient then @width / 2 else @height / 2
            yParam = if !@orient then @height / 2 else @width / 2
            classContext.getCells({ x: @position.x, y: @position.y }, xParam, yParam)

        getCells: (position, xParam, yParam) ->
            xParam = xParam || 0
            yParam = yParam || 0
            calculateX = (position.x - @axisXFieldStartPos() * @scaleParams.x + xParam * @scaleParams.x) / (@cellSize * @scaleParams.x)
            calculateY = (position.y - @position.y - @axisYFieldStartPos() * @scaleParams.y + yParam * @scaleParams.y) / (@cellSize * @scaleParams.y)
            cellX = Math.round(calculateX) - 1
            cellY = Math.round(calculateY) - 1
            console.log(cellX)
            console.log(cellY)
            return { cellX: cellX, cellY: cellY }

        placeSpriteObject: (classContext, cellY, cellX, isYourZone) ->
            xParam = if !@orient then @width / 2 else @height / 2
            yParam = if !@orient then @height / 2 else @width / 2
            diffX = if !@orient then @deckCount - 1 else 0
            diffY = if @orient then @deckCount - 1 else 0
            if isNaN(diffX)
                diffX = 0
            clearPositionX = classContext.cellSize * (cellX - diffX) + classContext.axisXFieldStartPos(isYourZone) + xParam - 2
            clearPositionY = classContext.cellSize * (cellY - diffY) + classContext.axisYFieldStartPos() + yParam - 2
            @position.x = clearPositionX
            @position.y = clearPositionY

        setShipInMap: (classContext, cellY, cellX, count) ->
            if !classContext.validateCell(cellX, cellY) then return

            if !@shipLocation
                console.log('create')
                @shipLocation = []
            classContext.shipSum += count
            while count > 0
                classContext.shipsMap[cellY][cellX] = 1
                @shipLocation.push({ x: cellX, y: cellY })
                if @orient
                    cellY--
                else
                    cellX--
                count--

        clearPreviousShipPosition: (classContext) ->
            if @shipLocation && @shipLocation.length
                for pos in @shipLocation
                    classContext.shipsMap[pos.y][pos.x] = 0
                @shipLocation = []
                classContext.shipSum -= @deckCount

        checkIsAllShipsValid: () ->
            if !@startBtn
                return
            if @shipSum == config.shipsSum
                @startBtn.disabled = false
                @startBtn.alpha = 1
            else
                @startBtn.disabled = true
                @startBtn.alpha = 0.6

        sendShips: (map) ->
            console.error('Must be implemented in Game.js')

        fire: (map) ->
            console.error('Must be implemented in Game.js')

        waitOtherPlayerBeforeStart: () ->
            @addTransparentBg()
            textMessage = 'Waiting for the other player...'
            if !@waitingText
                @waitingText = @addText(textMessage, { font: "40px Verdana", fill: "black", stroke: "#FF0000", strokeThickness: 6 }, { x: config.originalWidth / 2, y: config.originalHeight / 2 })
            else
                @waitingText.setText(textMessage)
            @addPreloader()

        playSound: (src) ->
            try
                audio = new Audio()
                audio.src = src
                audio.volume = 0.5
                audio.addEventListener('ended', () ->
                    audio = null
                , false)
                if audio.canPlayType('audio/mp3')
                    audio.play()
                @audioTheme = audio
            catch e
                console.log e

        playTheme: () ->
            try
                audio = new Audio()
                audio.src = './audio/hespirate.mp3'
                audio.volume = 0.2
                audio.addEventListener('ended', () ->
                    this.currentTime = 0
                    this.play()
                , false)
                if audio.canPlayType('audio/mp3')
                    audio.play()
                @audioTheme = audio
            catch e
                console.log e

        stopTheme: () ->
            if @audioTheme
                @audioTheme.pause()
                @audioTheme.currentTime = 0
                @audioTheme = null

        setTurn: (isYourTurn) ->
            if isYourTurn && !@isYourTurn
                @playSound('./audio/turn.mp3')
            @isYourTurn = isYourTurn
            if @isYourTurn
                @isEnableFire = true
                @startTime = new Date().getTime()
                @timerOn()

        timerOn: () ->
            @timerId = setInterval(() =>
                diff = parseInt((new Date().getTime() - @startTime) / 1000) - 1
                if config.waitTime - diff <= 10
                    if config.waitTime - diff <= 0
                        @clearTimer()
                        @fire({ x: -1, y: -1 })
                    else
                        @timeText.setText(config.waitTime - diff)
            , 1000)

        clearTimer: () ->
            clearInterval(@timerId)
            @timeText.setText('')

        startGame: (data) ->
            @setTurn(data.isYourTurn)
            @stopTheme()
            @removeTransparentBg()
            @removePreloader()
            @removeChild(@waitingText)
            @removeBtns()
            @scaleParams = { x: 0.67, y: 0.67 }
            @position.y = 30
            @battleStarted = true
            @addBattleField(true, @axisXFieldStartPos() - @xPicMargin)
            @scale.set(@scaleParams.x, @scaleParams.y)
            @changeTurn()
            @addXSprite()
            @addCannon()
            @initTextureFireResult()
            @addHPBars()
            @addTimeText()

        addTimeText: () ->
            @timeText = @addText('', { font: "34px Fjalla One", fill: '#FFFFFF', stroke: "#000000", strokeThickness: 3 }, { x: (config.originalWidth), y: (config.originalHeight / @scaleParams - 300) })

        addHPBars: () ->
            texture1 = PIXI.Texture.fromImage('./imgs/yourHPbar.png')
            texture2 = PIXI.Texture.fromImage('./imgs/enemyHPbar.png')

            yourMask = new PIXI.Graphics()
            @addChild(yourMask)
            enemyMask = new PIXI.Graphics()
            @addChild(enemyMask)

            yourHP = new PIXI.Sprite(texture1)
            yourHP.position.x = @fieldPaddingX
            yourHP.position.y = 0
            @addChild(yourHP)

            yourHP.mask = yourMask
            @HPBars['your'] = yourHP
            @updateBar('your', 20)

            enemyHP = new PIXI.Sprite(texture2)
            enemyHP.position.x = config.originalWidth - @fieldPaddingX - 15
            enemyHP.position.y = 0
            @addChild(enemyHP)

            enemyHP.mask = enemyMask
            @HPBars['enemy'] = enemyHP
            @updateBar('enemy', 20)

        updateBar: (which, shipsCount) ->
            mask = @HPBars[which].mask
            height = 21
            if which == 'your'
                x = @HPBars['your'].position.x
                width = shipsCount / 2 * 53
            else
                diffX = (20 - shipsCount) / 2 * 53
                x = @HPBars[which].position.x + diffX
                width = shipsCount / 2 * 53
            mask.clear()
            mask.beginFill()
            mask.drawRect(x, 0, width, height)
            mask.endFill()

        makeNormalShipCollor: () ->
            @allShips.forEach((ship) =>
                ship.tilePosition.y = 0
            )

        removeBtns: () ->
            @what2Remove.forEach((el) =>
                @removeChild(el)
            )
            @what2Remove = []
            @startBtn = null

        missed: () ->
            console.log('MISS!')

        damaged: () ->
            console.log('DAMAGED!')

        kill: () ->
            console.log('KILL')

        changeTurn: () ->
            if @isYourTurn
                text = "Your turn!"
                color = 'lime'
            else
                text = "Your oponent turn!"
                color = 'red'
            if @turnText
                @removeChild(@turnText)
            @turnText = @addText(text, { font: "40px Fjalla One", fill: color, stroke: "#000000", strokeThickness: 3 }, { x: config.originalWidth / @scaleParams.x / 2, y: -10 })

        rerenderBattleField: (data) ->
            if @isYourTurn
                if data.cell
                    @renderFireResult(data.status, data.cell)
                    @updateShootMap(data.status, data.cell, data.updateCells)
            else
                @updateYourShipsMap(data.map)

            if data.isYourTurn
                if @isYourTurn
                    @updateBar('enemy', data.shipCountArr[1])
            else
                if !@isYourTurn
                    @updateBar('your', data.shipCountArr[0])

            @setTurn(data.isYourTurn)
            @changeTurn()

        renderFireResult: (status, cell, isYourZone) ->
            damageTexture = if isYourZone then @damagedTexture else @xTexture
            texture = if status == 2 then @missedTexture else damageTexture
            x = new PIXI.Sprite(texture)
            x.zIndex = 0
            x.anchor.x = 0.5
            x.anchor.y = 0.5
            @addChild(x)
            @placeSpriteObject.call(x, @, cell.y, cell.x, isYourZone)

        updateYourShipsMap: (map) ->
            for cells, j in @shootMap
                for value2, i in cells
                    if map[j][i] != @shipsMap[j][i]
                        @renderFireResult(map[j][i], { x: i, y: j }, true)
                        @shipsMap[j][i] = map[j][i]

        initTextureFireResult: () ->
            @missedTexture = PIXI.Texture.fromImage('./imgs/missedFireResult.png')
            @damagedTexture = PIXI.Texture.fromImage('./imgs/damagedFireResult.png')
            @xTexture = PIXI.Texture.fromImage('./imgs/x.png')

        updateShootMap: (status, cell, updateCells) ->
            @shootMap[cell.y][cell.x] = if status == 2 then 2 else 3
            if updateCells.length
                updateCells.forEach((eachCell) =>
                    @shootMap[eachCell.y][eachCell.x] = 2
                    @renderFireResult(2, eachCell)
                )

        showWinner: (data) ->
            if window.playerName == data.winner
                msg = "You win"
            else
                msg = "You lose"
            @battleStarted = false
            setTimeout(() =>
                alert(msg)
                setTimeout(() =>
                    location.reload()
                , 2000)
            , 2000)

        renderFireAnimations: () ->
            if !@fireSpritesArr.length then return
            for fireSprite in @fireSpritesArr
                xPos = fireSprite.tilePosition.x
                yPos = fireSprite.tilePosition.y
                if xPos + 128 == 512
                    fireSprite.tilePosition.x = 0
                    fireSprite.tilePosition.y = if yPos + 128 == 512 then 0 else yPos + 128
                else
                    fireSprite.tilePosition.x = xPos + 128

    return GameScene
)

