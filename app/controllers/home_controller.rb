class HomeController < ApplicationController
	
	@@number_of_jobs = 1
	def index
	end

	def extract_urls_count
		if @@number_of_jobs > 2
			render json: false
		else
			@@number_of_jobs = @@number_of_jobs + 1
			@query = Query.create(:query_url => params[:base_url])
			@query.update_attribute(:status, 'incomplete')
			ScrapeForEmailsJob.perform_async(params[:base_url], @query.id)
			# ScrapeForEmailsJob.perform_later(params[:base_url], @query.id)
			render json: @query.id
		end
	end

	def get_records
		render partial: "home/records", locals: { records: Query.find(params[:query_id]).records }
	end
end