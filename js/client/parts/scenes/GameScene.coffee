define([
    'pixijs','Scene', 'text!./../config.json'
],  (PIXI,Scene,config)->
    config=JSON.parse(config)
    class GameScene extends Scene
      gameFieldSize:450
      fieldPaddingX:40
      fieldPaddingY:40

      constructor:(screen)->
          super(screen)
          @addBattleField()
          @addShips()



      addBattleField:()->
        texture= PIXI.Texture.fromImage('./imgs/battlefield.png');
        field = new PIXI.Sprite(texture);
        field.buttonMode = true;
        field.interactive = true;
        field.mousedown=field.tap= @clickHandler
        field.position.x=@getPaddingX()
        field.position.y=@getPaddingY()
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
        #        ship.anchor.x = 0.5;
        #        ship.anchor.y = 0.5;
        #        ship.position.x = 0;
        #        ship.position.y = 0;
        #        ship.tilePosition.y=0
        #        ship.tilePosition.x=0
        ship.mousedown = ship.touchstart = (data)->
          @data = data
          @alpha = 0.8
          @dragging = true
          @sx = @data.getLocalPosition(ship).x;
          @sy = @data.getLocalPosition(ship).y;

        ship.mouseup = ship.mouseupoutside = ship.touchend = ship.touchendoutside = (data)->
          this.alpha = 1
          this.dragging = false;
          this.data = null;
          @tilePosition.y=0

        ship.buttonMode = true;
        ship.interactive = true;
        ship.position.x = position.x;
        ship.position.y = position.y;
        ship.mousemove = ship.touchmove = (data)->
      			self.shipHandlerMove.call(@,self,data,height)
        @addChild(ship)

      shipHandlerMove:(context,eventData,height)->
#        console.log(@)
        if(@dragging)
            @position.x = @data.getLocalPosition(@parent).x - @sx
            @position.y = @data.getLocalPosition(@parent).y - @sy
            console.log(height)
            if context.isShipLocationVaild(eventData)
              console.log('1')
              @tilePosition.y=height
            else
              console.log('2')
              @tilePosition.y=height*2

#        console.log @
#        @tilePosition.y=height

      isShipLocationVaild:(eventData)->
        position=eventData.getLocalPosition(@parent)
        console.log position
        return position.x>232&&position.y>128&&position.x<602&&position.y<682

    return GameScene

)

