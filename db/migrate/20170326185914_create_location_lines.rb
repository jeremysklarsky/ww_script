class CreateLocationLines < ActiveRecord::Migration[5.0]
  def change
    create_table :location_lines do |t|
      t.integer :location_id
      t.integer :line_id

      t.timestamps
    end
  end
end
