# Directory browsing
alias repo='cd ~/Project/GSDI/gsdi/'
alias ipmi='cd /home/qparbhu/Project/ipmi/ipmitool/gerrit/ipmitool/'
alias dl='ls -ltr | grep drwx'

alias l='ls -ltr'
alias laptop='ssh qparbhu@elx151150z-cu.ki.sw.ericsson.se'
alias ipmicp='scp /home/qparbhu/Project/ipmi/ipmitool/gerrit/ipmitool/src/ipmitool root@10.0.5.21:'
strip_binarychars() {
	tr -cd '\11\12\15\40-\176' < "$1" > "$2"
}

# Brute Force search tools
alias findc='find . -name \*.c | xargs grep -ins'
alias finds='find . -name \*.c -o -name \*.h | xargs grep -ins'
alias findx='find . -name \* | xargs grep -ins'
alias findh='find . -name \*.h | xargs grep -ins'

# SSH related
alias dispass="cat ~/.ssh/id_rsa.pub | ssh root@10.0.5.21 'cat >> .ssh/authorized_keys'"
alias sgep601="ssh root@10.0.5.21"

# Gdb Related
alias getcore='scp root@10.0.5.21:core /home/qparbhu/Project/ipmi/ipmitool/gerrit/ipmitool/src/'
alias lgdb='gdb /home/qparbhu/Project/ipmi/ipmitool/gerrit/ipmitool/src/ipmitool /home/qparbhu/Project/ipmi/ipmitool/gerrit/ipmitool/src/core'
alias glgdb='getcore; lgdb'

#export myssh="ssh -o 'StrictHostKeyChecking no' root@"
alias sniff="sudo /usr/sbin/tcpdump -i ctrll0 -s 0 -vvvv -e -t"

# TIPC Stuff
alias brt="~/bin/start_tipc.sh"
alias rjenk='env LANGUAGE=en_US LC_ALL=en_US.UTF-8 ./lat2/lat.pl -e virtual-large suites/virsh/virsh_jenkins.yaml'
alias btipc='cd ../../; make M=net/tipc; cd -'

# Build commands
alias ms11="repo; make -j 20 sles11sp3; cd -"
alias ms11c="make -j 20 sles11sp3_clean"
alias ms11ru="make -j 20 sles11sp3_rpms_update"

# Tipc build commands
bimage() {
    make clean && make -j $(nproc) --output-sync=target install
}
export -f bimage
alias binstall="bimage && cd test/ && ~/bin/start_tipc.sh -e medium -ri && cd -"
alias binstmega="bimage && cd test/ && ~/bin/start_tipc.sh -e mega -ri && cd -"
alias bkernel='make -j $(nproc) --output-sync=target kernel-install'
alias birtl="bimage && cd test/ && ~/bin/start_tipc.sh -e large -ri -t suites/all.yaml && cd -"
alias birtm="bimage && cd test/ && ~/bin/start_tipc.sh -e medium -ri -t suites/all.yaml && cd -"

# Virsh 
alias virsh="sudo virsh"
virsh_destroy() {
	for((a=1; a<=$1; a++))
	do
		virsh destroy "tipc-$2-node$a"
	done
}

alias des_mega="virsh_destroy 16 mega"
alias des_large="virsh_destroy 8 large"
alias des_medium="virsh_destroy 4 medium"
alias des_small="virsh_destroy 2 small"
alias vcs1="virsh console tipc-small-node1"
alias vcs2="virsh console tipc-small-node2"
alias vcl1="virsh console tipc-large-node1"
alias vcl2="virsh console tipc-large-node2"

# Alias for searching alias functions
alias func="grep \"()\" ~/.bash_aliases | grep -v func | cut -d\"(\" -f1"

alias oscdir='cd /home/qparbhu/osc/home:qparbhu:branches:home:ericalp/tipc'


alias conv_srec="srec_cat pmbtable.bin -binary  -offset=0x78DE0000 -o pmbtable10.srec -motorola -obs=10 -enable=footer -execution-start-address=0 -header=\"HDR\""

alias gfile="nautilus –no-desktop"
alias csbuild='find $PWD -name "*.[ch]" -print > ./cscope.files ; cscope -bq'
alias cskbuild="rm -f cscope.* && ~/bin/gen_scope.sh"

alias lock="i3lock -d"
alias refresh="sudo apt-get update -qq; sudo apt-get upgrade -qq; sudo apt-get dist-upgrade -qq; echo DONE" 

alias disp_off="xrandr --output eDP1 --off"

function git_alias() {
	git config --list | grep alias
}
export -f git_alias

function _load_crash() {
	if [ $# -ne 2 ]; then
		echo "$0 <small/medium/large> <slot_number>"
		return
	fi

	sudo chmod -R 777 "/tmp/virsh_export/tipc-$1/node$2/"
	sudo chown $USER: "/tmp/virsh_export/tipc-$1/node$2/vmcore"
	~/git/crash/crash ./vmlinux "/tmp/virsh_export/tipc-$1/node$2/vmcore"
}
alias crash_setup=_load_crash

# keyboard language settings : setxkbmap -layout se,us

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

function getcommit() {
	awk 'NR=='"$1"' {print $1}' $2
}

cptftp() {
	if [ $# -ne 2 ]; then
		echo "$0 <slot_begin> <slot_end>"
		return
	fi
    for((a=$1; a<=$2; a++))
    do
        echo "copying boot image for blade$a"
        sudo chmod -R 777 "/srv/tftp/blade$a/"
        cp "build/tftpboot/initramfs.cpio.gz" "/srv/tftp/blade$a/"
        cp "build/tftpboot/vmlinuz" "/srv/tftp/blade$a/"
    done
}
export -f cptftp

alias mon_test="./lat2/lat.pl -e virtual-small suites/virsh/virsh_install.yaml --fatal && ~/monitor_utils/create_namespace.sh && ./lat2/lat.pl -e virtual-small suites/traffic.yaml --fatal"

alias diff_check="git diff HEAD~1 | ~/upstream/lab/linux/scripts/checkpatch.pl --no-tree --strict -"

# nmcli con up uuid 2bb97cc0-eac4-4a56-9b0a-02e09889fbc0 

# nmcli con status 

# nmcli con list 
#
