class AddGitLinkToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :gitLink, :string
  end
end
