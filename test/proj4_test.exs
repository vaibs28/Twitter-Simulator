defmodule Proj4Test do
  use ExUnit.Case
  doctest Proj4

  test "register user test" do
    IO.puts("==========================")
    IO.puts("Test 1: Register user test")
    IO.puts("==========================")
    GenServer.start_link(Server, [1, 1], name: :server)

    {isSuccess, _message} = Client.register("user1", "pass1")

    assert isSuccess
    assert :ets.tab2list(:Users) |> length === 1

    [{username, password}] = :ets.lookup(:Users, "user1")

    assert username === "user1"
    assert password === "pass1"
  end

  test "user already registerd test" do
    IO.puts("\n===================================")
    IO.puts("Test 2: User already registerd test")
    IO.puts("===================================")
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")

    {isSuccess, message} = Client.register("user1", "pass1")

    assert !isSuccess
    assert message === "User already registered"
    assert :ets.tab2list(:Users) |> length === 1
  end

  test "delete user test" do
    IO.puts("\n========================")
    IO.puts("Test 3: delete user test")
    IO.puts("========================")
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")

    {isDeleted, _message} = Client.delete("user1")

    assert isDeleted
    assert :ets.tab2list(:Users) |> length === 0
  end

  test "no user to delete test" do
    IO.puts("\n==============================")
    IO.puts("Test 4: no user to delete test")
    IO.puts("==============================")
    GenServer.start_link(Server, [1, 1], name: :server)
    assert :ets.tab2list(:Users) |> length === 0

    {isDeleted, message} = Client.delete("user1")
    assert !isDeleted
    assert message === "No user to delete"
    assert :ets.tab2list(:Users) |> length === 0
  end

  test "user not present while login test" do
    IO.puts("\n=========================================")
    IO.puts("Test 5: user not present while login test")
    IO.puts("=========================================")
    GenServer.start_link(Server, [1, 1], name: :server)

    {success, message} = Client.login("user1", "pass1")

    assert !success
    assert message == "user not registered"
  end

  test "user login successful test" do
    IO.puts("\n==================================")
    IO.puts("Test 6: user login successful test")
    IO.puts("===================================")
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")

    {success, _message} = Client.login("user1", "pass1")

    assert success
    assert :ets.lookup_element(:UserState, "user1", 2)
  end

  test "user is already logged in test" do
    IO.puts("\n======================================")
    IO.puts("Test 7: user is already logged in test")
    IO.puts("======================================")
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")

    {_success, _message} = Client.login("user1", "pass1")

    {success, message} = Client.login("user1", "pass1")
    assert !success
    assert message === "User is already logged in"
  end

  test "login password mismatch test" do
    IO.puts("\n====================================")
    IO.puts("Test 8: login password mismatch test")
    IO.puts("====================================")
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")

    {success, message} = Client.login("user1", "incorrect_password")

    assert !success
    assert message === "Password incorrect"
  end

  test "logout test" do
    IO.puts("\n===================")
    IO.puts("Test 9: logout test")
    IO.puts("===================")
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")
    Client.login("user1", "pass1")

    {success, message} = Client.logout("user1")

    assert success
    assert message === "Logout successful"
    assert :ets.lookup_element(:UserState, "user1", 2) == false
  end

  test "not logged in test" do
    IO.puts("\n====================")
    IO.puts("Test 10: logout test")
    IO.puts("====================")
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")

    {success, message} = Client.logout("user1")

    assert !success
    assert message === "User not logged in"
  end

  test "unsuccessful subscribe test" do
    IO.puts("\n====================================")
    IO.puts("Test 11: unsuccessful subscribe test")
    IO.puts("====================================")
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")
    Client.login("user1", "pass1")

    {success1, message1} = Client.add_follower("user1", "user2")

    assert !success1
    assert message1 === "user2 not registered"
  end

  test "subscribe to a user test" do
    IO.puts("\n=================================")
    IO.puts("Test 12: subscribe to a user test")
    IO.puts("=================================")
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
    IO.puts("\n================================")
    IO.puts("Test 13: already subscribed test")
    IO.puts("================================")
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

  test "tweet test" do
    IO.puts("\n===================")
    IO.puts("Test 14: tweet test")
    IO.puts("===================")
    GenServer.start_link(Server, [1, 1], name: :server)

    Client.register("user1", "pass1")
    Client.login("user1", "pass1")

    {success, message} = Client.tweet("user1", "Hello World")
    assert success
    assert message === "Success"

    assert :ets.lookup_element(:Tweets, "user1", 2) == ["Hello World"]
    assert :ets.lookup_element(:Tweets, "user1", 3) == ["tweet"]
    assert :ets.lookup_element(:TweetById, 1, 2) == "user1"
    assert :ets.lookup_element(:TweetById, 1, 3) == "Hello World"
  end

  test "tweet with hashtag" do
    IO.puts("\n===========================")
    IO.puts("Test 15: tweet with hashtag")
    IO.puts("===========================")
    GenServer.start_link(Server, [1, 1], name: :server)

    Client.register("user1", "pass1")
    Client.login("user1", "pass1")

    Client.tweet("user1", "#Hello #Hello #World")
    Client.tweet("user1", "#Hello Vaibhav")

    assert :ets.lookup_element(:Tweets, "user1", 2) |> length == 2

    assert :ets.lookup_element(:Hashtags, "Hello", 2) === [
             "#Hello Vaibhav",
             "#Hello #Hello #World"
           ]

    assert :ets.lookup_element(:Hashtags, "World", 2) === [
             "#Hello #Hello #World"
           ]
  end

  test "mentioned user not found test" do
    IO.puts("\n======================================")
    IO.puts("Test 16: mentioned user not found test")
    IO.puts("======================================")
    GenServer.start_link(Server, [1, 1], name: :server)
    Client.register("user1", "pass1")
    Client.login("user1", "pass1")

    {success, message} = Client.tweet("user1", "@user2 check this out")
    assert !success
    IO.inspect(message)
  end

  test "tweet with mention" do
    IO.puts("\n===========================")
    IO.puts("Test 17: tweet with mention")
    IO.puts("===========================")
    GenServer.start_link(Server, [1, 1], name: :server)

    Client.register("user1", "pass1")
    Client.register("user2", "pass2")
    Client.register("user3", "pass3")
    Client.login("user1", "pass1")
    Client.login("user2", "pass2")

    Client.tweet("user1", "@user2 @user3 This is awesome, and @user2 you should check this out")
    Client.tweet("user2", "@user1 @user3 Yes User1")

    assert :ets.lookup_element(:Tweets, "user1", 2) |> length == 1
    assert :ets.lookup_element(:Tweets, "user2", 2) |> length == 1

    assert :ets.tab2list(:TweetById) |> length == 2

    assert :ets.lookup_element(:Mentions, "user1", 2) === [
             "@user1 @user3 Yes User1"
           ]

    assert :ets.lookup_element(:Mentions, "user2", 2) === [
             "@user2 @user3 This is awesome, and @user2 you should check this out"
           ]

    assert :ets.lookup_element(:Mentions, "user3", 2) === [
             "@user1 @user3 Yes User1",
             "@user2 @user3 This is awesome, and @user2 you should check this out"
           ]
  end

  test "retweet test" do
    IO.puts("\n=====================")
    IO.puts("Test 18: retweet test")
    IO.puts("=====================")
    GenServer.start_link(Server, [1, 1], name: :server)

    Client.register("user1", "pass1")
    Client.register("user2", "pass2")
    Client.register("user3", "pass3")

    Client.login("user1", "pass1")
    Client.login("user2", "pass2")

    {_, _} = Client.add_follower("user1", "user2")
    {_, _} = Client.add_follower("user2", "user3")

    Client.tweet("user1", "Hello World")
    Client.retweet("user2", 1)

    assert :ets.lookup_element(:Tweets, "user1", 2) == ["Hello World"]
    assert :ets.lookup_element(:Tweets, "user1", 3) == ["tweet"]

    assert :ets.lookup_element(:Tweets, "user2", 2) == ["Hello World"]
    assert :ets.lookup_element(:Tweets, "user2", 3) == ["retweet"]

    assert :ets.lookup_element(:Notifications, "user2", 2) == ["Hello World"]
    assert :ets.lookup_element(:Notifications, "user3", 2) == []
  end

  test "query by hashtag test" do
    IO.puts("\n==============================")
    IO.puts("Test 19: query by hashtag test")
    IO.puts("==============================")
    GenServer.start_link(Server, [1, 1], name: :server)

    Client.register("user1", "pass1")
    Client.register("user2", "pass2")

    Client.login("user1", "pass1")
    Client.login("user2", "pass2")

    Client.tweet("user1", "#Hello #World 123")
    Client.tweet("user2", "#OkGoogle #Hello 1234")

    assert Client.query_by_hashtag("OkGoogle") === ["#OkGoogle #Hello 1234"]
    assert Client.query_by_hashtag("Hello") === ["#OkGoogle #Hello 1234", "#Hello #World 123"]
    assert Client.query_by_hashtag("World") === ["#Hello #World 123"]
  end

  test "query by mentions test" do
    IO.puts("\n===============================")
    IO.puts("Test 20: query by mentions test")
    IO.puts("===============================")
    GenServer.start_link(Server, [1, 1], name: :server)

    Client.register("user1", "pass1")
    Client.register("user2", "pass2")

    Client.login("user1", "pass1")
    Client.login("user2", "pass2")

    Client.tweet("user1", "@user2 123")
    Client.tweet("user2", "@user1 567")

    assert Client.query_by_mention("user1") === ["@user1 567"]
    assert Client.query_by_mention("user2") === ["@user2 123"]
  end

  test "query from tweets subscribed to" do
    IO.puts("\n========================================")
    IO.puts("Test 21: query from tweets subscribed to")
    IO.puts("========================================")
    GenServer.start_link(Server, [1, 1], name: :server)

    Client.register("user1", "pass1")
    Client.register("user2", "pass2")
    Client.register("user3", "pass3")

    Client.login("user1", "pass1")
    Client.login("user2", "pass2")
    Client.login("user3", "pass3")

    Client.add_follower("user1", "user2")
    Client.add_follower("user3", "user2")

    Client.tweet("user1", "Hello World")
    Client.tweet("user1", "Amazing World")
    Client.tweet("user3", "Hi, This is my World")

    assert Enum.sort(["Hello World", "Amazing World", "Hi, This is my World"]) ===
             Enum.sort(Client.query_by_subscribed_user("user2", "World"))

    assert Client.query_by_subscribed_user("user2", "Amazing") === ["Amazing World"]
  end

  test "notified tweet" do
    IO.puts("\n=======================")
    IO.puts("Test 22: notified tweet")
    IO.puts("=======================")
    GenServer.start_link(Server, [1, 1], name: :server)

    Client.register("user1", "pass1")
    Client.register("user2", "pass2")

    Client.login("user1", "pass1")
    Client.login("user2", "pass2")

    Client.add_follower("user1", "user2")
    Client.tweet("user1", "Hello World")
    Client.tweet("user1", "Hello World 2")

    assert Enum.sort(Enum.map(Client.subscribed_tweets("user2"), fn {t, id} -> t end)) ===
             Enum.sort(["Hello World 2", "Hello World"])
  end
end
