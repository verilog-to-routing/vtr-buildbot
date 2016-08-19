echo "=============================="
echo "Restarting Buildbot on $(date)"

cd /home/vtrbot/vtr-buildbot

echo "Looking for slaves in $(pwd)"
slaves=$(ls | grep "slave")

echo "Found slaves: $slaves"

echo "Starting Build Master"
buildbot restart buildmaster

for slave in $slaves; do
	echo "Starting Slave $slave"
	buildslave restart $slave
done
echo "=============================="
