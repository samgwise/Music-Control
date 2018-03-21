use v6.c;
use Test;
plan 6;

use Music::Control::Clock;
use Music::Control::Node;

class TestNode does Music::Control::Node {
  has Promise $.received-tick = Promise.new;
  has Promise $.received-event = Promise.new;

  method on-tick(Music::Control::Clock::Tick $tick) {
    given $!received-tick {
      .keep(True) if .status ~~ Planned
    }

    $!to-listeners.emit: self!mixin-event(True)
  }

  multi method on-event($event) {
    given $!received-event {
      .keep(True) if .status ~~ Planned
    }
  }
}

my Music::Control::Clock $clock .= new( :tick-interval(0.1) ); # emit every 100ms

my TestNode $parent .= new( :$clock );
is $parent.so, True, "Parent node created";

my TestNode $child .= new(
  :$clock
  :subscriptions($parent, )
);
is $child.so,             True,       "Child node created";
is $child.subscriptions,  $($parent), "Child is subscribed to parent";

my @event-prmises =
  $parent.received-tick,
  $child.received-tick,
  $child.received-event;

# Start timeout
Promise.in(1).then: {
  @event-prmises.map( { .break("Test timed out") unless .status ~~ Kept } )
}

await
  Promise.allof(
    |@event-prmises,
  );

is $parent.received-tick.status,  Kept, "Parent node received tick from clock";
is $child.received-tick.status,   Kept, "Child node received tick from clock";
is $child.received-event.status,  Kept, "Child node received event from parent";

# done-testing
