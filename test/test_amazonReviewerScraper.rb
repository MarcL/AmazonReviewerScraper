require 'test/unit'
require_relative '../lib/amazonReviewerScraper'

class AmazonReviewerScraperTests < Test::Unit::TestCase

	def setup
		@parser = AmazonReviewerScraper.new(:baseUrl => "http://www.amazon.co.uk")
	end

	def test_expectCorrectNameWhenPresent()
		pageUrl = "test/fixtures/reviewer-rank1.html"
		reviewer = @parser.ParseReviewerPage(pageUrl)

		assert_equal(reviewer["name"], "KM")
	end

	def test_expectEmptyStringWhenNoReviwerNamePresent()
		pageUrl = "test/fixtures/reviewer-nodata.html"
		reviewer = @parser.ParseReviewerPage(pageUrl)

		assert_equal(reviewer["name"], "")
	end

	def test_expectCorrectPageUrl()
		pageUrl = "test/fixtures/reviewer-rank1.html"
		reviewer = @parser.ParseReviewerPage(pageUrl)

		assert_equal(reviewer["url"], pageUrl)
	end

	def test_expectCorrectRanking()
		pageUrl = "test/fixtures/reviewer-rank1.html"
		reviewer = @parser.ParseReviewerPage(pageUrl)

		assert_equal(reviewer["ranking"], "1")
	end

	def test_expectEmptyStringWhenRankingNotPresent()
		pageUrl = "test/fixtures/reviewer-nodata.html"
		reviewer = @parser.ParseReviewerPage(pageUrl)

		assert_equal(reviewer["ranking"], "")
	end
end