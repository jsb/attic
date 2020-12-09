----------------
Evacuation v1.01
----------------

by jsb (Janis Born)
made for the Ludum Dare 48 Hour Programming Challenge

------------
Instructions
------------

Oh no!, the city is being attacked again by the Giant Black Wall. Unfortunately, the villagers are too stupid to escape on their own, so it's your job to pick them up and escort them to one of the subterranean bunkers before they get smashed by The Wall.
Your goal is to rescue a given amount of villagers while keeping fatalities as low as possible.

--------
Controls
--------

WASD - move player
E - use powerup
Tab - cycle through powerups
Space - player indicator

P - pause
Esc - quit

----
Misc
----

If you have Ruby installed, you can start the game by running main.rbw.

The game accepts the following command line parameters:

--fullscreen - Runs the game in fullscreen. Careful, it's 640x480.

------
Thanks
------

Thanks to jlnr for his Gosu library and all the guys of #gosu for some fun, productive days.
Enjoy the game!

---------------
Version History
---------------

1.01
  * some fixes to gosu's tile rendering by jlnr. Thanks!
  * bunkers should no longer appear under buildings and trap villagers
  * fixed the ear rape caused by repeatedly playing win.wav
