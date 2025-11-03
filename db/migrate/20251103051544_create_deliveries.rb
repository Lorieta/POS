class CreateDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :deliveries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.string :country
      t.string :province
      t.string :city
      t.string :street
      t.string :branggay
      t.string :unit
      t.string :floor
      t.string :building
      t.string :landmark
      t.string :remarks

      t.timestamps
    end
  end
end
