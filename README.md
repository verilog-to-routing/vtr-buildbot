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

# Creating a latent build slave on a Windows VM (compiling with Cygwin)
As described http://docs.buildbot.net/0.8.8/manual/cfg-buildslaves.html?highlight=latent#configuring-your-master, the free method to start a latent build slave is using the libvirt library. We use the libvirt Python bindings as that matches master.cfg.

Setting up master.cfg
---------------------
1. Create a new build slave following the instructions in the link above. (Example at the end of this section)

2. Follow the rest of the master.cfg format for creating a new slave (scheduler, factory, builder)

Modifying the VM
----------------
3. Ensure that the correct bit-version of cygwin is installed, and manually clone the VTR github repository. Build it to ensure that all the necessary libraries are also installed.

4. Within Cygwin, follow step #5 from "Starting a new BuildBot" using the same name and password as written in the master.cfg (step #1). (Note that you may have to use 'betzgrp-pchenry' as the hostname instead of 'localhost')

5. To get the slave to talk to the master on startup, we have to create a batch script that runs when the VM boots. 
The location of where to place this batch script can be found by doing the following:
	a. In the Windows search bar, type in "Run" (Desktop App)
	b. Inside the Run search bar, type in "shell:startup"
This will bring you to the folder where startup scripts can be placed.

The batch script will run a bash script through the cygwin environment in order to start the build slave.
	
	e.g. The contents of the batch script
			@echo off
			C:
			C:\cygwin64\bin\bash.exe -l C:\cygwin64\home\Buildbot-WIN20\startup.sh

Change the path to cygwin's bash.exe, as well as to startup.sh as necessary.

The bash script simply navigates to the directory where the slave's buildbot.tac was generated (step #4) and starts the slave.
	
	e.g. The contents of the bash script
			cd /home/Buildbot-WIN20/buildslave/slave_windows/
			buildslave start

6. The last step is to create a snapshot of the VM to load into the slave in master.cfg.

		A snapshot can be created by running "virsh snapshot-create-as --domain <name of VM> --disk-only". Then, we source the snapshot by specifying the base_image field when creating a new slave.

			from buildbot.buildslave.libvirt import LibVirtSlave, Connection
			bs6 = LibVirtSlave(
                 name="Buildbot-WIN10",
                 password="edmonton",
                 connection=Connection("qemu:///system"), #system used instead of session as the VM is run on root
                 hd_image="/scratch/VM/Buildbot-WIN10.qcow2",
                 base_image="/scratch/VM/Buildbot-WIN10.Windows-Cygwin-Buildbot-Snapshot",
                 build_wait_timeout=600,
                 )

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
