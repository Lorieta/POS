class MakeCustomerDeliveryOptional < ActiveRecord::Migration[8.1]
  def up
    change_column_null :customers, :delivery_id, true if column_exists?(:customers, :delivery_id)
  end

  def down
    change_column_null :customers, :delivery_id, false if column_exists?(:customers, :delivery_id)
  end
end
