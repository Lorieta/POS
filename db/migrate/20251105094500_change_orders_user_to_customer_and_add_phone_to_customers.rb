class ChangeOrdersUserToCustomerAndAddPhoneToCustomers < ActiveRecord::Migration[8.1]
  def up
    add_column :customers, :phone_number, :string unless column_exists?(:customers, :phone_number)
  end

  def down
    remove_column :customers, :phone_number if column_exists?(:customers, :phone_number)
  end
end
