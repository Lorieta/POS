class Product < ApplicationRecord
    belongs_to :user, optional: true
    has_many :orders
    has_many :deliveries
    has_one_attached :image
end
