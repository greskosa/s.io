define([
    'pixijs','Scene', 'text!./../config.json'
],  (PIXI,Scene,config)->
    config=JSON.parse(config)
    class GameScene extends Scene
      gameFieldSize:450
      fieldPaddingX:40
      fieldPaddingY:40
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
      shipMap:[
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



      addBattleField:()->
        texture= PIXI.Texture.fromImage('./imgs/battlefield.png');
        field = new PIXI.Sprite(texture);
        field.buttonMode = true;
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
        @oneShip('./imgs/ship4.png',240,65,{x:850,y:100},4)
        @oneShip('./imgs/ship4.png',240,65,{x:850,y:100},4)
        @oneShip('./imgs/ship3.png',175,65,{x:850,y:200},3)
        @oneShip('./imgs/ship2.png',123,65,{x:850,y:300},2)
        @oneShip('./imgs/ship1.png',65,65,{x:850,y:400},1)

      oneShip:(src,width,height,position,deckCount)->
        self=@
        texture= PIXI.Texture.fromImage(src);
        ship = new PIXI.TilingSprite(texture,width,height);
        ship.anchor.x = 0.5;
        ship.anchor.y = 0.5;
        ship.buttonMode = true;
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

      shipHandlerClickStart:(classContext)->
        classContext.choosenShip=@
        @alpha = 0.8
        @dragging = true

      shipHandlerClickEnd:(classContext)->
        this.alpha = 1
        this.dragging = false;
        if @valid
          classContext.setShipCell.call(@,classContext)

      validateShip:(classContext,eventData)->
        if(eventData)
          @position.x = eventData.global.x
          @position.y = eventData.global.y
        if classContext.isValidShipLocation.call(@,classContext,eventData)
          @tilePosition.y=@height
          @valid=true
        else
          @valid=false
          @tilePosition.y=@height*2

      isValidShipLocation:(classContext)->
        return classContext.isInBattleField.call(@,classContext)

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
#        console.log @
        cells=classContext.getShipCells.call(@,classContext)
        isValid=true
        count=@deckCount
        x10=if classContext.validateCell(cells.cellX-1,cells.cellY) then classContext.shipMap[cells.cellY][cells.cellX-1] else 0
        x11=if classContext.validateCell(cells.cellX,cells.cellY) then classContext.shipMap[cells.cellY][cells.cellX] else 0
        x12=if classContext.validateCell(cells.cellX+1,cells.cellY) then classContext.shipMap[cells.cellY][cells.cellX+1] else 0

        x00=if classContext.validateCell(cells.cellX-1,cells.cellY-1) then classContext.shipMap[cells.cellY-1][cells.cellX-1] else 0
        x01=if classContext.validateCell(cells.cellX,cells.cellY-1) then classContext.shipMap[cells.cellY-1][cells.cellX] else 0
        x02=if classContext.validateCell(cells.cellX+1,cells.cellY-1) then classContext.shipMap[cells.cellY-1][cells.cellX+1] else 0

        x20=if classContext.validateCell(cells.cellX-1,cells.cellY+1) then classContext.shipMap[cells.cellY+1][cells.cellX-1] else 0
        x21=if classContext.validateCell(cells.cellX,cells.cellY+1) then classContext.shipMap[cells.cellY+1][cells.cellX] else 0
        x22=if classContext.validateCell(cells.cellX+1,cells.cellY+1) then classContext.shipMap[cells.cellY+1][cells.cellX+1] else 0

        while(count>0)
          console.log('cycle')
          if x00==1||x01==1||x02==1||
             x10==1||x11==1||x12==1||
             x20==1||x21==1||x22==1
            isValid=false

          if @orient
            cells.cellY--
          else
            cells.cellX--
          count--
        console.log('VALIDATE!')
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

      handleRotateRight:()->
        if !@choosenShip
          return
        if(@choosenShip.rotation>4)
          @choosenShip.rotation=0
        else
          @choosenShip.rotation += Math.PI/2;
        setShipOrientation.call(@choosenShip)
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
        if !@valid
          return
        cells=classContext.getShipCells.call(@,classContext)
        classContext.setShipInMap.call(@,classContext,cells.cellY,cells.cellX,@deckCount)
        classContext.placeShip.call(@,classContext,cells.cellY,cells.cellX)

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
        clearPositionX=classContext.cellSize*(cellX-diffX)+classContext.axisXFieldStartPos()+xParam
        clearPositionY=classContext.cellSize*(cellY-diffY)+classContext.axisYFieldStartPos()+yParam
        @position.x=clearPositionX
        @position.y=clearPositionY

      setShipInMap:(classContext,cellY,cellX,count)->
#        ship context
        if !classContext.validateCell(cellX,cellY) then return

        if !@shipLocation
          console.log('create')
          @shipLocation=[]
        else
          classContext.clearPreviousShipPosition.call(@,classContext)
        while(count>0)
          classContext.shipMap[cellY][cellX]=1
          @shipLocation.push({x:cellX,y:cellY})
          if @orient
            cellY--
          else
            cellX--
          count--
        console.log(classContext.shipMap)

      clearPreviousShipPosition:(classContext)->
        if @shipLocation.length
          for pos in  @shipLocation
           classContext.shipMap[pos.y][pos.x]=0
          @shipLocation=[]





    return GameScene

)

