
code::

s.reboot;
// Create a DataSet with known data
~dataSet= FluidDataSet(s);

(
~points = 100.collect{|i|5.collect{|j|j+(i/100)}};
~dataSet.clear;
~tmpbuf = Buffer.alloc(s,5);

fork{
    s.sync;
    ~points.do{|x,i|
        ~tmpbuf.setn(0,x);
        ~dataSet.addPoint(i,~tmpbuf);
        s.sync;
    }
}
)

//check the source - the column is the integer part of the value, and the row is the fractional part. This will help us identify what we kept in our didactic query
~dataSet.print;

// Prepare a FluidDataSetQuery object
~query = FluidDataSetQuery.new;
~out = FluidDataSet(s);

// prepare a simple query
~query.filter(0,"<",0.04);
~query.addColumn(2);
~query.transform(~dataSet, ~out);

// check the result
~out.print;

//prepare a more complex query
~query.clear;
~query.filter(0,">",0.03);
~query.and(1,"<",1.08);
~query.or(2,">",2.98);
~query.addRange(2,2);
~query.transform(~dataSet, ~out);

// Check the results
~out.print;

::

STRONG:: Joining Datasets::

code::
//this is how to join 2 datasets, adding columns to items with the same identifier
//create 3 datasets
(
~dsA =  FluidDataSet(s);
~dsB =  FluidDataSet(s);
~dsC =  FluidDataSet(s);
)

//feed them items with almost overlaping identifier lists but with different dimensions
~dsA.load(Dictionary.newFrom([\cols, 2, \data, Dictionary.newFrom([\zero, [0,0], \one,[1,11],\two,[2,22], \three,[3,33],\four,[4,44]])]));
~dsB.load(Dictionary.newFrom([\cols, 2, \data, Dictionary.newFrom([\one,[111,1111],\two,[222,2222], \three,[333,3333],\four,[444,4444],\five,[555,5555]])]));
~dsA.print;
~dsB.print;

// no query/filter defined, copies all items with identifiers common to both, and all of the defined column of the first input
~joiner = FluidDataSetQuery.new;
~joiner.transformJoin(~dsA,~dsB,~dsC)
~dsC.print

// all the sophisticated conditions applicable to 'transform' can be done on the first dataset too. Selected columns of the first source are appended to matching items in the second source.
~joiner.filter(0,">",2.1)
~joiner.and(1,"<", 40)
~joiner.addColumn(0)
~joiner.transformJoin(~dsA,~dsB,~dsC)
~dsC.print
::
