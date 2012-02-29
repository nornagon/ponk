var Game, TitleScreen, batSpeed, canvas, ctx, game, point2canvas, v;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
canvas = atom.canvas;
canvas.width = 800;
canvas.height = 600;
ctx = atom.context;
ctx.scale(1, -1);
ctx.translate(0, -600);
batSpeed = 200;
v = cp.v;
Game = (function() {
  __extends(Game, atom.Game);
  function Game() {
    this.score = [0, 0];
    this.dir = -1;
    this.reset();
  }
  Game.prototype.newBat = function() {
    var body, shape;
    body = new cp.Body(Infinity, cp.momentForBox(Infinity, 50, 200));
    shape = this.space.addShape(new cp.BoxShape(body, 50, 200));
    shape.setElasticity(1);
    shape.setFriction(0.8);
    shape.group = 1;
    return body;
  };
  Game.prototype.newBall = function() {
    var body, shape;
    body = this.space.addBody(new cp.Body(25, cp.momentForBox(80, 20, 20)));
    shape = this.space.addShape(new cp.BoxShape(body, 20, 20));
    shape.setElasticity(0.9);
    shape.setFriction(0.6);
    return body;
  };
  Game.prototype.addWalls = function() {
    var bottom, top;
    bottom = this.space.addShape(new cp.SegmentShape(this.space.staticBody, v(0, 0), v(800, 0), 0));
    bottom.setElasticity(1);
    bottom.setFriction(0.1);
    bottom.group = 1;
    top = this.space.addShape(new cp.SegmentShape(this.space.staticBody, v(0, 600), v(800, 600), 0));
    top.setElasticity(1);
    top.setFriction(0.1);
    return top.group = 1;
  };
  Game.prototype.update = function(dt) {
    var b, i, _len, _ref;
    if (atom.input.pressed('tie')) {
      return this.reset();
    }
    dt = 1 / 60;
    _ref = this.bats;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      b = _ref[i];
      if (atom.input.down("b" + i + "up")) {
        b.setVelocity(v(0, batSpeed));
        b.w = 1 * (i * 2 - 1);
      } else if (atom.input.down("b" + i + "down")) {
        b.setVelocity(v(0, -batSpeed));
        b.w = -1 * (i * 2 - 1);
      } else {
        b.setVelocity(v(0, 0));
        b.w = 0;
      }
      b.position_func(dt);
    }
    this.space.step(dt);
    if (this.ball.p.x < -80) {
      this.win(1);
    } else if (this.ball.p.x > canvas.width + 80) {
      this.win(0);
    }
    if (this.ball.p.y < -100 || this.ball.p.y > canvas.height + 100) {
      return this.win(this.ball.p.x < canvas.width / 2 ? 1 : 0);
    }
  };
  Game.prototype.win = function(p) {
    this.score[p]++;
    this.dir = p === 0 ? -1 : 1;
    return this.reset();
  };
  Game.prototype.reset = function() {
    var b, _i, _j, _k, _len, _len2, _ref, _ref2;
    this.space = new cp.Space;
    this.space.gravity = v(0, -50);
    this.space.damping = 0.95;
    this.bats = [];
    for (_i = 0; _i <= 1; _i++) {
      this.bats.push(this.newBat());
    }
    this.bats[0].setPos(v(40, 300));
    this.bats[1].setPos(v(canvas.width - 40, 300));
    _ref = this.bats;
    for (_j = 0, _len = _ref.length; _j < _len; _j++) {
      b = _ref[_j];
      b.shapeList[0].update(b.p, b.rot);
    }
    this.ball = this.newBall();
    this.ball.setPos(v(400 - 10, 300 - 10));
    this.ball.setVelocity(v(140 * this.dir, 0));
    _ref2 = [this.ball];
    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
      b = _ref2[_k];
      b.shapeList[0].update(b.p, b.rot);
    }
    this.addWalls();
    ctx.fillStyle = 'black';
    return ctx.fillRect(0, 0, canvas.width, canvas.height);
  };
  Game.prototype.draw = function() {
    var b, _i, _len, _ref;
    ctx.fillStyle = 'rgba(0,0,0,0.2)';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = 'white';
    _ref = this.bats;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      b = _ref[_i];
      b.shapeList[0].draw(ctx);
    }
    this.ball.shapeList[0].draw(ctx);
    ctx.save();
    ctx.font = '50px KongtextRegular';
    ctx.scale(1, -1);
    ctx.textBaseline = 'top';
    ctx.textAlign = 'left';
    ctx.fillText(this.score[0], 150, -590);
    ctx.textAlign = 'right';
    ctx.fillText(this.score[1], 800 - 150, -590);
    return ctx.restore();
  };
  return Game;
})();
point2canvas = function(a) {
  return a;
};
cp.PolyShape.prototype.draw = function(ctx) {
  var i, lastPoint, len, p, verts;
  ctx.beginPath();
  verts = this.tVerts;
  len = verts.length;
  lastPoint = point2canvas(new cp.Vect(verts[len - 2], verts[len - 1]));
  ctx.moveTo(lastPoint.x, lastPoint.y);
  i = 0;
  while (i < len) {
    p = point2canvas(new cp.Vect(verts[i], verts[i + 1]));
    ctx.lineTo(p.x, p.y);
    i += 2;
  }
  return ctx.fill();
};
atom.input.bind(atom.key.Q, 'b0up');
atom.input.bind(atom.key.A, 'b0down');
atom.input.bind(atom.key.UP_ARROW, 'b1up');
atom.input.bind(atom.key.DOWN_ARROW, 'b1down');
atom.input.bind(atom.key.T, 'tie');
atom.input.bind(atom.key.SPACE, 'begin');
game = null;
TitleScreen = (function() {
  __extends(TitleScreen, atom.Game);
  function TitleScreen() {
    TitleScreen.__super__.constructor.call(this);
    this.time = 0;
  }
  TitleScreen.prototype.update = function(dt) {
    this.time += dt;
    if (atom.input.pressed('begin')) {
      this.stop();
      return setTimeout(function() {
        game = new Game;
        return game.run();
      }, 0);
    }
  };
  TitleScreen.prototype.draw = function() {
    ctx.fillStyle = 'rgba(0,0,0,0.2)';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.save();
    ctx.scale(1, -1);
    ctx.textBaseline = 'top';
    ctx.textAlign = 'center';
    ctx.fillStyle = 'white';
    ctx.font = '80px KongtextRegular';
    ctx.fillText('PONK', 400 + Math.cos(this.time * 2) * 30 * Math.cos(this.time * 3), -500 + Math.sin(this.time * 3) * 20);
    ctx.font = '25px KongtextRegular';
    if (Math.floor(this.time * 3) % 2) {
      ctx.fillText('PRESS SPACE TO PLAY', 400, -200);
    }
    return ctx.restore();
  };
  return TitleScreen;
})();
game = new TitleScreen;
game.run();
window.onblur = function() {
  return game.stop();
};
window.onfocus = function() {
  return game.run();
};