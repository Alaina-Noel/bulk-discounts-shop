require_relative '../facades/github_facade'
require_relative '../facades/holiday_facade'

class ApplicationController < ActionController::Base
  before_action :get_pr_total, :user_names, :repo_name, :user_commits, :next_holidays

  def next_holidays
    @next_holidays = HolidayFacade.next_3_holidays
  end

  def user_names
    @user_names = ["Alaina-Noel"]
  end

  def get_pr_total
    @pr_total = 123
  end

  def repo_name
    @repo_name = "Bulk Discounts"
  end

  def user_commits
    @user_commits = {"LlamaBack"=>4, "Alaina-Noel"=>13, "ajkrumholz"=>10, "Astrid-Hecht"=>3}
  end

end
