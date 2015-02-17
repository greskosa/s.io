define([
    'pixijs',
    'text!../config.json'
],  function(PIXI,config){
        config=JSON.parse(config)
function Game(){
       this.canvasWidth=window.outerWidth>800? 800:window.outerWidth
       this.canvasHeight=window.outerHeight>600? 600:window.outerHeight
       // create an new instance of a pixi stage
       this.stage = new PIXI.Stage();

       // create a renderer instance.
       var renderer
       if(window.WebGl){
           this.renderer = new PIXI.WebGLRenderer(this.canvasWidth, this.canvasHeight,{transparent:true});
       }
       else
           this.renderer= PIXI.autoDetectRenderer(this.canvasWidth, this.canvasHeight,{transparent:true});
       document.body.appendChild(this.renderer.view);
       requestAnimFrame(this.animate.bind(this));

}
Game.prototype.animate=function(){
    requestAnimFrame(this.animate.bind(this));
    this.renderer.render(this.stage);
}
Game.prototype.addGameTitle=function(){
    this.addText(config.appName,{font:"60px Verdana", fill:"black",stroke: "#FF0000", strokeThickness: 6},{x:this.canvasWidth/2,y:this.canvasHeight/3})
}
Game.prototype.addText=function(text,options,position){
    var text = new PIXI.Text(text, options);
    text.position.x=position.x;
    text.position.y=position.y;
    // center the sprites anchor point
    text.anchor.x = 0.5;
    text.anchor.y = 0.5;
    this.stage.addChild(text);
}
Game.prototype.addSuccesStageUi=function(name){
    this.addStartBtns()
    this.addPlayerName(name)
}
Game.prototype.addFailedStageUi=function(err){
    this.addErrorMessage(err)
}
Game.prototype.addStartBtns=function(){


}
Game.prototype.addErrorMessage=function(msg){
    console.log(msg)
    this.addText(msg,{font:"28px Verdana", fill:"#FF0000",stroke: "black", strokeThickness: 3},{x:this.canvasWidth/2,y:this.canvasHeight*2/3})
}
Game.prototype.addPlayerName=function(name){
    this.addText("Your name:"+name,{font:"16px Verdana", fill:"#FF0000",stroke: "black", strokeThickness: 2},{x:this.canvasWidth-128,y:20})
}




        // add the renderer view element to the DOM






        //// create a texture from an image path
        //var texture = PIXI.Texture.fromImage("imgs/bunny.png");
        //// create a new Sprite using the texture
        //var bunny = new PIXI.Sprite(texture);
        //// center the sprites anchor point
        //bunny.anchor.x = 0.5;
        //bunny.anchor.y = 0.5;
        //
        //// move the sprite t the center of the screen
        //bunny.position.x = 200;
        //bunny.position.y = 150;
        //
        //stage.addChild(bunny);

    return new Game()
}
)

