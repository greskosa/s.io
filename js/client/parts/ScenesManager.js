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
     * @param {number} width Width of canvas.
     * @param {number} height Width of canvas.
     * @param {number} object Options of renderer, fox example transparent.
     */
    ScenesManager.prototype.create= function(width,height,options){
        if (ScenesManager.prototype.renderer) return this
        this.width=width
        this.height=height
        if(window.WebGl){
          ScenesManager.prototype.renderer = new PIXI.WebGLRenderer(width, height, options);
        }
        else
          ScenesManager.prototype.renderer= PIXI.autoDetectRenderer(width, height, options);
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
        scene.setCanvasSize(this.width,this.height)
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

