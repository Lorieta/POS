class User < ApplicationRecord
  has_secure_password

  enum :status, { user: "user", admin: "admin" }

  has_many :products
  has_many :orders
  has_many :deliveries
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true
  validates :status, inclusion: { in: statuses.keys }
end
