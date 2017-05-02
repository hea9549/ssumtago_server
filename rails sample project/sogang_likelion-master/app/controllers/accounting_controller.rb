class AccountingController < ApplicationController
  before_action :loginCheck
  before_action :messageAll

  def index
  end
end
