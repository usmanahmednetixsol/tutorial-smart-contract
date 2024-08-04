// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TwitterContract {
    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 datePublished;
        uint256 likesCount;
    }

    struct TweetWithLikes {
        Tweet tweet;
        mapping(address => bool) likes;
    }

    mapping(address => TweetWithLikes[]) public tweets;
    uint16 public MAX_TWEET_LENGTH = 280;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    event createTweetEvent(uint256 id,address author, string content,uint256 datePublished);
    event LikeTweet(address liker,uint256 tweetId,address tweetAuthor, uint256 likesCount);
    event UnlikeTweet(address unliker,uint256 tweetId,address tweetAuthor, uint256 likesCount);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function changeTweetLength(uint16 _length) public onlyOwner {
        MAX_TWEET_LENGTH = _length;
    }

    function createTweet(string memory _tweet) public {
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet too long");

        TweetWithLikes storage newTweet = tweets[msg.sender].push();
        newTweet.tweet.id = tweets[msg.sender].length - 1;
        newTweet.tweet.author = msg.sender;
        newTweet.tweet.content = _tweet;
        newTweet.tweet.datePublished = block.timestamp;
        newTweet.tweet.likesCount = 0;
        emit createTweetEvent(tweets[msg.sender].length - 1, msg.sender, _tweet, block.timestamp);
    }

    function like(address _author, uint256 _id) external {
        require(tweets[_author].length > _id, "Tweet doesn't exist");

        TweetWithLikes storage twt = tweets[_author][_id];
        require(!twt.likes[msg.sender], "Already liked");

        twt.likes[msg.sender] = true;
        twt.tweet.likesCount++;
        emit LikeTweet(msg.sender, _id, _author, twt.tweet.likesCount);
    }

    function unlike(address _author, uint256 _id) external {
        require(tweets[_author].length > _id, "Tweet doesn't exist");

        TweetWithLikes storage twt = tweets[_author][_id];
        require(twt.likes[msg.sender], "Not liked yet");

        twt.likes[msg.sender] = false;
        twt.tweet.likesCount--;
        emit UnlikeTweet(msg.sender, _id, _author, twt.tweet.likesCount);
    }

    function totalLikes(address _author, uint256 _id) public view returns (uint256) {
        require(tweets[_author].length > _id, "Tweet doesn't exist");

        return tweets[_author][_id].tweet.likesCount;
    }

    function getTweet(address _author, uint _i) public view returns (Tweet memory) {
        require(tweets[_author].length > _i, "Tweet doesn't exist");
        return tweets[_author][_i].tweet;
    }

    function getAllTweets(address _author) public view returns (Tweet[] memory) {
        uint256 length = tweets[_author].length;
        Tweet[] memory allTweets = new Tweet[](length);
        for (uint256 i = 0; i < length; i++) {
            allTweets[i] = tweets[_author][i].tweet;
        }
        return allTweets;
    }
}
