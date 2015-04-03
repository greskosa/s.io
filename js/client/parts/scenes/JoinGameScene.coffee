define([
    'pixijs','Scene', 'text!./../config.json'
],  (PIXI,Scene,config)->
    config=JSON.parse(config)

    class JoinGameScene extends Scene
      constructor:(screen)->
          super(screen)


      renderAvailableRooms:(rooms)->
       console.log(rooms)
       count=0
       for index of  rooms
         @renderRoom(rooms[index],count)
         count++


      renderRoom:(room,count)->
        @addText(room.roomName,{font:"15px Verdana", fill:"white",stroke: "#FFFFFF", strokeThickness: 1},{x:200,y:100+count*50})
        @addText(room.host,{font:"15px Verdana", fill:"white",stroke: "#FFFFFF", strokeThickness: 1},{x:400,y:100+count*50})
        @addText(@getTime(room.created),{font:"15px Verdana", fill:"white",stroke: "#FFFFFF", strokeThickness: 1},{x:600,y:100+count*50})
        @addText(room.playersCount+"/2",{font:"15px Verdana", fill:"white",stroke: "#FFFFFF", strokeThickness: 1},{x:800,y:100+count*50})
        console.log(room.host)

      getTime:(created)->
        date=new Date(created)
        console.log(date.getHours().toString().length)
        h= if date.getHours().toString().length>1 then date.getHours() else "0#{date.getHours()}"
        m=if date.getMinutes().toString().length>1 then date.getMinutes() else "0#{date.getMinutes()}"
        return "#{h}:#{m}"

    return JoinGameScene

)

