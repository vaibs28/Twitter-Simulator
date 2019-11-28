defmodule Client do
  use GenServer

  def start_link(opts) do
    {:ok, opts}
  end

  def process_tweet(tweet) do
    {:ok, hashtag} = Regex.compile("#[^#@\\s]*")
    {:ok, mention} = Regex.compile("@[^#@\\s]*")
    hashtags = Regex.scan(hashtag, tweet)

    Enum.each(hashtags, fn hashtag ->
      hashtag = List.to_string(hashtag)
      :ets.insert(:Hashtags, {hashtag, tweet})
    end)

    mentions = Regex.scan(mention, tweet)

    Enum.each(mentions, fn mention ->
      mention = List.to_string(mention)
      :ets.insert(:Mentions, {mention, tweet})
    end)
  end

  def handle_call({:tweet, user_info}, _from, state) do
    userid = elem(user_info, 0)
    tweet = elem(user_info, 1)
    # check for retweet
    flag = elem(user_info, 2)
    [listOfOldTweets] = :ets.lookup(:Tweets, userid)
    oldTweet = elem(listOfOldTweets, 1)
    newTweet = [tweet | oldTweet]
    process_tweet(tweet)

    if(:ets.first(:TweetById) == :"$end_of_table") do
      tweetid = 1
      :ets.insert(:TweetById, {tweetid, userid, tweet})
    else
      tweetid = :ets.last(:TweetById)
      tweetid = tweetid + 1
      :ets.insert(:TweetById, {tweetid, userid, tweet})
    end

    oldFlags = :ets.lookup_element(:Tweets, userid, 3)
    newFlag = [flag | oldFlags]
    :ets.insert(:Tweets, {userid, newTweet, newFlag})

    :ets.insert(:User_Wall, {userid, newTweet})
    subscribers = :ets.lookup_element(:Followers, userid, 2)

    GenServer.call(
      String.to_atom("server"),
      {:post_tweet_to_subscribers, {userid, tweet, subscribers}}
    )

    {:reply, tweet, state}
  end

  def handle_call({:retweet, tweet_info}, _from, userState) do
    tweetuser = elem(tweet_info, 0)
    tweetId = elem(tweet_info, 1)
    userId = elem(tweet_info, 2)
    tweet = GenServer.call(String.to_atom(tweetuser), {:get_tweet_by_Id, {tweetId}})
    GenServer.call(String.to_atom(tweetuser), {:tweet, {userId, tweet, "retweet"}})
    {:reply, tweet, userState}
  end

  def handle_call({:get_tweet_by_Id, new_message}, _from, userState) do
    tweetId = elem(new_message, 0)
    tweet = :ets.lookup_element(:TweetById, tweetId, 3)
    {:reply, tweet, userState}
  end

  def handle_call({:add_follower, user_info}, _from, userState) do
    username = elem(user_info, 0)
    follower = elem(user_info, 1)
    [listOfFollowers] = :ets.lookup(:Followers, username)
    oldFollower = elem(listOfFollowers, 1)
    newFollower = [follower | oldFollower]

    if :ets.insert(:Followers, {username, newFollower}) == true do
      returnValue = true
      {:reply, returnValue, userState}
    else
      {:reply, false, userState}
    end
  end
end
