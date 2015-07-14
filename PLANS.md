Collisions:
Say `Sally` object and `Susy` object collide. `Sally.collide` will be passed `Susy`, and `Susy.collide` will be passed `Sally`.
Example:
A door and a person collide. The person's `.collide` method will call `.open_with_key key` on the door or something, and the door's `open_with_key` method will look at the key and any other stuff to decide whether to open or not. The door's `.collide` method will do jack. Unless it is a trap.

How to customize reactions
`Sally` interacts with `Susy` by calling methods on `Susy`.
Example:
`Sally` hits `Susy` with a sword. `Sally` might call `Susy.do_damage(:attack_roll => 15, :damage => 109, :type => :slashing, :attacker => self)`. `Susy` can decide what to do with this, depending on what her AC is or if she has an ability which might do damage back to `Sally`.
