#!/usr/bin/perl
use strict;
use warnings;

# --- Subroutines to get system info ---

sub get_hostname {
    # Run the 'hostname' command and capture its output using backticks
    my $hostname = `hostname`;
    chomp($hostname); # Remove the trailing newline from the command output
    return $hostname;
}

sub get_uptime_and_load {
    my $uptime_output = `uptime`;
    
    # Use a regular expression to parse the uptime output
    # Example: "up 2 days,  1:15,  load average: 0.01, 0.02, 0.00"
    if ($uptime_output =~ /up\s+(.+?),\s+.+load average:\s+(.*)/) {
        my $uptime_str = $1;
        my $load_avg   = $2;
        return ($uptime_str, $load_avg);
    }
    return ("Unknown", "Unknown");
}

sub get_disk_usage {
    # Get info for the root filesystem "/" only.
    my $disk_output = `df -h /`;
    
    # Split the output into lines
    my @lines = split /\n/, $disk_output;
    
    # The data is on the second line (index 1). Split it by spaces.
    my @fields = split /\s+/, $lines[1];
    
    # [1]=Total, [2]=Used, [3]=Avail, [4]=Percent
    my ($total, $used, $available, $percent) = ($fields[1], $fields[2], $fields[3], $fields[4]);
    return ($total, $used, $available, $percent);
}

sub get_memory_usage {
    # Run 'free -m' to get values in megabytes (easier to parse)
    my $mem_output = `free -m`;
    my @lines = split /\n/, $mem_output;
    
    # The main memory info is the second line (index 1)
    # Example: "Mem:   3919    849     2354    16      715     2807"
    if ($lines[1] =~ /^Mem:\s+(\d+)\s+(\d+)\s+(\d+)/) {
        my ($total_mb, $used_mb) = ($1, $2);
        
        # Calculate a simple percentage
        my $percent_used = int(($used_mb / $total_mb) * 100);
        return ($total_mb, $used_mb, $percent_used);
    }
    return ("N/A", "N/A", "N/A");
}

# --- Main Script ---

print "--- System Vitals Report ---\n\n";

# Call our functions to get the data
my $hostname = get_hostname();
my ($uptime, $load) = get_uptime_and_load();
my ($disk_total, $disk_used, $disk_avail, $disk_percent) = get_disk_usage();
my ($mem_total, $mem_used, $mem_percent) = get_memory_usage();

# Print the formatted report using printf for nice alignment
printf "Hostname      : %s\n", $hostname;
printf "Server Uptime : %s\n", $uptime;
printf "Load Average  : %s\n\n", $load;

printf "Root Disk     : %s used of %s total (%s)\n", $disk_used, $disk_total, $disk_percent;
printf "Memory        : %d MB used of %d MB total (%d%%)\n", $mem_used, $mem_total, $mem_percent;

print "\n------------------------------\n";
