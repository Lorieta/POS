class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :order_quantity
      t.date :order_date
      t.string :payment_method

      t.timestamps
    end
  end
end
