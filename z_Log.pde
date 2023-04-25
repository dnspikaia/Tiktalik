/*
Programming Log
What was done and when
01/17
ok, yesterday I missed out, t´was just the start
today:
defining the colorchange within the scheme. 
In principle now any color can be chosen as basis and will automatically be mapped to the scheme.
recalled how functions work and used them in excess in the color mapping of the HUD
done all the boolean functions for mouse event recognition as well
re-wrote the button geometry for the new HUD class
don´ get what it means "Java can exten only one class
got the base class for box-shaped elements extended to walls, plate and roofs no problem
got the HUD CLass extended to triggers as well, no problem
01/18
fighting a lot with naming and labelling the Trigger class (textsize related to screen size and box of the name related to textsize)
name and label align
fighting an awful lot with the line-of-progress making it safe for any rotation
all fighting victorious as it seems
Did the Torso of an info point class but nothing functional.
Took quite a long time to get the SML triggers functional. working now. 
Got the base-plate back in
01/19
made the 2-way-selctor, had some massive fighting with the lerp function.
NOTE: lerp does not work on integers, which is odd, since it is most useful for the int-i-loop
implemented a re-Pass variable in the HUD superclass, so objects can tell ctrl-items if they should do an optional change 
Made a Text with linebreak without a box
01/20
fixed bugreport about orientation
implemented shownAndActive: Hud items might appear or not, by adding this boolean to display functions and any mouseover function 
all events are supressed, if an item isn´t shown
got the wall class integrated
made a clean function for drawing the walls, needs improvements still
changed drawWall towards inner and outer shapes of the window/door cut 
so the first wall beautifully follows any change in the plate 
But it becomes spoiled with "alignLastWall" somethings freaky. It doesnt touch walls.get(0)
Maybe the fucktion isnt the problem...
Grand Fuck!!!
All behavior of the 1st wall immediately stops with insertion of a second wall
Me head is tight... wrote a function and completely forgot about it, while implementing it.
Got to see how I solved the problem last time. Did not have it, though. Plate wasnt moving, then.
...
..
Hhhmmh. That fugging bug kept bugging me. I worked with the Index-number last time.
Ok, that´s got nothn to do with the strike of Adam, when Eva shows up, but... thats n´nother problem, riddle, rather
Yet, I should solve the indexing problem, actually prev and nxt wall should work, somehow. 
Every Listoperation (walls removed or inserted) requires a reset of the list and by that a re-assignment of indexes
And then it should wöagh!
01/21
ok, ya, implented the addWall incl. indexing function and alignFunctions from older Version, 
found the if (Walls.size()==1) that should have been >0 
seems to work right now
introduced a String iconOrLabel in the HUD Superclass and made some voids for closed/door/window icons
probably those will have to be classes...
wrote a pass to suppress label if icon or Label =="icon" in the Trigger subclass
now I need to get the icons to the triggers
01/22
openninng Triggers work nnow, messy, since sinnncee I still need  a single unction  for each  trigger generation.
want one to geeneerate a triple trigger, by entering namees into the connstructor
problem was not  th ecleeanning  functionn, thats  betteer than I tought
(unnleess  someonee manageees  to geneeratee several triiggers withiin one frame...)
01/23
made first step on adding a generic block of multiple Triggers - so far it is manual entry of three names
but it should be a stringList and the coords are also required
01/24
Sliders are working - with or without ticks - horizontal or vertical - but - no repass yet and no wall aligning
a line in the log - a day of entangelment
01/25
Done a quick 4-Way-Selector, could be graphically improved
wrote an "imprint line" function - so I can quickly add tickmarks or directional lines on boards
the impprint lines as ticks still need to be replaced, though
Wall alignments are done, or so it seems
made the previous-to-follower function, applied in alignments. works.
01/26
renamed globalVar to globalMeth, started a reset HUD function there
made the slider-reset
done a failsafe clause for the activated wall to deactivate upon add.new (wall in the HUD
done the 4-w-Selector repass - function at global meth
01/27
made a reopsitioning for the walls without plate (putWallsToZero()) to always stay in the center of drawing
made the riteSide colors for walls of different angles - left sides require a button to prevent subsequent walls to turn with the activated one.
Made the outline for a button class need to do the following thing
on evocation make a preliminary button arraylist - transifer this list to the list inside each button except != this
if any of those becomes activated : this activated = false
added some buttons to switch subsequential turning of walls on and off 
introduced a boolean to wall class "rotation Sequence" that can be switched by the buttons - now the walls need to learn what to do
somehow "imageWalls" do not work here - so I have to find out why walls are turning anyway...
01/28
ok, now that was a tough puppy: as kind of failsafe function I had introduced a wallCount variable into the rotation by 4-way-Selector (run through selectors)
The idea was: it is an int set to zero, the activated wall sets it to 1.
If there is 1 and only 1 activated wall, rotation is enabled. I did not think that this enables rotation not just for this, but this and all subsequent walls
the solution is simple: after rotation raise the value again and by that fall out of the loop
It is not really cool that subsequent rotation of walls is triggered by buttons but only controlled within the 4-way selector
On the other hand it is pretty elegant, since through this wallcount variable I can easily make another item that defines how many walls should be turned
But - since it is mixing enabeling and counting, it becomes hard to turn the repetitive method into a function
Anyway: sequential rotation Mode deletes all rotations after the Active wall - need to change this, but my brains 
01/29
For the first - rewrote the addDoubleButton to seperate between leads and control items (made an addSetOfLaeds method instead)
Then made a noActivationMode for the Button, which means: if this ia set to true, it is possible that within a group of Buttons (myPals-group)
none of them is activated
For this as well introduces a deactivation sequence into the controlEvent method of Button class
Then failed to create a generic object class
The idea was that the oSnap method invokes an arraylist in its constructor, which is then passed internally to chose from the lists of objects, that 
can be (de-)activated through oSnap
Anyhow it works without, but it is not very smart and unsatisfyingly specific...
kicked the executeOnce=false passage out of every control item operation and put it once in the end of draw(), might be better off at the end of HUDinDaHood(). But it works like this
Ok, now a first inner wall is in and wondrously it moves according to the mouse - cant believe I made it work, although... it moves scrappy and dirty, as it has limits,
which is the baseplate or the wall outline. Unfortunatly its position is set back to the limit, which makes it jump from the position indicated by the mouse and its set limit
and of course it jumps out of mouse bounds loses touch and freezes - the other bug is a gain, if the view is turned over somme threshould, values change from pos to neg and it does weird stuff
so the whole oSnap, view-turn and againd the move to mouse section has to be revised
But be it as it is, it is there. it does something intended. it needs an "add"-Trigger and it needs to be set to grid ticks - the rest is tuning.
Made an adjustFirstInner Method to lift inner Walls to plate-level and set them to outer walls height
30/01
made a facadeCompletenes function again, but works onle if walls.get(0).rotation =0 and the last has half_pi+pi
01/31
Started redoign the Hud...
have a remove function that works, and the myFoll Function does not work in Plates - no clue why
02/09
Before going on with redoing the HUD it seems to make sense to take care of the inner walls
made some minmax variables for the inner walls to help the wobbling
enabled the add and remove functions for inner walls
made the icons and buttons for oSnap-Selection, now it is possible to catch only inner walls
02/10
for the grid movement of inner walls: introduced a getWallsMinPos() and getWallsMaxPos() to get the "real" min max coords of the walls
those can also be used to retrieve the rectangular outline of all walls, no matter what else.
ok the inner walls now move according to "a" grid. but it`s still a bit crappy:
the grid-position is the center of the wall, any attempt to clean that out - to make the inner wall align with the grid on its edge - brings the wobbling back
solution 1: a lot of difficile coding
solution 2: fuck that shit
solution 3: the bounding box has to be improved: bounds for reactToMouse must be wider than the movingBounds
02/11
made a BLock for Selection and incidentally one for the instantiation of objects
getting the control Items to move accordingly was a mess, but finally it seems to work
what is cool is that the creation method works for anything in the block, if it only has a name. 
No Subclasses so far - trying to establish the notion of a category instead of a class
not so cool is that without subclasses all methods and functions run in every block - maybe a boolean category to switch on and of routines
the second one requires a little more patience: first: icons instead of labels, since there is now just one label for eight triggers, sothese need to be self-explanatory
for some reason the cam.setState function doesn`t work with the dragging of blocks ´_`
02/12
too lazy to write log
02/13
all items can be dragged over the screen and can go into standba mode
so farso good - now I need to get rid of the leads. Which means:
all HUD-items need to be created in setUpHUD - those not required just hve to be set to !shownAndActive - then the "nully.pos" can be replaced by the block.pos...
02/14
all the Blocks now know the area they cover
02/15
Leads are out - now all items have coordinates relative to their block position
02/16-19
lazy in loggin/busy in coding
two plates possible now
"snapOn" now decides what mnpltW and selectC can do:
same Triggers, selectors and sliders now work for inner Walls as well as for outer walls
there are roofs now
when the facade is closed, a roof-add/del trigger is enabled (so far roofs cannot be deleted, sinced they can`t be selceted
blocks avoid each other - which means they never cover each other
therefore there is an availability check now:
blocks, which cannot be used are set to sleep mode and awaken again if snapOn is set to their functionality
blocks can also be set to standBy-Mode manually
major effort: walls can be added and deleted within the row and the myPrev/myFoll walls compensate the change in width
              but what actually the effort was is hard to tell. It was not adding an item in between other items
              it was just tricky coding, like: if(..);if(..); is different from if(..) else if(..); - stuff like that
inner walls now cann be moved with arrow-keys - since they have only half gridSpacing width, rotation by PI selects whether they build left or right from 0-position
issues with oSnap continue - someone has to write the perfect method for this
attempts with keepSnapped weren´t fully satisfactory
anyhow: got it far enough to make a first video as Dimi demands
also made a method for the walls (has to be in the HUD unfortunately, since changes happen there) to be able to change size within the row without shifting everything



//////////////
To Do
Next steps intended

- Outline detection and automatic wall generating
- need a redo-button
- save and open file
- delete gWalls
- move inner Walls with plates

- redo Boards: overlapping of outlines is awful
- redo Sliders: value should be displayed as textWindow besides mouse-cursor (so the eyes stay with the handle)
- definitely need a boolean or so, to suppress any kind of mouse-action, when the mouse is already hooked with something.
- improve movement/positioning of inner walls
-  the  blocks are also theere for thee hashes annd  may be the elocatiionn where thee parseer  runns
- blocks might  bee a thread
- rotatiiodiff first  miinus theenn plus (requires third button)

- make sequential rotations additive (old rotation+new rotation), right now all following walls get the same rotation as the activated
- make a viewOperationMode to prevent unsolicited activation of objects
- "Drehung" should switch with the view
- last idea: every object generates ist parameter as a string, strings add up to be a textfile that can be stored and read
  program is open source but the textfile becomes encrypted as a hash
- idea: make a thread that contains nothing but a buffer array. 
  if a wall (e.g.) is being activated, it sends a request to the buffer - 
  the buffer submits respective values to HUD items -
  The HUD items switch to the "new" "old" values
  the buffer is uodated at the end of the frame
  so "initial values are safely stored in the buffer and become update after everything is said and done.
  The buffers would probably images of the main application lists (like: buffer.imageWalls = walls; at the end of each frame)   ...is that cost efficient...?
- replace the frames-only with window or door
- the impprint lines as ticks still need to be replaced    
- make the colors of walls interactively changeable
- HUD Superclass should be changed, so that TextWindows don´t need unnecessary definition of height and width
- make method to detect inside-vertices in plates (1 alway outsid, 3 always outsid 4 inside 2 inside, if two more with same coord in one axis and exceding values in the other
- background that moves with camera-angle
- Pan for the 3D view
- do the info-Dots (Popping up of what to do with control items)


- another idea HUD panels make blocks//////////////////////////////////////////////////////////Done 
  blocks can drop out or fold in to the nameboxes of leads (so they do make sense)/////////////////
  blokcs can be moved, dragged at the lead nameboxes - so the can be pushed out of the way/////////
- do the following thing: make it possible to add walls in between other walls. see: splice()//Done - forgot about that splicing thing (But this wasn´t the cumbersome part)
- make method to add plates together///////////////////////////////////////////////////////////Done
- replace hudgie coords of ctrl items with the pos coords of their respective leads////////////Done - within Blocks
- write a generic block for double and Triple Triggers and an Array of Triggers////////////////Done - since long...
-   - and definitely: walls need to be protected from changing parameters upon activation//////Done - since long...
- last wall connected to the first - closing function - set 1st wall to be myFoll of the last//Done
- do the generic namebox esp for multiple items and include the myPals List to tripleTriggers//Done - within Blocks
- check why now many objects of the same kind can be activated simultanously///////////////////Done
- maybe a boolean category to switch on and of routines within the blocks /////////////////////Done
02/19
- makee  class conntrolblock  that conntaiinnns no   moree  tha  a  arraylist  of pvectors/////Done  
- each   conntrol iiteem reeceiis  a  pos, stored iinn   thiis  arrayliist/////////////////////Done
   and e functionto reecalcthe pveeecs in this arrayliist accordinn to the movees of the block/Done
- at the momen there is no way all buttons of a group are deactived////////////////////////////Done
- need a method for 3D objects to follow the mouse for inner walls -> on the grid//////////////Done
- wall alignments: check walls of different sizes going back to back///////////////////////////Done
- make a function to switch rotation of subsequent walls on and off////////////////////////////Done
- reposition walls without plate to av 0,0,0                               ///////////////////7Done
- make new wall in the rotation as previous                        ////////////////////////////Done
- thee failsafe for oSap  does not work  properly - use framecount the later activation counts/Done
   actually  it  just thee  activation  on new wall  that  should  deactivate nay other((((((((Done
- idea:  make a function from prev to next to have the chain of walls /////////////////////////Dunn, in a pretty elegant way, if I may say
- make walls aligning again                                           /////////////////////////Done
- re-write osnap: seeing from front catching left to right, from behind right to left, easy////Done
-  slider und button for getting the walls back in            /////////////////////////////////Done
- walls resizable                                         /////////////////////////////////////Done
- view still operating when mouse is over name boxes or label box of lead /////////////////////Solved
- hasDoor requires setting p to 0                //////////////////////////////////////////////Done
- change drawWall towards inner and outer shapes of the window/door cut ///////////////////////Done
- getting the walls back in                                        ////////////////////////////Done
- BUGREPORT: if you have a v-oriented plat and change its size, it switches back to h-orientation//Done
- do the functions for linebreak and textbox                       ////////////////////////////suspended, got a formated label without box
- for some f**king reason the f**king view rotates again during ctrl-events ///////////////////solved
- delete arc from Trigger-name-box                                     ////////////////////////Done
- doing the "line of progres", the thing that vissually connects the control items/////////////Done
- naming and labelling of HUD items                                    ////////////////////////done
- decide wether they are labelled or iconized                    ////////// for now: labelled//Done

*/
