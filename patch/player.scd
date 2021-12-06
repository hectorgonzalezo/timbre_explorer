os.options.outDevice = "Built-in Output";
(
s.waitForBoot({
	Buffer.freeAll;
	Window.closeAll;
	MIDIClient.init;
MIDIIn.connectAll;
	s.sync;
	~height = Window.availableBounds.height;
	~width = Window.availableBounds.width;

	~gridLocation = Rect(~width*0.1, ~height*0.05, ~height*0.8, ~height*0.8);
	~zLocation = Rect(~gridLocation.height+~gridLocation.left+20, ~gridLocation.top, 50,~gridLocation.height);

	~currentDir= "".resolveRelative;

	~number_steps = 4;
	~np1Playing =  true;

	~rateEnv = Env([1, 0.5, 2.0], [4, 127], [\lin, \exp, -6, \sin]);




	//functions
	~rainbow = {|value| Color.new(value.gaussCurve(1, 0.1, 0.3), value.gaussCurve(1, 0.5, 0.2), value.gaussCurve(1, 1, 0.3))};


		//proxy

	~startProxy = {
	~np1 = NodeProxy.audio(s, 2).play;
	~np1.fadeTime = 1;
	~np2 = NodeProxy.audio(s, 2).play;
	~np2.fadeTime = 1;

	~np1.source = {
		|b=63, vol=0, rate=1|
		Pan2.ar(
			BufRd.ar(1, b, LFSaw.ar(BufDur.ir(b).reciprocal* rate).range(0, BufFrames.ir(b)))
		) * Lag2.kr(vol, 0.2)
	};
	~np2.source = {
		|b=63, vol=0, rate=1|
		Pan2.ar(
			BufRd.ar(1, b, LFSaw.ar(BufDur.ir(b).reciprocal * rate).range(0, BufFrames.ir(b))) * Lag2.kr(vol, 0.2)
		)
	};


		~np1[10] = \filter -> { arg in, wetDel= 0;
		XFade2.ar(in,
			CombC.ar(in, 0.2, 0.01, 1), wetDel.linlin(0, 1, -1, 1)) };
	~np2[10] = \filter -> { arg in, wetDel= 0;
		XFade2.ar(in,
			CombC.ar(in, 0.2, 0.01, 1), wetDel.linlin(0, 1, -1, 1)) };

	~np1[20] = \filter -> { arg in, wetGrain= 0, grainSpeed = 32;
		XFade2.ar(in,
				GrainIn.ar(1, Impulse.kr(grainSpeed), 1/grainSpeed, in, 0, -1), wetGrain.linlin(0, 1, -1, 1)) };
	~np2[20] = \filter -> { arg in, wetGrain= 0, grainSpeed = 32;
		XFade2.ar(in,
			GrainIn.ar(1, Impulse.kr(grainSpeed), 1/grainSpeed, in, 0, -1), wetGrain.linlin(0, 1, -1, 1)) };

	~np1[30] = \filter -> { arg in, wetRev= 0, fb= 0.1;
		XFade2.ar(in,
				Greyhole.ar(in, 1, 0, 1, 0.707, fb), wetRev.linlin(0, 1, -1, 1)) };
		~np2[30] = \filter -> { arg in, wetRev= 0, fb= 0.1;
		XFade2.ar(in,
				Greyhole.ar(in, 1, 0, 1, 0.707, fb), wetRev.linlin(0, 1, -1, 1)) };

	};


	~startSounds = {
		|directory|
		Buffer.freeAll;
		~np1.clear(5);
		~np2.clear(5);
		//add all buffer, bufnum = 0 should be silence
		~buffers = BuffersFolder.read(directory);
		{
			~silence = Buffer.alloc(s, ~buffers[0].numFrames, 1);
			~buffers.addFirst(~silence);

			~startProxy.();
		}.defer(1)

	};



	//add buffer indices to dictionary for lookup
	~buffersIndexLookup = Dictionary.new;

	~indices = ~buffers.do({|buf| ~buffersIndexLookup.put(buf.path.asString.basename.splitext[0].split($_)[[2, 3, 4]].join.asInteger,buf.bufnum)});





	~createGui = {
		if(~gui.notNil,{ ~gui.close});

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

		~calButton = Button(~gui, Rect(~zLocation.left+~zLocation.width+(~height*0.02), ~gridLocation.top+50,  ~width-~zLocation.left-200, 50))
		.string_("Recalibrate")
		.font_(Font("Helvetica", 25));

		~calButton.action = {
			~previous = [0, 0, 0];
			~boundaries =  [[0,0], [-40, -40], [150, 150]];
		};



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

	};


	//sounds selecter
	w = Window.new("", Rect(300, 300, 300, 30)).front;
	m = PopUpMenu(w, Rect(0, 0, 300, 30));

	m.items = [
		"Select Sounds","clarinet, marbles and piano", "oboe, flute and bass", "bowl, water and whisper"
	];

	m.background_(Color.green(0.7));  // only changes the look of displayed item
	m.stringColor_(Color.white);   // only changes the look of displayed item
	m.font_(Font("Courier", 13));   // only changes the look of displayed item
	m.action = { arg menu;
		[menu.value, menu.item].postln;
		case { menu.value == 1} {
			~soundNames = ["Clarinet", "Marbles", "Piano"];
			~soundsDir = ~soundNames[0][0].toLower++~soundNames.join.drop(1);
			~startSounds.value(~currentDir++"sounds/"++~soundsDir);
			~createGui.value();

		}

		{ menu.value == 2} {
			~soundNames = ["Oboe", "Flute", "Bass"];
			~soundsDir = ~soundNames[0][0].toLower++~soundNames.join.drop(1);
			~startSounds.value(~currentDir++"sounds/"++~soundsDir);

			~createGui.value();
		}

		{ menu.value == 3} {
			~soundNames = ["Bowl", "Water", "Whisper"];
			~soundsDir = ~soundNames[0][0].toLower++~soundNames.join.drop(1);
			~startSounds.value(~currentDir++"sounds/"++~soundsDir);
			~createGui.value();
		};


	};




	~previousCoord = [0, 0, 0];
	~boundaries =  [[0,0], [-40, -40], [150, 150]];

	OSCdef(\right_hand, {
		|msg, time, addr, recvPort|
		var x, y, z, percentages, smoothCoord;
		//messages are received in the order x, z, y
		x = msg[1];
		y = msg[3];
		z = msg[2];
		//[x, y, z].postln;

		//smooths to prevent jitter
		smoothCoord = ([x, y, z] + ~previousCoord)/2;
		//converts from coordinates to percentages
		percentages = (smoothCoord).collect({|coord, i|
			//inverse the value of y
			if(i==1,
				//this should be changed if looking for an interpolation with a different ~number_steps
				{coord.linlin(~boundaries[i][0], ~boundaries[i][1], 1, 0).round(0.33).snap(1, 0.3, 1)},
				//for the rest
				{coord.linlin(~boundaries[i][0], ~boundaries[i][1], 0, 1).round(0.33).snap(1, 0.3, 1)})
		});
		percentages = (percentages * 100).asInteger;

		//smoothCoord.postln;

		//y is inversed, lower values are high up
		case
		{ ~boundaries[0][0] > x} {~boundaries[0][0] = x}
		{ ~boundaries[0][1] < x} {~boundaries[0][1] = x}
		{ ~boundaries[1][0] > y} {~boundaries[1][0] = y}
		{ ~boundaries[1][1] < y} {~boundaries[1][1] = y}
		{ ~boundaries[2][0] > z} {~boundaries[2][0] = z}
		{ ~boundaries[2][1] < z} {~boundaries[2][1] = z};


		//smoothly switch between sounds
		if(percentages != ~previousPercentages,{
			if(~np1Playing.not,
				{
					~np1.set(\vol, 0);
					~np2.set(\b, ~buffersIndexLookup[percentages.join.asInteger], \vol, 1);
					~np1Playing = true;
					percentages.postln;
					"si".postln;
				},
				{

					~np2.set(\vol, 0);
					~np1.set(\b, ~buffersIndexLookup[percentages.join.asInteger], \vol, 1);
					~np1Playing = false;
					percentages.postln;
					"no".postln;
			});
		});

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

		~previousCoord = [x, y, z];
		~previousPercentages = percentages;

	}, '/finger_pos');
});


~previousClass = 0;
OSCdef(\left_hand,
	{
		|msg, time|
		var class = msg[1];
		if(class != ~previousClass,
			{
				class.postln;
				if(class == 2.0,
					{
						OSCdef(\right_hand).disable;
					},
					{
						OSCdef(\right_hand).enable;
				});
		});

		~previousClass = class;
	},
	'/wek/outputs',
	NetAddr("127.0.0.1"),
	recvPort:57130
);


~midiPercentages = [0, 0, 0];

~playFromMidi = {
	|percentage|
	if(~np1Playing.not,
				{
					~np1.set(\vol, 0);
					~np2.set(\b, ~buffersIndexLookup[percentage.join.asInteger], \vol, 1);


				},
				{

					~np2.set(\vol, 0);
					~np1.set(\b, ~buffersIndexLookup[percentage.join.asInteger], \vol, 1);
		});
};

MIDIdef.cc(\nano,
	{ arg ...args;
		var ccNum = args[1];
		var val = args[0];

		args.postln;

		switch(ccNum,
			0, {
				~midiPercentages[0]= val.linlin(0, 127, 0, 100).round(33).snap(100, 30, 1).asInteger;
				~playFromMidi.value(~midiPercentages);
			},
			1, {
				~midiPercentages[1]= val.linlin(0, 127, 0, 100).round(33).snap(100, 30, 1).asInteger;
				~playFromMidi.value(~midiPercentages);
			},
			2, {
				~midiPercentages[2]= val.linlin(0, 127, 0, 100).round(33).snap(100, 30, 1).asInteger;
				~playFromMidi.value(~midiPercentages);
			},
			3, {
				~np1.set(\rate, ~rateEnv[val]);
				~np2.set(\rate, ~rateEnv[val]);
			},
			4, {
				~np1.set(\wetDel, val.linlin(0, 127, 0, 1));
				~np2.set(\wetDel, val.linlin(0, 127, 0, 1));
			},
			5, {
				~np1.set(\wetGrain, val.linlin(0, 127, 0, 1));
				~np2.set(\wetGrain, val.linlin(0, 127, 0, 1));
			},
			6, {
				~np1.set(\wetRev, val.linlin(0, 127, 0, 1));
				~np2.set(\wetRev, val.linlin(0, 127, 0, 1));
			},
			7, {

			},

			21, {
				~np1.set(\grainSpeed, val.linexp(0, 127, 1, 64));
				~np2.set(\grainSpeed, val.linexp(0, 127, 1, 64));
			},

			22, {
				~np1.set(\fb, val.linexp(0, 127, 0.1, 1));
				~np2.set(\fb, val.linexp(0, 127, 0.1, 1));
			}

		);
		~midiPercentages.postln;
		~lastPercentages.postln;





		{
			//change GUI text
			~coordinatesText.string_(~midiPercentages.asString)
			.stringColor_(Color.red(0.8));
			//change GUI coordinates
			~slider.setXY(
				~midiPercentages[0].linlin(0, 127, 0, 1),
				~midiPercentages[1].linlin(0, 127, 0, 1),
			);//.background_(~rainbow.(z.linlin(~boundaries[2][0], ~boundaries[2][1], 0, 1)))
			~zSlider.value_(~midiPercentages[2].linlin(0, 127, 0, 1))
		}.defer;

		{~lastPercentages = ~midiPercentages}.defer(2);
	}
);

)



//longer files
//with nanokontrol
//2 by 2
//4 by 4

(
SynthDef(\gs, {
		|sync =1, dens=20, grainDur=0.1, durRand=1, buf=0,
		rate=1, pos=0, posSpeed=1, posRand=0,
		grainEnv=(-1), pan=0, panHz=0, panRand=0, gate=1, atk=1, dec=0.3, rel=1, crv=(-1), amp=1, out=0, loopTime=20, ampLFO=0, lfoFreq= 0.5|

		var sig, env, densCtrl, durCtrl, posCtrl, panCtrl;

		env = Linen.kr(gate,atk,1,rel,2);

		densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]); //para seleccionar si la densidad es fija o aleatoria

		durCtrl = grainDur * LFNoise1.kr(100).exprange(1/durRand, durRand);

		posCtrl = Phasor.ar(0, posSpeed * BufRateScale.ir(buf),0, BufSamples.ir(buf)-1);
		posCtrl = posCtrl + LFNoise1.kr(100).bipolar(posRand*SampleRate.ir);
		posCtrl = posCtrl / BufSamples.ir(buf);
		posCtrl = posCtrl + pos;

		panCtrl = pan + LFNoise1.kr(panHz).bipolar(panRand);

		sig = GrainBuf.ar(
			2,
			densCtrl,
			durCtrl,
			buf,
			rate,
			posCtrl,
			2,
			panCtrl,
			grainEnv
		);

		sig = LeakDC.ar(sig * env);

		Out.ar(out, Select.ar(ampLFO,[sig*amp.lag2(0.1),sig *amp.lag(0.1)*LFNoise1.kr(LFNoise0.kr(lfoFreq).range(0.5,2)).range(0.3,1)]));

	}).add;

SynthDef(\wtabl,
	{arg out = 0, buf = 0, freq = 300, amp = 0.5, pan = 0, atk=0.01, rel=1;
		var sig, env;
		sig = Pan2.ar(PlayBuf.ar(1,buf,BufRateScale.ir(buf) *freq,1,0,1),pan);
		env = EnvGen.ar(Env.perc(atk,rel),doneAction:2);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,sig);
}).add;

SynthDef(\vplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, atk=0.0, sus=1, rel= 0, pos=0, gate=1;
		var sig, env;
		var size =5;
		sig = {|i| PlayBuf.ar(1,buf,BufRateScale.ir(buf) * rate * (i +1),1,BufDur.kr(buf)*pos*48000, 1, doneAction:2)}!size;
	sig = Pan2.ar(sig, pan);
		env = Linen.kr(gate, atk, 1,rel, doneAction:2);
		sig = sig * env;
		sig = sig * amp/size;
		Out.ar(out,sig);
}).add;


Pdef(\rythm,
	Pbind(
		\instrument, \gs,
		\dur, Pseq([1], inf),
		\buf, Pseq(~buffers.copySeries(1, 10,~buffers.size), inf).trace,
		\grainDur, 0.1,
		\dens, 10

	)
).play;


Pdef(\chords,
	Pbind(
		\instrument, \vplay,
		\dur, Pseq([5], inf),
		\atk, 1,
		\pos, 0,
		\rel, 1,
		\rate, 0.25,
		\amp, 1,
		\buf, Prand(~buffers, inf).trace,
	)
).play

)
~buffers[2..3]
~buffers.copyRange(1,~buffers.size).collect({|buf| buf.path.basename.postln})

~buffers.copySeries(1, 10,~buffers.size).collect({|buf| buf.path.basename.postln})

