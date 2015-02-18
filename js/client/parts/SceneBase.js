define([
    'pixijs'
],  function(PIXI){
  function Scene(){
      this.updateCallback=null
      this.paused=false
      this.size={}
      this.scale={}
      this.size.width=0
      this.size.height=0
      this.scale.scaleX=1
      this.scale.scaleY=1

      this.setCanvasSize=function(width,height){
          this.size.width=width
          this.size.height=height
      }
      this.setScale=function(scaleX,scaleY){
          this.scale.scaleX=scaleX
          this.scale.scaleY=scaleY
      }
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
          text.scale.x = this.scale.scaleX
          text.scale.y = this.scale.scaleY+0.1 //#hard fix
          this.addChild(text);
      }
      this.addButton=function(imgDefault,imgDown,imgOver,position){
            var self=this
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
            button.scale.x = this.scale.scaleX
            button.scale.y = this.scale.scaleY
            button.position.x = position.x
            button.position.y = position.y
            button.mousedown = button.touchstart = function(data) {
                if(self.isPaused()) return
                      this.isdown = true;
                      this.setTexture(textureButtonDown);
                      this.alpha = 1;
            };
           // set the mouseup and touchend callback..
            button.mouseup = button.touchend = button.mouseupoutside = button.touchendoutside = function(data) {
              if(self.isPaused()) return
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
                if(self.isPaused()) return
                this.isOver = true;
                if (this.isdown||!textureButtonOver)
                    return;
                this.setTexture(textureButtonOver);
            };
            // set the mouseout callback..
            button.mouseout = function(data) {
                if(self.isPaused()) return
                this.isOver = false;

                if (this.isdown)
                    return;
                this.setTexture(textureButton)
            }
            this.addChild(button)
      }
  }
  stage=new PIXI.Stage()
  Scene.prototype=stage
  Scene.prototype.rootStage=stage
  Scene.prototype.constructor=Scene


  return Scene
}
)

