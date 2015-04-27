define([
],  ()->
  class Device

     constructor:()->
       @fullScreenDomEl=document.getElementById('fullscreen-request')
       @hideIfPc()

     hideFullScreenDom:()->
        @fullScreenDomEl.style.display="none"

     makeFullscreen:(element)->
        @hideFullScreenDom()
        @start()
        if (element.requestFullscreen)
            element.requestFullscreen();
        else if (element.msRequestFullscreen)
            element.msRequestFullscreen();
        else if (element.mozRequestFullScreen)
            element.mozRequestFullScreen();
        else if (element.webkitRequestFullscreen)
            element.webkitRequestFullscreen();


     hideIfPc:()->
       if !@isMobile()
         @hideFullScreenDom()
         @start()

     isMobile:()->
       return navigator.userAgent.match(/Android/i)|| navigator.userAgent.match(/webOS/i)||navigator.userAgent.match(/iPhone/i)||navigator.userAgent.match(/iPad/i)||navigator.userAgent.match(/iPod/i)|| navigator.userAgent.match(/BlackBerry/i)||navigator.userAgent.match(/Windows Phone/i)

     start:()->
        require(["./parts/connections"])





  window.device=new Device()
  return device
)

