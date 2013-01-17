class TwitterStuff.Views.NodesIndex extends Backbone.View

	template: JST['nodes/index']
	events:
		'submit #twitter_handle': 'fetchFollowersAsync'
		'node': 'node_clicked'

	node_clicked: ->
		console.log "Node clicked"

	initialize: ->
		@ID = -1
		@selected = {}
		@collection.on 'add',@appendEntry,@
		@DATA = {}
	
	appendEntry: (entry) ->
		view = new TwitterStuff.Views.Node(model: entry)
		$("#entries").prepend(view.render().el)

	
	render: ->
		$(@el).html(@template())
		@collection.each(@appendEntry)
		$('#twitter_handle_name').focus()
		@

	fetchFollowersAsync: (event)->
		nestedAssign = @nestedAssign
		thisView = @
		event.preventDefault()
		callback = @handleUser
		console.log 'event clicked'
		screenname = $('#twitter_handle_name').val()
		URL = "https://api.twitter.com/1/statuses/followers/#{screenname}.json"
		#URL = 'http://mbostock.github.com/d3/talk/20111116/flare.json'
		followers = {}
		# DATA = @DATA
		parent = $('#twitter_handle_parent').val()
		$.ajax
			url:URL 
			dataType:"jsonp"
			crossdomain: true
			type:"get"
			async: false
			success:(data)->
				#DATA = data
				cnt=0
				children = []
				index = 0
				for x in data
				# 	# console.log x.name+" ->"+x
					followers[x.screen_name] = x
					children.push({name: x.screen_name, size:4000, parent: parent+"."+index++, node: x})
				# 	#if ++cnt>3  then break
				# # window.mydata = data
				# # console.log screenname+' here ',followers
				name = screenname
				# debugger
				if parent==""
					thisView.DATA = {name: name, children: children, size: 3000}
				else
					thisView.nestedAssign(thisView.DATA.children,parent, name, children, 3000)
						
			
			error: (httpReq,status,exception)->
				alert(status+" "+exception);
				debugger
	

			complete: ->
				window.myTree.showTree(thisView.DATA)
				console.log "Finish "+ Object.keys(followers).length
				console.log "After the fetchCall->"
				# callback screenname,followers,thisView

		# console.log screenname+' here ',followers
		#followers			
		
	getId: (screenname,nodes) -> if screenname of nodes then nodes[screenname] else Object.keys(nodes).length


	addFollowersToCollection: (followers,nodes,nodesArray,thisView,grpid) ->
		console.info "Adding New Followers to Nodes Collection"
		for ff of followers
			f = followers[ff]
			follower_name = f.screen_name
			id = thisView.getId follower_name,nodes
			selID = if follower_name of thisView.selected then 1 else 0
			nodeAttrs = name: follower_name, index:id, id: id, group: grpid , selected: selID
			nodesEntry = nodeAttrs

			nodes[follower_name] = id
			nodesArray[id] = nodesEntry

	addLinksToCollection: (screenname, followers,nodes,thisView)->
		console.info "Adding New links to links Collection"
		sourceId = thisView.getId(screenname,nodes)#nodes[screenname]
		for ff of followers
			f = followers[ff]
			fScreenName = f.screen_name
			destId = thisView.getId(fScreenName,nodes)#nodes[fScreenName]
			linkEntry = source: sourceId, target: destId, weight: 1
			thisView.options.linksArray.push linkEntry

	handleUser: (screenname,followers,thisView)-> 
		console.info "Handline USER : "+screenname
		# alert "1"
		# debugger
		####
		nodes = thisView.options.nodes
		nodesArray = thisView.options.nodesArray
		linksArray = thisView.options.linksArray
		collection = thisView.collection
		thisView.selected[screenname] = 1
		####   
		id = thisView.getId(screenname,nodes)
		grpId = ++thisView.ID

		attrs = name: screenname, followers: followers, id: id
		node = new TwitterStuff.Models.Node attrs

		nodeAttrs = name: screenname, index:id, id: id, group: grpId, selected: 1
		nodesEntry = nodeAttrs
		nodes[screenname] = id
		nodesArray[id] = nodesEntry

		thisView.addFollowersToCollection followers,nodes,nodesArray,thisView,grpId
		thisView.addLinksToCollection screenname,followers,nodes,thisView
		collection.add node

		json = {}
		json.nodes = nodesArray
		json.links = linksArray
		json.ncollection = nodes

		#utilFn.displayGraph json
		graph.addNodesLinks(json)


	###### util Functions
	nestedAssign: (obj, keyPathStr, name, children, size) ->
		keyPathStr= keyPathStr.substr(1)
		keyPath = keyPathStr.split(".")
		lastKeyIndex = keyPath.length - 1
		i = 0
		while i <= lastKeyIndex
			key = parseInt(keyPath[i])
			#obj[key] = {}  unless key of obj
			if obj[key].children
				obj = obj[key].children
			else
				obj[key].children = children
				obj[key].name = name
				obj[key].size = size
			++i
