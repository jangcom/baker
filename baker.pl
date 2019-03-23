#!/usr/bin/perl
use strict;
use warnings;
use autodie;
use utf8;
use feature        qw(say);
use File::Basename qw(basename);
use File::Copy     qw(copy);
use DateTime;
BEGIN { # Runs at compile time
    chomp(my $onedrive_path = `echo %OneDrive%`);
    unless (exists $ENV{PERL5LIB} and -e $ENV{PERL5LIB}) {
        my %lib_paths = (
            cwd      => ".", # @INC's become dotless since v5.26000
            onedrive => "$onedrive_path/cs/langs/perl",
        );
        unshift @INC, "$lib_paths{$_}/lib" for keys %lib_paths;
    }
}
use My::Toolset qw(:coding);


our $VERSION = '1.01';
our $LAST    = '2019-03-23';
our $FIRST   = '2017-01-02';


sub parse_argv {
    # """@ARGV parser"""
    
    my(
        $argv_aref,
        $cmd_opts_href,
        $run_opts_href,
    ) = @_;
    my %cmd_opts = %$cmd_opts_href; # For regexes
    
    foreach (@$argv_aref) {
        # Files to be backed up
        if (-e and not -d) {
            push @{$run_opts_href->{backup_fnames}}, $_;
        }
        
        # Timestamp
        if (/$cmd_opts{timestamp}/) {
            s/$cmd_opts{timestamp}//i;
            $run_opts_href->{timestamp} = $_;
        }
        
        # The front matter won't be displayed at the beginning of the program.
        if (/$cmd_opts{nofm}/) {
            $run_opts_href->{is_nofm} = 1;
        }
        
        # The shell won't be paused at the end of the program.
        if (/$cmd_opts{nopause}/) {
            $run_opts_href->{is_nopause} = 1;
        }
    }
    
    return;
}


sub baker {
    # """Back up the designated files."""
    
    my $run_opts_href = shift;
    my %datetimes     = construct_timestamps();
    my $timestamp_of_int =
        $run_opts_href->{timestamp} =~ /\bdt\b/i   ? $datetimes{ymdhm} :
        $run_opts_href->{timestamp} =~ /\bnone\b/i ? '' :
                                                     $datetimes{ymd};
    
    # Define filename elements.
    my($bname, $ext, $fname_new, $subdir);
    my %fname_old_and_new;
    my $lengthiest  = '';
    my $path_delim  = $^O =~ /MSWin/i ? '\\' : '/';
    my $path_of_int = '.';
    my $backup_flag = 'bak_'; # Used as the prefix of backup dirs
    
    foreach my $fname_old (@{$run_opts_href->{backup_fnames}}) {
        # Find the lengthiest filename to construct a conversion.
        $lengthiest = $fname_old if length($fname_old) > length($lengthiest);
        
        # Dissociate a filename and define a backup filename.
        ($bname = $fname_old) =~ s/(.*)([.]\w+)$/$1/;
        ($ext   = $fname_old) =~ s/(.*)([.]\w+)$/$2/;
        $fname_new = $bname.($timestamp_of_int ? '_' : '').$timestamp_of_int;
        $fname_new = $fname_new.$ext if $ext ne $fname_old;
        
        # Buffer the old and new fnames as key-val pairs.
        $subdir = $path_of_int.$path_delim.$backup_flag.$fname_old;
        $fname_old_and_new{$fname_old} = [
            $subdir,
            $subdir.$path_delim.$fname_new,
        ];
    }
    
    # Back up the designated files following displaying.
    if (%fname_old_and_new) {
        say '-' x 70;
        my $conv = '%-'.length($lengthiest).'s';
        while (my($k, $v) = each %fname_old_and_new) {
            printf("$conv => %s\n", $k, $v->[1]);
            mkdir $v->[0] if not -e $v->[0];
            copy($k, $v->[1]);
        }
        say '-' x 70;
    }
    print %fname_old_and_new ?
        "Backing up completed. " :
        "None of the designated files found in [$path_of_int$path_delim].\n";
    
    return;
}


sub baker_outer {
    if (@ARGV) {
        my %prog_info = (
            titl        => basename($0, '.pl'),
            expl        => 'File backup assistant',
            vers        => $VERSION,
            date_last   => $LAST,
            date_first  => $FIRST,
            auth        => {
                name => 'Jaewoong Jang',
                posi => 'PhD student',
                affi => 'University of Tokyo',
                mail => 'jan9@korea.ac.kr',
            },
        );
        my %cmd_opts = ( # Command-line opts
            timestamp => qr/-?-(?:timestamp|ts|dt)\s*=\s*/i, # dt: legacy
            nofm      => qr/-?-nofm/i,
            nopause   => qr/-?-nopause/i,
        );
        my %run_opts = ( # Program run opts
            backup_fnames => [],
            timestamp     => 'd', # d, dt, none
            is_nofm       => 0,
            is_nopause    => 0,
        );
        
        # ARGV validation and parsing
        validate_argv(\@ARGV, \%cmd_opts);
        parse_argv(\@ARGV, \%cmd_opts, \%run_opts);
        
        # Notification - beginning
        show_front_matter(\%prog_info, 'prog', 'auth', 'no_trailing_blkline')
            unless $run_opts{is_nofm};
        
        # Main
        baker(\%run_opts);
        
        # Notification - end
        pause_shell() unless $run_opts{is_nopause};
    }
    
    system("perldoc \"$0\"") if not @ARGV;
    
    return;
}


baker_outer();
__END__

=head1 NAME

baker - File backup assistant

=head1 SYNOPSIS

    perl baker.pl [file ...] [-timestamp=key]

=head1 DESCRIPTION

Back up files into respective subdirs prefixed by 'bak_'.

=head1 OPTIONS

    -timestamp=key (short term: -ts)
        d (default)
            Timestamp up to yyyymmdd
        dt
            Timestamp up to yyyymmdd_hhmm
        none
            No timestamp

=head1 EXAMPLES

    perl baker.pl oliver.eps heaviside.dat
    perl baker.pl bateman.ps -ts=d
    perl baker.pl harry_bateman.ps -ts=none

=head1 REQUIREMENTS

Perl 5

=head1 AUTHOR

Jaewoong Jang <jan9@korea.ac.kr>

=head1 COPYRIGHT

Copyright (c) 2017-2019 Jaewoong Jang

=head1 LICENSE

This software is available under the MIT license;
the license information is found in 'LICENSE'.

=cut
