class Query < ActiveRecord::Base
	has_many :query_records
	has_many :records, :through => :query_records

	enum status: [:incomplete, :complete]
end
