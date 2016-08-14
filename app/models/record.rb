class Record < ActiveRecord::Base
	has_many :query_records
	has_many :queries, :through => :query_records
end
