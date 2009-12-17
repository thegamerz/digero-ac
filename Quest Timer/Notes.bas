Attribute VB_Name = "Notes"
'**** ToDo *******
'  - Change chest stuff to use new ACHooks event and property:
'       ContainerOpened, OpenedContainer
'
'  - User-submitted quest notes

'**** Changes ****
'* 2.4.1 (???, 2005)
'  - Fixed /say bug for notes, where it would say it to the current channel,
'       rather than to local chat
'
'* 2.4.0 (October 19, 2005)
'  - Update to work with Decal 3
'
'* 2.3.3 (April 18, 2005)
'  - Integration with Treestats
'  - Fixed timer expiration messages -- if a timer expires more than once without
'       you logging out, it now shows the expiration message each time
'  - If the client changes timezones or DST settings, the plugin will compensate
'       and adjust all timers in the XML
'
'* 2.3.2 (January 8, 2005)
'  - You can now view all of your characters' timers at once on the Other
'       Characters tab
'  - Now will automatically upload when you add/remove a note, if you have auto
'       uploading enabled
'  - Fixed a bug with the "Only upload if your file is newer" setting (uploadct
'       is now sent in a comment with the loadquests requests)
'
'* 2.3.1 (January 6, 2005)
'  - Only upload if your file is newer
'  - Server checks that other characters' data is the same
'  - Save backups when downloading
'  - Fixed checking of chkCheckFileTime setting while saving quests file
'  - Filtering for the downloaded quests tab
'
'  - Increased max Note length for web responses to 200 characters & max
'       number of Notes to 10
'  - Added "currenttime" to web requests
'  - wtcwError now logs messages (instead of just HandleError)
'  - wtcwMessage font color is now 14
'
'* 2.3.0 (November 29, 2004)
'  - Allow for /tell triggers (& changed "Server Text" to be color 0 -- Green)
'  - Automatically reset timers for quests that expired X days ago
'  - Ctrl+Click on 'Time Up' to clear the timer
'  - Change 30 second upload delay to 5 seconds
'
'  - Alert users not to submit quests they haven't added themselves
'  - Changed name of chkWebMOTD control to chkWebNews (to reset setting)
'
'* 2.2.2 (August 15, 2004)
'  - Use GUID instead of just name for CheckIOwn (Quests.IOwn is now a collection
'        of GUIDs, instead of Boolean)
'  - New quests on download list are green again
'  - Triggers should start when an item is picked up directly into a side pack
'
'  - Added >> If Check = "" Or Pattern = "" Then Exit Function << to isLike function
'
'* 2.2.1 (June 21, 2004)
'  - Recompiled with ImpFilter 2.8.0.14 to remove dependency on 2.9.0.2 beta
'       (should work with all versions now)
'
'* 2.2.0 (June 19, 2004)
'  - Submit quests
'  - New type of trigger - specific item picked up within 60 secs of opening
'       specific corpse
'  - Plugin itself doesn't require username/password - handled by the site
'  - Dates saved in the ISO 8601 format in the Quests XML
'  - Option to not display "Time Up" messages when quests expire or at login
'  - Store GUID in quest file
'  - Comma-delimited list of characters, current GUID, Time Zone Offset sent
'       with web requests
'  - Multiple Upload Sites
'  - Add "Updated" Quests on the internet tab
'  - Option to disable modify check
'  - View other character's quests
'  - Remove Download Quests URL edit
'
'  - Fix MOTDs
'
'* 2.1.0 (April 27, 2004)
'  - Web!
'  - Notes!
'  - Must hold down Ctrl while deleting a quest/note
'  - Fixed bug where IOwn would not be checked when merging or reloading quests file
'  - Items on hooks should no longer trigger timers
'  - Wider UI
'  - Clicking to delete a quest no longer brings you to the top of the list (for
'       easier deleting multiple quests)
'
'  - Switched from Consts to Enums for tabs and columns of lists
'
'* 2.0.1 (April 19, 2004)
'  - Euro dates should save right now
'  - CheckIOwn uses wildcards correctly
'  - Fixed chat commands
'
'* 2.0.0 beta (April 13, 2004)
'  - Lots...



' **********************************
' *** Quest File version history ***
' 5 - added GMTOffset to root tag
' 4 - changed Completed to ISO format
' 3 and below (?)
