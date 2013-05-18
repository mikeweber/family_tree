$ ->
  repositionRoot()
  redrawFamilyTree()
  drawTransitionalLines()
  hideTreeLinks()
  
  $('.timeline').on 'mouseenter', '.person', makeActive
  $('.timeline').on 'mouseleave', '.person', removeActive
  $('.timeline').on 'click', '.show_parents', (event) ->
    event.preventDefault()
    
    person = $(this).parents('.person')
    $.getJSON $(this).attr('href'), {}, (response) ->
      renderParents(response.mother, response.father, person)

makeActive = ->
  $this = $(this)
  $this.addClass('active')
  
  $("##{$this.data('mother-id')}").addClass('active') if $this.data('mother-id')
  $("##{$this.data('father-id')}").addClass('active') if $this.data('father-id')

removeActive = ->
  $('.person').removeClass('active')

renderParents = (mother, father, child) ->
  renderPerson(mother, child) if mother
  renderPerson(father, child) if father
  drawTransitionalLines()
  hideTreeLinks()

drawTransitionalLines = ->
  render_count = 0
  renderingLoop = ->
    return if render_count >= 100
    
    render_count++
    repositionRoot()
    setTimeout renderingLoop, 10
  
  renderingLoop()

renderPerson = (person, added_from) ->
  person.has_parent = person.mother_id or person.father_id
  person.full_name = "#{person.first_name} #{person.last_name}"
  $('.timeline .people').append Mustache.render($('#person_template').html(), person)
  
  new_person = $("##{person.id}")
  new_person.hide()
  new_person.css('top', added_from.position().top) if added_from.length > 0
  new_person.addClass('alive') unless person.died?
  new_person.css('left', (person.born_year - baseline) * width_factor)
  end_year = person.died_year or (new Date()).getFullYear()
  new_person.css('width', (end_year - person.born_year) * width_factor)
  new_person.find('.lifespan').html("(#{lifespan(person.born, person.died)})")
  new_person.show()

lifespan = (born, died) ->
  span = "#{born}"
  span = "#{span} - #{died}" if died?
  
  return span

repositionRoot = ->
  repositionPerson $('.person.root'), 20
  redrawFamilyTree()

redrawFamilyTree = ->
  canvas = $('#timeline')[0]
  ctx = canvas.getContext("2d")
  ctx.clearRect(0, 0, canvas.width, canvas.height)
  connectToParents person, ctx for person in $('.people .person')

repositionPerson = (person, base) ->
  $person = $(person)
  return base if $person.length == 0
  
  new_base = base
  
  if father = $("##{$person.data('father-id')}")
    new_base = repositionPerson(father, new_base)
  new_base = new_base + 20
  $person.css(top: new_base)
  if mother = $("##{$person.data('mother-id')}")
    new_base = repositionPerson(mother, new_base + 20)
  
  return new_base

connectToParents = (person, ctx) ->
  $person = $(person)
  born = $person.offset().left
  top = $person.position().top
  bottom = top + $person.height()
  
  if (mother = $("##{$person.data('mother-id')}")).length > 0
    connectToPerson(mother, born, top, bottom, ctx)
  
  if (father = $("##{$person.data('father-id')}")).length > 0
    connectToPerson(father, born, top, bottom, ctx)

connectToPerson = (target_person, left, top, bottom, ctx) ->
  target_top = target_person.position().top
  target_bottom = target_top + target_person.height()
  target_above = top > target_top
  ctx.beginPath()
  ctx.moveTo(left, (if target_above then top else bottom))
  connect_to = if target_above then target_bottom else target_top
  ctx.lineTo(left, connect_to)
  ctx.stroke()
  drawArrowHead(ctx, left, connect_to, 270, target_above)

hideTreeLinks = ->
  for person in $('.timeline .person')
    mother = $("##{$(person).data('mother-id')}")
    father = $("##{$(person).data('father-id')}")
    
    if mother.length > 0 or father.length > 0
      $(person).find('.show_parents').remove()

drawArrowHead = (ctx, x, y, angle_from_horizontal_degrees, upside, barb_length, barb_angle_degrees, filled) ->
  barb_length = 8 unless barb_length?
  barb_angle_degrees = 20 unless barb_angle_degrees?
  filled = true unless filled?
  alpha_degrees = (if upside then -1 else 1) * angle_from_horizontal_degrees
  
  # first point is end of one barb
  plus = degToRad(alpha_degrees - barb_angle_degrees)
  a = x + (barb_length * Math.cos(plus))
  b = y + (barb_length * Math.sin(plus))
  
  # final point is end of the second barb
  minus = degToRad(alpha_degrees + barb_angle_degrees)
  c = x + (barb_length * Math.cos(minus))
  d = y + (barb_length * Math.sin(minus))
  
  ctx.beginPath()
  ctx.moveTo(a,b)
  ctx.lineTo(x,y)
  ctx.lineTo(c,d)
  if filled then ctx.fill() else ctx.stroke()
  
  return true

degToRad = (angle_degrees) ->
   angle_degrees / 180 * Math.PI
