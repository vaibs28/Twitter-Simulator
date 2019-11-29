defmodule Simulator do
  use GenServer

  def start_link(num_user, num_msg) do
    # start server
    GenServer.start_link(Server, [num_user, num_msg], name: :server)

    createAndRegisterUsers(num_user)
    loginAllUsers(num_user)

    Enum.each(1..num_user, fn n -> add_followers(n, num_user) end)

    generate_tweets(num_user, num_msg)

    for i <- 1..num_user do
      user = "user#{i}"
      get_user_state(user)
    end
  end

  def add_followers(user, num_user) do
    self_id = "user#{user}"

    num = floor(num_user * 20 / 100)
    usernames = Enum.map(1..num_user, fn i -> "user#{i}" end)
    randoms = Enum.take_random(usernames -- [self_id], num)
    Enum.each(randoms, fn n -> Client.add_follower(self_id, n) end)
  end

  def init(state) do
    {:ok, state}
  end

  def get_user_state(username) do
    IO.puts("Tweets by user")
    IO.inspect(:ets.lookup(:Tweets, username))
    IO.puts("Followers of user")
    IO.inspect(:ets.lookup(:Followers, username))
    IO.puts("User Subscribed To")
    IO.inspect(:ets.lookup(:SubscribedTo, username))
    IO.puts("User Wall")
    IO.inspect(:ets.lookup(:Notifications, username))
  end

  # create users based on the num_user and register them
  def createAndRegisterUsers(num_user) do
    for i <- 1..num_user do
      Client.register("user#{i}", "pass#{i}")
    end
  end

  # login all users
  def loginAllUsers(num_user) do
    for i <- 1..num_user do
      uname = "user#{i}"
      pass = "pass#{i}"
      Client.login(uname, pass)
    end
  end

  def logout_all_users(num_user) do
    for i <- 1..num_user do
      user = "user#{i}"
      ret = GenServer.call(:server, {:logout, {user}})
      IO.inspect("#{user} logout successful")
      ret
    end
  end

  # generate tweets
  def generate_tweets(num_user, num_tweets) do
    for i <- 1..num_user do
      user = "user#{i}"

      for j <- 1..num_tweets do
        tweet = "tweet #{j} from user #{user}"
        Client.tweet(user, tweet)
      end
    end
  end
end
