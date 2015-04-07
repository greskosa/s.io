define([
    'pixijs','Scene', 'text!./../config.json'
],  (PIXI,Scene,config)->
    config=JSON.parse(config)

    class JoinGameScene extends Scene
      roomsInfo:[]
      constructor:(screen)->
          super(screen)


      renderAvailableRooms:(rooms)->
       console.log rooms
       console.log Object.keys(rooms)
       @clearInfo()
       if(!rooms||(rooms&&!Object.keys(rooms).length))
         @msg=@addText('No rooms are available',{font:"15px Verdana", fill:"white",stroke: "#FFFFFF", strokeThickness: 1},{x:@size.width/2,y:100})
         return
       @rooms=rooms
       count=0
       for index of  @rooms
         @renderRoom(@rooms[index],count)
         count++

      clearInfo:()=>
        if @msg
            @removeChild(@msg);
        for child in @roomsInfo
            console.log('111')
            @removeChild(child)
        @roomsInfo=[]

      renderRoom:(room,count)->
        @roomsInfo.push(@addText(room.roomName,{font:"15px Verdana", fill:"white",stroke: "#FFFFFF", strokeThickness: 1},{x:200,y:100+count*50},()=>@connecting(room)))
        @roomsInfo.push(@addText(room.host,{font:"15px Verdana", fill:"white",stroke: "#FFFFFF", strokeThickness: 1},{x:400,y:100+count*50},()=>@connecting(room)))
        @roomsInfo.push(@addText(@getTime(room.created),{font:"15px Verdana", fill:"white",stroke: "#FFFFFF", strokeThickness: 1},{x:600,y:100+count*50},()=>@connecting(room)))
        @roomsInfo.push(@addText(room.playersCount+"/"+config.maxPlayersLimit,{font:"15px Verdana", fill:"white",stroke: "#FFFFFF", strokeThickness: 1},{x:800,y:100+count*50},()=>@connecting(room)))

      getTime:(created)->
        date=new Date(created)
        console.log(date.getHours().toString().length)
        h= if date.getHours().toString().length>1 then date.getHours() else "0#{date.getHours()}"
        m=if date.getMinutes().toString().length>1 then date.getMinutes() else "0#{date.getMinutes()}"
        return "#{h}:#{m}"

      connect2Room:(room)->
        console.error('Must be implemented in Game.js')


      connecting:(room)->
        textMessage='Connecting to the room...'
        if(!@text)
          @text=@addText(textMessage,{font:"40px Verdana", fill:"black",stroke: "#FF0000", strokeThickness: 6},{x:@size.width/2+10,y:@size.height/2})
        else
          @text.setText(textMessage)
        @addPreloader()
        setTimeout(()=>
          @connect2Room(room)
        ,2000)

      clearConnecting:()=>
        console.log @
        @removeText()
        @removePreloader()

    return JoinGameScene

)

