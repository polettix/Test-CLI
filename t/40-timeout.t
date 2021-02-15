use strict;
use warnings;
use Test::More;
use Test::Exception;
use Path::Tiny;

use Test::CLI qw< tc >;

$|++;
my $sparring = path(__FILE__)->parent->child('sparring')->stringify;

my $tc = tc($sparring, qw{ stdout 0 <sleep> });

$tc->run(sleep => 'sleep=0', -timeout => 1);
$tc->in_time
   ->timeout_is(0)
   ->timeout_isnt(2);

$tc->run(sleep => "sleep=2", -timeout => 1);
$tc->timed_out_ok
   ->timeout_is(1)
   ->timeout_isnt(2)
   ->timeout_isnt(0);

done_testing();
