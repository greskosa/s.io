require.config({
    urlArgs : 'antichache',
    baseUrl:"./js/client",
    paths:{
        pixijs:'./libs/pixi',
        connections:'./parts/connections',
        game:'./parts/game',
        Scene:'./parts/scenes/SceneBase',
        ScenesManager:'./parts/ScenesManager',
        StartScene:'./parts/scenes/StartScene',
        CreateGameScene:'./parts/scenes/CreateGameScene'
    },
    shim: {
        pixijs:{
            exports:'PIXI'
        },
        game:{
            deps:["pixijs"]
        }
    },



//#    kick start application
    deps: ['./parts/connections']
});