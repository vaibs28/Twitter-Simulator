defmodule Simulator do
  use GenServer

  def start_link(num_user, num_msg) do
    # start server
    GenServer.start_link(Server, [num_user, num_msg], name: String.to_atom("server"))
    # start simulation
    # register_user("user1", "pass1")
    # login_user("user1", "pass2")

    createAndRegisterusers(num_user)
    loginAllUsers(num_user)
    logout_all_users(num_user)
    IO.inspect(isUserLoggedIn("user500"))
    login_user("user500", "pass500")
    view_process_table()

    # for i <- 1..num_user do
    #  user1 = "user#{i}"

    #  for j <- 2..num_user do
    #    user2 = "user#{j}"
    #    add_follower(user1, user2)
    #  end
    # end

    generate_tweets(num_user, num_msg)

    get_user_state("user500")
    # for i <- 1..num_user do
    #  user = "user#{i}"
    #  get_user_state(user)
    # end

    # view_process_table()
    # loginAllUsers(num_user)
    # add_follower("user1", "user2")
    # add_follower("user1", "user3")
    # add_follower("user1", "user4")
    # new_tweet("user1", "tweet from user1")
    # new_tweet("user1", "2nd tweet from user1")
    # get_user_state("user1")
    # get_user_state("user2")
    # add_follower("user2", "user1")
    # get_user_state("user2")
    # get_user_state("user4")
    # new_tweet("user1", "3rd tweet from user1 #great #amazing @user3")
    # get_user_state("user2")
    # query_by_hashtag("#great")
    # query_by_hashtag("#amazing")
    # query_by_mention("@user3")
    # query_by_id(4)
    # retweet("user2", "user1", 1)
    # retweet("user2", "user1", 2)
    # new_tweet("user2", "tweet from user2")
    # get_user_state("user1")
    # new_tweet("user1", "4th tweet user1 #abc")
    # get_user_state("user2")
    # login_user("user1", "pass1")
    # delete_account("user1")
    # get_user_state("user1")
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

  def is_user_registered(username) do
    if :ets.lookup(:Users, username) != [] do
      true
    else
      false
    end
  end

  # login user with the passed credentials
  def login_user(userName, password) do
    if is_user_registered(userName) == false do
      false
    else
      currentUserState = :ets.lookup_element(:UserState, userName, 2)
      # not logged in
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
      :ets.lookup_element(:Tweets, username, 2)
    else
      "Not logged in"
    end
  end

  # return the logged in state , return true if logged in else returns false
  def isUserLoggedIn(username) do
    if(
      :ets.lookup(:UserState, username) == [] ||
        :ets.lookup_element(:UserState, username, 2) == false
    ) do
      false
    else
      :ets.lookup_element(:UserState, username, 2)
    end
  end

  def view_process_table() do
    IO.inspect(:ets.tab2list(:Process_Table))
  end

  # post a new tweet
  def new_tweet(username, tweet) do
    if isUserLoggedIn(username) == true do
      GenServer.call(String.to_atom(username), {:tweet, {username, tweet, "tweet"}})
      IO.puts("#{tweet} posted")
      true
    else
      false
    end
  end

  # retweet a post
  def retweet(username, tweetuser, tweetid) do
    ret = GenServer.call(String.to_atom(username), {:retweet, {tweetuser, tweetid, username}})
    ret
  end

  # prints the user's state including the tweets, followers and the wall
  def get_user_state(username) do
    IO.puts("Tweets by user")
    IO.inspect(:ets.lookup(:Tweets, username))
    IO.puts("Followers of user")
    IO.inspect(:ets.lookup(:Followers, username))
    IO.puts("User Wall")
    IO.inspect(:ets.lookup(:User_Wall, username))
  end

  def show_followers(user) do
    :ets.lookup_element(:Followers, user, 2)
  end

  # subscribe to a user
  @spec add_follower(any, any) :: any
  def add_follower(username, follower) do
    ret = GenServer.call(String.to_atom(username), {:add_follower, {username, follower}})

    if(ret == true) do
      IO.puts("#{follower} subscribed to #{username}")
    end

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

  def query_by_subscribeduserid(userid, user_subscribed_to) do
    IO.inspect(:ets.lookup(:TweetById, userid))
  end

  # delete account
  def delete_account(username) do
    if :ets.delete(:Users, username) == true do
      "User Deleted"
    else
      "Cannot Delete the User"
    end
  end

  # logout all users
  def logout_all_users(num_user) do
    for i <- 1..num_user do
      user = "user" <> "#{i}"
      GenServer.call(String.to_atom("server"), {:logout, {user}})
      ret = true
      IO.inspect("" <> user <> " logout successful")
      :ets.insert(:UserState,{user,false})
      ret
    end
  end

  # generate tweets
  def generate_tweets(num_user, num_tweets) do
    for i <- 1..num_user do
      user = "user" <> "#{i}"

      for j <- 1..num_tweets do
        tweet = "tweet #{j} from user #{user}"
        new_tweet(user, tweet)
      end
    end
  end
end
