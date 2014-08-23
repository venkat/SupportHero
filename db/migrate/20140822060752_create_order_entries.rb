class CreateOrderEntries < ActiveRecord::Migration
  def change
    create_table :order_entries do |t|
      t.integer :order
      t.references :user, index: true

      t.timestamps
    end
  end
end
