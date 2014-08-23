class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.date :date
      t.references :user, index: true

      t.timestamps
    end
    add_index :schedules, :date, unique: true
  end
end
