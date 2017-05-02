class CreateBoardComments < ActiveRecord::Migration[5.0]
  def change
    create_table :board_comments do |t|
      t.string :content
      t.references :user, foreign_key: true
      t.references :board, foreign_key: true

      t.timestamps
    end
  end
end
