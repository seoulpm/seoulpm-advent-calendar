#!/usr/bin/env perl
use 5.012;
use strict;
use warnings;
use Time::HiRes qw(gettimeofday);
use Term::ReadKey;

sub oneSentence {
    my ($original) = @_;

    chomp $original;
    say $original;

    my @arrOriginal = split //, $original;

    my $firstLetter;
    do {
        ReadMode 'cbreak';
        $firstLetter = ReadKey(0);
        ReadMode 'normal';
    } while ($firstLetter =~ /\s/);
    print $firstLetter;
    
    my $time1 = gettimeofday();
    my $typing = <STDIN>;
    my $time2 = gettimeofday();
    my $timeDif = ($time2 - $time1);
    
    chomp $typing;
    $typing = $firstLetter . $typing;
    if ($typing eq "quit") {
        return "quit";
    }
    my @arrTyping = split //, $typing;
    
    my $i = 0;
    my $j = length $typing;
    my $numCorrect = 0;
    foreach (@arrOriginal) {
        if ($j <= $i) {
            last;
        }
        if ($arrOriginal[$i] eq $arrTyping[$i]) {
            print "-"; 
            ++$numCorrect;
        }
        else {
            print "*";
        }
        ++$i;
    }
    print "\n";

    say "       Time: " . (int(100 * $timeDif) / 100) . " seconds";
    say "Correctness: " . (int(10000 * $numCorrect / length($original) / 100)) . "%" . " ($numCorrect / " . length($original) . ")";
    say "      Speed: " . (int(60 * 100 * length($typing) / $timeDif) / 100) . " keys / minute\n\n";

    return ($timeDif, length($original), length($typing), $numCorrect);
}

open my $data, '<', $ARGV[0] or die "Cannot read the file: $!";
my $mode;
my @inputArray;
my @outputArray;
my $totalTime    = 0;
my $totalLength  = 0;
my $totalTyping  = 0;
my $totalCorrect = 0;
my $arrayIndex;


say "\n***********************************************************";
say "*                                                         *";
say "*   Korea Perl Christmas Calendar - Typing Trainer v1.0   *";
say "*                                                         *";
say "*                   Merry Christmas! ^^                   *";
say "*                -------------------------                *";
say "*                                    v1.0 - 2011. 12. 22. *";
say "*                                                         *";
say "*  Type the sentence on the screen!                       *";
say "*  If you want to quit, just type 'quit'.                 *";
say "*                                                         *";
say "*  What training mode do you want?                        *";
say "*    1. Story  Mode (sentences appear sequencially)       *";
say "*    2. Random Mode (sentences appear randomly)           *";
say "*                                                         *";
say "***********************************************************\n";
print " Type a number ---> ";

while (<$data>) {
    push @inputArray, $_;
}

while (1) {
    $mode = <STDIN>;
    chomp $mode;
    if (($mode ne "1") && ($mode ne "2") && ($mode ne "quit")) {
        print " Type a number ---> ";
        next;
    } else {
        last;
    }
}

say "\n/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\".
    "/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\\n";

if ($mode eq "1") {
    $arrayIndex = 0;
} elsif ($mode eq "2") {
    $arrayIndex = int(rand(@inputArray));
}
if (($mode eq "1") || ($mode eq "2")) {
    while (1) {
        @outputArray = oneSentence($inputArray[$arrayIndex]);
        if (@outputArray == 4) {
            if ($mode eq "1") {
                ++$arrayIndex;
            } elsif ($mode eq "2") {
                $arrayIndex = int(rand(@inputArray));
            }

            if ($arrayIndex >= @inputArray) {
                $arrayIndex = 0;
            }
            $totalTime += $outputArray[0];
            $totalLength += $outputArray[1];
            $totalTyping += $outputArray[2];
            $totalCorrect += $outputArray[3];
        }
        else {
            last;
        }
    }
}

say "\n\n-----  Your total score  -----";
say "       Time: " . (int(100 * $totalTime) / 100) . " seconds";
if ($totalLength != 0) {
    say "Correctness: " . (int(10000 * $totalCorrect / $totalLength) / 100) . "%" . " ($totalCorrect / $totalLength)";
} else {
    say "Correctness: not applicable ($totalCorrect / $totalLength)";
}
if ($totalTime != 0) {
    say "      Speed: " . (int(60 * 100 * $totalTyping / $totalTime) / 100) . " keys / minute (total $totalTyping keys)\n";
} else {
    say "      Speed: not applicable\n";
}

close $data;
