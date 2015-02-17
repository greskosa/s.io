define([
    'pixijs'
],  function(PIXI){
  function Scene(){
      this.updateCallback=null
      this.paused=false

      this.onUpdate=function(updateCallback){
          if(!updateCallback) return false
          this.updateCallback=updateCallback
          return true;
      }
      this.update=function(){
          if(this.updateCallback) this.updateCallback()
      }
      this.pause=function(){
          this.paused = true;
      }
      this.resume=function(){
        this.paused = false;
      }
      this.isPaused=function() {
          return this.paused;
      }
      this.addText=function(text,options,position){
          console.log(this)
          var text = new PIXI.Text(text, options);
          text.position.x=position.x;
          text.position.y=position.y;
          // center the sprites anchor point
          text.anchor.x = 0.5;
          text.anchor.y = 0.5;
          this.addChild(text);
      }
      this.addButton=function(imgDefault,imgDown,imgOver,position){
            // create some textures from an image path
            var textureButton,textureButtonDown,textureButtonOver;
            textureButton= PIXI.Texture.fromImage(imgDefault);
            textureButtonDown = PIXI.Texture.fromImage(imgDown);
            if(imgOver)
                textureButtonOver = PIXI.Texture.fromImage(imgOver);
            var button = new PIXI.Sprite(textureButton);
            button.buttonMode = true;
            // make the button interactive..
            button.interactive = true;
            button.anchor.x = 0.5;
            button.anchor.y = 0.5;
            button.position.x = position.x
            button.position.y = position.y
            button.mousedown = button.touchstart = function(data) {
                      this.isdown = true;
                      this.setTexture(textureButtonDown);
                      this.alpha = 1;
            };
           // set the mouseup and touchend callback..
            button.mouseup = button.touchend = button.mouseupoutside = button.touchendoutside = function(data) {
              this.isdown = false;
              if (textureButtonOver&&this.isOver)
              {
                  this.setTexture(textureButtonOver);
              }
              else
              {
                  this.setTexture(textureButton);
              }
            };
                // set the mouseover callback..
            button.mouseover = function(data) {
                this.isOver = true;
                if (this.isdown||!textureButtonOver)
                    return;
                this.setTexture(textureButtonOver);
            };
            // set the mouseout callback..
            button.mouseout = function(data) {
                this.isOver = false;

                if (this.isdown)
                    return;
                this.setTexture(textureButton)
            }
            this.addChild(button)
      }
  }
  Scene.prototype=new PIXI.Stage()
  Scene.prototype.constructor=Scene


  return Scene
}
)

