(
s.waitForBoot({
	Buffer.freeAll;
	Window.closeAll;
	s.sync;
	~height = Window.availableBounds.height;
	~width = Window.availableBounds.width;
	//change soundNames to select different directory
	~soundNames = ["Oboe", "Flute", "Bass"];
	~soundsDir = ~soundNames[0][0].toLower++~soundNames.join.drop(1);

	~number_steps = 4;


	//add all buffer, bufnum = 0 should be silence
	~buffers = BuffersFolder.read(("sounds/"++~soundsDir).resolveRelative);
	s.sync;
	~silence = Buffer.alloc(s, ~buffers[0].numFrames, 1);
	~buffers.addFirst(~silence);


	//add buffer indices to dictionary for lookup
	~buffersIndexLookup = Dictionary.new;

	~indices = ~buffers.do({|buf| ~buffersIndexLookup.put(buf.path.asString.basename.splitext[0].split($_)[[2, 3, 4]].join.asInteger,buf.bufnum)});




	//proxy

	~np = NodeProxy.audio(s, 2).play(0, 2);
	~np.fadeTime = 1;
	~reader = NodeProxy.control(s, 1);

	~np.source = {|b| Pan2.ar(BufRd.ar(1, b, LFSaw.ar(BufDur.ir(b).reciprocal).range(0, BufFrames.ir(b))))};
	~np.set(\b, ~buffers[0].bufnum);
	~np[10] = \filter -> {arg in; FreeVerb.ar(in)};



	//functions
	~rainbow = {|value| Color.new(value.gaussCurve(1, 0.1, 0.3), value.gaussCurve(1, 0.5, 0.2), value.gaussCurve(1, 1, 0.3))};

	~gridLocation = Rect(~width*0.1, ~height*0.05, ~height*0.8, ~height*0.8);
	~zLocation = Rect(~gridLocation.height+~gridLocation.left+20, ~gridLocation.top, 50,~gridLocation.height);



	~gui = Window("Visualizer", Window.availableBounds);

	~slider = Slider2D(~gui, ~gridLocation)
	.x_(0) // initial location of x
	.y_(0)   // initial location of y
	//.alpha_(0)
	.background_(Color.grey(1, 0))
	.action_({|sl|
		[\sliderX, sl.x, \sliderY, sl.y].postln;
	});

	~zSlider = Slider(~gui, ~zLocation)
	.background_(Color.grey(1, 0));

	~zSlider.action.value;


	~coordIndText = StaticText(~gui, Rect(~zLocation.left+~zLocation.width+(~height*0.05), ~gridLocation.top+(~height*0.5),  ~width-~height-50, 100))
	.string_("Percentage of " ++ ~soundNames)
	.stringColor_(Color.blue)
	.font_(Font("Helvetica", 30));

	~coordinatesText = TextView(~gui, Rect(~zLocation.left+~zLocation.width+(~height*0.05), ~gridLocation.top+(~height*0.6),  ~width-(~zLocation.left+~zLocation.width+(~height*0.05))-50, 100))
	.font_(Font("Helvetica", 30));


	~xName = StaticText(~gui, Rect(~gridLocation.left+(~width*0.2), ~gridLocation.height+(~height*0.05),  ~width-~height-50, 100))
	.string_(~soundNames[0])
	.font_(Font("Helvetica", 25));

	~yName = StaticText(~gui, Rect(~width*0.01, ~gridLocation.height/2,  ~width-~height-50, 100))
	.string_(~soundNames[1])
	.font_(Font("Helvetica", 25));

	~zName = StaticText(~gui, Rect(~zLocation.left+~zLocation.width+(~height*0.02), ~gridLocation.top+(~height*0.35),  ~width-~height-50, 100))
	.string_(~soundNames[2])
	.font_(Font("Arial", 25, italic:true));


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
		var x, y, z, percentages;
		//messages are received in the order x, z, y
		x = msg[1];
		y = msg[3];
		z = msg[2];
		//[x, y, z].postln;

		//converts from coordinates to percentages
		percentages = [x, y, z].collect({|coord, i|
			//inverse the value of y
			if(i==1,
				//this should be changed if looking for an interpolation with a different ~number_steps
				{coord.linlin(~boundaries[i][0], ~boundaries[i][1], 1, 0).round(0.33).snap(1, 0.3, 1)},
				{coord.linlin(~boundaries[i][0], ~boundaries[i][1], 0, 1).round(0.33).snap(1, 0.3, 1)})
		});
		percentages = (percentages * 100).asInteger;
		percentages.join.postln;

		//y is inversed, lower values are high up
		case
		{ ~boundaries[0][0] > x} {~boundaries[0][0] = x}
		{ ~boundaries[0][1] < x} {~boundaries[0][1] = x}
		{ ~boundaries[1][0] > y} {~boundaries[1][0] = y}
		{ ~boundaries[1][1] < y} {~boundaries[1][1] = y}
		{ ~boundaries[2][0] > z} {~boundaries[2][0] = z}
		{ ~boundaries[2][1] < z} {~boundaries[2][1] = z};

		//play the sound.
		~buffersIndexLookup[percentages.join.asInteger].postln;
		~np.set(\b, ~buffersIndexLookup[percentages.join.asInteger]);





		{
			//change GUI text
			~coordinatesText.string_(percentages.asString)
	.stringColor_(Color.red(0.8));
			//change GUI coordinates
			~slider.setXY(
			x.linlin(~boundaries[0][0], ~boundaries[0][1], 0, 1),
			y.linlin(~boundaries[1][0], ~boundaries[0][1], 1, 0),
		);//.background_(~rainbow.(z.linlin(~boundaries[2][0], ~boundaries[2][1], 0, 1)))
		~zSlider.value_(z.linlin(~boundaries[2][0], ~boundaries[2][1], 0, 1))
		}.defer;



	}, '/finger_pos');
});
)