window.TwitterStuff =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: -> 
  	window.TwitterStuffRouter = new TwitterStuff.Routers.Nodes()
  	Backbone.history.start()
  	

$(document).ready ->
  TwitterStuff.initialize()
