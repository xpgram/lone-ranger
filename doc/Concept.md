# Concept

A grid-based, dungeon crawler. Like, I guess it's sorta like Mystery Dungeon. I'm much more inspired by Void Stranger and casting sick-ass fire spells, though.

A lot of games like this, historically, anyway, let you attack anyone adjacent. You can smack 'em by pushing into 'em.

I want to be able to open a menu and cast Fira 3-tiles away, or perform Blitz Strike and warp 4-tiles forward, damaging the 3-tiles you skipped past.

I also want these decisions to be very strategic. You wouldn't just cast them all the time.

And, to make this more interesting, I guess, following behind Void Stranger and such: abilities have secondary effects or uses that are helpful in either puzzle solving or puzzle combat.



## Mechanics

### Half-time combat

This game is turn based. When you move or act, then all enemies get to move or act. An example? Void Strange. Legit.

However!

Time is not frozen. The game hides this fact for a little while until you meet your first flesh enemy (non-golem), but enemies *can* act if you take too long.

Every action you take triggers a time tick-forward that I'll just call a "second" for simplicity. "Seconds" do not pass in real-world time.

Instead, a second passes when you take an action. But also, *fractional* seconds pass even while you're reading your own action menu. If a full fractional second passes while you're idling, then your character will "Wait," and then your enemies will be allowed to move.

Enemies will move after a "Wait" action even while your ability submenus are open, which means that if you're not paying attention, you might not even notice they did that.

The speed at which fractional seconds pass is variable. I'm not sure yet what should control it. But, later rooms are probably "faster" than earlier ones. And there might be an equippable item to give you more thinking time (though it does take an entire equipment slot).

Oh, maybe... maybe there should be a world object, like a lantern or something, whose effect speeds up time. That would leave the player the option of breaking it, too.

Also, technical implementation: when the player acts, a second passes, but this is rounded to the nearest whole number, e.g., if 0.78 fractional seconds pass, then acting would only pass the remaining 0.22 seconds. Acting always leaves the player with a full fractional second to pass and never allows the enemy double-act.

---

Another thing I want to do with this time aspect:

In Advance Wars, you can cursor over any enemy you like and hold B to see their attack range. Because LoneRanger has *time*, it would be interesting to test the player's perception and reflexes.

So, an enemy might cast some kind of delayed effect. They send a bunch of spiky rocks into the sky and next turn they're supposed to come down and hit you. Before they do, they show you where they're going to strike: those tiles will flash or shimmer briefly. Now, when you act—and remember, there is fractional time—you need to move to a safe tile, one that you remember didn't shimmer. You'll find out if your choice was correct when they strike.

I also think that these should happen in parallel time. If the enemy casts these things to strike "next turn," next turn might be 4 real world seconds. They strike when they strike, not as part of the time-tick system. They can still be affected by time-manipulating objects, though (either equipment or objects in the room).

I can also add an equippable that makes the shimmer effect longer, happen multiple times, or that prevents it from disappearing entirely.

---

You know what's fucked? :p 
Void Stranger actually already does this, haha. Ahh, it's for some end game bosses and such, though, it's a little different.

---

##### Jan 7, 2026

Half-time can be measured in 4-beats per bar, where a bar is usually 15 seconds or so. Whatever I decide.

A 'bar' is an official turn. Typically the player goes, and then all the enemies go, etc. A 'beat' is for free actions, like an enemy counter-attack. Free actions really only make sense in real-time (not golem-time), but they should feel pretty cool. Seeing an enemy prime to counter-attack you and then taking a quick action to get out of the way would be neat.

This would imply something, though. Here's a turn event list:

- Player attacks Enemy C.
- Enemies A and B take their turn. Enemy C flinches, hurt, but primes to counter-attack one beat later.
- Player dodges by normal movement.
- Enemies A and B take their turn. Enemy C uses their counter-attack as their turn, missing.
  - [*If the player had not dodged, Enemy C would counter attack, and then later, Enemies A, B, and C would all have acted after the player did as they normally would.*]

So, what feels weird here is that you're not dodging quickly. C's counter attack is 'fast' but you end up triggering the 'slow' A and B when you evade it.

I think this problem is already solved, though. Enemy C not getting to counter-attack and then also follow you like A and B do already feels pretty good.

If the player wants to dodge C without triggering A and B, maybe they can get some Haste or something to speed their own movement up. Moving the real-time meter beyond C's counter-attack beat should trigger the counter attack miss whether or not it's an official 4-beat turn.

### Minotaur

Since we're still travelling around a big stone-walled labyrinth, why not have a big, invulnerable monster chase you?

I think it would be cool if items you picked up change how you deal with them, too. Maybe in unexpected ways. Like, the Stun Rod, or whatever, doesn't stun him, so you might think your items are useless, but in fact, it *can* do something else to help you. And "help you" means it can get you access to hallways and doors previously thought to be aesthetic only.

And eventually you'll be able to straight up kill him. For what, I'm not sure.

Do you think he should have a second phase? Like, you kill him once after you get the big, important sword, and it's a huge moment, and you think "wow, what crazy shit does this unlock? I've never not had to deal with him." But then sometime later he comes back in ghost form, and you'll have to defeat him again some other way. That could be funny.

---

Much like Animal Well, Void Stranger, etc., I think this should be a game about recontextualizing things you've already seen.

## Abilities

### Sword

Attacks one tile in front of you.

### Wings

Allows you to float over 1-tile gaps.

### Lunge

An attack, but also lets you cross 2-tile gaps (3?).

Unlike Wings, you can't Lunge around corners, though. It's only straight lines.

### Hookshot

Requires ammo or recharge time to cast; it's limited.

Cast on a valid target, pulls you quickly to their position. If the object is light enough, may pull them to you instead.

This does not cost an action, so if the player does it quickly enough, they can travel long distances and attack in one time tick.

(I don't think I should give the player the privilege of resetting fractional time; that's way too much. But, I could guarantee they have a minimum of 0.15 seconds to act once they travel. Maybe that would be 0.5 real-world seconds or something, I'm not sure yet.)

## Enemies

### Stone-golem type

Early enemies that act as trials on temple grounds or something like that. They *only* act after you do, in turn-by-turn fashion, because they're point is to test you, not to kill you.

### Later, flesh type

The first enemy that isn't a golem will, naturally, not be concerned with tests. Now they will act when a "Wait" action occurs.