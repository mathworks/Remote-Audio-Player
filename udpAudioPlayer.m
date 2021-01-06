% udpAudioPlayer -- This is the player-side.  This script is intended to be running under a different
% MATLAB workspace than the GUI side.
%
% Copyright © 2020 The MathWorks, Inc.  
% Francis Tiong (ftiong@mathworks.com)

clear;

% setup UDP
global updateFlag;     % indicate need to update center Freq on player-side, or to display one frame data on GUI
global execFlag;       % flag indicate receive a start or stop command
global newCenter;      % value of new center freq
global newName;        % new audio file name
global newNameFlag;    % indicate new audio file name, driver, output select 
global useFilter;      % flag to indicate whether to use filer or not
global newDrvSel;      % received selection of driver from user
global newOutDevSel;   % received output device selection from user
global numCmdRced;     % counting num of commands received 

updateFlag = 0;
newCenter = 1000.0;
execFlag = 0;
newName = 'FunkyDrums-44p1-stereo-25secs.mp3';
newNameFlag = 0;
useFilter = 1;
newDrvSel = [];
newOutDevSel = [];
numCmdRced = 0;

%localIP = "192.168.1.5";  % IP address for local machine
%remoteIP = "192.168.1.14"; % IP address to send data towards (remote machine)
localIP = "127.0.0.1";
remoteIP = "127.0.0.1";

frameSize = 1024;      % UDP packets of 1024 floating point values to be send to GUI 
uu = udpport("datagram","IPV4","LocalHost",localIP,"LocalPort", 3030 , 'OutputDatagramSize', frameSize*4+20);
% Notice the IP address is the local PC address and the port is 3030

configureCallback(uu,"datagram",1,@receivedDatGram);    % callback function receivedDatGram to interpret the UDP message


%%
% prepare Driver selection info
% Check if we're running on Mac or PC
if(ispc)
    AudioDriverList = {'DirectSound','ASIO'};
else
    AudioDriverList = {'CoreAudio'};
end
AudioDriverDropDown = strjoin(AudioDriverList,',');

%%
% prepare output device list
h = audioDeviceWriter;
devices = getAudioDevices(h);
devicelist = strjoin(devices,',');


%%
device = devices{1};
driver = AudioDriverList{1};
newDrvSel = driver;
newOutDevSel = device;

% 
% FunkyDrums-44p1-stereo-25secs.mp3 ,  RockGuitar-16-44p1-stereo-72secs.wav
fileReader = dsp.AudioFileReader('FunkyDrums-44p1-stereo-25secs.mp3','PlayCount',inf,...
    'SamplesPerFrame',1024);
%deviceWriter = audioDeviceWriter('SampleRate',fileReader.SampleRate);

deviceWriter = audioDeviceWriter('Driver',driver, 'Device', device, 'SampleRate',fileReader.SampleRate);


% create an instance of the class object
sut = fosFilter;
sut.reset;
sut.Fs = fileReader.SampleRate;
sut.calculateCoefficients();

%drawnow

% create a one second delay between checking for new commands
ttt = timer( 'TimerFcn',@(~,~)disp(''),'StartDelay',1);

% Stream processing loop
nUnderruns = 0;
while (1) %~isDone(fileReader)   % enable checking will allow wav file to be run only once
    
    if  execFlag==1
    
        % If a new center frequency is received then update 
        if updateFlag==1
            sut.cFreq = newCenter;
            sut.calculateCoefficients();
            updateFlag = 0  
        end
        
        % Read from input, process, and write to output
        in = fileReader();
        out = single(process(sut,in));
        
        if useFilter==0
            out = single(in);
        end
        
        nUnderruns = nUnderruns + deviceWriter(out);

        write(uu, out(:,1), "single", remoteIP, 3031); % only send 1 channel over

        % Process parameterTuner callbacks
        drawnow limitrate
    else
        start(ttt)  % start timer, wait until the specified time before checking commands
        wait(ttt)
        if newNameFlag==1   % flag received for new file Name, send back Driver, device list
           fileReader = dsp.AudioFileReader(newName, 'PlayCount',inf,...
           'SamplesPerFrame',1024);

            sut.cFreq = newCenter;
            sut.calculateCoefficients(); 
            
            % send over driver selection list           
            txtcommand = 'auddrvl';
            outStr = strcat(txtcommand, AudioDriverDropDown);
            write(uu, outStr, "char", remoteIP, 3031);
            
            txtcommand = 'devices';
            outStr = strcat(txtcommand, devicelist);
            write(uu, outStr, "char", remoteIP, 3031);
            
           newNameFlag = 0; 
        else
            
            % keep sending selection list until sender has time to receive
            if numCmdRced < 4
                % send over driver selection list           
                txtcommand = 'auddrvl';
                outStr = strcat(txtcommand, AudioDriverDropDown);
                write(uu, outStr, "char", remoteIP, 3031);

                start(ttt)
                wait(ttt)
                txtcommand = 'devices';
                outStr = strcat(txtcommand, devicelist);
                write(uu, outStr, "char", remoteIP, 3031);
                
            end
            
            % update selected Driver and output device
            driver = newDrvSel;
            device = newOutDevSel;
            
            deviceWriter = audioDeviceWriter('Driver',driver, 'Device', device, 'SampleRate',fileReader.SampleRate);

        end
    end
end


% Clean up
release(fileReader)
release(deviceWriter)
clear uu;

