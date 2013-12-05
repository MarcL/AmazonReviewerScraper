require './lib/AmazonReviewerScraper'
require 'csv'

scraper = AmazonReviewerScraper.new(:baseUrl => "http://www.amazon.co.uk", :maxPages => 10, :followNextLink => true)
scraper.ParseASINReviews("B00DTWCHH0")
reviews = scraper.reviews

# Write all reviews to a file
CSV.open("all-reviews.csv", "w") do |csv|
	csv << ["rank", "name", "numStars", "email", "website", "review"]
	reviews.each { |review|
		reviewer = review["reviewer"]
		csv << [reviewer["rank"], review["name"], review["numStars"], reviewer["email"], reviewer["website"], review["review"]]
	}
end
