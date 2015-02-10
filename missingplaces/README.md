# Missing places script

This was Harry's weird way of solving a simple buffering geo-calculation as a script which could be re-run repeatedly.

We fetch the latest OSM data on places (Mali villages) using fetchplaces.sh

...and then we read in the GPX file of places people have clicked, and write out a GPX file of places which seem to be missing in OSM.
