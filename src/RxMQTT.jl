module RxMQTT

using Distributed: Future
using Base.Threads: Atomic
using Sockets: TCPSocket
using Random: randstring
using Dates
using Rocket

import Base: ReentrantLock, lock, unlock, convert
# import Base: connect, read, write, get

include("utils.jl")
include("client.jl")

# include("utils.jl")
# include("packet.jl")
# include("packets/connect.jl")
# include("packets/publish.jl")
# include("packets/subscribe.jl")
# include("packets/unsubscribe.jl")
# include("packets/disconnect.jl")
# include("packets/ping.jl")
# include("net.jl")
# include("client.jl")

export
    Client,
    Packet,
    register_publisher,
    register_subscriber
#     User,
#     QOS_0,
#     QOS_1,
#     QOS_2,
#     connect,
#     @subscribe,
#     subscribe,
#     unsubscribe,
#     @publish,
#     publish,
#     disconnect,
#     get,
#     MQTT_ERR_INVAL
end