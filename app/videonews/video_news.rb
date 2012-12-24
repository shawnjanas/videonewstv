class VideoNews
  def initialize(auth, user_id)
    @tw_client = Twitter::Client.new(
      :oauth_token => auth.token,
      :oauth_token_secret => auth.token_secret
    )
    @redis_client = Resque.redis
    @yt_client = YouTubeIt::Client.new

    @user_id = user_id
  end

  def self.get_videos(user, range, page = 1)
    client = Resque.redis
    time = VideoNews.time

    start_index = -1*page*10
    end_index = (-1*(page-1)*10) - 1

    videos = client.zrange("user:#{user.id}:top_videos:#{time}", start_index, end_index, :withscores => true).reverse
    videos = videos.map do |video|
      tweets = client.smembers("user:#{user.id}:video:#{video[0]}:tweets:#{time}")
      video_info = client.get("video:#{video[0]}")
      {
        :count => video[1].to_i,
        :video_id => video[0],
        :tweets => tweets.map{|t|JSON.parse(t)},
        :video_info => JSON.parse(video_info),
      }
    end
  end

  def timeline_tweets(options = {})
    params = {:count => 200}
    params[:max_id] = options[:max_id] unless options[:max_id].blank?
    params[:since_id] = options[:since_id] unless options[:since_id].blank?

    page = options[:page] || 0
    new_since_id = nil

    time = options[:time] || VideoNews.time

    begin
      tweets = @tw_client.home_timeline(params)
    rescue => e
      tweets = []
    end

    unless tweets.blank?
      max_id = nil
      last_date = nil

      tweets.each_with_index do |tweet,i|
        new_since_id = tweet.id if i == 0
        urls = tweet.urls
        urls.each do |url|
          if (video_id = self.parse_yt_url(url.expanded_url))
            self.store_video(video_id, tweet, time)
          end
        end
        max_id = tweet.id
      end

      page += 1

      # Twitter rate limit: 15 requests per 15 minutes for timeline_tweets
      if page < 15
        self.timeline_tweets(:max_id => max_id, :page => page, :time => time)
      end

      new_since_id
    end
  end

  def parse_yt_url(url)
    return nil if url.blank?

    if url.include? 'youtube.com'
      _url = url.split('?')
      query = Rack::Utils.parse_nested_query _url.last

      video_id = query['v']
      return video_id unless video_id.blank?
    elsif url.include? 'youtu.be'
      _url = url.split('/')
      video_id = _url.last[0,11]

      return video_id unless video_id.blank?
    end

    nil
  end

  def store_video(video_id, tweet, time)
    tweet_info = {
      :text => tweet['text'],
      :name => tweet['user']['name'],
      :avatar => tweet['user']['profile_image_url'],
    }
    @redis_client.sadd("user:#{@user_id}:video:#{video_id}:tweets:#{time}", tweet_info.to_json)

    yt_video = @yt_client.video_by(video_id)
    yt_info = {
      :title => yt_video.title,
      :duration => yt_video.duration,
      :thumbnail => "http://i.ytimg.com/vi/#{video_id}/default.jpg",
    }
    @redis_client.set("video:#{video_id}", yt_info.to_json)

    @redis_client.zincrby("user:#{@user_id}:top_videos:#{time}", 1, video_id)

    nil
  end

  def self.time
    now = Time.now.to_i
    now - (now % (15*60))
  end
end
