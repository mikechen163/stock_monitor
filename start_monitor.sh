#!/bin/bash

ruby index_monitor.rb -a index.db >> index.log &
ruby quicktrade.rb -a 60m.db 3600 >> 60m.log &
ruby quicktrade.rb -a 30m.db 1800 >> 30m.log &
