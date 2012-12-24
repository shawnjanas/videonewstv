class QueueNewVideoStream
  @queue = :medium

  def self.perform
    User.all.each do |user|
      next if user.since_id.blank?

      auth = user.authentications.first

      client = Twitter::Client.new(
        :oauth_token => auth.token,
        :oauth_token_secret => auth.token_secret
      )

      since_id = user.since_id
      video_news = VideoNews.new(auth, user.id)
      new_since_id = video_news.timeline_tweets(:since_id => since_id)

      unless new_since_id.blank?
        user.since_id = new_since_id
        user.save
      end
    end
    nil
  end
end
