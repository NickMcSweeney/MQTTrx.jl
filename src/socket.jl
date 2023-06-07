using Sockets

import Rocket: AbstractSubject, AbstractScheduler
import Rocket: AsapScheduler
import Base: show, similar, ==

struct SocketListener{I}
    schedulerinstance :: I
    actor
end

Base.show(io::IO, ::SocketListener) = print(io, "SocketListener()")

mutable struct RxSocket{D, H, I} <: AbstractSubject{D}
    listeners   :: List{SocketListener{I}}
    scheduler   :: H
    isactive    :: Bool
    iscompleted :: Bool
    isfailed    :: Bool
    lasterror   :: Any

    RxSocket{D, H, I}(scheduler::H) where { D, H <: AbstractScheduler, I } = new(List(SocketListener{I}), scheduler, true, false, false, nothing)
end

function RxSocket(::Type{D}; scheduler::H = AsapScheduler()) where { D, H <: AbstractScheduler }
    return RxSocket{D, H, instancetype(D, H)}(scheduler)
end

Base.show(io::IO, ::RxSocket{D, H}) where { D, H } = print(io, "Subject($D, $H)")

Base.similar(subject::RxSocket{D, H}) where { D, H } = RxSocket(D; scheduler = similar(subject.scheduler))


##

isactive(subject::RxSocket)    = subject.isactive
iscompleted(subject::RxSocket) = subject.iscompleted
isfailed(subject::RxSocket)    = subject.isfailed
lasterror(subject::RxSocket)   = subject.lasterror

setinactive!(subject::RxSocket)       = subject.isactive    = false
setcompleted!(subject::RxSocket)      = subject.iscompleted = true
setfailed!(subject::RxSocket)         = subject.isfailed    = true
setlasterror!(subject::RxSocket, err) = subject.lasterror   = err

##

# on next should take a mqtt packet and send it to the tcp socket
function on_next!(subject::RxSocket{D, H, I}, data::D) where { D, H, I }
    for listener in subject.listeners
        scheduled_next!(listener.actor, data, listener.schedulerinstance)
    end
end

# on error should 
function on_error!(subject::RxSocket, err)
    if isactive(subject)
        setinactive!(subject)
        setfailed!(subject)
        setlasterror!(subject, err)
        for listener in subject.listeners
            scheduled_error!(listener.actor, err, listener.schedulerinstance)
        end
        empty!(subject.listeners)
    end
end

function on_complete!(subject::RxSocket)
    if isactive(subject)
        setinactive!(subject)
        setcompleted!(subject)
        for listener in subject.listeners
            scheduled_complete!(listener.actor, listener.schedulerinstance)
        end
        empty!(subject.listeners)
    end
end

##