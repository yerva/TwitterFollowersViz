class myGraph
  constructor: (el) ->
    @el = el
    # set up the D3 visualisation in the specified element
    w = 1200 #$(el).innerWidth()
    h = 800 #$(el).innerHeight()
    @vis = d3.select(el).append("svg:svg").attr("width", w).attr("height", h)
    @force = d3.layout.force().distance(30).charge(-120).size([w, h-80])
    @nodes = @force.nodes()
    @links = @force.links()

    # # Make it all go
    @update()

  addNodesLinks: (json) ->
    @addNodes(json.nodes)
    @addLinks(json.links)
    @update()

  addNodes: (newNodes) ->
    @newNodes = newNodes
    for node in newNodes
      @addNode node

  addLinks: (newLinks) ->
    @newLinks = newLinks
    for link in newLinks
      @addLink link.source, link.target

  # Add and remove elements on the graph object
  addNode: (node) ->
    nodes = @nodes
    nodes.push node # {id: node.id, node: node}
    @update()

  removeNode: (id) =>
    links = @links
    nodes = @nodes
    n = @findNode(id)
    while i < links.length
      if (links[i]["source"] is n) or (links[i]["target"] is n)
        links.splice i, 1
      else
        i++
    nodes.splice @findNodeIndex(id), 1
    @update()

  addLink: (source, target) =>
    links = @links #d3.layout.tree().links(nodes)#@links
    links.push
      source: @findNode(source)
      target: @findNode(target)

    @update()

  findNode: (id) =>
    nodes = @nodes
    for i of nodes
      return nodes[i]  if nodes[i]["id"] is id

  findNodeIndex: (id) =>
    nodes = @nodes
    for i of nodes
      return i  if nodes[i]["id"] is id

  nodeColor: (d)-> 
    fill = d3.scale.category20()
    if d.selected==1 then "#3182bd" else fill(d.group) #c6dbef" 
  nodeRadius: (d)-> if d.selected==1 then 8 else 5

  update: =>
    # force = @force.charge((d)-> if d.selected==1 then -120 else -30)
    #   .linkDistance((d)-> if d.selected==1 then 30 else 30)



    vis = @vis
    links = @links
    nodes = @nodes
    force = @force
    fill = d3.scale.category20()

    # link properties
    link = vis.selectAll("line.link").data(links, (d) -> d.source.id + "-" + d.target.id )
    link.enter().insert("line").attr("class", "link")
      .style("stroke","gray").style("opacity",0.2)
      .style("stroke-width", (d) -> Math.sqrt(d.value) )
      .call(force.drag)
    link.exit().remove()

    # node properties
    node = vis.selectAll("g.node").data(nodes, (d) -> d.id )

    node.attr("r", @nodeRadius)
              .attr("fill", (d) -> if d.selected==1 then "red" else fill(d.group) )
              .attr("id",(d)->d.id)
              .on("mouseover",()->d3.select(@).attr("r",7))
              .on("mouseout",(d)->d3.select(@).attr("r",if d.selected==1 then 8 else 5))
    
    nodeEnter = node.enter().append("g").attr("class", "node")
    nodeEnter.append('svg:circle')
              .attr("class", "node")
              .attr("cx", (d) -> d.x )
              .attr("cy", (d) -> d.y )
              .attr("r", @nodeRadius)
              .attr("fill", (d) -> if d.selected==1 then "red" else fill(d.group) )
              .attr("id",(d)->d.id)
              .on("mouseover",()->d3.select(@).attr("r",7))
              .on("mouseout",(d)->d3.select(@).attr("r",if d.selected==1 then 8 else 5))
              .on("click", (d)-> 
                $("#twitter_handle_name").attr({"value": d.name})
                $("#twitter_handle").trigger("submit")
                # $(".node").trigger("node")
              )
              .call(force.drag)

    # node.append("svg:text").text( (d) -> d.name+":(id="+d.id+", group="+d.group+")" )

    node.exit().remove()

    vis.style("opacity", 1e-6)
    .transition()
    .duration(10)
    .style("opacity", 1)

    force.on "tick", ->
      link.attr("x1", (d) -> d.source.x)
          .attr("y1", (d) -> d.source.y)
          .attr("x2", (d) -> d.target.x)
          .attr "y2", (d) -> d.target.y

      # node.attr("cx", (d) -> d.x )
      #     .attr("cy", (d) -> d.y )

      node.attr "transform", (d) -> "translate(" + d.x + "," + d.y + ")"


    
    # Restart the force layout.
    force.nodes(nodes)
         .links(links)
    force.start()

  

$(document).ready ->
  window.graph = new myGraph("#graph")

# # # You can do this from the console as much as you like...
#   graph.addNode "Cause"
#   graph.addNode "Effect"
#   graph.addLink "Cause", "Effect"
#   graph.addNode "A"
#   graph.addNode "B"
#   graph.addLink "A", "B"
#   graph.addLink "Cause", "B"