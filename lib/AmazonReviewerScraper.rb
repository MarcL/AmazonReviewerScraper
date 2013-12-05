require 'nokogiri'
require 'open-uri'

class AmazonReviewerScraper
	attr_reader :reviewers

	def initialize(params = {})

		@baseUrl = params.fetch(:baseUrl, 'http://www.amazon.com')
		@maxPages = params.fetch(:maxPages, 1)
		@numPages = 1
		@reviewers = Array.new

		@reviewPageUrl = @baseUrl + "/review/top-reviewers?page="
		@productReviewsPageUrl = @baseUrl + "/product-reviews/%s/?pageNumber=%d"
	end

	def ParseTopReviewersPage(pageNum)
		pageUrl = @reviewPageUrl + @numPages.to_s
		data = Nokogiri::HTML(open(pageUrl))

		# Get links
		links = data.css("td.img a").map {|link| link['href']}

		# Remove any nils and make them unique (or we get multiple links to the same page)
		links = links.compact!.uniq

		# Follow each reviewer link and parse their data
		links.each{ |link|
			@reviewers.push(ParseReviewerPage(@baseUrl + link))
		}

		@numPages += 1

		# Reviewers page URL: /review/top-reviewers?page=<pagenum>
		if (@numPages <= @maxPages)
			ParseTopReviewersPage(@numPages)
		end

	end

	def ParseReviewerPage(pageUrl)

		data = Nokogiri::HTML(open(pageUrl))

		reviewer = Hash.new()
		reviewer["url"] = pageUrl

		# Name
		reviewer["name"] = data.xpath("//*/h1/span").text

		# Birthday!
		reviewer["birthday"] = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[2]/div[2]/span").text

		# Ranking info
		reviewer["ranking"] = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[1]/div[3]/div[1]/b/a").text

		# Location
		location = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[2]/div[1]").text
		location.slice! "Location:"
		reviewer["location"] = location

		# Email
		# Some email addresses have hidden spaces to avoid scrapers
		# Hence let's take it from the mailto: HREF instead!
		email = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[2]/div[2]/span/a/@href").text
		email.slice! "mailto:"
		reviewer["email"] = email

		# Website
		reviewer["website"] = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[2]/div[3]/span/a").text

		# Own words
		reviewer["ownWords"] = data.xpath("//*[@id=\"pdpLeftColumn\"]/div[2]/div[3]/div[2]").text

		# Interests
		# Check the pop-up first as it's the longer version
		interests = data.xpath("//*[@id=\"textPop_interests\"]").text
		if (interests.nil? or interests.empty?)
			interests = data.xpath("//*[@id=\"interestsTags\"]/div/div/div/div/div[1]").text
		end
		reviewer["interests"] = interests

		return reviewer
	end

	def ParseASINReviews(asin)
		# http://www.amazon.co.uk/product-reviews/B0050CJNO2/?pageNumber=2
	end

	def GetProductReviewPage(asin, pageNumber = 1)
		sprintf(@productReviewsPageUrl, asin, pageNumber)
	end
end