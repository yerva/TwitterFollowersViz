class TwitterStuff.Routers.Nodes extends Backbone.Router
    routes:
      '': 'index'
      'nodes/:id': 'show'
      
    initialize: ->
      @collection = new TwitterStuff.Collections.Nodes()
      @NodesCollection = {}
      @NodesArray = []
      @LinksArray = []


    index: ->
      view = new TwitterStuff.Views.NodesIndex(collection: @collection, nodes: @NodesCollection, nodesArray: @NodesArray, linksArray: @LinksArray )
      # view = new TwitterStuff.Views.NodesIndex(collection: @collection)
      $('#appcontainer').html(view.render().el)

    show: (id)->
      alert "Hello from Node #{id}"

