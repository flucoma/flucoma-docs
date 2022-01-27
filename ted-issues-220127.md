from flucoma-docs repo:
python3 -m flucoma.MakeRef sc build/json doc /Users/macprocomputer/Desktop/_flucoma/code/flucoma-sc/release-packaging/HelpSource  flucoma/doc/templates

### issues found by Ted 220127:
WARNING: SCDoc: In /Users/macprocomputer/Desktop/_flucoma/code/flucoma-sc/release-packaging/HelpSource/Classes/FluidLabelSet.schelp
  Method -setLabel not found.

seems that setLabel is in the Truth culled from the C++, but does not have a call in the sclang object?

---
