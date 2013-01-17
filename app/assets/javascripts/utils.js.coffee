$(document).ready ->
  w = 960
  h = 500
  vis = d3.select("#chart")
    .append("svg")
    .attr("width", w)
    .attr("height", h)


window.utilFn =  displayGraph: (json) ->
# displayGraph: (json) -> 
  w = 960
  h = 500
  fill = d3.scale.category20()

  vis = d3.select("svg")
  alert "Hii"
  debugger
  window.JSON=json
  force = d3.layout.force()
    .charge((d)-> if d.selected==1 then -120 else -60)
    .linkDistance((d)-> if d.selected==1 then 50 else 30)
    .nodes(json.nodes)
    .links(json.links)
    .size([w, h])
    .start();

  link = vis.selectAll("line.link")
    .data(json.links)
    .enter().append("svg:line")
    .attr("class", "link")
    .style("stroke","gray")
    .style("stroke-width", (d) -> Math.sqrt(d.value) )
    .attr("x1", (d) -> d.source.x )
    .attr("y1", (d) -> d.source.y )
    .attr("x2", (d) -> d.target.x )
    .attr("y2", (d) -> d.target.y )
    .call(force.drag)

  node = vis.selectAll("circle.node")
    .data(json.nodes)
    .enter().append("svg:circle")
    .attr("class", "node")
    .attr("cx", (d) -> d.x )
    .attr("cy", (d) -> d.y )
    .attr("r", 7)
    .style("fill", (d) -> if d.selected==1 then "red" else fill(d.group) )
    .attr("id",(d)->d.name)
    .on("mouseover",()->d3.select(@).attr("r",10))
    .on("mouseout",()->d3.select(@).attr("r",7))
    .on("click", (d)-> 
      $("#twitter_handle_name").attr({"value": d.name})
      $("#twitter_handle").trigger("submit")
      # $(".node").trigger("node")
    )
    .call(force.drag)

  node.append("svg:title")
    .text( (d) -> d.name+":(id="+d.id+", group="+d.group+")" )

  vis.style("opacity", 1e-6)
    .transition()
    .duration(1000)
    .style("opacity", 1)

  force.on("tick",  () ->
    link.attr("x1", (d) -> d.source.x )
      .attr("y1", (d) -> d.source.y )
      .attr("x2", (d) -> d.target.x )
      .attr("y2", (d) -> d.target.y )
    node.attr("cx", (d) -> d.x )
      .attr("cy", (d) -> d.y )
  )




# d3.json "miserables.json", displayGraph



# Array::append = (val)->
#   @.push.apply @,[val]
#   @
  



# convertJson: (old) ->
#   nJson = {}
#   nJson.nodes = []
#   nJson.links = []
#   node = {}
#   node.name = old.name
#   node.id = 
#   nJson.nodes.append(node)
#   for x in old.followers:
#     link = {}
#     link.source = 0
#     link.target = nJson.nodes.length-1
#     nJson.links.append(link)
