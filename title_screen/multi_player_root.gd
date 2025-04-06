extends Control
@export var address = "127.0.0.1"
@export var port = 8910
var peer:ENetMultiplayerPeer #Why is this scoped like this?

func _ready():
    multiplayer.peer_connected.connect(peer_connected)
    multiplayer.peer_disconnected.connect(peer_disconnected)
    multiplayer.connected_to_server.connect(connected_to_server)
    multiplayer.connection_failed.connect(connection_failed)
    pass
    
    
#Called on server & client
func peer_connected(id):
    print("Player Connected! ID: ", str(id))
 #Called on server & client

func peer_disconnected(id):
    print("Player Disconnected! ID: ", str(id))
    
#Called on client only
func connected_to_server():
    #Client to server data goes here apparently
    print("Connected to server")

#Called on client only
func connection_failed():
    print("Connection failed :(")


func _on_host_button_button_up() -> void:
    peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(port, 6)
    if error != OK:
        print("Cannot host, error: ", error)
        return
    #Should we use the compression at all?
    peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
    
    #Use our own connection as a peer and play our own game. I think.
    multiplayer.set_multiplayer_peer(peer)
    print("Waiting for players")
    pass # Replace with function body.


func _on_join_button_button_up() -> void:
    peer = ENetMultiplayerPeer.new()
    peer.create_client(address, port) #???
    #What horrors happen if I don't match compression types
    peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
    multiplayer.set_multiplayer_peer(peer)
    pass # Replace with function body.
