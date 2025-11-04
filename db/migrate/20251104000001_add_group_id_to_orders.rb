class AddGroupIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :group_id, :string
    add_index :orders, :group_id
  end
end
