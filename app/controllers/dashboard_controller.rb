class DashboardController < ApplicationController
  include RatfController

  def index
    @stats = DashboardStat.get_stats
  end
end
