class ChangeEpisodeActInScenes < ActiveRecord::Migration[5.0]
  def change
    rename_column :scenes, :episode_act, :episode_act_id
  end
end
