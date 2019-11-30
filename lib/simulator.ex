defmodule Simulator do
  use GenServer

  def start_link(num_user, num_msg, per) do
    # start server
    GenServer.start_link(Server, [num_user, num_msg], name: :server)

    ## Register Users
    createAndRegisterUsers(num_user)

    ## Login All Users
    loginAllUsers(num_user)

    s = floor(num_user / 2)

    zipf =
      Enum.map(
        Enum.map(1..num_user, fn i -> round(Float.floor(s / (num_user - i + 1))) - 1 end),
        fn x ->
          if(x > 0) do
            x
          else
            0
          end
        end
      )

    ## Add Subscriptions
    Enum.each(1..num_user, fn n -> add_followers(Enum.at(zipf, n - 1), n, num_user) end)

    toggle_login_number = trunc(per * num_user * 0.01)
    IO.puts("Toggle Loging number #{toggle_login_number}")

    Enum.each(Enum.take_random(1..num_user, toggle_login_number), fn n ->
      GenServer.cast(:"user#{n}", {:start_toggle})
    end)

    ## Generate Tweets for all users
    generate_tweets(num_user, num_msg)

    ### Retweet
    Enum.each(1..num_user, fn n ->
      user = "user#{n}"
      tweets = Client.subscribed_tweets(user)

      if tweets |> length > 0 do
        {_, tweetid} = Enum.random(tweets)
        Client.retweet(user, tweetid)
      end
    end)

    ### Logout users
    logout_all_users(num_user)

    ###
    IO.puts("tweets with hashtag_1 : #{inspect(Client.query_by_hashtag("hashtag_1") |> length)}")
  end

  def add_followers(num, user, num_user) do
    self_id = "user#{user}"

    usernames = Enum.map(1..num_user, fn i -> "user#{i}" end)

    if num > 0 do
      randoms = Enum.take_random(usernames -- [self_id], num)
      Enum.each(randoms, fn n -> Client.add_follower(self_id, n) end)
    end
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
      ret = Client.logout(user)
      IO.inspect("#{user} logout successful")
      ret
    end
  end

  # generate tweets
  def generate_tweets(num_user, num_tweets) do
    for i <- 1..num_user do
      user = "user#{i}"

      for j <- 1..num_tweets do
        tweet =
          "tweet #{j} from user #{user} ##{Enum.random(["hashtag_1", "hashtag_2", "hastag_3"])}"

        Client.tweet(user, tweet)
      end
    end
  end
end
