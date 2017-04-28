class CreateSceneCharacters < ActiveRecord::Migration[5.0]
  def change
    create_table :scene_characters do |t|
      t.integer :scene_id
      t.integer :character_id

      t.timestamps
    end
  end
end
