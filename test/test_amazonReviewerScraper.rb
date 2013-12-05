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

	def test_expectCorrectReviewPageUrlWhenPageNumberIs1()
		asin = "B00GJTV0J6"
		pageNum = 1
		expectedUrl = "http://www.amazon.co.uk/product-reviews/" + asin + "/?pageNumber=" + pageNum.to_s
		assert_equal(expectedUrl, @parser.GetProductReviewPage(asin, pageNum))
	end

	def test_expectCorrectReviewPageUrlWhenPageNumberIs2()
		asin = "B00GJTV0J6"
		pageNum = 2
		expectedUrl = "http://www.amazon.co.uk/product-reviews/" + asin + "/?pageNumber=" + pageNum.to_s
		assert_equal(expectedUrl, @parser.GetProductReviewPage(asin, pageNum))
	end

	def test_expectScrapeProductReviewersToRetrieve10ReviewersFromPage1WithoutFollowingLinks()
		parser = AmazonReviewerScraper.new(:baseUrl => "http://www.amazon.co.uk", :followNextLink => false)
		pageUrl = "test/fixtures/B00GJTV0J6-product-reviews-page-1.html"
		parser.ScrapeProductReviewers(pageUrl)
		reviews = parser.reviews
		expectedNumReviewers = 10
		assert_equal(expectedNumReviewers, reviews.length)
	end

	def test_expectScrapeProductReviewersToRetrieve10ReviewersFromPage1WithFollowingLinks()
		pageUrl = "test/fixtures/B00GJTV0J6-product-reviews-page-1.html"
		@parser.ScrapeProductReviewers(pageUrl)
		reviews = @parser.reviews
		expectedNumReviewers = 18
		assert_equal(expectedNumReviewers, reviews.length)
	end

	def test_expectScrapeProductReviewersToRetrieve8ReviewersFromPage2WithoutFollowingLinks()
		pageUrl = "test/fixtures/B00GJTV0J6-product-reviews-page-2.html"
		@parser.ScrapeProductReviewers(pageUrl)
		reviews = @parser.reviews
		expectedNumReviewers = 8
		assert_equal(expectedNumReviewers, reviews.length)
	end
end