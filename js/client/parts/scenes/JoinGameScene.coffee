define([
    'pixijs', 'Scene', 'text!./../config.json'
], (PIXI, Scene, config) ->
    config = JSON.parse(config)

    class JoinGameScene extends Scene
        roomsInfo: []

        constructor: (screen) ->
            super(screen)

        renderAvailableRooms: (rooms) ->
            console.log rooms
            console.log Object.keys(rooms)
            @clearInfo()

            if (!rooms || (rooms && !Object.keys(rooms).length))
                @msg = @addText(
                    'No rooms are available',
                    {
                        font: "18px Verdana",
                        fill: "#1a4a67",
                        stroke: "#FFFFFF",
                        strokeThickness: 3
                    },
                    {
                        x: config.originalWidth / 2,
                        y: 100
                    }
                )
                return

            @rooms = rooms
            count = 0
            @renderRoom(
                {
                    roomName: "Game Name:",
                    host: "HostName:",
                    created: "Time created:",
                    playersCount: "Players count:",
                    isLabel: true
                },
                -1
            )

            for index of @rooms
                @renderRoom(@rooms[index], count)
                count++

        clearInfo: () ->
            if @msg
                @removeChild(@msg)

            for child in @roomsInfo
                console.log('111')
                @removeChild(child)

            @roomsInfo = []

        renderRoom: (room, count) ->
            interactiveFunc = if room.isLabel then false else () => @connecting(room)

            @roomsInfo.push(
                @addText(
                    room.roomName,
                    {
                        font: "18px Verdana",
                        fill: "#1a4a67",
                        stroke: "#FFFFFF",
                        strokeThickness: 3
                    },
                    {
                        x: 200,
                        y: 130 + count * 50
                    },
                    interactiveFunc
                )
            )

            @roomsInfo.push(
                @addText(
                    room.host,
                    {
                        font: "18px Verdana",
                        fill: "#1a4a67",
                        stroke: "#FFFFFF",
                        strokeThickness: 3
                    },
                    {
                        x: 400,
                        y: 130 + count * 50
                    },
                    interactiveFunc
                )
            )

            @roomsInfo.push(
                @addText(
                    @getTime(room.created),
                    {
                        font: "18px Verdana",
                        fill: "#1a4a67",
                        stroke: "#FFFFFF",
                        strokeThickness: 3
                    },
                    {
                        x: 600,
                        y: 130 + count * 50
                    },
                    interactiveFunc
                )
            )

            playerText = if !isNaN(parseInt(room.playersCount)) then room.playersCount + "/" + config.maxPlayersLimit else room.playersCount

            @roomsInfo.push(
                @addText(
                    playerText,
                    {
                        font: "18px Verdana",
                        fill: "#1a4a67",
                        stroke: "#FFFFFF",
                        strokeThickness: 3
                    },
                    {
                        x: 800,
                        y: 130 + count * 50
                    },
                    interactiveFunc
                )
            )

        getTime: (created) ->
            if typeof created == 'string' then return created

            date = new Date(created)
            console.log(date.getHours().toString().length)

            h = if date.getHours().toString().length > 1 then date.getHours() else "0#{date.getHours()}"
            m = if date.getMinutes().toString().length > 1 then date.getMinutes() else "0#{date.getMinutes()}"

            return "#{h}:#{m}"

        connect2Room: (room) ->
            console.error('Must be implemented in Game.js')

        connecting: (room) ->
            if (@clicked)
                return

            textMessage = 'Connecting to the room...'

            if (!@text)
                @text = @addText(
                    textMessage,
                    {
                        font: "40px Verdana",
                        fill: "black",
                        stroke: "#FF0000",
                        strokeThickness: 6
                    },
                    {
                        x: config.originalWidth / 2 + 10,
                        y: config.originalHeight / 2
                    }
                )
            else
                @text.setText(textMessage)

            @addPreloader(true)
            @clicked = true

            setTimeout(() =>
                @connect2Room(room)
            , 2000)

        clearConnecting: () ->
            @clicked = false
            @removeText()
            @removePreloader()

    return JoinGameScene
)

