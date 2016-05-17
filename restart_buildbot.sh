slaves=$(ls | grep "slave")

buildbot restart buildmaster

for slave in $slaves; do
	echo $slave
	buildslave restart $slave
done

#start_server.sh

