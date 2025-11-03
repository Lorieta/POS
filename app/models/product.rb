class Product < ApplicationRecord
    has_one :user
    has_many :orders
    has_many :deliveries
    has_one_attached :image
end
