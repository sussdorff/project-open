#!/usr/bin/perl -w

# --------------------------------------------------------
#
# install-updates.perl
#
# ]project-open[ Project management System
# (c) 2008 - 2016 ]project-open[
# frank.bergmann@project-open.com
#
# --------------------------------------------------------

use strict;
use Getopt::Long;
use File::Copy qw(copy);

# --------------------------------------------------------
# Debug and other parameters
#
my $debug = 1;					# 0=no output, 10=very verbose
my $no_create = 0;
my $delete = 0;

my $this_script = "install-upgrades.perl";
my $package_dir = "/var/www/openacs/packages";			# By default packages are located in ~/packages/
my $this_package = "upgrade-5.0-5.3";		# Name of this upgrade package


# --------------------------------------------------------
# Check for command line options
#
my $result = GetOptions (
    "debug=i"    => \$debug,
    "no-create"  => \$no_create,
    "delete"     => \$delete
    ) or die "Usage:\n\nthis_script --debug 3 --no-create\n\n";


# --------------------------------------------------------
# 
#

# Get the list of all subdirectories in this package
open(FILES, "find $package_dir/$this_package/ -name 'upgrade-*.sql'| ");

# Loop through included files
my $cnt = 0;
while (my $file=<FILES>) {
    # Remove trailing "\n"
    chomp($file);
    my @file_parts = split("/", $file);
    my $upgrade_body = pop @file_parts;
    my $upgrade_package = pop @file_parts;
    pop @file_parts;
    my $full_package_dir = join("/", @file_parts);

    print "$this_script: file_parts=@file_parts\n" if ($debug > 9);
    print "$this_script: upgrade_body=$upgrade_body\n" if ($debug > 5);
    print "$this_script: upgrade_package=$upgrade_package\n" if ($debug > 5);

    # Skip if the package isn't installed
    next if (!-d "$full_package_dir/$upgrade_package");

    my $dest_folder = "$full_package_dir/$upgrade_package/sql/postgresql/upgrade";
    my $dest_file = "$dest_folder/$upgrade_body";
    print "$this_script: Copy $upgrade_package/$upgrade_body -> $dest_file\n" if ($debug eq 3);
    if ($no_create < 1) {
	mkdir $dest_folder;
	if ($delete < 1) { 
	    print "$this_script: Copy $upgrade_package/$upgrade_body\n" if ($debug eq 2);
	    copy $file, $dest_file or
		die "$this_script: Unable to copy\nfile\t$file\nto\t$dest_file\n\t$!\n";
	} else {
	    unlink $dest_file; 
	}
	$cnt++;
    }
}

if ($delete < 1) {
    print "$this_script: Successfully installed $cnt upgrade files.\n" if ($debug > 0);
} else {
    print "$this_script: Deleted $cnt files.\n" if ($debug > 0);
}

close(FILES);
exit(0);
