class QueueInitVideoStream
  @queue = :high

  def self.perform(user_id)
    if (user = User.find_by_id(user_id))
      auth = user.authentications.first

      client = Twitter::Client.new(
        :oauth_token => auth.token,
        :oauth_token_secret => auth.token_secret
      )

      tweets = client.home_timeline(:count => 200)

      unless tweets.blank?
        max_id = nil
        tweets.each do |tweet|
          url = tweet.urls
          max_id = tweet.id
        end
      end
    end
  end
end
