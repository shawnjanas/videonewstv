class Authentication < ActiveRecord::Base
  attr_accessible :provider, :uuid, :token, :token_secret

  belongs_to :user
end
