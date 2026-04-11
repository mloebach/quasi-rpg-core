@clearPrinter

Prelude


[lb]The story starts in a scene starkly different from the rest of the game.[rb]
[lb]We load into an the overworld of an RPG, and are currently in a small room of a dark castle. The player can move, open a status menu, and look at their items.[rb]

@icon Ipholsia
@icon Lannus
@icon Nerinorin
@icon Zenith


[lb]There are four people in the party, following behind the player. There's a cleric, a knight, a mage, and your player character clad in platinum armor.[rb]


[lb]The player is also in front of a save point, and can choose to interact with it to create their first save file.[rb]


@choice "[b]Save[/b]" play:true
;@choice "Save" play:true
@choice "Quit" disable:true
;[{zenith_name}] - 99;59 - [b]Save[/b] Quit
[{zenith_name}] - 99;59 


[lb]The door in front of them leads to a hallway. The story continues when the player enters.[rb]
[lb]As your party walks down the hall, more context is provided on the situation by Nerinorin, the mage.[rb]
[lb]These heroes have reached the end of their journey.[rb]
[lb]Waiting for them in the throne room at the end of the hall is the Dark Husk, the overlord who destroyed the world.[rb]

@icon DarkHusk

[lb]It has been an incredibly difficult journey across several different lands. Several of their friends have died to get them to this battle.[rb]
[lb]They've rung all the Bells in the Elemental Temples necessary to weaken the Dark Husk's power.[rb]
[lb]The Dark Husk is guarding the final Bell. If they can ring it, they will be able to use the wish they will be granted by the Zenithian Spring to bring the world back to the way it previously was.[rb]
[lb]...[rb]
[lb]In simplest terms possible, this is a battle they [i]cannot afford to lose.][/i[rb]
[lb]{zenith_name} is silent, and nods.[rb]
[lb]The group reaches the end of the hallway, and reaches the door.[rb]



@choice "[b]Yes[/b]" play:true
@choice "No" disable:true
[b]Beyond this door is the beginning of the end of your journey. Are you ready for what lies ahead?[/b]

[lb]Once the player is ready, the party enters the door to the final stop of their journey - the castle's throne room.[rb]

[lb] Inside, an shadowy overlord covered in heavy armor is sitting right in front of them, expecting their arrival - The Dark Husk.[rb]
[lb]The Dark Husk delivers a speech. The dreams of the party are about to be crushed, and once this futile effort from the party is dealt with, their conquest shall spread to the rest of the Star Salted Sea.[rb]
[lb]Nerinorin, Ipholsia, and Lannus, all respond. The Dark Husk and their forces have killed too many innocents, too many of their friends, caused too many sacrifices for the four of them to back down. They will give it everything they got.[rb]
[lb]The party turns to {zenith_name}[rb]
...
[lb]{zenith_name} nods, and gets out their sword to attack.[rb]
[b][The battle begins.][/b]


@cg VSDarkHusk1

[lb]This opponent, the Dark Husk, is an enemy worthy of final boss-tier difficulty. They make the first move, buffing themselves and casting fire magic on {zenith_name}.[rb]
[lb]{zenith_name} is the only character the player can directly control, the other three act on their own - Nerinorin is a mage with damage spells and buffs, Ipholsia is a cleric that focuses on healing, and Lannus is another damage dealer. [rb]
[lb]{zenith_name} has the highest speed, so after the Dark Husk's two initial turns, will always go first.[rb]
...
[lb]{zenith_name}'s normal attacks do around 3000 to 4000 damage. Their special attacks deal around 8000 damage.[rb]

[lb]Ipholsia's normal attacks do around 200 to 800 damage. She has no significant offensive spells.[rb]
[lb]Nerinorin's normal attacks do around 600 to 1000 damage. Their magic spells deal around 3000-6000, but can only cast about five of these before their mana runs out.[rb]
[lb]Lannus's normal attacks do around 900 to 1800 damage. Besides that, they have no other means of attack.[rb]
[lb]The Dark Husk can move twice each turn. In this phase of the fight, they can hit one party member for about 2500 damage or everyone for about 1500 damage.[rb]
[lb]The Dark Husk also...[rb]

@cg VSDarkHusk2

[lb]...has 250,000 Health.[rb]

[lb]Dark Husk's third rotation of spells. They hit Lannus with a single target attack, and then use an area attack. This is enough to down Lannus.[rb]

@cg VSDarkHusk3

[lb]There is a shift everyone's behavior after the Dark Husk's third rotation of spells. If there's any hope of breaking through the Dark Husk's massive health bar, it's through you, {zenith_name}.[rb]
[lb]Nerinorin switches from using expensive damaging spells to cheaper single-target buffs applied to Zenith.[rb]
[lb]After Ipholsia revives Lannus, she switches from applying defensive spells to exclusively using group healing spells.[rb]
[lb]Lannus, once back up, switching from attacking to using Mana restoring items on the party.[rb]

@cg VSDarkHusk4

[lb]Once they reach about 70% health, the Dark Husk begins their second phase.[rb]
They begin their turn by buffing the magic to it's maximum level. They then use [b]Nightmare Crusher[/b], a devastating area of effect attack.

@cg VSDarkHusk5

[lb]{zenith_name} is barely effected, but Lannus is down to a few points of health and Ipholsia and Nerinorin down.[rb]
...
[lb]Ipholsia doesn't have much energy left. She doesn't think...she's gonna make it.[rb]
[lb]She confesses she loves Nerinorin. Nerinorin is silent...coughs...and quietly says that they love her too.[rb]
...

@cg VSDarkHusk6

[i][Ipholsia and Nerinorin are now out of the battle.][/i]
[lb]The battle continues. A shift in mood occurs.[rb]
[lb]Ipholsia and Nerinorin are gone. Not just down. [b]Gone.[/b][rb]
[lb]{zenith_name}'s attacks do more damage from this point on.[rb]
[lb]Lannus will use a Revival Item on the party slot above them, hoping to heal Ipholsia.[rb]


@cg VSDarkHusk7

[lb]The Dark Husk's turn again. They use [b]Heat Riser[/b] - their attack, magic, defense, and speed have all drastically risen.[rb]
[lb]They then move their focus to {zenith_name}, hitting them with a single target attack. {zenith_name} is taken to 1200 HP remaining.[rb]
[lb]Your move.[rb]
@icon Lannus
Lannus: "NO!"
Lannus: "After everything we've gone through..."
Lannus: "Everything we've done to save the Skychosen Lands..."
Lannus: "After everyone we've lost..."
Lannus: "Nerinorin...Ipholsia..."
Lannus: "It can't end like this!"

[lb]{zenith_name} is silent. No matter what the player chooses this turn, {zenith_name} will not move.[rb]
[lb]Lannus uses a potion on {zenith_name} to restore them to full health.[rb]
[lb]The Dark Husk's turn.[rb]
[lb]The Dark Husk uses their first turn to attack {zenith_name} again. It critically strikes, taking {zenith_name} all the way down to 238 health.[rb]
[lb]The Dark Husk follows this up with [b]Mind Charge.[/b] Their next spell will deal twice as much damage.[rb]
[lb]Next turn, they are going to use [b]Nightmare Crusher[/b] again.[rb]

...

@cg VSDarkHusk8

...
[lb]...No.[rb]
[lb]This...shall not continue.[rb]
[lb]You have the power to stop this. Even if the cost may be great, there is one way to stop this..[rb]
[lb]If there's any time to unlock that power...[rb]


@choice "[b]AWAKEN[/b]" play:true
[lb]It's now.[rb]

@cg VSDarkHusk9

[lb]Once you press the button, the screen is washed in a white light.[rb]

@cg WhiteScreen

...

@cg VSDarkHusk10

[lb]Lannus can't move, he's too scared to do anything.[rb]
[lb]Dark Husk's turn.[rb]
[lb]The Dark Husk uses Nightmare Crusher.[rb]
...

@cg VSDarkHusk11

[lb]{zenith_name} and Lannus both take no damage.[rb]
[lb]Lannus immediately realizes what's happening.[rb]

@icon Lannus

Lannus: "What...{zenith_name}!"
Lannus: "That forbidden technique..."
Lannus: "No, you can't! You need to stop, NOW!"
Lannus: "You know what will happen if you do that, right?"
Lannus: "You'll..."
[lb]The Dark Husk's turn isn't done yet. They use [b]Mind Charge[/b] again, to prepare another Nightmare Crusher.[rb]

[lb]Our turn again.[rb]
...


[lb]{zenith_name} speaks for the first time, to Lannus.[rb]
@choice "I know...what will happen to me." play:true
...
@icon Zenith
@choice "If I must protect the smiles of the Star Salted Sea from Evil, then no sacrifice is too great." play:true
[i]"I know...what will happen to me."[/i]


@choice "But, I don't want you to fear." play:true
[i]"If I must protect the smiles of the Star Salted Sea from Evil, then no sacrifice is too great."[/i]

@choice "I promise, this is not the last time we will meet." play:true
[i]"But, I don't want you to fear."[/i]

@choice "I promise one day, I will return to this world." play:true
[i]"I promise, this is not the last time we will meet."[/i]

@choice "My story will not end here, because you will survive." play:true
[i]"I promise one day, I will return to this world.""[/i]

@choice "Even if I'm gone, my story will live on." play:true
[i]"My story will not end here, because you will survive."[/i]

@choice "So, promise me, Lannus..." play:true
[i]"Even if I'm gone, my story will live on.""[/i]

@choice "Promise me, you will keep my story alive..." play:true
[i]"So, promise me, Lannus..."[/i]

@choice "And promise me, when they day comes..." play:true
[i]"Promise me, you will keep my story alive..."[/i]

@choice "You will find me again..." play:true
[i]"And promise me, when they day comes..."[/i]

[i]"You will find me again..."[/i]
[lb]All of these come in the form of single choice dialogue options to be chosen by the player.[rb]

[i][New music.][/i]

[lb]{zenith_name} regains their senses.[rb]

@cg VSDarkHusk12

[lb]The first thing they do with their power is teleport Lannus out of the castle. The results of this battle will be explosive, and they don't want them to get hurt.[rb]
[i][Lannus is out of the battle. It's just {zenith_name} and the Dark Husk now.][/i]
[lb]The Dark Husk uses [b]Nightmare Crusher[/b] again.[rb]

@cg VSDarkHusk13

[lb]{zenith_name} begins charging an attack of their own.[rb]
[lb]The Dark Husk uses Nightmare Crusher![rb]
[lb]]{zenith_name} takes no damage.[rb]
[lb]The Dark Husk uses Nightmare Crusher again![rb]
[lb]{zenith_name} takes no damage.[rb]
[lb]{zenith_name} is almost done charging.[rb]
[lb]The Dark Husk uses Nightmare Crusher once more![rb]
[lb]{zenith_name} takes no damage.[rb]
[lb]The Dark Husk tries to punch {zenith_name}, with all their might![rb]

[lb]{zenith_name} takes no damage.[rb]
[lb]{zenith_name} has finished charging their ultimate attack.[rb]

@cg VSDarkHusk14

[lb]{zenith_name} casts Dream Ender.[rb]

@cg WhiteScreen

[lb]The screen goes white. Sounds of divine arrows, swords, and light fills the screen.[rb]
...

@cg VSDarkHusk15

[lb]The Dark Husk... has been defeated.[rb]
[lb]The battle concludes.[rb]

[lb]Cut back to the overworld. {zenith_name} is alone.[rb]
[lb]The door to the Zenithian Bell is in the door behind them, and to save the world, {zenith_name} just has to walk to it and make the wish.[rb]
[lb]{zenith_name}'s walking speed has been reduced to a crawl. All items in their inventory are gone.[rb]
[lb]They feel incredibly tired.[rb]

[lb]We eventually make it to the Zenithian Bell. It is inside a beautiful spring, filled with life.[rb]
[lb]{zenith_name} weakly walks up to the bell, and rings it.[rb]
[lb]Light erupts from the spring.[rb]
[lb]{zenith_name} falls over, and fades into peacefully into flickers of spectral dust.[rb]
[lb]Cut to a continent floating in the sky, covered in haze. A beam of white light erupts upwards, streaming straight into the sky.[rb]
[lb]The screen gradually fades into white.[rb]

@cg WhiteScreen
...
@cg BlackScreen
...
[lb]Shift in User Interface from RPG to Visual Novel[rb]

;@firstScript Prologue
@goto Prologue

@stop
