import MQTTrx: topic_wildcard_len_check, filter_wildcard_len_check, MQTTException

@testset "topic_wildcard_len_check" begin
    @test_throws MQTTException topic_wildcard_len_check("+")
    @test topic_wildcard_len_check("foo") |> isnothing
    @test_throws MQTTException topic_wildcard_len_check("#")
    @test_throws MQTTException topic_wildcard_len_check("")
end;

@testset "filter_wildcard_len_check" begin
    @test_throws MQTTException filter_wildcard_len_check("")
    @test_throws MQTTException filter_wildcard_len_check("#/")
    @test_throws MQTTException filter_wildcard_len_check("f+oo/bar/more")
    @test_throws MQTTException filter_wildcard_len_check("f#oo/bar/more")
    @test filter_wildcard_len_check("foo/bar/more") |> isnothing
    @test filter_wildcard_len_check("foo/bar/more/#") |> isnothing
    @test filter_wildcard_len_check("foo/+/bar/more") |> isnothing
end;
