class AddTypeToLectures < ActiveRecord::Migration[5.0]
  def change
    add_column :lectures, :lecType, :integer, :default => 1
  end
end
