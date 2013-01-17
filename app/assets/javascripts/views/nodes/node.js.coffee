class TwitterStuff.Views.Node extends Backbone.View

	template: JST['nodes/node']
	tagName: 'li'
	
	render: ->
		$(@el).html(@template(entry: @model,followers: @model.get('followers')))

		$('#twitter_handle_name').focus()
		@
