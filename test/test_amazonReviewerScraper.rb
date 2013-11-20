require 'test/unit'
require_relative '../lib/amazonReviewerScraper'

class AmazonReviewerScraperTests < Test::Unit::TestCase

	def setup
		@parser = AmazonReviewerScraper.new("http://www.amazon.co.uk")
	end

	def test_expectCorrectNameWhenPresent()
		pageUrl = "fixtures/reviewer-rank1.html"
		reviewer = @parser.ParseReviewerPage(pageUrl)

		assert_equal(reviewer["name"], "KM")
	end

	def test_expectEmptyStringWhenNoReviwerNamePresent()
		pageUrl = "fixtures/reviewer-nodata.html"
		reviewer = @parser.ParseReviewerPage(pageUrl)

		assert_equal(reviewer["name"], "")
	end

	def test_expectCorrectPageUrl()
		pageUrl = "fixtures/reviewer-rank1.html"
		reviewer = @parser.ParseReviewerPage(pageUrl)

		assert_equal(reviewer["url"], pageUrl)
	end
end