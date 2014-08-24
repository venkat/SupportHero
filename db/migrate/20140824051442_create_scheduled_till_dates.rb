class CreateScheduledTillDates < ActiveRecord::Migration
  def change
    create_table :scheduled_till_dates do |t|
      t.date :date

      t.timestamps
    end
    add_index :scheduled_till_dates, :date, unique: true
  end
end
