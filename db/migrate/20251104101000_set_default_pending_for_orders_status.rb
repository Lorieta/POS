class SetDefaultPendingForOrdersStatus < ActiveRecord::Migration[8.1]
  def up
    # Ensure existing records have a valid status
    execute "UPDATE orders SET status = 'pending' WHERE status IS NULL"

    # Set default and enforce not-null for future records
    change_column_default :orders, :status, 'pending'
    change_column_null :orders, :status, false
  end

  def down
    change_column_null :orders, :status, true
    change_column_default :orders, :status, nil
  end
end
