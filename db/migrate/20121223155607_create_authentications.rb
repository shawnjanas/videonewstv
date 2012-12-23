class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.string :provider
      t.string :uuid
      t.string :token
      t.string :token_secret
      t.integer :user_id

      t.timestamps
    end
  end
end
