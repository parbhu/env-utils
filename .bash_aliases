# Directory browsing
alias repo='cd ~/Project/GSDI/gsdi/'
alias ipmi='cd /home/qparbhu/Project/ipmi/ipmitool/gerrit/ipmitool/'
alias dl='ls -ltr | grep drwx'

alias l='ls -ltr'
alias laptop='ssh qparbhu@elx151150z-cu.ki.sw.ericsson.se'
alias ipmicp='scp /home/qparbhu/Project/ipmi/ipmitool/gerrit/ipmitool/src/ipmitool root@10.0.5.21:'

# Brute Force search tools
alias findc='find . -name \*.c | xargs grep -in'
alias findx='find . -name \*.* | xargs grep -in'
alias findh='find . -name \*.h | xargs grep -in'

# SSH related
alias dispass="cat ~/.ssh/id_rsa.pub | ssh root@10.0.5.21 'cat >> .ssh/authorized_keys'"
alias sgep601="ssh root@10.0.5.21"

# Gdb Related
alias getcore='scp root@10.0.5.21:core /home/qparbhu/Project/ipmi/ipmitool/gerrit/ipmitool/src/'
alias lgdb='gdb /home/qparbhu/Project/ipmi/ipmitool/gerrit/ipmitool/src/ipmitool /home/qparbhu/Project/ipmi/ipmitool/gerrit/ipmitool/src/core'
alias glgdb='getcore; lgdb'

#export myssh="ssh -o 'StrictHostKeyChecking no' root@"
alias sniff="sudo /usr/sbin/tcpdump -i ctrll0 -s 0 -vvvv -e -t" 

# Build commands
alias ms11="repo; make -j 20 sles11sp3; cd -"
alias ms11c="make -j 20 sles11sp3_clean"
alias ms11ru="make -j 20 sles11sp3_rpms_update"


# Alias for searching alias functions
alias func="grep \"()\" ~/.bash_aliases | grep -v func | cut -d\"(\" -f1"



alias conv_srec="srec_cat pmbtable.bin -binary  -offset=0x78DE0000 -o pmbtable10.srec -motorola -obs=10 -enable=footer -execution-start-address=0 -header=\"HDR\""

alias gfile="nautilus –no-desktop"
alias csbuild='find $PWD -name "*.c" -o -name "*.h" > ./cscope.files ; cscope -Rbkq'

alias lock="dm-tool lock"
alias refresh="sudo apt-get update; sudo apt-get dist-upgrade" 

# CMXB commands
rebl() {
count=$2
status=0
if [ $# -lt 1 ]; then
	echo "$0 <slot_number_to_reset> [warm]"
	echo "By default a cold reset is used"
else
	if [ $# == 2 ]; then 
		ssh root@10.0.5.254 blade_ipmi resetBlade $1 warm
	else
		A=`ssh root@10.0.5.254 blade_ipmi resetBlade $1 cold`
	fi
	[[ $A =~ ERROR ]]
	if [ $? -eq 0 ] ; then
		if [ "$count" -lt 5 ] ; then 
			echo "Failed to restart Slot $1"
			count= $(( $count + 1 ))
			rebl $1 $count
		fi
	else
		echo "Restarted Slot $1"
	fi
	echo "status : $status $count"
fi
}

dssh() {
	sed -i $1d ~/.ssh/known_hosts
}
