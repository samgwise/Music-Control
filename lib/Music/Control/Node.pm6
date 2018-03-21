use v6.c;

unit role Music::Control::Node;
use Music::Control::Clock;
use Music::Control::Clock::Tick;
use Music::Control::Event;

has Music::Control::Clock $.clock is required;
has List $.subscriptions;
has Supplier $!to-listeners = Supplier.new;

submethod TWEAK() {
  # Start default Supply tapping setup for a control node
  Supply.merge(
    $!clock.ticks,
    |$!subscriptions.values.map( -> Music::Control::Node $n { $n.events-supply } )
  ).act: {
    when Music::Control::Event {
      self.on-event($_)
    }
    when Music::Control::Clock::Tick {
      self.on-tick($_)
    }
    default {
      warn "Unhandled event of type: { .WHAT.gist } received!";
    }
  }
}

submethod DESTROY() {
  $!to-listeners.done;
}

method events-supply( --> Supply) {
  $!to-listeners.Supply
}

method !mixin-event($e) {
  $e but Music::Control::Event;
}

method on-tick(Music::Control::Clock::Tick $tick) { ... }

multi method on-event($event) { ... }
