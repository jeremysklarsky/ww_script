class CreateLines < ActiveRecord::Migration[5.0]
  def change
    create_table :lines do |t|
      t.string :text
      t.integer :character_id
      t.integer :scene_id
      t.integer :episode_id
      t.integer :location_id

      t.timestamps
    end
  end
end
