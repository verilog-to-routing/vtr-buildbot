#!/bin/bash
pid=$(ps aux | grep '[s]erver_db' | awk '{print $2}')
if [ "$pid" ]; then
    echo $pid found
    kill $pid
else
    echo "no server found"
fi

/home/vtrbot/buildbot_vtr/slave_basic/builder_basic/build/vtr_flow/scripts/benchtracker/server_db.py \
--port 8088 --database nightly.db --root_directory /home/vtrbot/benchtracker_data/
