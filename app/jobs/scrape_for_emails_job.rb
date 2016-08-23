class ParsePDF
	def self.extract_writer_information_from_pdf
		require 'pdf-reader'
		emails = Array.new
		File.open("test.pdf", "rb") do |io|
			reader = ( PDF::Reader.new(io) rescue nil )
			if reader
			 	reader.pages.first.text.lines.delete_if { | line | line.strip.empty? }.each do |line|
			 		line.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).each do |email|
			 			emails << email
			 		end
			 	end
			end
		end
		File.delete('test.pdf')
		return emails
	end
end


class ScrapeForEmailsJob
	include SuckerPunch::Job

  def perform(base_url, query_id)
  	require 'mechanize'
  	require 'pdf-reader'

  	query = Query.find(query_id)
  	puts base_url
  	urls_scrapper = []
	mechanize = Mechanize.new
	arr = Array.new
	files = Array.new
	page = mechanize.get(base_url)
	if page.present? and !urls_scrapper.include?(page.uri)
		urls_scrapper << page.uri
		if page.class.name == "Mechanize::Page"
			final_content = page.body.to_s.gsub("{at}", "@")
		elsif page.class.name == "Mechanize::File"
			final_content = ""
			page.save("test.pdf")
			File.open("test.pdf", "rb") do |io|
				reader = ( PDF::Reader.new(io) rescue nil )
				if reader
				 	reader.pages.first.text.lines.delete_if { | line | line.strip.empty? }.each do |line|
				 		line.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).each do |email|
				 			final_content = final_content + "\n" + line
				 		end
				 	end
				end
			end
			File.delete('test.pdf')
		end
		emails = final_content.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)
		puts page.uri
		if emails.present?
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
		end
		if page.class.name == "Mechanize::Page"
			page.links.each do |link|
				arr << link
			end
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
				end
		  	if page1.class.name == "Mechanize::Page"
			  	page1.links.each do |link1|
			  		arr << link1
			  	end
			  elsif page1.class.name == "Mechanize::File"
			  	puts "Scrapping PDF"
			  	page1.save("test.pdf")
					emails = ParsePDF.extract_writer_information_from_pdf
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
			  	puts "Scrapping PDF"
			  end
			end
	  	i += 1
		end
	end
	query.update_attribute(:status, "complete")
  end
end