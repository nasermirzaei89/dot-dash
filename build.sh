#!/bin/bash
cd src
zip -9 -q -r ../pkg/dot-dash.love .
cd ..
cat `which love` pkg/dot-dash.love > bin/dot-dash
chmod +x bin/dot-dash