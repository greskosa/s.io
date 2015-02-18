define([
    'pixijs','Scene','StartScene'
],  function(PIXI,Scene,StartScene){
      function ScenesManager(){

      }
    ScenesManager.prototype.scenes={}
    ScenesManager.prototype.renderer=null
    ScenesManager.prototype.currentScene=null

     /**
     * Create an instance of Renderer
     *
     * @param {object} screen Width,Height or Scale of canvas.
     * @param {object} options Options of renderer, fox example transparent.
     */
    ScenesManager.prototype.create= function(screen,options){
        if (ScenesManager.prototype.renderer) return this
        console.log(screen)
        this.screen=screen
        ScenesManager.prototype.renderer= PIXI.autoDetectRenderer(screen.width, screen.height, options);
        document.body.appendChild(ScenesManager.prototype.renderer.view);
        requestAnimFrame(this.loop.bind(this));
        return this;
    }
    /**
    * Rerender current scene via requestAnimFrame
    *
    */
    ScenesManager.prototype.loop=function(){
        requestAnimFrame(function(){this.loop()}.bind(this));
        if (!this.currentScene || this.currentScene.isPaused()) return;
        this.currentScene.update();
        this.renderer.render(this.currentScene.rootStage);
    }
    /**
    * Create new scene
    *
    * @param {string} id Id of new scene.
    */
    ScenesManager.prototype.createScene=function(id){
        if (this.scenes[id]) return undefined; //doesn't create if exist
        var scene;
        switch (id){
            case 'StartScene':
                scene = new StartScene();
                break;
            default:
                scene=new Scene()
        }
        scene.setCanvasSize(this.screen.width,this.screen.height)
        scene.setScale(this.screen.scaleX,this.screen.scaleY)
        this.scenes[id] = scene;
        return scene;
    }
    /**
     * Change current scene
     *
     * @param {string} id Id of new scene.
     */
    ScenesManager.prototype.goToScene=function(id){
            if(!this.scenes[id]) return false;
            if(this.currentScene) this.currentScene.pause()
            this.currentScene= this.scenes[id]
            this.currentScene.resume()
            return true
    }









    return ScenesManager
}
)

