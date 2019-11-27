defmodule Proj4Test do
  use ExUnit.Case
  doctest Proj4

  test "register user test1" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    assert Simulator.register_user("user1", "pass1") == true
  end

  test "register user test2" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    assert Simulator.register_user("vaibhav", "password") == true
  end

  test "already registered test" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    assert Simulator.register_user("user1", "pass1") == false
  end

  test "login user test success" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    assert Simulator.login_user("user1", "pass1") == true
  end

  test "login user test failure incorrect password" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    assert Simulator.login_user("user1", "pass2") == false
  end

  test "login user test failure incorrect username" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    assert Simulator.login_user("user2", "pass1") == false
  end

  test "user logged in test success" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    assert Simulator.isUserLoggedIn("user1") == true
  end

  test "user logged in test failure" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    assert Simulator.isUserLoggedIn("user2") == false
  end

  test "new tweet failure due to not logging in" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    assert Simulator.new_tweet("user1", "tweet from user1") == false
  end

  test "new tweet success" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    assert Simulator.new_tweet("user1", "tweet from user1") == true
  end

  test "new tweet success with hashtag" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    assert Simulator.new_tweet("user1", "tweet from user1 #hello") == true
  end

  test "new tweet success with mention" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    assert Simulator.new_tweet("user1", "tweet from user1 @user2") == true
  end

  test "show tweets by a user failure" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.new_tweet("user1", "tweet from user1")
    expected = "Not logged in"
    actual = Simulator.get_tweets("user1")
    assert expected == actual
  end

  test "show tweets by a user success" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    Simulator.new_tweet("user1", "tweet from user1")
    expected = "Successfully fetched"
    actual = Simulator.get_tweets("user1")
    assert expected == actual
  end

  test "follow user" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    assert Simulator.add_follower("user1", "user2") == true
  end

  test "query by hashtag failure" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    Simulator.new_tweet("user1", "tweet from user1 #hey")
    expected = "hashtag not found"
    actual = Simulator.query_by_hashtag("#hi")
    assert expected == actual
  end

  test "query by hashtag success" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    Simulator.new_tweet("user1", "tweet from user1 #hey")
    expected = "tweet from user1 #hey"
    actual = Simulator.query_by_hashtag("#hey")
    assert expected == actual
  end

  test "query by mention failure" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    Simulator.new_tweet("user1", "tweet from user1 @user2")
    expected = "mention not found"
    actual = Simulator.query_by_mention("@user3")
    assert expected == actual
  end

  test "query by mention success" do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    Simulator.register_user("user1", "pass1")
    Simulator.login_user("user1", "pass1")
    Simulator.new_tweet("user1", "tweet from user1 @user2")
    expected = "tweet from user1 @user2"
    actual = Simulator.query_by_mention("@user2")
    assert expected == actual
  end
end
