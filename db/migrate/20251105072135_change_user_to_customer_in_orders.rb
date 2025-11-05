class ChangeUserToCustomerInOrders < ActiveRecord::Migration[8.1]
  def change
    # Remove the existing foreign key and user_id column
    remove_foreign_key :orders, :users
    remove_index :orders, :user_id if index_exists?(:orders, :user_id)
    remove_column :orders, :user_id, :integer

    # Add new reference to customers
    add_reference :orders, :customer, null: false, foreign_key: true
  end
end
