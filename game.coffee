canvas = atom.canvas
canvas.width = 800
canvas.height = 600
ctx = atom.context
ctx.scale 1, -1
ctx.translate 0,-600

batSpeed = 200

v = cp.v

class Game extends atom.Game
	constructor: ->
		@score = [0,0]
		@dir = -1
		@reset()

	newBat: ->
		body = new cp.Body Infinity, cp.momentForBox(Infinity, 50, 200)
		shape = @space.addShape new cp.BoxShape body, 50, 200
		shape.setElasticity 1
		shape.setFriction 0.8
		shape.group = 1
		body # rogue body

	newBall: ->
		body = @space.addBody new cp.Body 25, cp.momentForBox 80, 20, 20
		shape = @space.addShape new cp.BoxShape body, 20, 20
		shape.setElasticity 0.9
		shape.setFriction 0.6
		body

	addWalls: ->
		bottom = @space.addShape(new cp.SegmentShape(@space.staticBody, v(0, 0), v(800, 0), 0))
		bottom.setElasticity(1)
		bottom.setFriction(0.1)
		bottom.group = 1
		top = @space.addShape(new cp.SegmentShape(@space.staticBody, v(0, 600), v(800, 600), 0))
		top.setElasticity(1)
		top.setFriction(0.1)
		top.group = 1

	update: (dt) ->
		if atom.input.pressed 'tie'
			return @reset()

		dt = 1/60
		
		for b,i in @bats
			if atom.input.down "b#{i}up"
				b.setVelocity v(0, batSpeed)
				b.w = 1*(i*2-1)
			else if atom.input.down "b#{i}down"
				b.setVelocity v(0, -batSpeed)
				b.w = -1*(i*2-1)
			else
				b.setVelocity v(0, 0)
				b.w = 0

			b.position_func(dt)
			#b.velocity_func(v(0,0), 1, dt)

		@space.step dt

		if @ball.p.x < -80
			@win 1
		else if @ball.p.x > canvas.width + 80
			@win 0

		if @ball.p.y < -100 or @ball.p.y > canvas.height + 100
			@win if @ball.p.x < canvas.width/2 then 1 else 0

	win: (p) ->
		@score[p]++
		@dir = if p == 0 then -1 else 1
		@reset()

	reset: ->
		@space = new cp.Space
		@space.gravity = v(0, -50)
		@space.damping = 0.95
		@bats = []
		@bats.push @newBat() for [0..1]
		@bats[0].setPos v(40, 300)
		@bats[1].setPos v(canvas.width-40, 300)
		b.shapeList[0].update(b.p, b.rot) for b in @bats

		@ball = @newBall()
		@ball.setPos v(400-10, 300-10)
		@ball.setVelocity v(140*@dir,0)
		b.shapeList[0].update(b.p, b.rot) for b in [@ball]

		@addWalls()
		ctx.fillStyle = 'black'
		ctx.fillRect 0, 0, canvas.width, canvas.height

	draw: ->
		ctx.fillStyle = 'rgba(0,0,0,0.2)'
		ctx.fillRect 0, 0, canvas.width, canvas.height
		ctx.fillStyle = 'white'
		for b in @bats
			b.shapeList[0].draw(ctx)
		@ball.shapeList[0].draw(ctx)

		ctx.save()
		ctx.font = '50px KongtextRegular'
		ctx.scale 1,-1
		ctx.textBaseline = 'top'
		ctx.textAlign = 'left'
		ctx.fillText @score[0], 150, -590
		ctx.textAlign = 'right'
		ctx.fillText @score[1], 800-150, -590
		ctx.restore()

point2canvas = (a) -> a
cp.PolyShape::draw = (ctx) ->
  ctx.beginPath()

  verts = this.tVerts
  len = verts.length
  lastPoint = point2canvas(new cp.Vect(verts[len - 2], verts[len - 1]))
  ctx.moveTo(lastPoint.x, lastPoint.y)

  i = 0
  while i < len
    p = point2canvas(new cp.Vect(verts[i], verts[i+1]))
    ctx.lineTo(p.x, p.y)
    i += 2
  ctx.fill()
	#ctx.stroke()

atom.input.bind atom.key.Q, 'b0up'
atom.input.bind atom.key.A, 'b0down'
atom.input.bind atom.key.UP_ARROW, 'b1up'
atom.input.bind atom.key.DOWN_ARROW, 'b1down'

atom.input.bind atom.key.T, 'tie'
atom.input.bind atom.key.SPACE, 'begin'

game = null

class TitleScreen extends atom.Game
	constructor: ->
		super()
		@time = 0

	update: (dt) ->
		@time += dt
		if atom.input.pressed 'begin'
			@stop()
			setTimeout ->
				game = new Game
				game.run()
			, 0

	draw: ->
		ctx.fillStyle = 'rgba(0,0,0,0.2)'
		ctx.fillRect 0, 0, canvas.width, canvas.height
		ctx.save()
		ctx.scale 1, -1
		ctx.textBaseline = 'top'
		ctx.textAlign = 'center'
		ctx.fillStyle = 'white'
		ctx.font = '80px KongtextRegular'
		ctx.fillText 'PONK', 400+Math.cos(@time*2)*30*Math.cos(@time*3), -500+Math.sin(@time*3)*20

		ctx.font = '25px KongtextRegular'
		ctx.fillText 'PRESS SPACE TO PLAY', 400, -200 if Math.floor(@time*3) % 2
		ctx.restore()

game = new TitleScreen
game.run()

window.onblur = -> game.stop()
window.onfocus = -> game.run()
