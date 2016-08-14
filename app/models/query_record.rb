class QueryRecord < ActiveRecord::Base
	belongs_to :query
	belongs_to :record
end
