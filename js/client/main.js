require.config({
    urlArgs : 'antichache',
    baseUrl:"./js/client",
    paths:{
        pixijs:'./libs/pixi',
        connection:'./parts/connection',
        checkWebGl:'./parts/checkWebGl',
        canvas:'./parts/canvas'
    },
    shim: {
        pixijs:{
            exports:'PIXI'
        },
        canvas:{
            deps:["pixijs","checkWebGl"]
        }
    },



//#    kick start application
    deps: ['./parts/connection']
});