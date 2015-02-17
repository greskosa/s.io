require.config({
    urlArgs : 'antichache',
    baseUrl:"./js/client",
    paths:{
        pixijs:'./libs/pixi',
        connection:'./parts/connection',
        checkWebGl:'./parts/checkWebGl',
        game:'./parts/game'
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