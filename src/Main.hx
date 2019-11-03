import love.Love;
import love.event.EventModule;
import love.graphics.GraphicsModule;
import love.graphics.FilterMode;
import love.graphics.Image;
import love.image.ImageModule;
import love.window.WindowModule;
import love.mouse.MouseModule;

typedef Color = {r:Float, g:Float, b:Float, a:Float}

class Game {
	var vis:Bool = false;
	var x:Float = 10.0;
	var y:Float = 10.0;
	var frame:Float = 0;
	var img1:Image = null;
	var img2:Image = null;
	var img3:Image = null;

	public function new() {}

	function genImage(w:Int, h:Int, bilinear:Bool, f:Int->Int->Color):Image {
		var id = ImageModule.newImageData(w, h);
		for (y in 0...h) {
			for (x in 0...w) {
				var c = f(x, y);
				id.setPixel(x, y, c.r, c.g, c.b, c.a);
			}
		}
		var r = GraphicsModule.newImage(id);
		var filter = bilinear ? FilterMode.Linear : FilterMode.Nearest;
		r.setFilter(filter, filter);
		return r;
	}

	public function load(args:lua.Table<Dynamic, Dynamic>) {
		WindowModule.setTitle("yolo");
		MouseModule.setVisible(false);
		img1 = genImage(16, 16, false, function(x, y) {
			return {
				r: (x ^ y) & 1,
				g: 1,
				b: 1,
				a: 1
			};
		});
		img2 = genImage(16, 16, true, function(x, y) {
			var dx = (x - 7.5) / 7.5, dy = (y - 7.5) / 7.5;
			var v = 1 - Math.min(1, Math.sqrt(dx * dx + dy * dy));
			return {
				r: 1,
				g: 1,
				b: 1,
				a: v
			};
		});
		img3 = GraphicsModule.newImage("crosshair.png");
	}

	public function draw():Void {
		var mode = WindowModule.getMode();
		var sz = img1.getDimensions();
		var cx = 0.5 * mode.width, cy = 0.5 * mode.height;
		var s1 = 80.0, s2 = 20.0, r = 150.0;
		GraphicsModule.setColor(1, 1, 1, 1);
		GraphicsModule.draw(img1, cx, cy, -0.01 * frame, s1, s1, 0.5 * sz.width, 0.5 * sz.height);
		GraphicsModule.setColor(1, 0, 0, 1);
		GraphicsModule.draw(img2, cx + r * Math.cos(0.07 * frame), cy + r * Math.sin(0.08 * frame), 0, s2, s2, 0.5 * sz.width, 0.5 * sz.height);
		if (vis) {
			GraphicsModule.setColor(0.0, 1.0, 0.0, 1.0);
			GraphicsModule.draw(img3, x - 8, y - 8);
		}
	}

	public function update(dt:Float):Void {
		frame += dt * 60.0;
	}

	public function keypressed(k, c:String, b:Bool):Void {
		switch (c) {
			case "escape":
				EventModule.quit();
		}
	}

	public function touchmoved(id:lua.UserData, x, y, dx, dy, pressure:Float):Void {
		this.x = x;
		this.y = y;
	}

	public function touchpressed(id:lua.UserData, x, y, dx, dy, pressure:Float):Void {
		vis = true;
	}

	public function touchreleased(id:lua.UserData, x, y, dx, dy, pressure:Float):Void {
		vis = false;
	}
}

class Main {
	static public function main():Void {
		var g = new Game();
		Love.load = g.load;
		Love.draw = g.draw;
		Love.update = g.update;
		Love.keypressed = g.keypressed;
		Love.touchmoved = g.touchmoved;
		Love.touchpressed = g.touchpressed;
		Love.touchreleased = g.touchreleased;
	}
}
