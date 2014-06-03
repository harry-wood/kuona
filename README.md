kuona
=====

Kuona is/was a micro-tasking tool to help with H.O.T. mapping of villages in Mali. It presented users with a bing imagery square, and asked them to click if they see any buildings/villages. More advanced OpenStreetMap mappers could then use the results to find missing villages across a very sparesely populated saharan landscape.

It was developed by nicolas17 (AKA "PovAddict") as quick proof of concept which was used quite effectively during the [2012 Mail Crisis](http://wiki.openstreetmap.org/wiki/2012_Mali_Crisis) response mapping.

Output from the tool was a GPX file showing where everybody had been clicking. Intially these points were just viewed directly in JOSM. Harry developed a ruby script to eliminate points which already appeared to be mapped. Pierre G set up [a special task manager job](http://tasks.hotosm.org/job/198) using the data. This presented task squares spread out in an interesting pattern (unlike the usual grid).

The tool was initially deployed here: http://stuff.povaddict.com.ar/mali-crowdsource/
