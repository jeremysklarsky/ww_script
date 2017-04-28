class AddEpisodeActToScenes < ActiveRecord::Migration[5.0]
  def change
    add_column :scenes, :episode_act, :integer
  end
end
