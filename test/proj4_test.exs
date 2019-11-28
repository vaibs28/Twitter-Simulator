defmodule Proj4Test do
  use ExUnit.Case
  doctest Proj4

  setup_all(block) do
    GenServer.start_link(Server, [1, 1], name: String.to_atom("server"))
    :ok
  end

  test "register user test1" do
    assert Simulator.register_user("user1", "pass1") == true
  end

  test "register user test2" do
    assert Simulator.register_user("vaibhav", "password") == true
  end

  test "already registered test" do
    assert Simulator.register_user("user1", "pass1") == false
  end

  test "login user test success" do
    assert Simulator.login_user("user1", "pass1") == true
  end

  test "login user test failure incorrect password" do
    Simulator.register_user("user2", "pass2")
    assert Simulator.login_user("user2", "pass3") == false
  end

  test "login user test failure incorrect username" do
    Simulator.register_user("user3", "pass3")
    assert Simulator.login_user("user4", "pass3") == false
  end

  test "user logged in test success" do
    Simulator.login_user("user1", "pass1")
    assert Simulator.isUserLoggedIn("user1") == true
  end

  test "user logged in test failure" do
    assert Simulator.isUserLoggedIn("user2") == false
  end

  test "new tweet success" do
    assert Simulator.new_tweet("user1", "tweet from user1") == true
  end

  test "new tweet success with hashtag" do
    assert Simulator.new_tweet("user1", "tweet from user1 #hello") == true
  end

  test "new tweet success with mention" do
    assert Simulator.new_tweet("user1", "tweet from user1 @user2") == true
  end

  test "show tweets by a user failure" do
    expected = "Not logged in"
    actual = Simulator.get_tweets("user9")
    assert expected == actual
  end

  test "show tweets by a user success" do
    Simulator.login_user("user1", "pass1")
    expected = ["tweet from user1 @user2", "tweet from user1 #hello", "tweet from user1"]
    actual = Simulator.get_tweets("user1")
    assert expected == actual
  end

  test "show tweets by user2" do
    Simulator.login_user("vaibhav", "password")
    expected = []
    actual = Simulator.get_tweets("vaibhav")
    assert expected == actual
  end

  test "show tweets by user2 after new tweets" do
    Simulator.new_tweet("vaibhav", "first tweet from vaibhav")
    Simulator.new_tweet("vaibhav", "second tweet from vaibhav")
    expected = ["second tweet from vaibhav", "first tweet from vaibhav"]
    actual = Simulator.get_tweets("vaibhav")
    assert expected == actual
  end

  test "follow user" do
    assert Simulator.add_follower("user1", "user2") == true
  end

  test "show followers failure" do
    expected = ["user10"]
    actual = Simulator.show_followers("user1")
    refute expected == actual
  end

  test "show followers success" do
    expected = ["user2"]
    actual = Simulator.show_followers("user1")
    assert expected = actual
  end

  test "query by hashtag failure" do
    Simulator.new_tweet("user1", "tweet from user1 #hey")
    expected = "hashtag not found"
    actual = Simulator.query_by_hashtag("#hi")
    assert expected == actual
  end

  test "query by hashtag success" do
    Simulator.new_tweet("user1", "tweet from user1 #hey")
    expected = "tweet from user1 #hey"
    actual = Simulator.query_by_hashtag("#hey")
    assert expected == actual
  end

  test "query by mention failure" do
    Simulator.new_tweet("user1", "tweet from user1 @user2")
    expected = "mention not found"
    actual = Simulator.query_by_mention("@user3")
    assert expected == actual
  end

  test "query by mention success" do
    Simulator.new_tweet("user1", "tweet from user1 @user2")
    expected = "tweet from user1 @user2"
    actual = Simulator.query_by_mention("@user2")
    assert expected == actual
  end

  test "retweet success" do
    actual = Simulator.retweet("vaibhav", "user1", 1)
    expected = "tweet from user1"
    assert expected == actual
  end

  test "retweet success2" do
    actual = Simulator.retweet("vaibhav", "user1", 2)
    expected = "tweet from user1 #hello"
    assert expected == actual
  end

  test "retweet failure" do
    actual = Simulator.retweet("vaibhav", "user1", 1)
    expected = "tweet from user2"
    refute expected == actual
  end

  test "retweet failure2" do
    actual = Simulator.retweet("vaibhav", "user1", 1)
    expected = "tweet from user2"
    refute expected == actual
  end

  test "logout success" do
    actual = Simulator.logout_user("vaibhav")
    expected = true
    assert actual == expected
  end

  test "post tweet after logout" do
    actual = Simulator.new_tweet("vaibhav", "tweet after logout")
    expected = false
    assert actual == expected
  end

  test "view tweets after logout" do
    expected = "Not logged in"
    actual = Simulator.get_tweets("vaibhav")
    assert expected == actual
  end

  test "logout failure" do
    actual = Simulator.logout_user("vaibhav1")
    expected = true
    refute actual == expected
  end
end
