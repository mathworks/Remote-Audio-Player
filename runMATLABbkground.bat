@echo off
matlab -sd "G:\Documents\udpPlayer\remoteaudioplayer" -automation -r "udpAudioPlayer; pause(5); quit" > matlab_output.log
exit
