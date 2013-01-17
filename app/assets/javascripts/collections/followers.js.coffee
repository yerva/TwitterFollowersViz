class TwitterStuff.Collections.Followers extends Backbone.Collection
  urlf: -> "https://api.twitter.com/1/statuses/followers/#{@node}.json"

  initialize: (val)->
  	@node = 'imph0enix'
  	@url = @urlf()

  model: TwitterStuff.Models.Node

