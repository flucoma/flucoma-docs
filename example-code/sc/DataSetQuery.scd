code::

// Create a DataSet with known data

(
var dict = Dictionary.newFrom([
	"cols",5,
	"data",Dictionary.newFrom(
		100.collect{
			arg i;
			var point = 5.collect{
				arg j;
				j+(i/100);
			};
			[i,point];
		}.flatten
	)
]);

//the integer part of the value is the dimension, and the fractional part is the identifier.
~ds = FluidDataSet(s).load(dict).print;

~tmpbuf = Buffer.alloc(s,5);
)


// Prepare a FluidDataSetQuery object
(
~query = FluidDataSetQuery(s);
~out = FluidDataSet(s);

// prepare a simple query
// select points where the value in column 0 is less than 0.04
~query.filter(0,"<",0.04);
~query.addColumn(2); // the column we actually want copied into ~out is column 2
~query.transform(~ds, ~out);

// check the result
~out.print;
)

(
//prepare a more complex query
~query.clear;
~query.filter(0,">",0.03);
~query.and(1,"<",1.08);
~query.or(2,">",2.98);
~query.addRange(2,3); // addRange will add 3 columns starting at column index 2
~query.transform(~ds, ~out);

// Check the results
~out.print;
)

::
STRONG:: Joining Datasets::
code::

// this is how to join 2 datasets, adding columns to items with the same identifier
// create 2 datasets

(
~dsA = FluidDataSet(s);
~dsB = FluidDataSet(s);
)

//feed them items with almost overlaping identifier lists but with different dimensions
(
~dsA.load(
	Dictionary.newFrom([
		\cols, 2,
		\data, Dictionary.newFrom([
			\zero, [0,0],
			\one,[1,11],
			\two,[2,22],
			\three,[3,33],
			\four,[4,44]
		])
	])
);

~dsB.load
(Dictionary.newFrom([
	\cols, 2,
	\data, Dictionary.newFrom([
		\one,[111,1111],
		\two,[222,2222],
		\three,[333,3333],
		\four,[444,4444],
		\five,[555,5555]
	])
])
);

~dsA.print;
~dsB.print;
)

// no query/filter defined, copies all items with identifiers common to both, and all of the defined column of the first input
(
~ds_joined = FluidDataSet(s);
~joiner = FluidDataSetQuery(s);
~joiner.transformJoin(~dsA,~dsB,~ds_joined);
~ds_joined.print
)

(
// all the conditions applicable to 'transform' can be done on the first dataset too. Selected columns of the first source are appended to matching items in the second source.
~joiner.clear;
~joiner.filter(0,">",2.1);
~joiner.and(1,"<", 40);
~joiner.addColumn(0);
~joiner.transformJoin(~dsA,~dsB,~ds_joined);
~ds_joined.print;
)

::
strong::Audio Analysis Data::
code::

~src = Buffer.read(s,FluidFilesPath("Tremblay-ASWINE-ScratchySynth-M.wav"));

// take a listen
~src.play;

// make a dataset of pitch anlyses
(
~features = Buffer(s);
FluidBufPitch.processBlocking(s,~src,features:~features);
~ds_pitch = FluidDataSet(s).fromBuffer(~features);
~ds_pitch.print;
)

// select only the pitch analyses where the pitch confidence is > 0.9
(
~ds_filtered = FluidDataSet(s);
~dsq = FluidDataSetQuery(s);
~dsq.filter(1,">",0.9);
~dsq.addColumn(0);
~dsq.transform(~ds_pitch,~ds_filtered);
~ds_filtered.print;
)

// make another dataset of spectral analyses
(
FluidBufSpectralShape.processBlocking(s,~src,features:~features);
~ds_spec = FluidDataSet(s).fromBuffer(~features);
~ds_spec.print;
)

// select only the spectral analyses where the pitch confidence is > 0.9;
(
~ds_selected = FluidDataSet(s);
~dsq.clear;
~dsq.filter(1,">",0.9);
~dsq.transformJoin(~ds_pitch,~ds_spec,~ds_selected);
~ds_selected.print;
)

// or just append it all together to make one big dataset
(
~dsq.clear;
~dsq.addRange(0,2); // starting at column 0 add two columns (both of the columns in ~ds_pitch)
~dsq.transformJoin(~ds_pitch,~ds_spec,~ds_selected);
~ds_selected.print;
)

// or do it all at once:
(
~dsq.clear;
~dsq.filter(1,">",0.9); // only analyses where the pitch conf is high
~dsq.addColumn(0); // we'll take the pitch freq...
~dsq.transformJoin(~ds_pitch,~ds_spec,~ds_selected);// ... and append it to the spectral analyses
~ds_selected.print;
)

::