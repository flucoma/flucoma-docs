/*
Dirty grab of existing EXAMPLE:: block from Flucoma class docs. Had hoped that parsing the tree would be quick and easy
but there's no mechanism to re-render back to original content, and writing one seems like overkill.

Instead, just check which Flucoma classes have doc, and rely on knowing where that file is in order to use sed to lift out everytihng after the EXAMPLE:: tag is encountered and write that to a new .scd file in flucoma-docs
*/
(
~helps = "/Users/owen/dev/flucoma-sc/release-packaging/HelpSource/Classes/%.schelp";
~dest = "/Users/owen/dev/flucoma-docs/examples/sc/%.scd";

/*~walk = { |n,stream|
    (n.id++"::").postln;
    if(n.text.notNil) {n.text.postln};
    if(n.children.notNil) {n.children.do{ |child|
        ~walk.value(child);
    }
    }
};*/

Class.allClasses.select({|c|
    "^Fluid.*".matchRegexp(c.name.asString)
}).do{ |c|
    var key = ("Classes" ++ '/' ++ c.name);
    var docentry = SCDoc.documents.at(key);
    if(docentry.isUndocumentedClass.not) {
        var name = c.name.asString.findRegexp("Fluid(.+)")[1][1];
        var cmd = ("cat" + format(~helps,c.name.asString) + "| sed -Ee '1,/(EXAMPLES|examples)::/ d' >" + format(~dest,name));
        cmd.postln;
        cmd.systemCmd.postln;

/*        var doc = SCDoc.parseDoc(docentry);
        var example_block = doc.findChild('BODY').findChild('EXAMPLES');
        var name = c.name.asString.findRegexp("Fluid(.+)")[1][1];
        var path = format("/Users/owen/dev/flucoma-docs/examples/sc/%.scd",name);

        ~walk.value(example_block); */

/*        var f = File(path, "w");
        docentry.toJSON(f);
        // f.write(example_block.asString);
        f.close();    */
    }
}
)
