class Customer < ApplicationRecord
  belongs_to :delivery, optional: true
  has_many :orders, dependent: :nullify
end
