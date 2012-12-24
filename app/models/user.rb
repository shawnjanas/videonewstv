class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :nickname, :name, :image, :since_id

  has_many :authentications

  def self.find_for_twitter_oauth(omniauth)
    authentication = Authentication.find_by_provider_and_uuid(omniauth['provider'], omniauth['uid'])
    if authentication && authentication.user
      authentication.user
    else
      user = User.create!(
        :nickname => omniauth['info']['nickname'],
        :name => omniauth['info']['name'],
        :image => omniauth['info']['image'],
        :password => Devise.friendly_token[0,20]
      )
      user.authentications.create!(:provider => omniauth['provider'], :uuid => omniauth['uid'], :token => omniauth['credentials']['token'], :token_secret => omniauth['credentials']['secret'])
      user.save

      Resque.enqueue(QueueInitVideoStream, user.id)
      user
    end
  end
end
