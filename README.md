# Remote Audio Player

## Overview
Here is a possible usage scenario:
User machine -- MATLAB Web App Server -- Lab machine
Any user can control the Lab machine through the web browser.  The code at the Web Server is running in the server and is communicating with the Lab machine.  The sound processing and playing is done at the Lab machine.  The user access the web server through a web browser.  Another usage scenario is to have the user control app and responding code both be running in the same PC but through two instances.  The code is default to this scenario.

These files intend to demonstrate an application running with two instances.  The application allows a user to play an audio file, adjust a fourth-order filter to notch a frequency band and to toggle the use of the filter ON and OFF. The GUI side will send user selections to the player side.  The player side will send the audio data back to the GUI for display.


Files needed on the player side:
udpAudioPlayer.m   
fosFilter.m
receivedDatGram.m

Files needed on the GUI side:
runGUI.m
guiFOSFilterApp.mlapp
receivedDatGram.m

## Direction (three different usage scenarios)
=========  
(To run in same machine but with different Matlab instances)
This allows testing of the user side and the player side on the same PC.
1, Modify the path in runMATLABbkground.bat to the location of the file udpAudioPlayer.
2, In MATLAB workspace run runAll.m.

(To run through local network without using Web App Server)
This allows testing of the user side and the player side on the same network and not using the webAppServer
1, modify guiFOSFilterApp.mlapp line 129 to set the proper (server and user) IP address.
2, modify udpAudioPlayer.m line 24 to set the proper IP address (user and server).
3, On one side run the file udpAudioPlayer -- this is the player side.
4, On the other side run runGUI -- this is the GUI side.

(GUI side running in MATLAB Web App Server and audio playing in another)
This is for the usage sencario: User machine -- MATLAB Web App Server -- Lab machine
1, modify guiFOSFilterApp.mlapp line 129 to set the proper (server and user) IP address.
2, In App Designer, click Share -> Web App to create the ctf file.
3, copy the generated ctf file to the web app server for deployment.
4, modify udpAudioPlayer.m line 24 to set the proper IP address (user and server).
5, run udpAudioPlayer on the user machine.
6, on the user machine, through the web server, access the app.


## File List
=========  
runAll.m 		-- this is the starter file when both the controlling app (guiFOSFilerApp) and the responding code (udpAudioPlayer) needs to be run in the same PC.

runMATLABbkground.bat -- this is a batch file to run udpAudioPlayer in the background. It is called by runAll.m.

runGUI.m		-- this is the starter file that would bring up the GUI, it simply calls guiFOSFilterApp.mlapp

guiFOSFilterApp.mlapp -- all the code on the GUI side resides in this file.  It collects user inputs and send them over to the player side through UDP.  It would also display the playing data received from the player side through UDP.

receivedDatGram.m  -- this is the file that interprets the received UDP message.  Note that it interrepts both the messages received from the GUI and from the player side.  The received command will be displayed on the workspace.

udpAudioPlayer.m   -- this is the player side script. It will fetch the audio file received and also act on the commands received from the GUI side.  It calls fosFilter.m to create and instance of the forth order filter class.

fosFilter.m  	  -- this is the class definition of the forth order filter.


## Contact

Francis Tiong (Application Engineering)

## Relevant Industries

audio components design, audio equipments design, audio systems design, web applications, remote access, remote control

## Relevant Products
 *  MATLAB 2020b
 *  MATLAB App Designer
 *  MATLAB Web App Server
 *  DSP System Toolbox
 *  Instrument Control Toolbox
 *  Audio Toolbox


Copyright 2020 - 2022 The MathWorks, Inc.

