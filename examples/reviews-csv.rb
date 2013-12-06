require './lib/AmazonReviewerScraper'
require 'csv'

def usage()
	puts "Usage: ruby reviews-csv.rb -asin <ASIN>"
end

# Get arguments
case ARGV[0]
when "-asin"
	if (ARGV[1].nil?)
		usage()
		exit 1
	else
		asin = ARGV[1]
	end
else
	usage()
	exit 1	
end


scraper = AmazonReviewerScraper.new(:baseUrl => "http://www.amazon.co.uk", :maxPages => 10, :followNextLink => true)
scraper.ParseASINReviews(asin)
reviews = scraper.reviews

# Write all reviews to a file
CSV.open("#{asin}-reviews.csv", "w") do |csv|
	csv << ["rank", "name", "numStars", "email", "website", "reviewerAmazonUrl", "review"]
	reviews.each { |review|
		reviewer = review["reviewer"]
		csv << [reviewer["rank"], review["name"], review["numStars"], reviewer["email"], reviewer["website"], review["reviewerAmazonUrl"], review["review"]]
	}
end
