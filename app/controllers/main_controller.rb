class MainController < ApplicationController
  def index
    headers['Access-Control-Allow-Origin'] = "*"
  end

  def show
  	uid = params[:id]
  	@users = getUids(uid)
  end

  private
  	def getUids(uid)
  		t = Twitter.new
  		t1 = t.user(uid)
  		t1.followers_ids
  	end
end
