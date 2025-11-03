class UpdateUserStatusValues < ActiveRecord::Migration[8.1]
  def up
    unless column_exists?(:users, :status)
      add_column :users, :status, :string, null: false, default: "user"
      return
    end

    change_column_default :users, :status, "user"

    execute <<~SQL.squish
      UPDATE users
      SET status = 'user'
      WHERE status IS NULL OR status NOT IN ('user', 'admin');
    SQL
  end

  def down
    return unless column_exists?(:users, :status)

    execute <<~SQL.squish
      UPDATE users
      SET status = CASE
        WHEN status = 'admin' THEN 'inactive'
        ELSE 'active'
      END
      WHERE status IN ('user', 'admin');
    SQL

    change_column_default :users, :status, "active"
  end
end
