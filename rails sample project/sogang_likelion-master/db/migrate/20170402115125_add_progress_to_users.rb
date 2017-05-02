class AddProgressToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :lecProgress, :string, :default => "0%"
    add_column :users, :workProgress, :string, :default => "0%"
  end
end
