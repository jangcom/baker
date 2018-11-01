#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use DateTime;
use feature        qw(say);
use File::Basename qw(basename);
use File::Copy     qw(copy);
use Carp           qw(croak);
use constant ARRAY => ref [];
use constant HASH  => ref {};


#
# Outermost lexicals
#
my %prog_info = (
    titl        => basename($0, '.pl'),
    expl        => 'File backup assistant',
    vers        => 'v1.0.0',
    date_last   => '2018-09-12',
    date_first  => '2017-01-02',
    opts        => { # Command options
        tstamp_up_to_d => qr/-dt=d/i,
        no_tstamp      => qr/-dt=none/i,
    },
    auth        => {
        name => 'Jaewoong Jang',
        posi => 'PhD student',
        affi => 'University of Tokyo',
        mail => 'jang.comsci@gmail.com',
    },
    usage       => <<'    END_HEREDOC'
    NAME
        baker - File backup assistant
    SYNOPSIS
        perl baker.pl [-dt=key] file ...
    DESCRIPTION
        Back up files into respective subdirs prefixed by 'bak_'.
    OPTIONS
        -dt=key
            d
                Timestamp reduces from yyyymmdd_hhmm to yyyymmdd.
            none
                Timestamp suppressed.
    EXAMPLES
        perl baker.pl oliver.eps heaviside.dat
        perl baker.pl bateman.ps -dt=d
        perl baker.pl harry_bateman.ps -dt=none
    REQUIREMENTS
        Perl 5
    SEE ALSO
        perl(1)
    AUTHOR
        Jaewoong Jang <jang.comsci@gmail.com>
    COPYRIGHT
        Copyright (c) 2017-2018 Jaewoong Jang
    LICENSE
        This software is available under the MIT license;
        the license information is found in 'LICENSE'.
    END_HEREDOC
);
my %datetimes     = construct_timestamps();
my $tstamp_of_int = $datetimes{ymdhm};


#
# Subroutine calls
#
if (@ARGV) {
    show_front_matter(\%prog_info, 'prog', 'auth');
    validate_argv(\%prog_info, \@ARGV);
    parse_argv();
    baker();
}
elsif (not @ARGV) {
    show_front_matter(\%prog_info, 'usage');
}
pause_shell();


#
# Subroutine definitions
#
sub parse_argv {
    my @_argv = @ARGV;
    
    # If requested, reduce the datetime element.
    foreach (@_argv) {
        # Up to ymd (no hms)
        $tstamp_of_int = $datetimes{ymd}
            if $_ =~ $prog_info{opts}->{tstamp_up_to_d};
        # No timestamp at all
        $tstamp_of_int = $datetimes{none}
            if $_ =~ $prog_info{opts}->{no_tstamp};
    }
}


sub baker {
    my @_argv = @ARGV;
    my($bname, $ext, $fname_new, $subdir);
    my %fname_old_and_new;
    my $lengthiest = 0;
    
    # Define filename elements.
    my $fname_space = '_';
    my $path_delim  = $^O =~ /MSWin/i ? '\\' : '/';
    my $path_of_int = '.';
    my $backup_flag = 'bak'.$fname_space; # Used as the prefix of backup dirs
    
    foreach my $fname_old (@_argv) {
        next if $fname_old eq $prog_info{opts}->{tstamp_up_to_d};
        next if -d $fname_old;
        next if not -e $fname_old;
        
        # Find the lengthiest filename to construct a conversion.
        $lengthiest = $fname_old if length($fname_old) > length($lengthiest);
        
        # Dissociate a filename and define a backup filename.
        ($bname = $fname_old) =~ s/(.*)([.]\w+)$/$1/;
        ($ext   = $fname_old) =~ s/(.*)([.]\w+)$/$2/;
        $fname_new = $bname.($tstamp_of_int ? $fname_space : '').$tstamp_of_int;
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
}


#
# Subroutines from My::Toolset
#
sub show_front_matter {
    my $hash_ref = shift; # Arg 1: To be %_prog_info
    
    #
    # Data type validation and deref: Arg 1
    #
    my $_sub_name = join('::', (caller(0))[0, 3]);
    croak "The 1st arg to [$_sub_name] must be a hash ref!"
        unless ref $hash_ref eq HASH;
    my %_prog_info = %$hash_ref;
    
    # Subroutine optional arguments
    my(
        $is_prog,
        $is_auth,
        $is_usage,
        $is_timestamp,
        $is_no_trailing_blkline,
        $is_no_newline,
        $is_copy,
    );
    my $lead_symb    = '';
    foreach (@_) {
        $is_prog                = 1  if /prog/i;
        $is_auth                = 1  if /auth/i;
        $is_usage               = 1  if /usage/i;
        $is_timestamp           = 1  if /timestamp/i;
        $is_no_trailing_blkline = 1  if /no_trailing_blkline/i;
        $is_no_newline          = 1  if /no_newline/i;
        $is_copy                = 1  if /copy/i;
        # A single non-alphanumeric character
        $lead_symb              = $_ if /^[^a-zA-Z0-9]$/;
    }
    my $newline = $is_no_newline ? "" : "\n";
    
    #
    # Fill in the front matter array.
    #
    my @_fm;
    my $k = 0;
    my $border_len = $lead_symb ? 69 : 70;
    my %borders = (
        '+' => $lead_symb.('+' x $border_len).$newline,
        '*' => $lead_symb.('*' x $border_len).$newline,
    );
    
    # Top rule
    if ($is_prog or $is_auth) {
        $_fm[$k++] = $borders{'+'};
    }
    
    # Program info, except the usage
    if ($is_prog) {
        $_fm[$k++] = sprintf(
            "%s%s %s: %s%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            $_prog_info{titl},
            $_prog_info{vers},
            $_prog_info{expl},
            $newline
        );
        $_fm[$k++] = sprintf(
            "%s%s%s%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            'Last update:'.($is_timestamp ? '  ': ' '),
            $_prog_info{date_last},
            $newline
        );
    }
    
    # Timestamp
    if ($is_timestamp) {
        my %_datetimes = construct_timestamps('-');
        $_fm[$k++] = sprintf(
            "%sCurrent time: %s%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            $_datetimes{ymdhms},
            $newline
        );
    }
    
    # Author info
    if ($is_auth) {
        $_fm[$k++] = $lead_symb.$newline if $is_prog;
        $_fm[$k++] = sprintf(
            "%s%s%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            $_prog_info{auth}{$_},
            $newline
        ) for qw(name posi affi mail);
    }
    
    # Bottom rule
    if ($is_prog or $is_auth) {
        $_fm[$k++] = $borders{'+'};
    }
    
    # Program usage: Leading symbols are not used.
    if ($is_usage) {
        $_fm[$k++] = $newline if $is_prog or $is_auth;
        $_fm[$k++] = $_prog_info{usage};
    }
    
    # Feed a blank line at the end of the front matter.
    if (not $is_no_trailing_blkline) {
        $_fm[$k++] = $newline;
    }
    
    #
    # Print the front matter.
    #
    if ($is_copy) {
        return @_fm;
    }
    elsif (not $is_copy) {
        print for @_fm;
    }
}


sub construct_timestamps {
    # Optional setting for the date component separator
    my $_date_sep  = '';
    
    # Terminate the program if the argument passed
    # is not allowed to be a delimiter.
    my @_delims = ('-', '_');
    if ($_[0]) {
        $_date_sep = $_[0];
        my $is_correct_delim = grep $_date_sep eq $_, @_delims;
        croak "The date delimiter must be one of: [".join(', ', @_delims)."]"
            unless $is_correct_delim;
    }
    
    # Construct and return a datetime hash.
    my $_dt  = DateTime->now(time_zone => 'local');
    my $_ymd = $_dt->ymd($_date_sep);
    my $_hms = $_dt->hms(($_date_sep ? ':' : ''));
    (my $_hm = $_hms) =~ s/[0-9]{2}$//;
    
    my %_datetimes = (
        none   => '', # Used for timestamp suppressing
        ymd    => $_ymd,
        hms    => $_hms,
        hm     => $_hm,
        ymdhms => sprintf("%s%s%s", $_ymd, ($_date_sep ? ' ' : '_'), $_hms),
        ymdhm  => sprintf("%s%s%s", $_ymd, ($_date_sep ? ' ' : '_'), $_hm),
    );
    
    return %_datetimes;
}


sub validate_argv {
    my $hash_ref  = shift; # Arg 1: To be %_prog_info
    my $array_ref = shift; # Arg 2: To be @_argv
    my $num_of_req_argv;   # Arg 3: (Optional) Number of required args
    $num_of_req_argv = shift if defined $_[0];
    
    #
    # Data type validation and deref: Arg 1
    #
    my $_sub_name = join('::', (caller(0))[0, 3]);
    croak "The 1st arg to [$_sub_name] must be a hash ref!"
        unless ref $hash_ref eq HASH;
    my %_prog_info = %$hash_ref;
    
    #
    # Data type validation and deref: Arg 2
    #
    croak "The 2nd arg to [$_sub_name] must be an array ref!"
        unless ref $array_ref eq ARRAY;
    my @_argv = @$array_ref;
    
    #
    # Terminate the program if the number of required arguments passed
    # is not sufficient.
    # (performed only when the 3rd optional argument is given)
    #
    if ($num_of_req_argv) {
        my $num_of_req_argv_passed = grep $_ !~ /-/, @_argv;
        if ($num_of_req_argv_passed < $num_of_req_argv) {
            say $_prog_info{usage};
            say "    | You have input $num_of_req_argv_passed required args,".
                " but we need $num_of_req_argv.";
            say "    | Please refer to the usage above.";
            exit;
        }
    }
    
    #
    # Count the number of correctly passed options.
    #
    
    # Non-fnames
    my $num_of_corr_opts = 0;
    foreach my $arg (@_argv) {
        foreach my $v (values %{$_prog_info{opts}}) {
            if ($arg =~ /$v/i) {
                $num_of_corr_opts++;
                next;
            }
        }
    }
    
    # Fname-likes
    my $num_of_fnames = 0;
    $num_of_fnames = grep $_ !~ /^-/, @_argv;
    $num_of_corr_opts += $num_of_fnames;
    
    # Warn if "no" correct options have been passed.
    if ($num_of_corr_opts == 0) {
        say $_prog_info{usage};
        say "    | None of the command-line options was correct.";
        say "    | Please refer to the usage above.";
        exit;
    }
}


sub pause_shell {
    print "Press enter to exit...";
    while (<STDIN>) { last; }
}
#eof