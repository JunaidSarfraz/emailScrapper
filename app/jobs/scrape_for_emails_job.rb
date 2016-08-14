class ScrapeForEmailsJob
	include SuckerPunch::Job

  def perform(base_url, query_id)
  	require 'mechanize'
  	query = Query.find(query_id)
  	puts "=-=-=-=- Query Id: " + query.id.to_s
  	puts base_url
  	urls_scrapper = []
		mechanize = Mechanize.new
		arr = Array.new
		files = Array.new
		page = mechanize.get(base_url)
		if page.present? and !urls_scrapper.include?(page.uri)
			urls_scrapper << page.uri
			final_content = page.body.to_s.gsub("{at}", "@")
			emails = final_content.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)
			puts page.uri
			if emails.present?
				puts "=-=-=-=-=- Some Emails =-=-=-=-=--\n"
				emails.each do |email|
					unless query.records.pluck(:email).include?(email)
						if Record.where(:email => email).count > 0
							query.records << Record.where(:email => email).first
						else
							query.records.create(:email => email)
						end
						puts email
					end
				end
				puts "=-=-=-=-=- Some Emails =-=-=-=-=--\n"
			end
			page.links.each do |link|
				arr << link
			end
			i = 0
			while i < arr.length  do
		  	link = arr[i]
		  	page1 = link.click rescue nil
		  	if page1.present? and !urls_scrapper.include?(page1.uri)
		  		urls_scrapper << page1.uri
			  	final_content = page1.body.to_s.gsub("{at}", "@")
			  	emails = final_content.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)
					puts page1.uri
					if emails.present?
						puts "=-=-=-=-=- Some Emails =-=-=-=-=--\n"
						emails.each do |email|
							unless query.records.pluck(:email).include?(email)
								if Record.where(:email => email).count > 0
									query.records << Record.where(:email => email).first
								else
									query.records.create(:email => email)
								end
								puts email
							end
						end
						puts "=-=-=-=-=- Some Emails =-=-=-=-=--\n"
					end
			  	if page1.class.name == "Mechanize::Page"
				  	page1.links.each do |link1|
				  		arr << link1
				  	end
				  elsif page1.class.name == "Mechanize::File"
				  	files << link
				  end
				end
		  	i += 1
			end
		end
  end
end