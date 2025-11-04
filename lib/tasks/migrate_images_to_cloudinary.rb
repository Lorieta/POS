#!/usr/bin/env ruby
# Run with: rails runner lib/tasks/migrate_images_to_cloudinary.rb

puts "Starting migration of product images from local storage to Cloudinary..."
puts "=" * 80

Product.find_each do |product|
  next unless product.image.attached?

  # Skip if already on Cloudinary
  if product.image.service_name == "cloudinary"
    puts "Product #{product.id} (#{product.name}): Already on Cloudinary ✓"
    next
  end

  begin
    puts "\nMigrating Product #{product.id} (#{product.name})..."

    # Download the image data from local storage
    image_data = product.image.download
    filename = product.image.filename.to_s
    content_type = product.image.content_type

    # Remove the old attachment
    product.image.purge

    # Re-attach with Cloudinary (new uploads will use the configured service)
    product.image.attach(
      io: StringIO.new(image_data),
      filename: filename,
      content_type: content_type
    )

    # Verify it's now on Cloudinary
    product.reload
    if product.image.attached? && product.image.service_name == "cloudinary"
      puts "  ✓ Successfully migrated to Cloudinary"
      puts "  Service: #{product.image.service_name}"
      puts "  URL: #{product.image.url}"
    else
      puts "  ✗ Migration failed - still on #{product.image.service_name}"
    end

  rescue => e
    puts "  ✗ Error migrating Product #{product.id}: #{e.message}"
    puts "  #{e.backtrace.first}"
  end
end

puts "\n" + "=" * 80
puts "Migration complete!"
puts "\nSummary:"
Product.find_each do |product|
  if product.image.attached?
    puts "  Product #{product.id} (#{product.name}): #{product.image.service_name}"
  else
    puts "  Product #{product.id} (#{product.name}): no image"
  end
end
