class AddStatusInQuery < ActiveRecord::Migration
  def change
  	add_column :queries, :status, :integer
  end
end
