define([
    'pixijs','Scene', 'text!./../config.json'
],  (PIXI,Scene,config)->
    config=JSON.parse(config)
    class GameScene extends Scene
      gameFieldSize:450
      fieldPaddingX:40
      fieldPaddingY:40
      choosenShip:null

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
        @oneShip('./imgs/ship4.png',240,65,{x:750,y:100})
        @oneShip('./imgs/ship3.png',175,65,{x:750,y:200})
        @oneShip('./imgs/ship2.png',123,65,{x:750,y:300})
        @oneShip('./imgs/ship1.png',65,65,{x:750,y:400})

      oneShip:(src,width,height,position)->
        self=@
        texture= PIXI.Texture.fromImage(src);
        ship = new PIXI.TilingSprite(texture,width,height);
        ship.mousedown = ship.touchstart = (data)->
          self.choosenShip=@
          @data = data
          @alpha = 0.8
          @dragging = true
        ship.mouseup = ship.mouseupoutside = ship.touchend  = (data)->
          this.alpha = 1
          this.dragging = false;
          this.data = null;
        ship.anchor.x = 0.5;
        ship.anchor.y = 0.5;
        ship.buttonMode = true;
        ship.interactive = true;
        ship.position.x = position.x;
        ship.position.y = position.y;
        ship.mousemove = ship.touchmove = (data)->
      			self.shipHandlerMove.call(@,self,data)
        @addChild(ship)

      shipHandlerMove:(classContext,eventData)->
        if(@dragging)
            classContext.validateShip.call(@,classContext,eventData)

      validateShip:(classContext,eventData)->
        if(eventData)
          @position.x = eventData.global.x
          @position.y = eventData.global.y
        if classContext.isValidShipLocation.call(@,classContext,eventData)
          @tilePosition.y=@height
        else
          @tilePosition.y=@height*2

      isValidShipLocation:(classContext)->
        return classContext.isInBattleField.call(@)

      isInBattleField:()->
#        if eventData
#          @currentPosition=eventData.global
        xParam= if !@orient then @width else @height
        yParam= if !@orient then @height else @width
        xBorderLeft=103+xParam*0.45
        yBorderUp=103+yParam*0.45
        yBorderRight=703-xParam*0.45
        yBorderDown=703-yParam*0.45
        return @position.x>xBorderLeft&&@position.y>yBorderUp&&@position.x<yBorderRight&&@position.y<yBorderDown

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
        console.log 2
        setShipOrientation.call(@choosenShip)
        @validateShip.call(@choosenShip,@)


      handleRotateLeft:()->
        if !@choosenShip
           return
        if(@choosenShip.rotation<-4)
           @choosenShip.rotation=0
        else
           @choosenShip.rotation -= Math.PI/2;
        console.log 1
        setShipOrientation.call(@choosenShip)
        @validateShip.call(@choosenShip,@)


      setShipOrientation=()->
        rotatetionABS=Math.abs(parseInt(@rotation))
        if rotatetionABS==1||rotatetionABS==4
            @orient=1
            return
        @orient=0

    return GameScene

)

