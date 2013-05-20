$ ->
  window.onresize = takeoverWindow
  takeoverWindow()
  repositionRoot()
  animateFamilyConnections(1000)
  hideTreeLinks()
  repositionWindow()
  
  $('.timeline').on 'mouseenter', '.person', makeActive
  $('.timeline').on 'mouseleave', '.person', removeActive
  $('.timeline').on 'click', '.show_parents', (event) ->
    event.preventDefault()
    
    person = $(this).parents('.person')
    $.getJSON $(this).attr('href'), {}, (response) ->
      renderParents(response.mother, response.father, person)

takeoverWindow = ->
  $('.timeline').css('width', $(window).width()).css('height', $(window).height() - 100)

repositionWindow = ->
  min_left = Math.min.apply null, $('.person').map ->
    $(this).offset().left
  
  $('.timeline').scrollLeft(min_left - 100)

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
  repositionRoot()
  hideTreeLinks()
  animateFamilyConnections(1000)

animateFamilyConnections = (duration) ->
  start = new Date().getTime()
  end = start + duration
  
  step = ->
    timestamp = new Date().getTime()
    progress = Math.min((duration - (end - timestamp)) / duration, 1)
    redrawFamilyTree()
    
    requestAnimationFrame(step) if (progress < 1)
  
  step()

renderPerson = (person, added_from) ->
  person.has_parent = person.mother_id or person.father_id
  $('.timeline .people').append Mustache.render($('#person_template').html(), person)
  
  new_person = $("##{person.id}")
  new_person.hide()
  new_person.css('top', $('.timeline').scrollTop() + added_from.position().top) if added_from.length > 0
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
  born = $('.timeline').scrollLeft() + $person.offset().left
  top =  $('.timeline').scrollTop() + $person.position().top
  bottom = top + $person.outerHeight()
  
  if (mother = $("##{$person.data('mother-id')}")).length > 0
    connectToPerson(mother, born, top, bottom, ctx)
  
  if (father = $("##{$person.data('father-id')}")).length > 0
    connectToPerson(father, born, top, bottom, ctx)

connectToPerson = (target_person, left, top, bottom, ctx) ->
  target_top      = $('.timeline').scrollTop() + target_person.position().top
  target_bottom   = target_top + target_person.outerHeight()
  target_above    = top > target_top
  ctx.beginPath()
  ctx.moveTo(left, (if target_above then top else bottom))
  connect_to_top  = if target_above then target_bottom else target_top
  connect_to_left = left - width_factor * (3 / 4)
  ctx.lineTo(connect_to_left, connect_to_top)
  ctx.stroke()
  
  x = 0
  y = 0
  if target_above
    x = left - connect_to_left
    y = top - connect_to_top
  else
    x = left - connect_to_left
    y = bottom - connect_to_top
  
  radians = Math.atan2 y, x
  
  drawArrowHead(ctx, connect_to_left, connect_to_top, radians, false, 10)

hideTreeLinks = ->
  for person in $('.timeline .person')
    mother = $("##{$(person).data('mother-id')}")
    father = $("##{$(person).data('father-id')}")
    
    if mother.length > 0 or father.length > 0
      $(person).find('.show_parents').remove()

drawArrowHead = (ctx, x, y, angle_from_horizontal_radians, upside, barb_length, barb_angle_radians, filled) ->
  barb_length = 8 unless barb_length?
  barb_angle_radians = 0.349 unless barb_angle_radians?
  filled = true unless filled?
  alpha_radians = (if upside then -1 else 1) * angle_from_horizontal_radians
  
  # first point is end of one barb
  plus = alpha_radians - barb_angle_radians
  a = x + (barb_length * Math.cos(plus))
  b = y + (barb_length * Math.sin(plus))
  
  # final point is end of the second barb
  minus = alpha_radians + barb_angle_radians
  c = x + (barb_length * Math.cos(minus))
  d = y + (barb_length * Math.sin(minus))
  
  ctx.beginPath()
  ctx.moveTo(a,b)
  ctx.lineTo(x,y)
  ctx.lineTo(c,d)
  if filled then ctx.fill() else ctx.stroke()
  
  return true

requestAnimationFrame =
  window.requestAnimationFrame or
  window.webkitRequestAnimationFrame or
  window.mozRequestAnimationFrame or
  window.msRequestAnimationFrame or
  window.oRequestAnimationFrame or
  (callback) ->
    setTimeout(callback, 1)
