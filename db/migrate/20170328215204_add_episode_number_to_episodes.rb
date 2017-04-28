class AddEpisodeNumberToEpisodes < ActiveRecord::Migration[5.0]
  def change
    add_column :episodes, :number, :integer
  end
end
