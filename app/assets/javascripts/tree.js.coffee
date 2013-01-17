class myTree
  constructor: (el) ->
    @el = el
    # set up the D3 visualisation in the specified element
    @w = 1200 #$(el).innerWidth()
    @h = 600 #$(el).innerHeight()
    @vis = d3.select(el).append("svg:svg").attr("width", @w).attr("height", @h)
    @force = d3.layout.force().distance(30).size([@w, @h-80])
                      .charge((d) -> if d._children then -90 else -70)
                      .linkDistance((d) -> if d.target._children then 80 else 50)
    @nodes = @force.nodes()
    @links = @force.links()
    @nodesCollection = []

    # # Make it all go
    ##@update()

  showTree: (root) ->
    # alert "Hi"
    # debugger
    @root = root
    @update()

  ####### Call back Functions #######
  # Color leaf nodes orange, and packages white or blue.
  color: (d) -> if d._children then "#3182bd" else (if d.children then "#c6dbef" else "#fd8d3c")

  # Toggle children on click.
  click: (d) ->
    if d.children
      d._children = d.children
      d.children = null
      window.myTree.update()
    else
      d.children = d._children
      d._children = null
      if d.children == null
        $("#twitter_handle_name").attr({"value": d.name})
        $("#twitter_handle_parent").attr({"value": d.parent})
        $("#twitter_handle").trigger("submit")
      else
        window.myTree.update()
  # Toggle children on click.
  mouseover: (d) ->
    d3.select(@).style('stroke','black').style('stroke-width',3)
    # debugger
    url = decodeURI(d.node.profile_image_url)
    $('#image').html("<img src=#{url}></img>")
    $('#name').html(d.node.name)
    $('#followers').html(d.node.followers_count)
    $('#friends').html(d.node.friends_count)
    if d.node.status.text
      $('#text').html(d.node.status.text)
    $('#userInfoCenter').attr("hidden",false)

  mouseout: (d) ->
    d3.select(@).style('stroke','black').style('stroke-width',0.5)
    $('#userInfoCenter').attr("hidden",true)
  
  addNode: (nodes, node) =>
    idx = @nodes.length + nodes.length
    for i of @nodes
      if @nodes[i]["name"] == node.name
        idx = i
        break
    node.id = idx
    nodes.push node
    #nodesCollection.push node
    

  # Returns a list of all nodes under the root.
  flatten: (root, addNode) ->
    recurse = (node) ->
      if node.children
        node.size = node.children.reduce((p, v) ->
          p + recurse(v)
        , 0)
      # node.id = i++  unless node.id
      # nodes.push node
      addNode nodes,node
      node.size
    nodes = []
    i = 0
    root.size = recurse(root)
    nodes



  update: ->
    @nodes = @force.nodes()
    root = @root
    nodes = @flatten(root, @addNode)
    links =  d3.layout.tree().links(nodes)
    ###### setting up variables ######
    vis = @vis
    force = @force
    #links = @links
    #nodes = @nodes
    force.nodes(nodes)
         .links(links)

    ###### Links ######
    # Update the links…
    link = vis.selectAll("line.link").data(links, (d) -> d.target.id)

    # Enter any new links.
    link.enter().insert("svg:line", ".node")
                .attr("class", "link")
                .attr("x1", (d) -> d.source.x)
                .attr("y1", (d) -> d.source.y)
                .attr("x2", (d) -> d.target.x)
                .attr("y2", (d) -> d.target.y)

    # Exit any old links.
    link.exit().remove()

    ###### Nodes #######
    # Update the nodes…
    node = vis.selectAll("circle.node").data(nodes, (d) -> d.id).style("fill", @color)
    node.transition().attr( "r", (d) -> (if d.children then 4.5 else Math.sqrt(d.size) / 10))


    # Enter any new nodes.
    node.enter().append("svg:circle")
                .attr("class", "node")
                .attr("cx", (d) -> d.x)
                .attr("cy", (d) ->d.y)
                .attr("r", (d) ->(if d.children then 8 else 6))#Math.sqrt(d.size) / 10))
                .style("fill", @color)
                .on("click", @click)
                .on("mouseover",@mouseover)
                .on("mouseout",@mouseout)
                .text((d) -> d.id)
                .call(force.drag)

    # Exit any old nodes.
    node.exit().remove()

    ##### resetting force params ####
    force.on("tick", ->
      link.attr("x1", (d) ->d.source.x)
          .attr("y1", (d) ->d.source.y)
          .attr("x2", (d) ->d.target.x)
          .attr("y2", (d) -> d.target.y)

      node.attr("cx", (d) ->d.x)
          .attr("cy", (d) ->d.y) )

    force.start()

$(document).ready ->
  window.myTree = new myTree("#tree")        