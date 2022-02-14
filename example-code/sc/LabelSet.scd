
code::
~ls = FluidLabelSet.new(s);

["one", "two", "three"].collect{|x,i| ~ls.addLabel(i, x);};
~ls.print;

~ls.free;
::
