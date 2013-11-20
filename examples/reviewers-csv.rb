require './lib/AmazonReviewerScraper'
require 'csv'

scraper = AmazonReviewerScraper.new(:baseUrl => "http://www.amazon.co.uk", :maxPages => 10)
scraper.ParseTopReviewersPage(1)
reviewers = scraper.reviewers

# Write all reviewers to a file
CSV.open("all-reviewers.csv", "w") do |csv|
	csv << ["rank", "name", "email", "website", "interests"]
	reviewers.each { |reviewer|
		csv << [reviewer["ranking"], reviewer["name"], reviewer["email"], reviewer["website"], reviewer["interests"]]
	}
end
