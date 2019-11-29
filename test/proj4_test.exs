defmodule Proj4Test do
  use ExUnit.Case
  doctest Proj4

  test "register user test" do
    GenServer.start_link(Server, [1, 1], name: :server)

    {isSuccess, _message} = Client.register("user1", "pass1")

    assert isSuccess
    assert :ets.tab2list(:Users) |> length === 1

    [{username, password}] = :ets.lookup(:Users, "user1")

    assert username === "user1"
    assert password === "pass1"
  end

  test "user already registerd test" do
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")

    {isSuccess, message} = Client.register("user1", "pass1")

    assert !isSuccess
    assert message === "User already registered"
    assert :ets.tab2list(:Users) |> length === 1
  end

  test "delete user test" do
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")

    {isDeleted, _message} = Client.delete("user1")

    assert isDeleted
    assert :ets.tab2list(:Users) |> length === 0
  end

  test "no user to delete test" do
    GenServer.start_link(Server, [1, 1], name: :server)
    assert :ets.tab2list(:Users) |> length === 0

    {isDeleted, message} = Client.delete("user1")
    assert !isDeleted
    assert message === "No user to delete"
    assert :ets.tab2list(:Users) |> length === 0
  end

  test "user not present while login test" do
    GenServer.start_link(Server, [1, 1], name: :server)

    {success, message} = Client.login("user1", "pass1")

    assert !success
    assert message == "user not registered"
  end

  test "user login successful test" do
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")

    {success, _message} = Client.login("user1", "pass1")

    assert success
    assert :ets.lookup_element(:UserState, "user1", 2)
  end

  test "user is already logged in test" do
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")

    {_success, _message} = Client.login("user1", "pass1")

    {success, message} = Client.login("user1", "pass1")
    assert !success
    assert message === "User is already logged in"
  end

  test "login password mismatch test" do
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")

    {success, message} = Client.login("user1", "incorrect_password")

    assert !success
    assert message === "Password incorrect"
  end

  test "unsuccessful subscribe test" do
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")
    Client.login("user1", "pass1")

    {success1, message1} = Client.add_follower("user1", "user2")

    assert !success1
    assert message1 === "user2 not registered"
  end

  test "subscribe to a user test" do
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")
    Client.register("user2", "pass2")
    Client.register("user3", "pass3")

    Client.login("user1", "pass1")
    Client.login("user2", "pass2")

    {success, message} = Client.add_follower("user1", "user2")
    assert success
    assert message === "Success"

    {success, message} = Client.add_follower("user1", "user3")
    assert success
    assert message === "Success"

    {success, message} = Client.add_follower("user2", "user3")
    assert success
    assert message === "Success"

    assert :ets.lookup_element(:Followers, "user1", 2) === ["user3", "user2"]
    assert :ets.lookup_element(:Followers, "user2", 2) === ["user3"]
    assert :ets.lookup_element(:Followers, "user3", 2) === []

    assert :ets.lookup_element(:SubscribedTo, "user1", 2) === []
    assert :ets.lookup_element(:SubscribedTo, "user2", 2) === ["user1"]
    assert :ets.lookup_element(:SubscribedTo, "user3", 2) === ["user2", "user1"]
  end

  test "already subscribed test" do
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")
    Client.register("user2", "pass2")

    Client.login("user1", "pass1")

    {success, message} = Client.add_follower("user1", "user2")
    assert success
    assert message === "Success"

    {success, message} = Client.add_follower("user1", "user2")
    assert !success
    assert message === "Already Subscribed"

  end
end
