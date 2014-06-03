kuona
=====

Kuona is/was a micro-tasking tool to help with H.O.T. mapping of villages in Mali. It presented users with a bing imagery square, and asked them to click if they see any buildings/villages. This micro task was super-simple, and didn't even require a login. Much easier to learn than even the most simplistic editing of OpenStreetMap.

More advanced OpenStreetMap mappers could then use the results to find missing villages (which was useful across this very sparesely populated saharan landscape)

It was developed by nicolas17 (AKA "PovAddict") as quick proof of concept which was used quite effectively during the [2012 Mail Crisis](http://wiki.openstreetmap.org/wiki/2012_Mali_Crisis) response mapping. 
The tool was initially deployed here: http://stuff.povaddict.com.ar/mali-crowdsource/

Output from the tool was a GPX file showing where everybody had been clicking. Intially these points were just viewed directly in JOSM. Harry developed a ruby script to eliminate points which already appeared to be mapped. Pierre G set up [a special task manager job](http://tasks.hotosm.org/job/198) using the data. This presented task squares spread out in an interesting pattern (unlike the usual grid).

The tool also had a behind-the-scenes admin interface displaying a count of how many times a tiles had been seen vs "hits" (times users had decided to click) and nicolas was able to direct attention onto re-checking tiles or looking at new ones as desired.
