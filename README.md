#vtr-buildbot
The Verilog-to-Routing project uses Buildbot to automate testing of functionality and Quality of Results (QoR). Vtr-BuildBot currently contains all the configuration and script files needed to start this buildbot on a new machine. 

# Buildbot Infrastructure for VTR
This Buildbot has a buildmaster and four slaves: "slave_basic", "slave_strong", "slave_nightly", and "slave_weekly". Slaves "basic" and "strong" are run after every check-in, while the "nightly" and "weekly" slaves are scheduled to run every night and week respectively. 

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

8. Create a cronjob to run both the "restart_buildbot" and "start_server" script daily.

# Manually triggering builds
When testing the buildbot configuration (rather than VTR code) it is often useful to trigger builds manually.
This can be done via the web GUI, or via IRC (by interacting with vtrbot at #vtr-dev on irc.freenode.org)
