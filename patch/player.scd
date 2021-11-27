a = {|freq= 400, vol= 0.1, modSpeed= 0.1| SinOsc.ar(SinOsc.kr(modSpeed).range(freq-(freq/10), freq+(freq/10))) * vol}.play

a.set(\modDepth, 100)
(
//functions
~rainbow = {|value| Color.new(value.gaussCurve(1, 0.1, 0.3), value.gaussCurve(1, 0.5, 0.2), value.gaussCurve(1, 1, 0.3))};

~gridLocation = Rect(~width*0.05, ~height*0.05, ~height*0.8, ~height*0.8);
~zLocation = Rect(~gridLocation.height+~gridLocation.left+20, ~gridLocation.top, 50,~gridLocation.height);


Window.closeAll;
~height = Window.availableBounds.height;
~width = Window.availableBounds.width;
~gui = Window("Visualizer", Window.availableBounds);

~slider = Slider2D(~gui, ~gridLocation)
        .x_(0) // initial location of x
        .y_(0)   // initial location of y
//.alpha_(0)
.background_(Color.grey(1, 0))
        .action_({|sl|
            [\sliderX, sl.x, \sliderY, sl.y].postln;
        });

c = NumberBox(~gui, Rect(0,0, 0, 0));
~zSlider = Slider(~gui, ~zLocation)
.background_(Color.grey(1, 0))
    .action_({
        c.value_(~zSlider.value)
        });
~zSlider.action.value;

~gui.front;

~grid1 = DrawGrid(~gridLocation, ControlSpec(0, 4, step:1).grid, ControlSpec(0, 4, step:1).grid )
.gridColors_([Color.black, Color.black]);

~grid2 = DrawGrid(~zLocation, ControlSpec(0, 1, step:1).grid, ControlSpec(0, 4, step:1).grid )
.gridColors_([Color.black, Color.black]);

~gui.drawFunc = {
	~grid1.draw;
	~grid2.draw;

};

~gui.refresh;

~previous = [0, 0, 0];
~boundaries =  [[0,0], [0, 0], [20, 0]];
OSCdef(\right_hand, {
	|msg, time, addr, recvPort|
	var x, y, z;
	//messages are received in the order x, z, y
	x = msg[1];
	y = msg[3];
	z = msg[2];
	[x, y, z].postln;

//y is inversed, lower values are high up
		case
		{ ~boundaries[0][0] > x} {~boundaries[0][0] = x}
		{ ~boundaries[0][1] < x} {~boundaries[0][1] = x}
		{ ~boundaries[1][0] > y} {~boundaries[1][0] = y}
		{ ~boundaries[1][1] < y} {~boundaries[1][1] = y}
		{ ~boundaries[2][0] > z} {~boundaries[2][0] = z}
	{ ~boundaries[2][1] < z} {~boundaries[2][1] = z};

	a.set(
		\freq, x.linexp(~boundaries[0][0],~boundaries[0][1], 200, 800),
		\modSpeed, y.linexp(~boundaries[1][0],~boundaries[1][1], 200, 0.1),//ALWAYS REVERSE MAPPING WITH Y
		\vol, z.linlin(~boundaries[2][0],~boundaries[2][1], 0.1, 1));

	{~slider.setXY(
		x.linlin(~boundaries[0][0], ~boundaries[0][1], 0, 1),
		y.linlin(~boundaries[1][0], ~boundaries[0][1], 1, 0),
	);//.background_(~rainbow.(z.linlin(~boundaries[2][0], ~boundaries[2][1], 0, 1)))
	~zSlider.value_(z.linlin(~boundaries[2][0], ~boundaries[2][1], 0, 1))
	}.defer;



}, '/finger_pos');
)

\freq.asSpec
