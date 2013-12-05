require './lib/AmazonReviewerScraper'
require 'csv'

scraper = AmazonReviewerScraper.new(:baseUrl => "http://www.amazon.co.uk", :maxPages => 10, :followNextLink => true)
scraper.ParseASINReviews("B00GJTV0J6")
reviews = scraper.reviews

# Write all reviews to a file
CSV.open("all-reviews.csv", "w") do |csv|
	csv << ["rank", "name", "numStars", "review", "email", "website"]
	reviews.each { |review|
		reviewer = review["reviewer"]
		csv << [reviewer["rank"], review["name"], review["numStars"], review["review"], reviewer["email"], reviewer["website"]]
	}
end
