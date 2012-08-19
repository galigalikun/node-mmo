{decodeObject} = Nmmo.Utils

class Nmmo.Game extends enchant.Game
  constructor: ->
    window.game = @
    # init params
    super 320, 240
    @fps = 30
    @keybind 'Z'.charCodeAt(0), 'a'
    @keybind 'X'.charCodeAt(0), 'b'
    @preload [
      "avatarBg1.png"
      "avatarBg2.png"
      "avatarBg3.png"
    ]

  onload: ->
    @players  = new enchant.Group
    @monsters = new enchant.Group
    @objects  = new enchant.Group

    @rootScene.addChild @players

    @rootScene.backgroundColor="#000000"
    @rootScene.addChild @bg = new enchant.AvatarBG(2)
    @rootScene.addChild _.tap new enchant.Label, (label) =>
      label.text = "Nmmo Test Scene"
      label.color = "white"

    # @rootScene.addChild _.tap new enchant.Label, (label) =>

  bindIO: (socket) ->
    socket.on 'getPlayerData', (@player_id) =>
      socket.on 'update', ({o}) =>
        @sync(o)
        @update(o)

  sync: (objects) ->
    client_ids = (obj.user_id for obj in game.players.childNodes)
    server_ids = (id for [id] in objects)

    # オブジェクトの追加
    for obj in objects
      decoded = decodeObject obj
      unless decoded.user_id in client_ids
        @players.addChild new Nmmo.Player(decoded.avatar, decoded.user_id)

    # オブジェクトの削除
    for node in @players.childNodes
      unless node.user_id in server_ids
        @players.removeChild node

  update: (objects) ->
    for obj in objects
      decoded = decodeObject(obj)
      player = _.find @players.childNodes, (node) ->
        node.user_id is decoded.user_id
      player.update decoded
