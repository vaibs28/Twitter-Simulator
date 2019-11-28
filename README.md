# Twitter-Simulator
Twitter simulator in elixir

### Group Members
1.   Madhav Sodhani       :     1988-9109 
2.   Vaibhav Mohan Sahay  :     5454-1830

### Steps to run the Project:
   `mix run proj4 <num_user> <num_tweets>`

### Steps to run the Tests:
    `mix test`

### What is Working

1. User Registration
2. User Login
3. Tweet by a logged in user
4. Follow a user and subscibe to his tweets
5. Retweet a tweet made by another user
6. View the subscribed and made tweets on the user wall
7. Tweets with hashtags and mentions.
8. Query the tweets with the hashtags and mentions.

### Functionalities Implemented

The project has an application module which is the entry point of the application.
The module calls the Simulator module with the parameters num_user and num_message.
We have a Client which will correspond to each of the users and a Server which will have ETS tables as the datastore and it performs the functionality of user registration , user logging and distribution of tweets.
The client implements the tweet and retweet functionality as well as subscribing to another user.
The simulator has helper methods for generating and logging in the users as well as generating tweets.

### Test Cases Created

1. Test User Registration
2. Test User Login Successfully
3. Test User Login Failure because of wrong username or password
4. Test for already registered user
5. Test for posting a new tweet
6. Test for posting a retweet successfully
7. Test for posting a new tweet with hashtag
8. Test for posting a new tweet with mention
9. Test for show tweets of a particular user
10. Test for show tweets of a user's subscription
11. Test for show followers of a user
12. Test for querying by hashtag
13. Test for querying by mention
14. Test for retweet failure
