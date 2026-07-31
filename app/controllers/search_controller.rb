class SearchController < ApplicationController
  include RatfController

  def index
    @query = params[:q].to_s.strip
    @results = {}
    return if @query.blank?

    like = "%#{@query}%"
    @results[:jobs] = Job.where("name LIKE ? OR description LIKE ?", like, like).limit(5)
    @results[:test_suites] = TestSuite.where("name LIKE ?", like).limit(5)
    @results[:test_cases] = TestCase.where("name LIKE ? OR description LIKE ?", like, like).limit(5)
    @results[:issues] = Issue.where("title LIKE ? OR description LIKE ?", like, like).limit(5)
    @results[:posts] = Post.where("title LIKE ? OR content LIKE ?", like, like).limit(5)
    @results[:projects] = Project.where("name LIKE ?", like).limit(5)
  end
end
