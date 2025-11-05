class MakeDeliveryUserOptional < ActiveRecord::Migration[8.1]
  def up
    change_column_null :deliveries, :user_id, true if column_exists?(:deliveries, :user_id)
  end

  def down
    change_column_null :deliveries, :user_id, false if column_exists?(:deliveries, :user_id)
  end
end
