use v6.c;

unit role Music::Control::Clock;
use Music::Control::Clock::Tick;

has Numeric $.tick-interval = 0.01;
has Supplier $!subscribers = Supplier.new;
has Cancellation $!clock-events;

submethod TWEAK() {
  $!clock-events = self!start-clock
}

submethod DESTROY() {
  self!stop-clock
}

method !start-clock( --> Cancellation) {
  $*SCHEDULER.cue: { $!subscribers.emit: Music::Control::Clock::Tick }, :every($!tick-interval)
}

method !stop-clock() {
  .cancel with $!subscribers
}

method ticks( --> Supply) {
  $!subscribers.Supply
}
