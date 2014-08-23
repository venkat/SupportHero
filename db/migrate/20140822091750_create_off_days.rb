class CreateOffDays < ActiveRecord::Migration
  def change
    create_table :off_days do |t|
      t.date :date
      t.references :user, index: true

      t.timestamps
    end
    add_index :off_days, :date, unique: true
  end
end
