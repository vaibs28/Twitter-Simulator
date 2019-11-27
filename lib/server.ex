defmodule Server do
  use GenServer

  def init(init_arg) do
    create_tables()
    {:ok, init_arg}
  end

  def create_tables() do
    :ets.new(:Users, [:set, :public, :named_table])   #stores username and password
    :ets.new(:Tweets, [:set, :public, :named_table])  #stores username,tweets and tweet/retweet flag
    :ets.new(:Followers, [:set, :public, :named_table]) #stores username and followers of that user
    :ets.new(:UserState, [:set, :public, :named_table]) #stores if user is logged in or not
    :ets.new(:User_Wall, [:set, :public, :named_table]) #stores username and tweets made by other users to which the user is subscribed to
    :ets.new(:Hashtags, [:set, :public, :named_table])  #stores hashtags and the tweet
    :ets.new(:Mentions, [:set, :public, :named_table])  #stores mentions and the tweet
    :ets.new(:TweetById, [:set, :public, :named_table]) #stores tweetId,username,tweet
  end

  # register callback
  def handle_call({:register_user, user_info}, _from, state) do
    username = elem(user_info, 0)
    password = elem(user_info, 1)
    returnValue = false

    case :ets.lookup(:Users, username) do
      [_] ->
        {:reply, returnValue, state}

      [] ->
        returnValue = true
        # initializing the tables with no tweets and no followers
        :ets.insert(:Users, {username, password})
        :ets.insert(:Tweets, {username, [], []})
        :ets.insert(:Followers, {username, []})
        :ets.insert(:UserState, {username, false})
        :ets.insert(:User_Wall, {username, []})
        {:reply, returnValue, state}
    end
  end

  # login callback
  def handle_call({:login_user, user_info}, _from, state) do
    username = elem(user_info, 0)
    password = elem(user_info, 1)
    returnValue = false

    case :ets.lookup(:Users, username) do
      [_] ->
        storedPassword = :ets.lookup_element(:Users, username, 2)

        if storedPassword === password do
          {:ok, pid} = GenServer.start_link(Client, username, name: String.to_atom(username))
          returnValue = true
          # :ets.insert(:Process_Table, {username, pid})
          # to check if user is logged in or not
          :ets.insert(:UserState, {username, true})
          {:reply, returnValue, state}
        else
          {:reply, returnValue, state}
        end

      [] ->
        {:error, returnValue, state}
    end
  end

  # get tweets callback
  def handle_call({:get_tweets, user_info}, from, _state) do
    username = elem(user_info, 0)
    state = :ets.lookup(:Tweets, username)
    {:reply, from, state}
  end

  # post tweet to subscriber
  def handle_call({:post_tweet_to_subscribers, user_info}, from, state) do
    tweet = elem(user_info, 1)
    subscribers = elem(user_info, 2)
    # add to the table User_Wall for all subscribers
    Enum.each(subscribers, fn subscriber ->
      [listOfOldTweets] = :ets.lookup(:User_Wall, subscriber)
      oldTweet = elem(listOfOldTweets, 1)
      newTweet = [tweet | oldTweet]
      :ets.insert(:User_Wall, {subscriber, newTweet})
    end)

    {:reply, from, state}
  end
end
