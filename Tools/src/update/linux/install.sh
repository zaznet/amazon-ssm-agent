#!/bin/bash

s3path=$1

# helper function to set error output
function error_exit
{
	echo "$1" 1>&2
	exit 1
}

# allow ssm-agent to finish it's work
sleep 2

if [[ `/sbin/init --version` =~ upstart ]]; then
	echo "upstart detected"
	echo "Installing agent" 
	yum install -y amazon-ssm-agent.rpm

	agentVersion=$(rpm -q --qf '%{VERSION}\n' amazon-ssm-agent)
	echo "Installed version: $agentVersion"
	echo "starting agent"
	/sbin/start amazon-ssm-agent
	echo "$(status amazon-ssm-agent)"
elif [[ `systemctl` =~ -\.mount ]]; then
	if [[ "$(systemctl is-active amazon-ssm-agent)" == "active" ]]; then
		echo "-> Agent is running in the instance"
		echo "Stopping the agent"
		echo "$(systemctl stop amazon-ssm-agent)"
		echo "Agent stopped"
		echo "$(systemctl daemon-reload)"
		echo "Reload daemon"	
	else
		echo "-> Agent is not running in the instance"
	fi
		
	echo "Installing agent" 
	echo "$(yum install -y amazon-ssm-agent.rpm)"
		
	echo "Starting agent"
	$(systemctl daemon-reload)
	$(systemctl start amazon-ssm-agent)
	echo "$(systemctl status amazon-ssm-agent)"
else
	echo "The amazon-ssm-agent is not supported on this platform. Please visit the documentation for the list of supported platforms"
fi


