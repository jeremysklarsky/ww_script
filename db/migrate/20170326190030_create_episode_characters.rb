class CreateEpisodeCharacters < ActiveRecord::Migration[5.0]
  def change
    create_table :episode_characters do |t|
      t.integer :episode_id
      t.integer :character_id

      t.timestamps
    end
  end
end
