#!/bin/sh -e
################################################################################
# Simple harness using the GNU parallel command to run simulations in parallel.
################################################################################

COMMAND=./diffusion_simulation.py

# Print usage information.
if [ -z "$5" ]; then
  echo "Usage: $0 t_min t_step t_max iterations input_file1.txt [input_file2.txt ...]"
  echo "Example: $0 0.00 0.02 0.40 100 network.snap.txt SampleRndGraph.txt"
  exit 1
fi

# Unique identifier for this run. Included in all file names.
# It's just the start timestamp plus the PID of the runner process.
TAG="$(date +'%Y%m%d.%H%M%S')-$$"

COMMANDS_LIST=commands-$TAG.list

# Print the start time.
echo "[ $(date) ] Starting..."

t_min=$1; shift
t_step=$1; shift
t_max=$1; shift
iterations=$1; shift

# T values.
t_values=$(seq $t_min $t_step $t_max)

# Generate commands list file
# Example line: ./diffusion_simulation.py network.snap.txt 0.05 2 infected-0.05.out
echo "Generating $COMMANDS_LIST file..."
> $COMMANDS_LIST # Clear file contents.
for input_file in $*; do
  for t in $t_values; do
    echo "$COMMAND $input_file $t $iterations infected-$TAG-$input_file-$t.dat" >> $COMMANDS_LIST
  done
done

echo "Contents of the $COMMANDS_LIST file:"
echo ================================================================================
cat $COMMANDS_LIST
echo ================================================================================
echo

# Now, run the simulation.
echo "[ $(date) ] Running the simulation..."
time parallel -j -1 -t --eta --halt-on-error 2 -a $COMMANDS_LIST

STATS_FILE=summary-infected-$TAG.dat
IMAGE_FILE=infected-$TAG.pdf
cat infected-$TAG*.dat | grep -v "^#" | sort -n > $STATS_FILE

echo "Plotting the simulation..."
./plot_simulation.py $STATS_FILE $IMAGE_FILE

echo "[ $(date) ] Done!"

exit 0
