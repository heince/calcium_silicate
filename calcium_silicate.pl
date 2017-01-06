#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: calcium_silicate.pl
#
#        USAGE: ./calcium_silicate.pl [diameter] [totalreq] [layer] [margin error]
#
#  DESCRIPTION:
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Heince Kurniawan
#       EMAIL : heince@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 12/27/16 21:08:38
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Carp;
use 5.0101;
use Smart::Comments -ENV;
use List::Util qw/sum/;
use Algorithm::Combinatorics qw/combinations_with_repetition/;

#-------------------------------------------------------------------------------
#  usually the initial request by customer is [diameter] x [total size number]
#  which is stored in $diameter and $totalreq
#  $layer is used to give possible layer configuration on the array thickness
#  $margin is to give max cap tolerance diff from the total requested size number
#-------------------------------------------------------------------------------
my $diameter = $ARGV[ 0 ] || usage();
my $totalreq = $ARGV[ 1 ] || usage();
my $layer    = $ARGV[ 2 ] || usage();
my $margin   = $ARGV[ 3 ] || 25;        # default value is 25
$margin = $totalreq + $margin;          # define margin tolerance

### [<now>] [<file>][<line>] diameter:  $diameter 
### [<now>] [<file>][<line>] totalreq:  $totalreq 
### [<now>] [<file>][<line>] layer:     $diameter 
### [<now>] [<file>][<line>] margin:    $margin 

#-------------------------------------------------------------------------------
#  supported thickness configuration
#-------------------------------------------------------------------------------
my @thickness = qw /75 65 50 40 30 25/;
my %result;

### [<now>] [<file>][<line>] supported thickness: @thickness

my %pipe_int = (
                 '0.25' => 16,
                 '0.5'  => 23,
                 '0.75' => 28,
                 '1'    => 35,
                 '1.25' => 44,
                 '1.5'  => 50,
                 '2'    => 62,
                 '2.5'  => 77,
                 '3'    => 90,
                 '3.5'  => 103,
                 '4'    => 115,
                 '4.5'  => 128,
                 '5'    => 143,
                 '5.5'  => 155,
                 '6'    => 171,
                 '7'    => 196,
                 '8'    => 222,
                 '9'    => 246,
                 '10'   => 275,
                 '11'   => 300,
                 '12'   => 327,
                 #'13'   => 339,
                 '14'   => 358,
                 '15'   => 384,
                 '16'   => 409,
                 '17'   => 427,
                 '18'   => 460,
                 '19'   => 486,
                 '20'   => 511,
                 '24'   => 613,
                 '26'   => 664,
                 '28'   => 715,
                 '30'   => 766,
                 '32'   => 817,
                 '36'   => 919,
                 '40'   => 1022,
                 '42'   => 1073,
                 '72'   => 1836,
               );

#-------------------------------------------------------------------------------
#  main run start here
#-------------------------------------------------------------------------------
my $dm_init = get_diameter_value( $diameter );
### [<now>] [<file>][<line>] diameter initial value: $dm_init

my $iter = combinations_with_repetition( \@thickness, $layer );
while ( my $p = $iter->next )
{
    validate( $p );
}

for my $key ( sort sort_value ( keys %result ) )
{
    process( \$key );
}
#-------------------------------------------------------------------------------
#  main run stop here
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#  subroutines
#-------------------------------------------------------------------------------
sub process
{
    my $key = shift;
    my @arr = split '\s+' => $$key;

    ### [<now>] [<file>][<line>] combination: $$key 

    say $$key;
    say "\t$diameter x $arr[0]";
    for ( 1 .. $#arr )
    {
        my $value = $dm_init + ( $arr[ $_ ] * 2 );
        my $c_diameter = get_closest_key( $value );
        say "\t$c_diameter x $arr[$_]";
    }

    return;
}

sub sort_value
{
    return $result{ $a } <=> $result{ $b };
}

sub validate
{
    my $array = shift;
    my $sum   = sum @$array;

    if ( $sum == $totalreq )
    {
        $result{ join ( ' ', @$array ) } = 0;
        return 1;
    }
    elsif ( $sum > $totalreq and $sum < $margin )
    {
        $result{ join ( ' ', @$array ) } = $sum - $totalreq;
        return 1;
    }
    else
    {
        return 0;
    }
}

sub get_closest_key
{
    my $value = shift;
    my $result;

    for my $key ( sort { $a <=> $b } keys %pipe_int )
    {
        if ( $pipe_int{ $key } > $value )
        {
            $result = $key;
            last;
        }
    }

    $result ? return $result : die "can't get closest diameter value\n";
    return;
}

sub get_diameter_value
{
    my $value = shift;
    my $result;

    for my $key ( sort { $a <=> $b } keys %pipe_int )
    {
        if ( $key == $value )
        {
            $result = $pipe_int{ $key };
            return $result;
        }
    }

    die "diameter not supported\n";
}

sub usage
{
    say "$0 [diameter] [totalreq] [layer] [margin error]";
    exit 255;
}
