class CreateAttendances < ActiveRecord::Migration[5.0]
  def change
    create_table :attendances do |t|
      t.references :member, foreign_key: true
      t.references :round, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
