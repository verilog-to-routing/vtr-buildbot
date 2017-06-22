#vtr-buildbot
The Verilog-to-Routing project uses Buildbot to automate testing of functionality and Quality of Results (QoR). Vtr-BuildBot currently contains all the configuration and script files needed to start this buildbot on a new machine. 

# Buildbot Infrastructure for VTR
This Buildbot has a buildmaster and six slaves: "slave_basic", "slave_configs", "slave_strong", "slave_nightly", "slave_weekly", and "slave_windows". Slaves "basic", "strong" and "windows" are run after every check-in, while the "nightly" and "build_configs" slaves are scheduled to run every night, and "weekly" once per week. 

Most of the configuration for the Vtr-Buildbot is done in ~/vtr-buildbot/buildmaster/master.cfg. The slaves are contained in the files: ~/vtr_buildbot/slave_basic, ~/vtr_buildbot/slave_strong, ~/vtr_buildbot/slave_nightly, and ~/vtr_buildbot/slave_weekly. Results of each successful test are stored in a seperate folder: ~/benchtracker_data.

Currently, the buildbot runs on two webservers:  
1. The main VTR webserver on port 8080  
2. The benchtracker webserver on port 8088  

The status of each test can be seen [here](http://betzgrp-pchenry.eecg.utoronto.ca:8080/waterfall).
 
# Starting a new BuildBot
Ensure that the necessary programs are installed on your machine. Documentation of the required programs and how to install them can be found on the BuildBot website [here](http://docs.buildbot.net/current/manual/installation.html).

When all the programs are installed, follow the steps below.

1. Clone this repository to wherever the new BuildBot will run.

2. In the buildmaster directory, create the buildmaster by typing: buildbot create-master --force

3. At the end of the "master.cfg" file, change the buildbotURL to that of the new machine.    

        	c['buildbotURL'] = "NEW_MACHINE:8080/" 
        	
4. Start the buildmaster. This should set up the buildmaster so that the home page is displayed at localhost:8080.      

		"buildbot start"

5. After the buildmaster is running, change back to the "vtr-buildbot/" directory and create the buildslaves. Replace "slave_basic" with the name of the slave you want to create. Make sure that the name, port number, and password match those specified in the "master.cfg" file.     
    
		buildslave create-slave slave_basic localhost:3462 slave_basic PASSWORD

5. When the buildslaves are created, start them by running "restart_buildbot.sh". You should be able to see the slaves running on the webpage. 
	
6. Transfer old QoR data to the new machine so as not to lose any data in the QoR tracker. This data is not on GitHub, but is stored in the current machine under ~/benchtracker_data. 

7. Start up the QoR tracker by running "start_server.sh". 

8. Create a cronjob to restart buildbot after machine reboots (see the file crontab.txt as an example).

# Manually triggering builds
When testing the buildbot configuration (rather than VTR code) it is often useful to trigger builds manually.
This can be done via the web GUI, or via IRC (by interacting with vtrbot at #vtr-dev on https://webchat.freenode.net/)

1. Sign into https://webchat.freenode.net/ (Channels: vtr-dev)

2. Interact with the vtrbot by typing 'vtrbot: <command>' (substitute <command> with help for instructions)

	e.g. To get buildbot to run strong tests, run 'vtrbot: force build strong'.
			[13:48] <user> vtrbot: force build strong
			[13:48] <vtrbot> build forced [ETA 12m57s]
			[13:48] <vtrbot> I'll give a shout when the build finishes
		 The waterfall display will then update with the current status of the build.
		 Eventually, the buildbot should respond with the status of the test.
			[14:01] <vtrbot> Hey! build strong #99 is complete: Failure [failed vtr_reg_strong]
