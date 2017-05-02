class CreateChecks < ActiveRecord::Migration[5.0]
  def change
    create_table :checks do |t|
      t.boolean :isCheck
      t.references :user, foreign_key: true
      t.references :lecture, foreign_key: true

      t.timestamps
    end
  end
end
