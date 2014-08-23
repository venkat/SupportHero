class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays do |t|
      t.date :data

      t.timestamps
    end
    add_index :holidays, :data, unique: true
  end
end
