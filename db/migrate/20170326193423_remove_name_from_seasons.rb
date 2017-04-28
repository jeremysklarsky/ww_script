class RemoveNameFromSeasons < ActiveRecord::Migration[5.0]
  def change
    remove_column :seasons, :name, :string
  end
end
