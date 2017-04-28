class CreateEpisodeActs < ActiveRecord::Migration[5.0]
  def change
    create_table :episode_acts do |t|
      t.string :name
      t.integer :episode_id
      t.integer :act_id

      t.timestamps
    end
  end
end
