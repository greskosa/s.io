define([
    'pixijs'
],  function(PIXI){
        var canvasWidth=window.outerWidth>800? 800:window.outerWidth
        var canvasHeight=window.outerHeight>600? 600:window.outerHeight
        // create an new instance of a pixi stage
        var stage = new PIXI.Stage();

        // create a renderer instance.
        var renderer
        if(window.WebGl){
            renderer = new PIXI.WebGLRenderer(canvasWidth, canvasHeight,{transparent:true});
        }
        else
            renderer= PIXI.autoDetectRenderer(canvasWidth, canvasHeight,{transparent:true});


        // add the renderer view element to the DOM
        document.body.appendChild(renderer.view);


        var text = new PIXI.Text("SeaBattle 1.0", {font:"60px Verdana", fill:"black",stroke: "#FF0000", strokeThickness: 6});
        text.position.x=canvasWidth/2
        text.position.y=canvasHeight/3
        // center the sprites anchor point
        text.anchor.x = 0.5;
        text.anchor.y = 0.5;
        stage.addChild(text);
        requestAnimFrame( animate );


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

        function animate() {

            requestAnimFrame( animate );

            // just for fun, lets rotate mr rabbit a little
//            bunny.rotation += 0.1;

            // render the stage
            renderer.render(stage);
        }
}
)

