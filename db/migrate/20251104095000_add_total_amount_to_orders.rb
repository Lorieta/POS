class AddTotalAmountToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :total_amount, :decimal, precision: 12, scale: 2, null: false, default: 0
  end
end
