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
          return
#          @hitArea = new PIXI.Rectangle(0, 0, @getGameFieldSize(), @getGameFieldSize());
#          @interactive = true;
#          @buttonMode = true;
#          graphics = new PIXI.Graphics();
#
#          graphics.beginFill(0xFFFF00);
#
##      // set the line style to have a width of 5 and set the color to red
#          graphics.lineStyle(5, 0xFF0000);
#
##      // draw a rectangle
#          graphics.drawRect(@getPaddingX(), @getPaddingY(), @getGameFieldSize(), @getGameFieldSize());
#          graphics.drawRect(@getGameFieldSize()+@getPaddingX(2), @getPaddingY(), @getGameFieldSize(), @getGameFieldSize());
#
#          @addChild(graphics);

#          @addTransparentBg()
#          @loadingWait()


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
          alert 1
          newPosition = data.getLocalPosition(this.parent);
          console.log(newPosition)

    return GameScene

)

