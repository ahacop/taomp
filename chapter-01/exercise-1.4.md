# When we know switch is off

When the prisoners meet, Prisoner A counts the other prisoners and remembers the number.

When a prisoner enters the cell:

- if the switch is on, do nothing.
- if the switch is off
  - and it is their first visit, turn it on
  - and it is not their first visit, do nothing

When Prisoner A enters the cell:

- if the switch is on, decrement the count and turns the switch off
- if the switch is off, do nothing

When the count reaches zero then Prisoner A knows that everyone has visited the cell at least once.

This may take awhile, since a prisoner may visit the cell many times before Prisoner A can reset the switch, but at least Prisoner A will know with certainty when to make the declaration.

# When we don't know switch's initial state

If they don't know the initial state of the switch, then they can't use the same strategy, because if Prisoner A is the first prisoner to enter the cell, and the initial state is on, he will incorrectly think another prisoner has visited the cell.

So, Prisoner A can instead ignore the switch on his first visit. If it's on, it shouldn't count as a visit, and he should turn it off.

Every other prisoner should do the same thing as before, but flip the switch on two of their visits, instead of only once.

Prisoner A should count until 2\*(N-1)-1. N-1, because he's not counting himself. And minus one from the overall, to account for the possibility that the first time he sees the switch he doesn't know if it's state was caused by a visit or not.
