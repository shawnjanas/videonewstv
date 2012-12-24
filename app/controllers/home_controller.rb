class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:more_videos]

  def index
    if current_user
      client = Resque.redis

      if current_user.since_id
        @user_init = true

        @videos = VideoNews.get_videos(current_user, :hour)
      else
        @user_init = false
      end
    end
  end

  def more_videos
    @user_init = true

    page = params[:page].to_i || 1
    @videos = VideoNews.get_videos(current_user, :hour, page)

    render :partial => 'video_stream', :layout => false
  end

  def user_ready
    if current_user && !current_user.since_id.blank?
      render :json => {:ready => true}
    else
      render :json => {:ready => false}
    end
  end
end
