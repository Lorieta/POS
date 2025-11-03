class AddstatustoColumn < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :status, :string, null: false, default: "user"
  end
end
