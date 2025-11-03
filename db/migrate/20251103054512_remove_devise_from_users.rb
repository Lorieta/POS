class RemoveDeviseFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :encrypted_password, :string, if_exists: true
    remove_column :users, :reset_password_token, :string, if_exists: true
    remove_column :users, :reset_password_sent_at, :datetime, if_exists: true
    remove_column :users, :remember_created_at, :datetime, if_exists: true

    remove_index :users, name: 'index_users_on_email', if_exists: true
    remove_index :users, column: :reset_password_token, if_exists: true

    add_column :users, :password_digest, :string
  end
end
