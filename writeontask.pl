#!/usr/bin/env perl
use strict;
use Time::HiRes qw(clock_gettime CLOCK_MONOTONIC);
use JSON::PP qw(encode_json decode_json);
use Getopt::Long;
use Cwd qw(abs_path);
use File::Spec;




my $hme = $ENV{'HOME'};

my $wordspermin;
my $wordgoal = 0;
my $actugoal;
my $curncount;
my $attime;
my $comdir;
my $next_crio;
my $lastcaff; # When did we last caffeinate?
my @mesgs;
my $origin_time; # Unchanging record of when daemon started or last thawed
my $this_daemon_id; # Safe process-ID to register daemon process as

my $caff_a;
my $caff_b;
$caff_a = 200; $caff_b = 250;
$caff_a = 50; $caff_b = 90;

my $maxbehind = 500;
my $the_main_loop = 1;
my $soundfile; # Sound to be played when you are behind
$wordspermin = 10;

my $pause_on = 0;
my $pause_at;

my $headstart = 20;

my $criothaw = 0;


GetOptions(
    'help|h' => sub {
        print while <DATA>;
        exit 0;
    },
    'crio|c' => sub { $criothaw = 1; },
    'head|t=i'   => \$headstart,
    'wpm|w=f'    => \$wordspermin,
    'max=i'    => \$maxbehind,
    'msg|m=s' => sub {
        my ($name, @values) = @_;
        push @mesgs, \@values;
    },
    'addfile|a=s' => sub {
        my ($name, $file) = @_;
        push @mesgs, ["addfile:" . best_file_path($file)];
    },
    'cutfile|x=s' => sub {
        my ($name, $file) = @_;
        push @mesgs, ["cutfile:" . best_file_path($file)];
    },
) or die "Tye `writeontask --help` or `writeontask-util --help`\n  for proper usage.\n";


$comdir = shift(@ARGV);
$soundfile = shift @ARGV;

my $tot_time = $headstart;      # Total of unpaused time
my $actu_tot_time = $headstart; # Total of ALL time

$maxbehind > 0 or die "--max must be a positive integer\n";
$wordspermin >= 0 or die "--wpm must be a non-negative number\n";
$headstart >= 0 or die "--head must be a non-negative integer\n";

if ( system('mkdir','-p',$comdir) != 0 )
{
  die(
    "Failed to create communications directory:\n: "
     . $comdir . " :\n"
  );
}

if ( system('chmod','0700',$comdir) != 0 )
{
  die(
    "Failed to secure communications directory:\n: "
     . $comdir . " :\n"
  );
}

if ( @mesgs )
{
  my $lc_meg;
  my $lc_za;
  my $lc_zb;
  my $lc_repf;
  my $lc_cm;
  
  $lc_za = time();
  $lc_zb = 0;
  foreach $lc_meg (@mesgs)
  {
    $lc_zb = int($lc_zb + 1.2);
    $lc_repf = $comdir . '/mesg-' . $lc_za . '-' . $lc_zb . '.txt';
    $lc_cm = shell_qt('echo',(':' . $lc_meg->[0] . ':'));
    $lc_cm .= ' > ' . &shell_qt($lc_repf);
    system($lc_cm);
  }
  exit(0);
}

&force_caff();


daemon_register();

my @fileset;
@fileset = ();
{
  my $lc_a;
  foreach $lc_a (@ARGV)
  {
    resp_add_file($lc_a);
  }
}

$wordgoal = word_count(@fileset);
$actugoal = $wordgoal;
$curncount = $wordgoal;
$origin_time = agtm();
$attime = $origin_time + $headstart;
if ( $criothaw ) { thaw_criogenum(); }
frc_make_criogenum({'clean' => 0,});
while ( $the_main_loop )
{
  daemon_verify();
  ford_pause();
  alg_gendaround();
  readmesg();
  oky_make_criogenum({'clean' => 0,});
}
frc_make_criogenum({'clean' => 1,});

sub alg_gendaround {
  my $lc_now;
  my $lc_elps;
  my $lc_true_total;
  my $lc_fl_true_total;
  #my $lc_wordgoal;
  #my $lc_wordnow;
  my $lc_min_ahd;
  my $lc_sec_ahd;
  
  docaff(); # DON'T FALL ASLEEP ON THE JOB
  
  $lc_now = agtm();
  $lc_elps = ( $lc_now - $attime );
  $actugoal = $wordgoal + ( $wordspermin * $lc_elps / 60 );
  $curncount = word_count(@fileset);
  $lc_true_total = ( $tot_time + $lc_elps );
  $lc_fl_true_total = ( $actu_tot_time + $lc_elps );
  
  if ( $lc_elps > 30.5 )
  {
    $tot_time += $lc_elps;
    $actu_tot_time += $lc_elps;
    $attime = $lc_now;
    $wordgoal = $actugoal;
  }
  
  if ( $actugoal > $curncount )
  {
    my $lc2_wordsbhind;
    my $lc2_loudy;
    my $lc2_cm;
    $lc2_wordsbhind = ( $actugoal - $curncount );
    $lc2_loudy = ( $lc2_wordsbhind / $maxbehind );
    if ( $lc2_loudy > 1 ) { $lc2_loudy = 1; }
    
    
    print make_decimal($lc2_wordsbhind) . ' WORDS BEHIND: ';
    print '[' . $curncount . ' @ ' . $wordspermin . 'wpm] ';
    
    print ' VOLUME: ' . $lc2_loudy;
    print ' ' . secs_to_hms($lc_true_total);
    print '/' . secs_to_hms($lc_fl_true_total);
    
    print " :\n";
    
    $lc2_cm = shell_qt('writeontask-afplay',$soundfile,'-v',$lc2_loudy);
    $lc2_cm .= ' &bg;';
    $lc2_cm = '( ' . $lc2_cm . ' ) > /dev/null 2> /dev/null';
    
    system($lc2_cm);
    
    sleep(3); return;
  }
  
  print make_decimal(( $curncount - $actugoal )) . ' WAh: ';
  print '[' . $curncount . ' @ ' . $wordspermin . 'wpm] ';
  print ' ' . secs_to_hms($lc_true_total);
  print '/' . secs_to_hms($lc_fl_true_total);

  if ( $wordspermin > 0 )
  {
    $lc_min_ahd = (( $curncount - $actugoal ) / $wordspermin);
    $lc_sec_ahd = int(($lc_min_ahd * 60)+ 0.5);
    print ' (' . secs_to_hms($lc_sec_ahd) . ' ahd)';
  } else {
    print ' (no countdown)';
  }
  
  print " :\n";
  
  sleep(5);
}


exit(0);
##############

# ############################################## #
# ##  SPECIALIZED MESSAGE RESPONSE FUNCTIONS  ## #
# ############################################## #
# These functions are implementations of one-step responses
# to specific in-flight messages.

sub resp_cut_file {
    my ($file) = @_;

    $file = best_file_path($file);

    for (my $i = 0; $i < @fileset; $i++) {
        if (the_same_file($file, $fileset[$i])) {
            my $lc3_exfile;
            $wordgoal -= word_count($fileset[$i]);
            $lc3_exfile = $fileset[$i];
            splice(@fileset, $i, 1);
            print "SUCCESS: File Removed from Monitor List:\n";
            print "    File: " . $file . " :\n";
            print "      As: " . $lc3_exfile . " :\n";
            frc_make_criogenum({'clean' => 0,});
            return 1;
        }
    }
    
    print "NO SUCH FILE FOUND ON MONITOR LIST AND\n  THUS COULD NOT BE REMOVED:\n";
    print "    File: " . $file . " :\n";

    return 0;
}

sub resp_change_wpm {
  my $lc_val; # Requested new WPM

  $lc_val = $_[0];

  # Reject anything that isn't numeric.
  if ( $lc_val !~ /\A[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?\z/ )
  {
    print "WPM change rejected: '$lc_val' is not a valid number.\n";
    return;
  }

  # Negative WPM is not permitted.
  if ( $lc_val < 0 )
  {
    print "WPM change rejected: " . $lc_val . " is negative; remaining at " . $wordspermin . " WPM.\n";
    return;
  }

  # Account for elapsed time at the old WPM.
  frc_update_progress();

  # Apply the new WPM.
  $wordspermin = $lc_val;
  print "Words perminute adjusted to: " . $wordspermin . " :\n";
  frc_make_criogenum({'clean' => 0,});
}

sub resp_do_sort {
  # The argument is a reference to a comparison function.
  # Rearrange the monitored files using that function, then
  # immediately preserve the new order in the criogenum.

  my $lc_compare = $_[0];

  @fileset = sort { $lc_compare->($a,$b) } @fileset;
  frc_make_criogenum({'clean' => 0,});
  print "SUCCESS: Monitor list sorted.\n";
  return 1;
}


sub resp_list_files {
  my $lc_slpr = $_[0];
  my $lc_each;
  foreach $lc_each (@fileset)
  {
    print ": " . word_count($lc_each) . ' : ' . $lc_each . " :\n";
  }
  docaff();
  while ( $lc_slpr > 5.5 )
  {
    sleep(5);
    $lc_slpr = int($lc_slpr - 4.8);
    docaff();
  }
  if ( $lc_slpr > 0.5 )
  {
    sleep($lc_slpr);
    docaff();
  }
  return 1;
}

# ##################################### #
# ##  FILENAME COMPARISON FUNCTIONS  ## #
# ##################################### #
# Each of these functions compares two filenames -- generally
# complete pathnames.


sub compare_fnom_alph {
  # Compare two complete pathnames alphabetically.
  # The comparison is case-sensitive.

  return $_[0] cmp $_[1];
}

sub compare_fnom_nat {
  # Compare two complete pathnames using natural sorting.
  # Consecutive ASCII digits are compared numerically,
  # while other characters are compared alphabetically.
  # Original pathname spelling breaks otherwise equal ties.

  my $lc_a = $_[0];
  my $lc_b = $_[1];
  my $lc_token_a;
  my $lc_token_b;
  my $lc_cmp;

  # Compare successive tokens until one pathname ends
  # or a difference is found.
  while ( ( $lc_a ne '' ) && ( $lc_b ne '' ) )
  {
    $lc_token_a = extract_nat_token(\$lc_a);
    $lc_token_b = extract_nat_token(\$lc_b);

    # Compare numerically when both tokens are numbers.
    if ( ( $lc_token_a =~ /^[0-9]/ ) && ( $lc_token_b =~ /^[0-9]/ ) )
    {
      $lc_cmp = compare_numbers_nat($lc_token_a,$lc_token_b);
    } else {
      $lc_cmp = $lc_token_a cmp $lc_token_b;
    }

    if ( $lc_cmp != 0 ) { return $lc_cmp; }
  }

  # A pathname that ends first sorts before one that
  # still has characters remaining.
  if ( $lc_a ne $lc_b ) { return $lc_a cmp $lc_b; }

  # Break ties caused by different spellings of equal
  # numeric values, such as 02 versus 2.
  return $_[0] cmp $_[1];
}

sub compare_numbers_nat {
  # Compare two strings containing only ASCII digits.
  # Treat them as nonnegative integers, without converting
  # them to Perl numbers, thus avoiding integer overflow.
  # Leading zeroes do not affect the comparison.

  my $lc_num_a = $_[0];
  my $lc_num_b = $_[1];
  my $lc_cmp;

  # Remove leading zeroes.
  $lc_num_a =~ s/^0+//;
  $lc_num_b =~ s/^0+//;

  # Account for numbers consisting entirely of zeroes.
  if ( $lc_num_a eq '' ) { $lc_num_a = '0'; }
  if ( $lc_num_b eq '' ) { $lc_num_b = '0'; }

  # The longer normalized number is the larger one.
  $lc_cmp = length($lc_num_a) <=> length($lc_num_b);
  if ( $lc_cmp != 0 ) { return $lc_cmp; }

  # Equal-length numbers can be compared lexically.
  return $lc_num_a cmp $lc_num_b;
}


# ###################################### #
# ##  LIBRARY INDEPENDENCE FUNCTIONS  ## #
# ###################################### #

sub shell_qt {
  my $lc_ret;
  my $lc_ech;
  
  $lc_ret = ' ';
  foreach $lc_ech (@_)
  {
    $lc_ret .= ( _shell_quote($lc_ech) . ' ' );
  }
  return $lc_ret;
}

sub _shell_quote {
  my $lc_strg;
  ($lc_strg) = @_;
  return "''" if !defined($lc_strg) || $lc_strg eq '';
  $lc_strg =~ s/'/'"'"'/g;
  return "'$lc_strg'";
}


# #################################### #
# ##  MISCELANEUS HELPER FUNCTIONS  ## #
# #################################### #


sub daemon_register {
  my $lc_outp;
  
  # First, we get the regular process-ID:
  $this_daemon_id = $$;
  
  # Now we register everything:
  open $lc_outp, '>', ($comdir . '/current-process.dat');
  print {$lc_outp} ( 'xxx:' . $this_daemon_id . ":xxx\n" );
  close $lc_outp;
  
  # And we're done!!!!!
  return;
}


sub daemon_verify {
  my $lc_inp;
  my $lc_text;
  my $lc_junk;
  my $lc_regid;
  
  # Read the registration:
  $lc_text = '';
  if ( open $lc_inp, '<', ($comdir . '/current-process.dat') )
  {
    local $/;
    $lc_text = <$lc_inp>;
    close $lc_inp;
  }
  
  # The registered process-ID is whatever lies between
  # the first and second colons:
  ($lc_junk,$lc_regid) = split(/:/,$lc_text,3);
  if ( ! defined($lc_regid) )
  {
    $lc_regid = '';
  }
  
  # If we're no longer the registered daemon, die immediately.
  # In particular, do NOT create a criogenum.
  if ( $lc_regid ne $this_daemon_id )
  {
    die "\nThis daemon is no longer the registered process.\n\n";
  }
  
  return;
}


sub extract_nat_token {
  # The argument is a reference to the unprocessed portion
  # of a pathname.
  # Extract and return either a consecutive sequence of
  # ASCII digits or one non-digit character.
  # Remove the extracted token from the supplied string.
  # Return undef if the string is already exhausted.

  my $lc_remain = $_[0];
  my $lc_token;

  if ( $$lc_remain eq '' ) { return undef; }

  $$lc_remain =~ s/^([0-9]+|[^0-9])//;
  $lc_token = $1;

  return $lc_token;
}



sub frc_update_progress {
  # This function updates the progress variables for the
  # time progression --- regardless of whether the minimum
  # elapsed time has arrived.
  
  my $lc_now; # The current moment
  my $lc_elps; # Time elapsed since the last update
  
  # Make sure this doesn't collide with pauses:
  ford_pause();
  
  $lc_now = agtm();
  $lc_elps = ( $lc_now - $attime );
  
  # Now we don't want this to affect the initial head-start
  # time.
  if ( $lc_elps < 0 ) { return; }
  
  # And we now calculate the actual goal before the rest
  # of the update
  $actugoal = $wordgoal + ( $wordspermin * $lc_elps / 60 );
  
  # And now for the heart of the update
  $tot_time += $lc_elps;
  $attime = $lc_now;
  $wordgoal = $actugoal;
}



sub raw_get_mappair {
  return [ time(), agtm() ];
}

sub oky_make_criogenum {
  if ( agtm() < $next_crio ) { return; }
  return frc_make_criogenum(@_);
}

sub frc_make_criogenum {
  my $lc_crgh;
  my $lc_crgj;
  my $lc_outst;
  my $lc_inf;
  
  $lc_inf = $_[0];
  
  $lc_crgh = {
    'map' => raw_get_mappair(),
    'pause_on' => $pause_on,
    'pause_at' => $pause_at, # TSTMP
    'tot_time' => $tot_time,
    'actu_tot_time' => $actu_tot_time,
    'fileset' => [@fileset],
    'wordspermin' => $wordspermin,
    'wordgoal' => $wordgoal,
    'attime' => $attime, # TSTMP
    'clean' => $lc_inf->{'clean'},
  };
  $lc_crgj = encode_json($lc_crgh);
  
  daemon_verify();
  
  open $lc_outst, '>', ($comdir . '/criogen.json');
  print {$lc_outst} $lc_crgj;
  close $lc_outst;
  
  {
    my $lc2_now; # Current moment
    my $lc2_elps; # Elapsation since last startup/thaw
    my $lc2_max; # Maximum seconds demanded between criogena
    my $lc2_exten; # Actual seconds demanded for next criogenum
    
    $lc2_now = $lc_crgh->{'map'}->[1];
    $lc2_elps = ( $lc2_now - $origin_time );
    $lc2_max = ( 30 * 60 );
    $lc2_exten = int(($lc2_elps / 5) + 4.2);
    if ( $lc2_exten > $lc2_max ) { $lc2_exten = $lc2_max; }
    $next_crio = int($lc2_now + $lc2_exten + 0.2);
  }
}

sub thaw_criogenum {
  my $lc_jstrg;
  my $lc_instr;
  my $lc_jdata;
  my $lc_jsfail;
  my $lc_mappair;
  my $lc_mapn; # New Map
  my $lc_mapo; # Old Map
  my $lc_ogmn; # Augmentation variable
  
  # Get the JSON string
  $lc_jstrg = '';
  if ( open $lc_instr, '<', ($comdir . '/criogen.json') )
  {
    local $/;
    $lc_jstrg = <$lc_instr>;
    close $lc_instr;
  }
  
  $lc_jsfail = 1;
  eval {
    $lc_jdata = decode_json($lc_jstrg);
    $lc_jsfail = 0;
  };
  if ( $lc_jsfail )
  {
    die "\nFailed to thaw a criogenum.\n\n";
  }
  
  if ( ref($lc_jdata) ne 'HASH' ) { die "\nWrong format for criogenum.\n\n"; }
  $lc_mapn = raw_get_mappair();
  $lc_mapo = $lc_jdata->{'map'};
  
  # Find the time-shift
  #$lc_ogmn = ($lc_mapn->[1] - $lc_mapo->[1]);
  #if ( !($lc_jdata->{'clean'}) ) { $lc_ogmn -= ( $lc_mapn->[0] - $lc_mapn->[0] ); }
  $lc_ogmn = 0;
  if ( $lc_jdata->{'clean'} )
  {
    $lc_ogmn = $lc_mapn->[1] - $lc_mapo->[1];
  }
  else
  {
    $lc_ogmn =
        ($lc_mapn->[1] - $lc_mapo->[1])
      - ($lc_mapn->[0] - $lc_mapo->[0])
    ;
  }
  
  # Unload the thawed thing
  $pause_on = $lc_jdata->{'pause_on'};
  $pause_at = $lc_jdata->{'pause_at'};
  $tot_time = $lc_jdata->{'tot_time'};
  $actu_tot_time = $lc_jdata->{'actu_tot_time'};
  $wordspermin = $lc_jdata->{'wordspermin'};
  $wordgoal = $lc_jdata->{'wordgoal'};
  $attime = $lc_jdata->{'attime'};
  @fileset = @{ $lc_jdata->{'fileset'} };
  
  # Apply the time-shift:
  $attime += $lc_ogmn;
  if ( $pause_on ) { $pause_at += $lc_ogmn; }
  
  # A few more things:
  $actugoal = $wordgoal;
  $curncount = $wordgoal;
}


sub resp_add_file {
    my ($file) = @_;

    $file = best_file_path($file);

    foreach my $existing (@fileset) {
        if ( the_same_file($file, $existing) )
        {
          print "REDUNDANT FILE WILL NOT BE ADDED TO MONITOR LIST:\n";
          print "       Exists: " . $existing . " :\n";
          print "    Redundant: " . $file . " :\n";
          return 0;
        }
    }

    $wordgoal += word_count($file);
    push @fileset, $file;

    print "SUCCESS: File Added to Monitor List:\n";
    print "    File: " . $file . " :\n";
    
    frc_make_criogenum({'clean' => 0,});

    return 1;
}





sub best_file_path {
    my ($file) = @_;

    if (-e $file) {
        return abs_path($file);
    }

    return File::Spec->rel2abs($file);
}


sub the_same_file {
    my ($a, $b) = @_;

    if (-e $a && -e $b) {
        my @sa = stat($a);
        my @sb = stat($b);

        return 1 if @sa && @sb
                 && $sa[0] == $sb[0]   # device
                 && $sa[1] == $sb[1];  # inode
    }

    return best_file_path($a) eq best_file_path($b) ? 1 : 0;
}


sub secs_to_hms {
    my $secs = int($_[0]);

    my $hours = int($secs / 3600);
    $secs %= 3600;

    my $mins = int($secs / 60);
    $secs %= 60;

    return sprintf('%02d:%02d:%02d', $hours, $mins, $secs);
}



sub make_decimal {
    return sprintf('%.2f', $_[0]);
}

sub readmesg {
  my $lc_cm;
  my $lc_glob;
  my @lc_allfl;
  my $lc_file;
  my $lc_dfile;
  my $lc_junk;
  my $lc_nom;
  my $lc_val;
  
  $lc_cm = '( ' . shell_qt('cd',$comdir) . ' && ls -1d mesg-*.txt ) 2> /dev/null';
  $lc_glob = `$lc_cm`;
  @lc_allfl = split(/\n/,$lc_glob);
  foreach $lc_file (@lc_allfl)
  {
    $lc_dfile = $comdir . '/' . $lc_file;
    if ( -f $lc_dfile )
    {
      docaff();
      sleep(2);
      $lc_cm = shell_qt('cat',$lc_dfile);
      $lc_glob = `$lc_cm`;
      system('rm','-rf',$lc_dfile);
      
      $lc_glob = cleanse_final_colon($lc_glob);
      $lc_glob =~ s/^://;
      $lc_glob =~ s/:$//;
      ($lc_nom, $lc_val) = split(/:/, $lc_glob, 2);
      $lc_val = '' unless defined $lc_val;
      
      this_one_mesg($lc_nom, $lc_val);
    }
  }
}

sub cleanse_final_colon {
    my ($text) = @_;

    my $colon_count = ($text =~ tr/:/:/);
    return '' if $colon_count < 2;

    my $pos = rindex($text, ':');
    return substr($text, 0, $pos + 1);
}


sub ford_pause {
  my $lc_now;
  my $lc_elps;

  if ( ! ($pause_on) ) { return; }
  
  $lc_now = agtm();
  $lc_elps = ( $lc_now - $pause_at );
  if ( $lc_elps < 0.5 ) { return; }
  
  $attime = int( $attime + $lc_elps + 0.2 );
  $actu_tot_time = int( $actu_tot_time + $lc_elps + 0.2 );
  $pause_at = $lc_now;
}

sub this_one_mesg {
  my $lc_nom;
  my $lc_val;
  
  ($lc_nom,$lc_val) = @_;
  
  if (grep { $_ eq $lc_nom } ( 'end', 'stop' ) )
  {
    print "STOP SIGNAL RECEIVED.\n";
    $the_main_loop = 0;
    return;
  }
  
  if ( $lc_nom eq 'wpm' ) { return resp_change_wpm($lc_val); }
  
  if ( $lc_nom eq 'pause' )
  {
    if ( $pause_on )
    {
      print "Treadmill ALREADY paused.\n";
      return;
    }
    $pause_on = 1;
    $pause_at = agtm();
    print "Treadmill paused.\n";
    frc_make_criogenum({'clean' => 0,});
    return;
  }
  
  if ( $lc_nom eq 'unpause' )
  {
    ford_pause();
    if ( $pause_on )
    {
      $pause_on = 0;
      print "Treadmill UNPAUSED.\n";
      frc_make_criogenum({'clean' => 0,});
      return;
    }
    print "Treadmill WASN'T PAUSED TO BEGIN WITH.\n";
    return;
  }
  
  if ( $lc_nom eq 'list' )
  {
    return resp_list_files($lc_val);
  }
  
  if ( $lc_nom eq 'sort' ) { return resp_do_sort(\&compare_fnom_alph); }
  if ( $lc_nom eq 'nsort' ) { return resp_do_sort(\&compare_fnom_nat); }

  if ( $lc_nom eq 'addfile' ) { return resp_add_file($lc_val); }
  if ( $lc_nom eq 'cutfile' ) { return resp_cut_file($lc_val); }
  
  print "Unknown message type: " . $lc_nom . " :\n";
}

sub docaff {
  if ( $pause_on )
  {
    if ( ( $curncount - $actugoal ) > 10.5 ) { return; }
  }
  if ( ( &agtm() - $lastcaff ) < $caff_a ) { return; }
  &force_caff();
}

sub force_caff {
  my $lc_cm;
  
  $lc_cm = "writeontask-caffeinate";
  $lc_cm .= " -t " . $caff_b;
  $lc_cm .= " -d";
  
  $lc_cm = "( " . $lc_cm . " ) &bg;";
  $lc_cm = "( " . $lc_cm . " ) > /dev/null 2> /dev/null";
  system($lc_cm);
  $lastcaff = &agtm();
}

sub agtm {
  #if ( $cut_the_leaps ) { return time(); }
  return int(clock_gettime(CLOCK_MONOTONIC));
}



sub word_count {
    my $count = 0;

    for my $file (@_) {
        next unless -f $file;

        open my $fh, '<:encoding(UTF-8)', $file or next;
        local $/;
        my $text = <$fh>;
        close $fh;

        $text =~ s/<(?:[^"'<>]|"[^"]*"|'[^']*')*>//gs;

        while ($text =~ /(\S+)/g) {
            my $token = $1;
            $count++ if $token =~ /[\p{L}\p{N}]/;
        }
    }

    return $count;
}




__DATA__

writeontask - writing treadmill

USAGE:
    writeontask-util MSGDIR SOUNDFILE [options] FILE [FILE ...]
    writeontask [options] FILE [FILE ...]

NOTE:
    You should have `writeontask` installed as a script that wraps
    `writeontask-util` and adds the location of the message-directory
    and the alarm sound-file.

OPTIONS:
    --addfile FILENAME, -a FILENAME
        Sends to the main process a message to add a file to the
        list of files being monitored.

    --crio, -c
        Revives a previously interrupted session

    --cutfile FILENAME, -x FILENAME
        Sends to the main process a message to remove a file from
        the list of files being monitored.

    --head SECONDS, --t SECONDS
        Number of seconds of head start.

    --wpm NUMBER, -w NUMBER
        Target words per minute.

    --max WORDS
        Number of words behind you must be for alarm
        bell to reach full volume.

    --msg MESSAGE, -m MESSAGE
        Send a mid-flight directive to the main process.
        Messages include:
          sort   Sort monitored files by complete pathname alphabetically.
          nsort  Sort monitored files by complete pathname naturally,
                 comparing embedded digit sequences numerically.

    --help, -h
        Display this help text.        

