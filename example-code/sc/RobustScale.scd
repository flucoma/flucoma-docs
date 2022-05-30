code::

s.boot;

~src = Buffer.readChannel(s,FluidFilesPath("Olencki-TenTromboneLongTones-M.wav"),channels:[0]);

// spectral analysis
(
~select = [\skewness,\flatness];
~features = Buffer(s);
FluidBufSpectralShape.processBlocking(s,~src,features:~features,select:~select);
~ds = FluidDataSet(s).fromBuffer(~features);
~ds.print;
)

// scale using Normalize, Standardize, and RobustScale
(
~ds_norm = FluidDataSet(s);
~ds_stan = FluidDataSet(s);
~ds_robu = FluidDataSet(s);
FluidNormalize(s).fitTransform(~ds,~ds_norm);
FluidStandardize(s).fitTransform(~ds,~ds_stan);
~robu = FluidRobustScale(s).fitTransform(~ds,~ds_robu);
~ds_norm.print;
~ds_stan.print;
~ds_robu.print;
)

// plot the three scalers
(
~ds_norm.dump({
	arg dict_norm;
	~ds_stan.dump({
		arg dict_stan;
		~ds_robu.dump({
			arg dict_robu;

			defer{
				var win = Window("Comparing Scalers",Rect(0,0,1500,500));
				var comp = CompositeView(win,win.bounds);
				comp.layout_(
					HLayout(
						*[dict_norm,dict_stan,dict_robu].collect{
							arg dict;
							FluidPlotter(
								win,
								standalone:false,
								dict:dict,
								xmin:-3,
								xmax:3,
								ymin:-3,
								ymax:3
							);
						};
					)
				);

				UserView(win,win.bounds)
				.drawFunc_{
					Pen.stringInRect("All plots are the same data with different scalers.\nAll axes are from -3 to 3.",Rect(20,30,win.bounds.width * 0.3,40),color:Color.blue);
					["Normalize","Standardize","RobustScale"].do{
						arg name, i;
						Pen.stringAtPoint(name,Point((i * win.bounds.width * 0.33) + 20,15),color:Color.red);
					};
					Pen.stringInRect("In this case, RobustScale keeps more of the data centred around 0 in both\ndimensions than Standardize (and of course better than Normalize).\nNotice however that there's a lot of data \"off-plot\" with RobustScale.",Rect(win.bounds.width * 0.67,win.bounds.height * 0.88,win.bounds.width * 0.3,win.bounds.height * 0.3),color:Color.blue);
				};

				win.front;
			};
		});
	});
});
)

::
strong::Server-side Querying::
code::

(
{
	var src = PlayBuf.ar(1,~src,BufRateScale.ir(~src),loop:1);
	var inputPoint = LocalBuf(2);
	var outputPoint = LocalBuf(2);
	var analysis = FluidSpectralShape.kr(src,~select);
	var robu, sig;

	analysis.poll(label:"Raw Analysis");
	FluidKrToBuf.kr(analysis,inputPoint);
	~robu.kr(Impulse.kr(100),inputPoint,outputPoint);
	robu = FluidBufToKr.kr(outputPoint);
	robu.poll(label:"RobustScale Analysis");

	sig = AllpassC.ar(src,5,robu.abs.clip(0,5).lag(1));
	sig;
}.play;
)
::
