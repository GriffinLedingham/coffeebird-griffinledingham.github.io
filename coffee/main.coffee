vel = rot = state = tick = highscore = score = 0
pos = 150
grav = .25
jump = -4.6
pipeHeight = 90
pipeWidth = 52
pipes = []
canReplay = false
updateInterval = undefined

start = =>
	state = 1
	$('#title').stop()
	$('#title').transition({opacity:0},200,'ease')
	setBigScore(false)
	updateInterval = setInterval(update, 1000/60)

update = =>
	tick += 1
	if tick % 70 == 0
		updatePipes()

	player = $('#player')
	vel += grav
	pos += vel
	updatePlayer(player)
	box = document.getElementById("player").getBoundingClientRect()
	w = 34.0
	h = 24.0
	width = w - (Math.sin(Math.abs(rot) / 90) * 8)
	height = (h + box.height) / 2
	left = ((box.width - width) / 2) + box.left
	right = left + width
	top = ((box.height - height) / 2) + box.top
	bot = top + height	
	if box.bottom >= $("#land").offset().top
		playerDead()

	ceiling = $("#ceiling")
	pos = 0 if top < ceiling.offset().top + ceiling.height()
	return unless pipes[0]?
	pipe = pipes[0]
	topPipe = pipe.children(".pipe_upper")
	pipeTop = topPipe.offset().top + topPipe.height()
	pipeLeft = topPipe.offset().left - 2
	pipeRight = pipeLeft + pipeWidth
	pipeBottom = pipeTop + pipeHeight

	if right > pipeLeft
		if top < pipeTop || bot > pipeBottom
			playerDead()
	if left > pipeRight
		pipes.splice 0, 1
		playerScore()

showSplash = =>
  state = 0  
  vel = 0
  pos = 180
  rot = 0
  score = 0
  
  $("#player").css
    y: 0
    x: 0

  updatePlayer($("#player"))  
  $(".pipe").remove()
  pipes = []  
  $(".animated").css "animation-play-state", "running"
  $(".animated").css "-webkit-animation-play-state", "running" 
  $("#title").transition
    opacity: 1
  , 1000, "ease"

updatePlayer = (player) => 
  rot = Math.min((vel / 10) * 90, 90)
  $(player).css
    rotate: rot
    top: pos

screenClick = =>
  if state is 1
    playerJump()
  else if state is 0
  	start()
  	playerJump()

playerJump = =>
  vel = jump

playerDead = =>
  $(".animated").css "animation-play-state", "paused"
  $(".animated").css "-webkit-animation-play-state", "paused"
  playerbottom = $("#player").position().top + $("#player").width() 
  floor = $("#stage").height()
  del = Math.max(0, floor - playerbottom)

  $("#player").transition({rotate:90}, 500, 'easeInOutCubic', =>
  	$("#player").transition({y:del+'px'}, 700, 'easeInOutCubic')	
  )
  state = 2
  clearInterval updateInterval
  updateInterval = null
  showScore()

updatePipes = => 
  $(".pipe").filter(->
    $(this).position().left <= -100
  ).remove()
  
  padding = 80
  constraint = 420 - pipeHeight - (padding * 2)
  topheight = Math.floor((Math.random() * constraint) + padding)
  bottomheight = (420 - pipeHeight) - topheight
  newpipe = $("<div class=\"pipe animated\"><div class=\"pipe_upper\" style=\"height: " + topheight + "px;\"></div><div class=\"pipe_lower\" style=\"height: " + bottomheight + "px;\"></div></div>")
  $("#stage").append newpipe
  pipes.push newpipe

showScore = =>
  $("#scoreboard").css "display", "block"
  setBigScore(true)
  if score > highscore    
    highscore = score    
    setCookie "highscore", highscore, 999

  setSmallScore()
  setHighScore()
  medal = setMedal()
  
  $("#scoreboard").css 
    y: "40px"
    opacity: 0

  $("#replay").css
    y: "40px"
    opacity: 0

  $("#scoreboard").transition
    y: "0px"
    opacity: 1
  , 600, "ease", =>
    $("#replay").transition
      y: "0px"
      opacity: 1
    , 600, "ease"
    
    if medal
      $("#medal").css
        scale: 2
        opacity: 0

      $("#medal").transition
        opacity: 1
        scale: 1
      , 1200, "ease"
  canReplay = true

playerScore = =>
  score += 1
  setBigScore()

$("#replay").click =>
  unless canReplay
    return
  else
    canReplay = false
 
  $("#scoreboard").transition
    y: "-40px"
    opacity: 0
  , 1000, "ease", =>
    
    $("#scoreboard").css "display", "none" 
    showSplash()

setBigScore = (erase) ->
  elemscore = $("#score")
  elemscore.empty()
  return if erase
  digits = score.toString().split("")
  for i in [0..digits.length-1]
    elemscore.append "<img src='assets/font_big_" + digits[i] + ".png' alt='" + digits[i] + "'>"

setSmallScore = ->
  elemscore = $("#currentscore")
  elemscore.empty()
  digits = score.toString().split("")
  for i in [0..digits.length-1]
    elemscore.append "<img src='assets/font_small_" + digits[i] + ".png' alt='" + digits[i] + "'>"

setHighScore = ->
  elemscore = $("#highscore")
  elemscore.empty()
  digits = highscore.toString().split("")
  for i in [0..digits.length-1]
    elemscore.append "<img src='assets/font_small_" + digits[i] + ".png' alt='" + digits[i] + "'>"

setMedal = ->
  elemmedal = $("#medal")
  elemmedal.empty()
  return false  if score < 10
  medal = "bronze"  if score >= 10
  medal = "silver"  if score >= 20
  medal = "gold"  if score >= 30
  medal = "platinum"  if score >= 40
  elemmedal.append "<img src=\"assets/medal_" + medal + ".png\" alt=\"" + medal + "\">"
  true

getCookie = (cname) ->
  name = cname + "="
  ca = document.cookie.split(";")
  for i in [0..ca.length-1]
    c = ca[i].trim()
    return c.substring(name.length, c.length)  if c.indexOf(name) is 0
  ""
setCookie = (cname, cvalue, exdays) ->
  d = new Date()
  d.setTime d.getTime() + (exdays * 24 * 60 * 60 * 1000)
  expires = "expires=" + d.toGMTString()
  document.cookie = cname + "=" + cvalue + "; " + expires

$(document).ready =>
  savedscore = getCookie("highscore")
  highscore = parseInt(savedscore)  unless savedscore is ""
  showSplash()

$("#replay").click =>
  unless canReplay
    return
  else
    canReplay = false
 
  $("#scoreboard").transition
    y: "-40px"
    opacity: 0
  , 1000, "ease", =>
    
    $("#scoreboard").css "display", "none" 
    showSplash()

$(document).keydown (e) =>
  if e.keyCode is 32
    if state is 2
      $("#replay").click()
    else
      screenClick()
  return

if "ontouchstart" of window
  $(document).on "touchstart", screenClick
else
  $(document).on "mousedown", screenClick