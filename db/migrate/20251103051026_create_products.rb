class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :product_photo
      t.string :product_type
      t.float :product_price

      t.timestamps
    end
  end
end
