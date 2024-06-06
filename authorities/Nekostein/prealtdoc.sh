#!/bin/bash

bash "authorities/$OFFICE/altdoc-lib/tomldata2tex.sh" > .workdir/tomldata2tex.texpart
bash "authorities/$OFFICE/altdoc-lib/fulltomldata.sh" > .workdir/fulltomldata.texpart
