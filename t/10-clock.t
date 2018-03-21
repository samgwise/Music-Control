use v6.c;
use Test;
plan 4;
use Music::Control::Clock;

my Music::Control::Clock $clock .= new( :tick-interval(0.1) ); # emit every 100ms
is $clock.so, True, "Created clock object";

for 1..3 -> $count {
  my Promise $received-tick .= new;
  my $tap = $clock.ticks.tap: {
    $received-tick.keep: True
  }

  await
    Promise.anyof(
      $received-tick,
      Promise.in(1).then( { $received-tick.break("Test timed out") } )
    );

  $tap.close;

  is $received-tick.status, Kept, "Clock emitted ticks in a timely manner ($count)";
}
