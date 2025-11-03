# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding database..."

# Create a user
user = User.find_or_create_by!(email: "test@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
  u.first_name = "Test"
  u.last_name = "User"
  u.phone_number = "1234567890"
  u.status = "user"
end
puts "Created user: #{user.email}"

# Create a product
product = Product.find_or_create_by!(name: "Sample Product") do |p|
  p.product_price = 10.99
  p.product_type = "General"
end
puts "Created product: #{product.name}"

# Create an order
order = Order.find_or_create_by!(user: user, product: product) do |o|
  o.order_date = Date.today
  o.order_quantity = 2
  o.payment_method = "Credit Card"
end
puts "Created order: #{order.id}"

# Create a delivery
delivery = Delivery.find_or_create_by!(order: order) do |d|
  d.user = user
  d.street = "123 Main St"
  d.city = "Anytown"
  d.province = "Anystate"
  d.country = "USA"
  d.branggay = "Downtown"
end
puts "Created delivery for order: #{delivery.order_id}"

puts "Seeding complete."