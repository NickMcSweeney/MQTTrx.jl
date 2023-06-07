@testset "Smoke tests" begin
    println("Running smoke tests")

    condition = Condition()
    topic = "foo"
    payload = Random.randstring(20)
    foo = Subject(Packet, scheduler=AsyncScheduler())
    bar = Subject(Packet, scheduler=AsyncScheduler())

    client = Client()
    println(client)

    register_subscriber(client, ("foo",foo))
    register_publisher(client, ("foo", bar))

    subscribe!(bar, logger())


    println("Testing reconnect")
    connect(client, "test.mosquitto.org")
    # disconnect(client)
    # connect(client, "test.mosquitto.org")

    # @time subscribe(client, (topic, QOS_0))

    # println("Testing publish qos 0")
    # publish(client, topic, payload, qos=QOS_0)
    # wait(condition)

    # println("Testing publish qos 1")
    # publish(client, topic, payload, qos=QOS_1)
    # wait(condition)

    # println("Testing publish qos 2")
    # publish(client, topic, payload, qos=QOS_2)
    # wait(condition)

    # println("Testing connect will")
    # disconnect(client)
    # connect(client, "test.mosquitto.org", will=Message(false, 0x00, false, topic, payload))

    # disconnect(client)
end