class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
    	t.integer :query_id
    	t.string 	:email
      t.timestamps null: false
    end
  end
end
