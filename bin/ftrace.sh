#!/bin/bash -e

if [ $# -lt 1 ]; then
	echo "$0 <command>"
	exit
fi

SYS="/sys/kernel/debug/tracing"
ROOT="/root"
CMD="$@"

rm -rf /media/webtv/offs-test*

reset_trace() {
	:> $SYS/trace
	echo 0 > $SYS/tracing_on
}

set_filters() {
	echo ':mod:offs*' > $SYS/set_ftrace_filter
#	echo PoolGetBuf >> $SYS/set_ftrace_filter
#	echo FlashPoolBufPipe >> $SYS/set_ftrace_filter
#	echo flio_write_poolbuf >> $SYS/set_ftrace_filter
}

enable_stacktrace() {
	echo function_graph > $SYS/current_tracer
#	echo function > $SYS/current_tracer
#	echo stacktrace > $SYS/trace_options
#	echo func_stack_trace > $SYS/trace_options
}

do_ftrace() {
	reset_trace
	set_filters
	enable_stacktrace

	echo $BASHPID > $SYS/set_ftrace_pid
	echo 1 > $SYS/tracing_on
	echo "$CMD"
	exec $CMD
}

export SYS
export ROOT
export CMD
export -f do_ftrace

(do_ftrace)
wait

cat $SYS/trace > $ROOT/trace_$$.txt
vi $ROOT/trace_$$.txt
