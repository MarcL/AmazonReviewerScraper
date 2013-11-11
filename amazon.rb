require 'nokogiri'
require 'open-uri'

class AmazonReviewerParser

	def initialize(baseUrl)
		@baseUrl = baseUrl
		@maxPages = 3
		@numPages = 0
	end

	def ParseTopReviewersPage(pageUrl)
		data = Nokogiri::HTML(open(pageUrl))

		# Get links
		links = data.css("td.img a").map {|link| link['href']}

		# Remove any nils and make them unique (or we get multiple links to the same page)
		links = links.compact!.uniq

		# links.each{ |link| ParseReviewerPage(@baseUrl + link)}

		# Next page if we have one
		nextPage = data.xpath("/html/body/table/tbody/tr/td[1]/table[3]/tbody/tr/td[2]/div/span/a[3]/@href")
		puts nextPage
		@numPages += 1
		if (!nextPage.nil? and @numPages < @maxPages)
		end

	end

	def ParseReviewerPage(pageUrl)

		puts pageUrl
		data = Nokogiri::HTML(open(pageUrl))

		# Name
		# //*[@id="profileHeader"]/table/tbody/tr/td/table/tbody/tr/td/h1/span
		name = data.xpath("//*/h1/span").text
		puts "Name: " + name

		# Birthday!
		birthday = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[2]/div[2]/span").text
		puts "Birthday: " + birthday

		# Ranking info
		ranking = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[1]/div[3]/div[1]/b/a").text
		puts "Ranking: " + ranking

		# Location
		location = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[2]/div[1]").text
		location.slice! "Location:"
		puts "Location: " + location

		# Email
		# Some email addresses have hidden spaces to avoid scrapers
		# Hence let's take it from the mailto: HREF instead!
		email = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[2]/div[2]/span/a/@href").text
		email.slice! "mailto:"
		puts "Email: " + email

		# Website
		website = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[2]/div[3]/span/a").text
		puts "Website: " + website

		# Own words
		ownWords = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[2]/div[3]/div[2]").text
		puts "Own words: " + ownWords

		# Interests

		# //*[@id="interestsTags"]/div/div/div/div/div[1]
		# Check the pop-up first as it's the longer version
		interests = data.xpath("//*[@id=\"textPop_interests\"]").text
		if (interests.nil? or interests.empty?)
			interests = data.xpath("//*[@id=\"interestsTags\"]/div/div/div/div/div[1]").text
		end
		puts "Interests: " + interests
	end
end


parser = AmazonReviewerParser.new("http://www.amazon.co.uk")
# parser.ParseReviewerPage("http://www.amazon.co.uk/gp/pdp/profile/A1E0K9B6TW9MEY/ref=cm_cr_tr_tbl_1_name")
# parser.ParseReviewerPage("http://www.amazon.co.uk/gp/pdp/profile/A2N6VMZN3XIIYK/ref=cm_cr_tr_tbl_2_name")
# parser.ParseReviewerPage("http://www.amazon.co.uk/gp/pdp/profile/A1JUKS0DSO2XZG/ref=cm_cr_tr_tbl_3_name")
# parser.ParseReviewerPage("http://www.amazon.co.uk/gp/pdp/profile/A68CUQ90V1K1Y/ref=cm_cr_tr_tbl_5_name")
# parser.ParseReviewerPage("http://www.amazon.co.uk/gp/pdp/profile/A1RD1LL5E5JZOT/ref=cm_cr_tr_tbl_6_name")
# parser.ParseReviewerPage("http://www.amazon.co.uk/gp/pdp/profile/A2KG24N8MMUNFI/ref=cm_cr_tr_tbl_7_name")
parser.ParseTopReviewersPage("http://www.amazon.co.uk/reviews/top-reviewers")


# url = "http://www.amazon.co.uk/reviews/top-reviewers"
# # url = "http://www.amazon.co.uk/Mice-Genius-Study-Guide-ebook/dp/B00AJ3XEWO"
# # url = "http://www.amazon.co.uk/Revision-Literature-Annoying-Brothers-ebook/dp/B00CQYOYEG/ref=pd_sim_sbs_kinc_2"

# data = Nokogiri::HTML(open(url))

# # Regular expression to get number after a hash: #([1-9](?:\d{0,2})(?:,\d{3})*(?:\.\d*[1-9])?|0?\.\d*[1-9]|0)
# reviewers = data.at_css('tr#reviewer1').text
# puts reviewers

# # re = /#([1-9](?:\d{0,2})(?:,\d{3})*(?:\.\d*[1-9])?|0?\.\d*[1-9]|0)/
# # matches = salesRank.match re

# # puts matches
