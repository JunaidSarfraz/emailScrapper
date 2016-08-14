class HomeController < ApplicationController
	
	def index
	end

	def extract_urls_count
		@query = Query.create(:query_url => params[:base_url])
		ScrapeForEmailsJob.perform_async(params[:base_url], @query.id)
		# ScrapeForEmailsJob.perform_later(params[:base_url], @query.id)
		render json: @query.id
	end

	def get_records
		render partial: "home/records", locals: { records: Query.find(params[:query_id]).records }
	end
end