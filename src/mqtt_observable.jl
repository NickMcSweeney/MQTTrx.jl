export mqtt, MQTTObservable

using Sockets

import Base: ==
import Base: show

"""
    MQTTObservable{D, Address, Port, S}()

MQTTObservable listens for the messages of type `D` from remote server with specified `Address` and `Port` parameters.

# See also: [`mqtt`](@ref), [`Subscribable`](@ref)
"""
@subscribable struct MQTTObservable{D, A, P, S} <: Subscribable{D} end

function on_subscribe!(observable::MQTTObservable{D, Address, Port, S}, actor) where { D, Address, Port, S }
    clientside = Sockets.connect(Address, Port)
    @async begin
        try
            while isopen(clientside)
                count = read(clientside, Int)
                if count === 0
                    complete!(actor)
                    return nothing
                elseif count === -1
                    error!(actor, ErrorException("MQTTObservableError"))
                    return nothing
                else
                    next!(actor, read(clientside, D))
                end
            end
        catch err
            if !(err isa EOFError)
                error!(actor, err)
            end
        end
    end
    return MQTTObservableSubscritpion(clientside)
end

function on_subscribe!(observable::MQTTObservable{Vector{D}, Address, Port, S}, actor) where { D, Address, Port, S }
    clientside = Sockets.connect(Address, Port)
    @async begin
        try
            buffer = Vector{D}(undef, S)
            while isopen(clientside)
                count = read(clientside, Int)
                if count === 0
                    complete!(actor)
                    return nothing
                elseif count === -1
                    error!(actor, ErrorException("MQTTObservableError"))
                    return nothing
                else
                    unsafe_read(clientside, pointer(buffer), count * sizeof(D))
                    next!(actor, unsafe_wrap(Vector{D}, pointer(buffer), count))
                end
            end
        catch err
            if !(err isa EOFError)
                error!(actor, err)
            end
        end
    end
    return MQTTObservableSubscritpion(clientside)
end

struct MQTTObservableSubscritpion <: Teardown
    clientside :: TCPSocket
end

as_teardown(::Type{<:MQTTObservableSubscritpion}) = UnsubscribableTeardownLogic()

function on_unsubscribe!(subscription::MQTTObservableSubscritpion)
    close(subscription.clientside)
end

"""
    mqtt(::Type{D}, port::Int)             where D
    mqtt(::Type{D}, address::A, port::Int) where { D, A <: IPAddr }

    mqtt(::Type{Vector{D}}, port::Int, buffer_size::Int)             where D
    mqtt(::Type{Vector{D}}, address::A, port::Int, buffer_size::Int) where { D, A <: IPAddr }

Creation operator for the `MQTTObservable` that emits messages from the server with specified `address` and `port` arguments.

See also: [`MQTTObservable`](@ref), [`subscribe!`](@ref)
"""
mqtt(::Type{D}, port::Int)             where D                  = mqtt(D, Sockets.localhost, port)
mqtt(::Type{D}, address::A, port::Int) where { D, A <: IPAddr } = MQTTObservable{D, address, port, 0}()

mqtt(::Type{Vector{D}}, port::Int)             where D                  = error("Specify maximum buffer size for input data")
mqtt(::Type{Vector{D}}, address::A, port::Int) where { D, A <: IPAddr } = error("Specify maximum buffer size for input data")

mqtt(::Type{Vector{D}}, port::Int, buffer_size::Int)             where D                  = mqtt(Vector{D}, Sockets.localhost, port, buffer_size)
mqtt(::Type{Vector{D}}, address::A, port::Int, buffer_size::Int) where { D, A <: IPAddr } = MQTTObservable{Vector{D}, address, port, buffer_size}()

Base.:(==)(::MQTTObservable{D1, A1, P1}, ::MQTTObservable{D2, A2, P2}) where { D1, A1, P1 } where { D2, A2, P2 } = D1 == D2 && A1 == A2 && P1 == P2

Base.show(io::IO, observable::MQTTObservable{D, A, P}) where { D, A, P } = print(io, "MQTTObservable($D, address = $A, port = $P)")