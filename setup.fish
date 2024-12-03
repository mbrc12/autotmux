#!/usr/bin/fish

if test (count $argv) -gt 1
	echo "Usage: ./setup.fish <config_file> or ./setup.fish"
	echo "If no config file is provided, setup.json will be used."
	exit 1
end

if test (count $argv) -eq 1
	set conf $argv[1]
else
	set conf setup.json
end

if not type -q jq
	echo "jq is required to parse the configuration file."
	exit 1
end

if not test -f $conf
	echo "Configuration file $conf not found."
	exit 1
end

if not type -q tmux
	echo "tmux is required to create the session."
	exit 1
end

set session_name (jq -r ".name" $conf)
if tmux kill-session -t $session_name
	echo "Session $session_name found and killed."
else
	echo "Session $session_name not found."
end

if tmux new -s $session_name -d
	echo "Session $session_name created."
else
	echo "Failed to create session $session_name."
	exit 1
end

set current_dir (pwd)

echo "Current directory: $current_dir"

tmux send-keys -t $session_name "cd $current_dir" C-m

set n_windows (jq -r ".windows | length" $conf)

for index in (seq 0 (math "$n_windows - 1"))
	echo "Creating window $index ..."

	set window_name (jq -r ".windows[$index].name" $conf)
	tmux new-window -t $session_name -n $window_name

	set n_panes (jq -r ".windows[$index].panes | length" $conf)

	# split n-1 times horizontally
	for i in (seq 2 $n_panes)
		tmux split-window -t $session_name:$window_name -h # split vertically
	end

	for i in (seq 1 $n_panes)
		set pane_index (math "$i - 1")
		set pane_command (jq -r ".windows[$index].panes[$pane_index]" $conf)

		tmux send-keys -t $session_name:$window_name.$pane_index "cd $current_dir" C-m
		tmux send-keys -t $session_name:$window_name.$pane_index "$pane_command" C-m

		echo "Created pane with command $pane_command"
	end

	# select the first pane, or the focused pane if specified
	set focused_pane (jq -r ".windows[$index].focus" $conf)
	if test $focused_pane = "null"
		set focused_pane 0
	end
	tmux select-pane -t $session_name:$window_name.$focused_pane
end

# delete the first window
tmux send-keys -t $session_name:0 "exit" C-m

# select the first window
tmux select-window -t $session_name:0 

# attach to the session using the term command
set tmux_cmd tmux attach -t $session_name
set term_template (jq -r ".term" $conf)
set term_cmd (echo $term_template | sed "s/%/$tmux_cmd/")

echo "Starting terminal with tmux session $session_name with command "
fish -c $term_cmd &; disown
