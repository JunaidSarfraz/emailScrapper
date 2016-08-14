class CreateQueryRecords < ActiveRecord::Migration
  def change
    create_table :query_records do |t|
    	t.integer :query_id
    	t.integer :record_id
    	
      t.timestamps null: false
    end
  end
end
