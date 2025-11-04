require "sendgrid-ruby"

class OrderMailer
  include SendGrid

  def self.payment_confirmation(orders:, summary:, recipient:)
    new(orders:, summary:, recipient:).deliver
  end

  def initialize(orders:, summary:, recipient:)
    @orders = Array(orders)
    @summary = normalize_summary(summary)
    @recipient = recipient
  end

  def deliver
    from = Email.new(email: default_from_address)
    to = Email.new(email: @recipient)
    subject = "✓ Payment Confirmed - Order #{order_reference_line}"
    content = Content.new(type: "text/html", value: html_body)
    mail = Mail.new(from, subject, to, content)

    sg = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    response = sg.client.mail._("send").post(request_body: mail.to_json)

    raise "SendGrid error: #{response.status_code} #{response.body}" unless response.status_code.to_i.between?(200, 299)

    response
  end

  private

  def default_from_address
    ENV.fetch("DEFAULT_MAIL_FROM", "helioad49@gmail.com")
  end

  def html_body
    total_amount = @summary.dig(:totals, :grand_total) || @orders.sum(&:total_amount)

    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Order Confirmation</title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
          }
          .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
          }
          .header {
            background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
            color: white;
            text-align: center;
            padding: 40px 20px;
          }
          .header h1 {
            margin: 0 0 10px 0;
            font-size: 28px;
            font-weight: 600;
          }
          .header p {
            margin: 0;
            font-size: 16px;
            opacity: 0.9;
          }
          .content {
            padding: 30px;
          }
          .section {
            margin-bottom: 30px;
          }
          .section-title {
            font-size: 18px;
            font-weight: 600;
            color: #4CAF50;
            margin-bottom: 15px;
            padding-bottom: 8px;
            border-bottom: 2px solid #e8f5e9;
          }
          .order-item {
            display: table;
            width: 100%;
            margin-bottom: 20px;
            padding: 20px;
            background-color: #fafafa;
            border-radius: 10px;
            border: 1px solid #e0e0e0;
          }
          .order-item-row {
            display: table-row;
          }
          .product-image-cell {
            display: table-cell;
            width: 120px;
            vertical-align: top;
            padding-right: 20px;
          }
          .product-image {
            width: 100px;
            height: 100px;
            object-fit: cover;
            border-radius: 8px;
            border: 2px solid #e0e0e0;
          }
          .order-details-cell {
            display: table-cell;
            vertical-align: top;
          }
          .product-name {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
          }
          .order-info {
            font-size: 14px;
            color: #666;
            margin: 5px 0;
          }
          .price {
            font-size: 18px;
            font-weight: 600;
            color: #4CAF50;
            margin-top: 10px;
          }
          .info-box {
            background-color: #f9f9f9;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #2196F3;
          }
          .info-line {
            margin: 8px 0;
            font-size: 14px;
          }
          .info-line strong {
            display: inline-block;
            min-width: 120px;
            color: #555;
          }
          .total-box {
            background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
            color: white;
            padding: 25px;
            border-radius: 10px;
            text-align: center;
            margin-top: 30px;
          }
          .total-label {
            font-size: 16px;
            opacity: 0.9;
            margin-bottom: 10px;
          }
          .total-amount {
            font-size: 36px;
            font-weight: 700;
            margin: 10px 0;
          }
          .status-badge {
            display: inline-block;
            background-color: rgba(255,255,255,0.2);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            margin-top: 10px;
            font-weight: 500;
          }
          .footer {
            background-color: #f5f5f5;
            text-align: center;
            padding: 30px 20px;
            color: #666;
            font-size: 13px;
            border-top: 1px solid #e0e0e0;
          }
          .footer p {
            margin: 8px 0;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1> Order Confirmation!</h1>
            <p>Thank you for your order</p>
            <p style="font-size: 14px; margin-top: 10px; opacity: 0.8;">Order #{order_reference_line}</p>
          </div>

          <div class="content">
            #{render_customer_section}
            #{render_delivery_section}
            #{render_orders_section}

            <div class="total-box">
              <div class="total-label">Total Amount Paid</div>
              <div class="total-amount">₱#{format_currency(total_amount)}</div>
              <div class="status-badge">CONFIRMED</div>
            </div>
          </div>

          <div class="footer">
            <p><strong>Thank you for your business!</strong></p>
            <p>This is an automated email. Please do not reply.</p>
            <p>If you have any questions, please contact our support team.</p>
            <p style="margin-top: 15px; font-size: 12px;">© #{Time.current.year} POS System. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    HTML
  end

  def render_customer_section
    return "" unless @summary.dig(:customer, :first_name) || @orders.first&.user

    user = @orders.first.user
    customer_name = @summary.dig(:customer, :first_name) || "#{user&.first_name} #{user&.last_name}".strip
    customer_email = @summary.dig(:customer, :email) || user&.email
    customer_phone = @summary.dig(:customer, :phone) || user&.phone_number

    <<~HTML
      <div class="section">
        <div class="section-title">👤 Customer Information</div>
        <div class="info-box">
          <div class="info-line"><strong>Name:</strong> #{customer_name}</div>
          #{customer_email ? "<div class=\"info-line\"><strong>Email:</strong> #{customer_email}</div>" : ''}
          #{customer_phone ? "<div class=\"info-line\"><strong>Phone:</strong> #{customer_phone}</div>" : ''}
          #{@summary[:payment_method] ? "<div class=\"info-line\"><strong>Payment Method:</strong> #{@summary[:payment_method]}</div>" : ''}
        </div>
      </div>
    HTML
  end

  def render_delivery_section
    # Try to get delivery from the first order
    delivery = @orders.first&.user&.deliveries&.last

    # If not found, try to find by order
    delivery ||= Delivery.find_by(order_id: @orders.first&.id) if @orders.first

    return "" unless delivery

    address_parts = []
    address_parts << [ delivery.floor, delivery.unit, delivery.building ].compact.reject(&:blank?).join(", ") if [ delivery.floor, delivery.unit, delivery.building ].any?(&:present?)
    address_parts << "#{delivery.street}, #{delivery.branggay}" if delivery.street.present?
    address_parts << "#{delivery.city}, #{delivery.province}" if delivery.city.present?
    address_parts << delivery.country if delivery.country.present?

    <<~HTML
      <div class="section">
        <div class="section-title">🚚 Delivery Information</div>
        <div class="info-box" style="border-left-color: #FF9800;">
          <div class="info-line"><strong>Address:</strong></div>
          #{address_parts.map { |line| "<div class=\"info-line\" style=\"padding-left: 20px;\">#{line}</div>" }.join("\n")}
          #{delivery.landmark.present? ? "<div class=\"info-line\"><strong>Landmark:</strong> #{delivery.landmark}</div>" : ''}
          #{delivery.remarks.present? ? "<div class=\"info-line\"><strong>Remarks:</strong> #{delivery.remarks}</div>" : ''}
        </div>
      </div>
    HTML
  end

  def render_orders_section
    <<~HTML
      <div class="section">
        <div class="section-title">📦 Order Details</div>
        #{@orders.map { |order| render_order_item(order) }.join("\n")}
      </div>
    HTML
  end

  def render_order_item(order)
    product = order.product
    image_url = get_product_image_url(product)

    <<~HTML
      <div class="order-item">
        <div class="order-item-row">
          #{image_url ? "<div class=\"product-image-cell\"><img src=\"#{image_url}\" alt=\"#{product.name}\" class=\"product-image\"></div>" : ''}
          <div class="order-details-cell">
            <div class="product-name">#{product.name}</div>
            <div class="order-info"><strong>Order ID:</strong> ##{order.id}</div>
            <div class="order-info"><strong>Quantity:</strong> #{order.order_quantity} pcs</div>
            <div class="order-info"><strong>Unit Price:</strong> ₱#{format_currency(product.product_price)}</div>
            <div class="order-info"><strong>Order Date:</strong> #{order.order_date.strftime('%B %d, %Y')}</div>
            #{order.status ? "<div class=\"order-info\"><strong>Status:</strong> #{order.status.titleize}</div>" : ''}
            <div class="price">Subtotal: ₱#{format_currency(order.total_amount)}</div>
          </div>
        </div>
      </div>
    HTML
  end

  def get_product_image_url(product)
    return nil unless product.image.attached?

    # For Active Storage with Cloudinary
    if product.image.service_name.to_s == "cloudinary"
      # Get the Cloudinary URL directly
      product.image.url
    else
      # For local disk storage, use Rails URL helpers which properly handle encoding
      # Get the configured host or default to localhost:3000
      default_url_options = Rails.application.config.action_mailer.default_url_options || {}
      host = default_url_options[:host] || "localhost:3000"
      protocol = default_url_options[:protocol] || (Rails.env.production? ? "https" : "http")

      # Use the rails_blob_url helper to generate proper URL with encoding
      Rails.application.routes.url_helpers.rails_blob_url(
        product.image,
        host: host,
        protocol: protocol
      )
    end
  rescue => e
    Rails.logger.error("Error getting product image URL: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    nil
  end

  def format_currency(amount)
    "%.2f" % amount.to_f
  end

  def format_amount(amount)
    amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  def normalize_summary(summary)
    return {} unless summary.present?

    deep_transform_keys(summary) { |key| key.to_s.underscore.to_sym }
  end

  def order_reference_line
    @orders.map { |order| "##{order.id}" }.join(", ")
  end

  def deep_transform_keys(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[block.call(key)] = deep_transform_keys(value, &block)
      end
    when Array
      object.map { |value| deep_transform_keys(value, &block) }
    else
      object
    end
  end
end
