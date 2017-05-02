class CreateRounds < ActiveRecord::Migration[5.0]
  def change
    create_table :rounds do |t|
      t.integer :month
      t.integer :week
      t.integer :count

      t.timestamps
    end
  end
end
