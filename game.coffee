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
		@space = new cp.Space
		@space.gravity = v(0, -50)
		@space.damping = 0.95
		@bats = []
		@bats.push @newBat() for [0..1]
		@bats[0].setPos v(40, 300)
		@bats[1].setPos v(canvas.width-40, 300)

		@ball = @newBall()
		@ball.setPos v(400-10, 300-10)
		@ball.setVelocity v(-140,0)

		@addWalls()

	newBat: ->
		body = new cp.Body Infinity, cp.momentForBox(Infinity, 50, 200)
		shape = @space.addShape new cp.BoxShape body, 50, 200
		shape.setElasticity 1.5
		shape.setFriction 0.8
		shape.group = 1
		body # rogue body

	newBall: ->
		body = @space.addBody new cp.Body 25, cp.momentForBox 25, 20, 20
		shape = @space.addShape new cp.BoxShape body, 20, 20
		shape.setElasticity 1.1
		shape.setFriction 0.6
		body

	addWalls: ->
		bottom = @space.addShape(new cp.SegmentShape(@space.staticBody, v(0, 0), v(800, 0), 0))
		bottom.setElasticity(1)
		bottom.setFriction(0.4)
		bottom.group = 1
		top = @space.addShape(new cp.SegmentShape(@space.staticBody, v(0, 600), v(800, 600), 0))
		top.setElasticity(1)
		top.setFriction(0.4)
		top.group = 1

	update: (dt) ->
		dt = 1/60
		
		for b,i in @bats
			if atom.input.down "b#{i}up"
				b.setVelocity v(0, batSpeed)
			else if atom.input.down "b#{i}down"
				b.setVelocity v(0, -batSpeed)
			else
				b.setVelocity v(0, 0)

			b.position_func(dt)
			#b.velocity_func(v(0,0), 1, dt)

		@space.step dt

	draw: ->
		ctx.fillStyle = 'black'
		ctx.fillRect 0, 0, canvas.width, canvas.height
		ctx.fillStyle = 'white'
		for b in @bats
			b.shapeList[0].draw(ctx)
		@ball.shapeList[0].draw(ctx)

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
  ctx.stroke()

atom.input.bind atom.key.Q, 'b0up'
atom.input.bind atom.key.A, 'b0down'
atom.input.bind atom.key.UP_ARROW, 'b1up'
atom.input.bind atom.key.DOWN_ARROW, 'b1down'

game = new Game
game.run()
