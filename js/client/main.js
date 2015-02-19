require.config({
    urlArgs : 'antichache',
    baseUrl:"./js/client",
    paths:{
        pixijs:'./libs/pixi',
        connection:'./parts/connection',
        checkWebGl:'./parts/checkWebGl',
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
            deps:["pixijs","checkWebGl"]
        }
    },



//#    kick start application
    deps: ['./parts/connection']
});