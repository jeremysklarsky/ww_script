class AddNumberToSeasons < ActiveRecord::Migration[5.0]
  def change
    add_column :seasons, :number, :integer
  end
end
