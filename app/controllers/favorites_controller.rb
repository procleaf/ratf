class FavoritesController < ApplicationController
  include RatfController

  before_action :require_login
  before_action :set_test_case, only: [:create, :destroy, :toggle]

  def index
    @records = paginate(
      TestCase.joins(:favorites)
              .where(favorites: { user_id: current_user.id })
              .order("favorites.created_at DESC")
    )
  end

  def create
    fav = current_user.favorites.find_or_create_by!(test_case_id: @test_case.id)
    respond_to do |format|
      format.json { render json: { starred: true, favorite_id: fav.id } }
      format.turbo_stream
      format.html { redirect_back fallback_location: test_cases_path, notice: "Added to favorites." }
    end
  end

  def destroy
    fav = current_user.favorites.find_by!(test_case_id: @test_case.id)
    fav.destroy!
    respond_to do |format|
      format.json { render json: { starred: false } }
      format.turbo_stream
      format.html { redirect_back fallback_location: test_cases_path, notice: "Removed from favorites." }
    end
  end

  def toggle
    fav = current_user.favorites.find_by(test_case_id: @test_case.id)
    if fav
      fav.destroy!
      @starred = false
    else
      fav = current_user.favorites.create!(test_case_id: @test_case.id)
      @starred = true
    end
    respond_to do |format|
      format.json { render json: { starred: @starred, favorite_id: fav&.id } }
      format.turbo_stream
      format.html { redirect_back fallback_location: test_cases_path, notice: @starred ? "Added to favorites." : "Removed from favorites." }
    end
  end

  private

  def set_test_case
    id = params[:test_case_id] || (params[:id] && current_user.favorites.find_by(id: params[:id])&.test_case_id)
    @test_case = TestCase.find(id) if id
    raise ActiveRecord::RecordNotFound unless @test_case
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json: { error: "Test case not found" }, status: :not_found }
      format.html { redirect_to test_cases_path, alert: "Test case not found." }
    end
  end
end
