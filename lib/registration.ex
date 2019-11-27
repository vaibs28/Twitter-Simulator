defmodule Registration do

  def register_user(username, credentials) do
      case :ets.lookup(:users, username) do
          [_] -> {:error, :username_taken}
          [] -> :ets.insert(:users,{username, credentials})
                  {:ok, :registered}
      end
  end

  # service API for logging in. Returns a pid of a "User" actor if the login worked, :login_failed if it didn't
  def login(userid, _credentials, clientpid) do
      userlookup = :ets.lookup(:users, userid)
      case userlookup do
          [{userid, _credentials}] ->
              userserver = :ets.lookup(:user_servers,userid)
              if (length(userserver)==0) do
                  tweetidtuple = :ets.lookup(:user_tweet_counter, userid)
                  tweetcounter = if(length(tweetidtuple)==0) do 0 else elem(hd(tweetidtuple),1) + 1 end
                  {:ok, pid}=UserActor.start(%{:userid=>userid,:clientpid=>clientpid, :tweetcounter=>tweetcounter})
                  :ets.insert(:user_servers, {userid, pid})
                  UserActor.deliver_unread(pid)
                  pid
              else
                  {_, pid}=hd(userserver)
                  UserActor.update_client(pid, clientpid)
                  pid
              end
          [] -> {:error, :no_such_user}
      end
  end

  def logout(userid, _credentials) do
      userlookup = :ets.lookup(:users, userid)
      case userlookup do
          [{userid, _credentials}] ->
              [userserver] = :ets.lookup(:user_servers,userid)
              if (userserver==nil) do
                  {:ok, :logout}
              else
                  {_, pid}=userserver
                  if Process.alive?(pid) do GenServer.stop(pid) end
                  :ets.delete(:user_servers, userid)
                  {:ok, :logout}
              end
          [] -> {:error, :no_such_user}
      end
  end
end
