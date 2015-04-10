define([
    'pixijs','Scene', 'text!./../config.json'
],  (PIXI,Scene,config)->
    config=JSON.parse(config)
    class GameScene extends Scene
      gameFieldSize:450
      fieldPaddingX:40
      fieldPaddingY:40
      shipSum:0
      choosenShip:null
      axisXFieldStartPos:()->
        return @fieldPaddingX+63

      axisYFieldStartPos:()->
        return @fieldPaddingY+63

      axisXFieldEndPos:()->
          return @axisXFieldStartPos()+@cellSize*10

      axisYFieldEndPos:()->
        return @axisYFieldStartPos()+@cellSize*10

      cellSize:60
      shipsMap:[
               [0,0,0,0,0,0,0,0,0,0],
               [0,0,0,0,0,0,0,0,0,0],
               [0,0,0,0,0,0,0,0,0,0],
               [0,0,0,0,0,0,0,0,0,0],
               [0,0,0,0,0,0,0,0,0,0],
               [0,0,0,0,0,0,0,0,0,0],
               [0,0,0,0,0,0,0,0,0,0],
               [0,0,0,0,0,0,0,0,0,0],
               [0,0,0,0,0,0,0,0,0,0],
               [0,0,0,0,0,0,0,0,0,0]
      ]

      constructor:(screen)->
          super(screen)
          @addBattleField()
          @addShips()
          @addRotatingControl()
          @addStartBtn()
          @onUpdate(()=>
              @checkIsAllShipsValid()
              @updatePreloader()
          )
          @playTheme()

      addBattleField:()->
        texture= PIXI.Texture.fromImage('./imgs/battlefield.png');
        field = new PIXI.Sprite(texture);
        field.buttonMode = true;
        field.zIndex = 0;
        field.interactive = true;
        field.mousedown=field.tap= @clickHandler
        field.position.x=@getPaddingX()
        field.position.y=@getPaddingY()
        @bf=field
        @addChild(field)

      changeText:(text)->
        if(@text) then @text.setText(text)


      getPaddingX:(index=1)->
        return @fieldPaddingX*index

      getPaddingY:(index=1)->
        return @fieldPaddingY*index

      getGameFieldSize:()->
        return @gameFieldSize


      clickHandler:(data)->
          newPosition = data.getLocalPosition(this.parent);
          console.log(newPosition)

      addShips:()->
        xPos=@size.width-140
        @oneShip('./imgs/ship4.png',240,65,{x:xPos,y:200},4)
        @oneShip('./imgs/ship3.png',175,65,{x:xPos,y:300},3)
        @oneShip('./imgs/ship3.png',175,65,{x:xPos,y:300},3)
        @oneShip('./imgs/ship2.png',123,65,{x:xPos,y:400},2)
        @oneShip('./imgs/ship2.png',123,65,{x:xPos,y:400},2)
        @oneShip('./imgs/ship2.png',123,65,{x:xPos,y:400},2)
        @oneShip('./imgs/ship1.png',65,65,{x:xPos,y:500},1)
        @oneShip('./imgs/ship1.png',65,65,{x:xPos,y:500},1)
        @oneShip('./imgs/ship1.png',65,65,{x:xPos,y:500},1)
        @oneShip('./imgs/ship1.png',65,65,{x:xPos,y:500},1)

      oneShip:(src,width,height,position,deckCount)->
        self=@
        texture= PIXI.Texture.fromImage(src);
        ship = new PIXI.TilingSprite(texture,width,height);
        ship.zIndex = 1;
        ship.anchor.x = 0.5;
        ship.anchor.y = 0.5;
        ship.interactive = true;
        ship.position.x = position.x;
        ship.position.y = position.y;
        ship.deckCount= deckCount;
        ship.mousemove = ship.touchmove = (data)->
      			self.shipHandlerMove.call(@,self,data)

        ship.mousedown = ship.touchstart = (data)->
          self.shipHandlerClickStart.call(@,self)
        ship.mouseup = ship.mouseupoutside = ship.touchend  = (data)->
          self.shipHandlerClickEnd.call(@,self)
        @addChild(ship)

      shipHandlerMove:(classContext,eventData)->
        if(@dragging)
            classContext.validateShip.call(@,classContext,eventData)


      updateLayersOrder: () ->
          @children.sort((a,b) ->
              zIndex1 = a.zIndex || 0;
              zIndex2 = b.zIndex || 0;
              return  zIndex1-zIndex2
          );
          console.log(@children)


      shipHandlerClickStart:(classContext)->
#        ship context
        @zIndex=2
#        classContext.updateLayersOrder()
        classContext.clearPreviousShipPosition.call(@,classContext)
        classContext.choosenShip=@
        @alpha = 0.8
        @dragging = true

      shipHandlerClickEnd:(classContext)->
#        ship context
        if @dragging
          @alpha = 1
          @dragging = false;
          if @valid
            console.log('VALID!')
            classContext.setShipCell.call(@,classContext)

      validateShip:(classContext,eventData)->
        if(eventData)
          @position.x = eventData.global.x
          @position.y = eventData.global.y
        isV=classContext.isValidShipLocation.call(@,classContext,eventData)
        if isV
          @tilePosition.y=@height
          @valid=true
        else
          @valid=false
          @tilePosition.y=@height*2

      isValidShipLocation:(classContext)->
        return classContext.isInBattleField.call(@,classContext)&&classContext.validateSpaceBeetweenShips.call(@,classContext)

      isInBattleField:(classContext)->
#        ship context
        xParam= if !@orient then @width else @height
        yParam= if !@orient then @height else @width
        xBorderLeft=classContext.axisXFieldStartPos()+xParam*0.45
        yBorderUp=classContext.axisYFieldStartPos()+yParam*0.45
        yBorderRight=classContext.axisXFieldEndPos()-xParam*0.45
        yBorderDown=classContext.axisYFieldEndPos()-yParam*0.45
        return @position.x>xBorderLeft&&@position.y>yBorderUp&&@position.x<yBorderRight&&@position.y<yBorderDown

      validateCell:(cellX,cellY)->
        if cellX>9 or cellX<0 or cellY<0 or cellY>9
          return false
        return true

      validateSpaceBeetweenShips:(classContext)->
#        ship context
        cells=classContext.getShipCells.call(@,classContext)
        isValid=true
        count=@deckCount
        while(count>0)
          x10=if classContext.validateCell(cells.cellX-1,cells.cellY) then classContext.shipsMap[cells.cellY][cells.cellX-1] else 0
          x11=if classContext.validateCell(cells.cellX,cells.cellY) then classContext.shipsMap[cells.cellY][cells.cellX] else 0
          x12=if classContext.validateCell(cells.cellX+1,cells.cellY) then classContext.shipsMap[cells.cellY][cells.cellX+1] else 0

          x00=if classContext.validateCell(cells.cellX-1,cells.cellY-1) then classContext.shipsMap[cells.cellY-1][cells.cellX-1] else 0
          x01=if classContext.validateCell(cells.cellX,cells.cellY-1) then classContext.shipsMap[cells.cellY-1][cells.cellX] else 0
          x02=if classContext.validateCell(cells.cellX+1,cells.cellY-1) then classContext.shipsMap[cells.cellY-1][cells.cellX+1] else 0

          x20=if classContext.validateCell(cells.cellX-1,cells.cellY+1) then classContext.shipsMap[cells.cellY+1][cells.cellX-1] else 0
          x21=if classContext.validateCell(cells.cellX,cells.cellY+1) then classContext.shipsMap[cells.cellY+1][cells.cellX] else 0
          x22=if classContext.validateCell(cells.cellX+1,cells.cellY+1) then classContext.shipsMap[cells.cellY+1][cells.cellX+1] else 0
          if x00==1||x01==1||x02==1||
             x10==1||x11==1||x12==1||
             x20==1||x21==1||x22==1
            isValid=false

          if @orient
            cells.cellY-=1
          else
            cells.cellX-=1

          count--
        return isValid

      addRotatingControl:()->
          textureLeft= PIXI.Texture.fromImage('./imgs/rotate-arrow-left.png');
          textureRight= PIXI.Texture.fromImage('./imgs/rotate-arrow-right.png');
          buttonLeft = new PIXI.Sprite(textureLeft);
          buttonRight = new PIXI.Sprite(textureRight);
          buttonLeft.buttonMode = true;
          buttonRight.buttonMode = true;
          #            // make the button interactive..
          buttonLeft.interactive = true;
          buttonRight.interactive = true;
          buttonLeft.position.x = @size.width-200;
          buttonLeft.position.y = @size.height-100;
          buttonRight.position.x = @size.width-60;
          buttonRight.position.y = @size.height-100;
          buttonLeft.anchor.x = 0.5;
          buttonLeft.anchor.y = 0.5;
          buttonRight.anchor.x = 0.5;
          buttonRight.anchor.y = 0.5;
          buttonRight.click = buttonRight.tap =  (data) =>
            @handleRotateRight()

          buttonLeft.click = buttonLeft.tap =  (data) =>
           @handleRotateLeft()

          @addChild(buttonLeft)
          @addChild(buttonRight)

      addStartBtn:()->
          self=@
          texture= PIXI.Texture.fromImage('./imgs/battle.png');
          btn = new PIXI.Sprite(texture);
          btn.alpha= 0.6
          btn.disabled= true
          btn.buttonMode = true;
          #            // make the button interactive..
          btn.interactive = true;
          btn.position.x = @size.width-140;
          btn.position.y = 90
          btn.anchor.x = 0.5;
          btn.anchor.y = 0.5;
          btn.click = btn.tap =  (data) ->
            if !@disabled
              self.sendShips(self.shipsMap)
          @startBtn=btn
          @addChild(btn)

      handleRotateRight:()->
        if !@choosenShip
          return
        if(@choosenShip.rotation>4)
          @choosenShip.rotation=0
        else
          @choosenShip.rotation += Math.PI/2;
        setShipOrientation.call(@choosenShip)
        @clearPreviousShipPosition.call(@choosenShip,@)
        @validateShip.call(@choosenShip,@)
        @setShipCell.call(@choosenShip,@)


      handleRotateLeft:()->
        if !@choosenShip
           return
        if(@choosenShip.rotation<-4)
           @choosenShip.rotation=0
        else
           @choosenShip.rotation -= Math.PI/2;
        setShipOrientation.call(@choosenShip)
        @clearPreviousShipPosition.call(@choosenShip,@)
        @validateShip.call(@choosenShip,@)
        @setShipCell.call(@choosenShip,@)


      setShipOrientation=()->
#        ship context
        rotatetionABS=Math.abs(parseInt(@rotation))
        if rotatetionABS==1||rotatetionABS==4
            @orient=1
            return
        @orient=0

      setShipCell:(classContext)->
#        ship context
        cells=classContext.getShipCells.call(@,classContext)
        classContext.placeShip.call(@,classContext,cells.cellY,cells.cellX)
        if !@valid
            return
        classContext.setShipInMap.call(@,classContext,cells.cellY,cells.cellX,@deckCount)

      getShipCells:(classContext)->
        xParam=if !@orient then @width/2 else @height/2
        yParam=if !@orient then @height/2 else @width/2
        calculateX =(@position.x-classContext.axisXFieldStartPos()+xParam)/(classContext.cellSize)
        calculateY=(@position.y-classContext.axisYFieldStartPos()+yParam)/(classContext.cellSize)
        cellX= Math.round(calculateX)-1
        cellY= Math.round(calculateY)-1
        return {cellX:cellX,cellY:cellY}

      placeShip:(classContext,cellY,cellX)->
#        ship context
        xParam=if !@orient then @width/2 else @height/2
        yParam=if !@orient then @height/2 else @width/2
        diffX=if !@orient then @deckCount-1 else 0
        diffY=if @orient then @deckCount-1 else 0
        clearPositionX=classContext.cellSize*(cellX-diffX)+classContext.axisXFieldStartPos()+xParam-2 #2px fix middle
        clearPositionY=classContext.cellSize*(cellY-diffY)+classContext.axisYFieldStartPos()+yParam-2 #2px fix middle
        @position.x=clearPositionX
        @position.y=clearPositionY

      setShipInMap:(classContext,cellY,cellX,count)->
#        ship context
        if !classContext.validateCell(cellX,cellY) then return

        if !@shipLocation
          console.log('create')
          @shipLocation=[]
        classContext.shipSum+=count
        while(count>0)
          classContext.shipsMap[cellY][cellX]=1
          @shipLocation.push({x:cellX,y:cellY})
          if @orient
            cellY--
          else
            cellX--
          count--
        console.log(classContext.shipSum)
#        console.log(classContext.shipsMap)

      clearPreviousShipPosition:(classContext)->
        if @shipLocation&&@shipLocation.length
          for pos in  @shipLocation
           classContext.shipsMap[pos.y][pos.x]=0
          @shipLocation=[]
          console.log @deckCount
          classContext.shipSum-=@deckCount
          console.log(classContext.shipSum)
          
          
      checkIsAllShipsValid:()->
        if @shipSum==20
          @startBtn.disabled=false
          @startBtn.alpha=1
        else
          @startBtn.disabled=true
          @startBtn.alpha=0.6

      sendShips:(map)->
        console.error('Must be implemented in Game.js')

      waitOtherPlayerBeforeStart:()->
        @addTransparentBg()
        textMessage='Waiting for the other player...'
        if(!@text)
          @text=@addText(textMessage,{font:"40px Verdana", fill:"black",stroke: "#FF0000", strokeThickness: 6},{x:@size.width/2+10,y:@size.height/2})
        else
           @text.setText(textMessage)
        @addPreloader()

      playTheme:()->
        console.log('play')
        try
          audio = new Audio();
          audio.src='./audio/hespirate.mp3'
          audio.volume=0.2
          audio.addEventListener('ended', () ->
              this.currentTime = 0;
              this.play();
          , false);
          if audio.canPlayType('audio/mp3')
            audio.play()
          @audioTheme=audio
        catch e
            console.log e


      stopTheme:()->
       @audioTheme.pause()
       @audioTheme.currentTime=0
       @audioTheme=null


      startGame:()->
        @stopTheme()



    return GameScene

)

