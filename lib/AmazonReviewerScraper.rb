require 'nokogiri'
require 'open-uri'

class AmazonReviewerScraper
	attr_reader :reviewers
	attr_reader :reviews

	def initialize(params = {})

		@baseUrl = params.fetch(:baseUrl, 'http://www.amazon.com')
		@maxPages = params.fetch(:maxPages, 1)
		@numPages = 1
		@reviewers = Array.new
		@reviews = Array.new

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

	def ParseASINReviews(asin, pageNumber = 1)

		# Get review page
		pageUrl = GetProductReviewPage(asin, pageNumber)

		# Scrape reviewers
		ScrapeProductReviewers(pageUrl)
	end

	def ScrapeProductReviewers(pageUrl)
		data = Nokogiri::HTML(open(pageUrl))

		reviewsData = data.xpath("//table[@id=\"productReviews\"]/tr/td/div")
		
		# Iterate through each reviewer and find info on them
		reviewsData.each do |reviewNode|
			review = Hash.new()

			# Star rating - e.g. 5.0 out of 5 stars
			# Trim to first word (i.e. the rating) and return it as a float
			review["numStars"] = reviewNode.xpath("./div[2]/span[1]/span/span").text.split(' ')[0...1].join('').to_f

			review["author"] = reviewNode.xpath("./div[3]/div[1]/div[2]/a[1]/span").text
			review["authorAmazonUrl"] = reviewNode.xpath("./div[3]/div[1]/div[2]/a[1]/@href").text
			review["reviewTitle"] = reviewNode.xpath("./div[2]/span[2]/b").text
			review["reviewDate"] = reviewNode.xpath("./div[2]/span[2]/nobr").text
			review["verifiedPurchase"] = (!reviewNode.xpath("./div[4]/span/b").text.empty?).to_s

			review["text"] = reviewNode.xpath("./text()").text.strip!

			# Follow link to Amazon reviewer page to get email address
			review["reviewer"] = ParseReviewerPage(@baseUrl + review["authorAmazonUrl"])
			puts review

			@reviews.push(review)
		end

		# TODO: Go to next page of reviews
	end

	def GetProductReviewPage(asin, pageNumber = 1)
		sprintf(@productReviewsPageUrl, asin, pageNumber)
	end
end