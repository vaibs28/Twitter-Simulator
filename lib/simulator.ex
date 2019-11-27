defmodule Simulator do
  use GenServer

  def start_link(num_user, num_msg) do
    # start server
    GenServer.start_link(Server, [num_user, num_msg], name: String.to_atom("server"))
    # start simulation
    # register_user("user1", "pass1")
    # login_user("user1", "pass2")
    :ets.new(:Process_Table, [:set, :public, :named_table])
    createAndRegisterusers(num_user)
    # view_process_table()
    loginAllUsers(num_user)
    add_follower("user1", "user2")
    add_follower("user1", "user3")
    add_follower("user1", "user4")
    new_tweet("user1", "tweet from user1")
    new_tweet("user1", "2nd tweet from user1")
    #get_user_state("user1")
    get_user_state("user2")
    #add_follower("user2", "user1")
    #get_user_state("user2")
    #get_user_state("user4")
    new_tweet("user1", "3rd tweet from user1 #great #amazing @user3")
    get_user_state("user2")
    #query_by_hashtag("#great")
    #query_by_hashtag("#amazing")
    #query_by_mention("@user3")
    #query_by_id(4)
    #retweet("user2", "user1", 1)
    #retweet("user2", "user1", 2)
    #get_user_state("user1")
    new_tweet("user1", "4th tweet user1 #abc")
    get_user_state("user2")
    # login_user("user1", "pass1")
  end

  def init(state) do
    # IO.inspect(state)
    {:ok, state}
  end

  # create users based on the num_user and register them
  def createAndRegisterusers(num_user) do
    for i <- 1..num_user do
      uname = "user" <> "#{i}"
      pass = "pass" <> "#{i}"
      pid = register_user(uname, pass)
      # :ets.insert(:Process_Table, {uname, pid})
      # IO.inspect(pid)
    end
  end

  # login all users
  @spec loginAllUsers(integer) :: [any]
  def loginAllUsers(num_user) do
    for i <- 1..num_user do
      uname = "user" <> "#{i}"
      pass = "pass" <> "#{i}"
      login_user(uname, pass)
      # IO.inspect(pid)
    end
  end

  # register a new user with the username if the username does not exist
  def register_user(userName, password) do
    ret = GenServer.call(String.to_atom("server"), {:register_user, {userName, password}})

    if(ret == true) do
      IO.puts("registration successful for #{userName}")
    else
      IO.puts("registration unsuccessful")
    end

    ret
  end

  # login user with the passed credentials
  def login_user(userName, password) do
    if :ets.lookup(:UserState, userName) == [] do
      false
    else
      currentUserState = :ets.lookup_element(:UserState, userName, 2)

      if(currentUserState == false) do
        ret = GenServer.call(String.to_atom("server"), {:login_user, {userName, password}})

        if(ret == true) do
          IO.puts("login successful for #{userName}")
          # get the tweets made by the user
          get_tweets(userName)
          ret
        else
          IO.puts("login unsuccessful")
          ret
        end
      else
        IO.puts("User #{userName} already logged in")
        false
      end
    end
  end

  # get all tweets for a user if the user is logged in
  def get_tweets(username) do
    if(isUserLoggedIn(username) == true) do
      GenServer.call(String.to_atom("server"), {:get_tweets, {username}})
      "Successfully fetched"
    else
      "Not logged in"
    end
  end

  # return the logged in state , return true if logged in else returns false
  def isUserLoggedIn(username) do
    if(:ets.lookup(:UserState, username) == []) do
      false
    else
      :ets.lookup_element(:UserState, username, 2)
    end
  end

  def view_process_table() do
    IO.inspect(:ets.lookup(:Process_Table, "user1"))
  end

  def new_tweet(username, tweet) do
    if isUserLoggedIn(username) == true do
      GenServer.call(String.to_atom(username), {:tweet, {username, tweet}})
      IO.puts("tweet posted")
      true
    else
      false
    end
  end

  def retweet(username, tweetuser, tweetid) do
    GenServer.call(String.to_atom(username), {:retweet, {tweetuser, tweetid, username}})
  end

  def get_user_state(username) do
    IO.puts("Tweets by user")
    IO.inspect(:ets.lookup(:Tweets, username))
    IO.puts("Followers of user")
    IO.inspect(:ets.lookup(:Followers, username))
    IO.puts("User Wall")
    IO.inspect(:ets.lookup(:User_Wall, username))
  end

  def add_follower(username, follower) do
    ret = GenServer.call(String.to_atom(username), {:add_follower, {username, follower}})
    ret
  end

  def query_by_hashtag(hashtag) do
    IO.inspect(:ets.lookup(:Hashtags, hashtag))

    if :ets.lookup(:Hashtags, hashtag) == [] do
      "hashtag not found"
    else
      :ets.lookup_element(:Hashtags, hashtag, 2)
    end
  end

  def query_by_mention(mention) do
    IO.inspect(:ets.lookup(:Mentions, mention))

    if :ets.lookup(:Mentions, mention) == [] do
      "mention not found"
    else
      :ets.lookup_element(:Mentions, mention, 2)
    end
  end

  def query_by_id(id) do
    IO.inspect(:ets.lookup(:TweetById, id))
  end
end
