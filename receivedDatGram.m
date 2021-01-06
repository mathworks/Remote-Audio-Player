%  receivedDatGram -- the callback function to interprete the datagram
%  message.  This is used on both the player side and the GUI side
%
% Copyright © 2020 The MathWorks, Inc.  
% Francis Tiong (ftiong@mathworks.com)

function data = receivedDatGram(source, eventdata)

global updateFlag;     % indicate need to update center Freq on player-side, or to display one frame data on GUI
global newDataBlock;   % array holding new frame of data on GUI
global execFlag;       % flag indicate receive a start or stop command
global newCenter;      % value of new center freq
global newName;        % new audio file name
global newNameFlag;    % indicate new audio file name 
global useFilter;      % flag to indicate whether to use filer or not
global newDrvList;     % new driver list
global newDevices;     % new devices list
global newDrvSel;      % new Driver selection value
global newOutDevSel;   % new Out Device selection value
global numCmdRced;     % counting number of new commands received

data = read(source,source.NumDatagramsAvailable);

ll = length(data);      % ll is the total number of packets received

if ll>0
    Data = data.Data;

    % checking for the letters "st" which is the same for commands start
    % and stopp.  Note that the two commands are both of length 5.
    if length(Data) == 5 && Data(1) == 115 && Data(2) == 116
       outt = char(Data);
       if strcmp(outt, 'start')
           execFlag = 1
       elseif strcmp(outt, 'stopp')
           execFlag = 0
       end
    elseif length(Data)> 5 && strcmp(char(Data(1:6)), 'effect')
        value = 0;
        if strcmp(char(Data(7:8)), 'On')
            value = 1;
        end
        useFilter = value
    elseif length(Data)> 5 && strcmp(char(Data(1:7)), 'newname')
        newName = char(Data(8:end))
        newNameFlag = 1
    elseif length(Data)> 5 && strcmp(char(Data(1:7)), 'auddrvl')
        newDrvList = char(Data(8:end));
    elseif length(Data)> 5 && strcmp(char(Data(1:7)), 'devices')
        newDevices = char(Data(8:end));
    elseif length(Data)> 5 && strcmp(char(Data(1:6)), 'drvSel')
        newDrvSel = char(Data(7:end))
        %newDrvSel = typecast(uint8(Data),'single');
    elseif length(Data)> 5 && strcmp(char(Data(1:9)), 'OutDevSel')
        newOutDevSel = char(Data(10:end))
        %newOutDevSel = typecast(uint8(Data),'single');

   % if the data is not a command then it has to be a floating point value
    elseif mod(length(Data),4)==0  
        outt = typecast(uint8(Data),'single');
        
        % 1024 is the frameSize specified for the packets to be sent for
        % display
        if length(outt)==1024
           newDataBlock = outt;
           
        % one floating point value is used to send the center frequency
        elseif length(outt)==1
           newCenter = outt
        end
        updateFlag = 1;
    end

    numCmdRced = numCmdRced +1;
end