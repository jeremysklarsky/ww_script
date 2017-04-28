class CreateEpisodeLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :episode_locations do |t|
      t.integer :episode_id
      t.integer :location_id

      t.timestamps
    end
  end
end
