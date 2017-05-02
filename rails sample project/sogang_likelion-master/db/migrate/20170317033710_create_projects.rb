class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.references :user
      t.string :title
      t.text :content
      t.string :link
      t.string :img

      t.timestamps
    end
  end
end
