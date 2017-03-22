class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :uid
      t.text :name
      t.integer :mobile
      t.integer :r_id	
      t.timestamps
    end
  end
end
