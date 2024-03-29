class QueueInitVideoStream
  @queue = :high

  def self.perform(user_id)
    if (user = User.find_by_id(user_id))
      auth = user.authentications.first

      client = Twitter::Client.new(
        :oauth_token => auth.token,
        :oauth_token_secret => auth.token_secret
      )

      video_news = VideoNews.new(auth, user_id)
      new_since_id = video_news.timeline_tweets

      unless new_since_id.blank?
        user.since_id = new_since_id
        user.save
      end
    end
    nil
  end
end
