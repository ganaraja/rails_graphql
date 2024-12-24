class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :full_name
      t.string :address
      t.string :status
      t.string :item_name
      t.integer :total

      t.timestamps
    end
  end
end
