defmodule Client do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  # Directly Calls the server
  def register(username, password) do
    {isSuccess, message} = GenServer.call(:server, {:register_user, {username, password}})

    if(isSuccess) do
      IO.puts("registration successful for #{username}")
    else
      IO.puts("#{username} already registered")
    end

    {isSuccess, message}
  end

  def show_followers(user) do
    GenServer.call(String.to_atom(user), {:show_followers, user})
  end

  def query_by_hashtag(hashtag) do
    GenServer.call(:server, {:query_by_hashtag, hashtag})
  end

  def query_by_mention(mention) do
    GenServer.call(:server, {:query_by_mention, mention})
  end

  def add_follower(username, follower) do
    GenServer.call(String.to_atom(username), {:add_follower, {username, follower}})
  end

  def handle_call({:show_followers, username}, _from, state) do
    {:reply, GenServer.call(:server, {:show_followers, username}), state}
  end

  def handle_call({:retweet, {tweetuser, tweetId, userId}}, _from, userState) do
    tweet = GenServer.call(String.to_atom(tweetuser), {:get_tweet_by_Id, {tweetId}})
    GenServer.call(String.to_atom(tweetuser), {:tweet, {userId, tweet, "retweet"}})
    {:reply, tweet, userState}
  end

  def handle_call({:get_tweet_by_Id, {tweetId}}, _from, userState) do
    {:reply, GenServer.call(:server, {:get_tweet_by_id, tweetId}), userState}
  end

  def handle_call({:tweet, {userid, tweet, flag}}, _from, state) do
    {:reply, GenServer.call(:server, {:tweet, {userid, tweet, flag}}, :infinity), state}
  end

  def handle_call({:logout, username}, _from, state) do
    {:stop, :normal, GenServer.call(:server, {:logout, username}), state}
  end

  def handle_call({:add_follower, {username, follower}}, _from, state) do
    if is_user_registered(follower) do
      {:reply, GenServer.call(:server, {:add_follower, {username, follower}}), state}
    else
      {:reply, {false, "#{follower} not registered"}, state}
    end
  end

  def tweet(username, tweet) do
    if(Server.isUserLoggedIn(username) == true) do
      GenServer.call(String.to_atom(username), {:tweet, {username, tweet, "tweet"}})
      IO.puts("#{tweet} posted")
      true
    else
      false
    end
  end

  def delete(username) do
    if(Client.is_user_registered(username)) do
      GenServer.call(:server, {:delete, username})
    else
      "user not registered"
    end
  end

  def is_user_registered(username) do
    GenServer.call(:server, {:is_user_registered, username})
  end

  def login(username, password) do
    if is_user_registered(username) == false do
      {false, "user not registered"}
    else
      currentUserState = GenServer.call(:server, {:is_logged_in, username})
      # not logged in
      if(currentUserState == false) do
        ret = GenServer.call(:server, {:login_user, {username, password}})

        if(ret == true) do
          IO.puts("login successful for #{username}")
          {true, "Login Successful"}
        else
          IO.puts("Password incorrect")
          {false, "Password incorrect"}
        end
      else
        IO.puts("User #{username} already logged in")
        {false, "User is already logged in"}
      end
    end
  end

  def retweet(username, tweetuser, tweetid) do
    if(Server.isUserLoggedIn(username)==true) do
      GenServer.call(String.to_atom(username), {:retweet, {tweetuser, tweetid, username}})
    else
      "User not logged in"
    end

  end

  def get_tweets(username) do
    if(Server.isUserLoggedIn(username) == true) do
      GenServer.call(:server, {:get_tweets, {username}})
    else
      "Not logged in"
    end
  end

  def logout(username) do
    if Process.whereis(String.to_atom(username)) == nil do
      false
    else
      GenServer.call(String.to_atom(username), {:logout, username})
    end
  end
end
