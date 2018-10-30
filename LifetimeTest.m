%Reset variables and clear screen everytime script runs
clear
clc

%Put the directory for the data file you wish to analyze
%Example: filepath = "//sv-fileserver01/Test_Lab/Test Lab Data/TLR/TLR_10000_to_10999/TLR_10256/210/TLR_10256_210_H.E.sensor data/LiveAbore1.dat";
%OCTAVE USES FORWARD SLASHES - NOT BACK SLASHES
filepath = "//sv-fileserver01/Test_Lab/Test Lab Data/TLR/TLR_10000_to_10999/TLR_10256/207/TLR_10256_207_H.E.sensor data/LiveAbore1.dat";

%Stores the number of opens and closes in the dataset
numopen = 0;
numclose = 0;

%These thresholds need to be set based on the level of the magnetic field detected
%by the hall sensor for open and closed positions
hall_open_threshold = 2.81;
hall_close_threshold = 2.77;

%Veriables for Plots
openvalue = hall_open_threshold;
closevalue = hall_close_threshold;
lowerrange = 1000;
upperrange = 2000;

%Stores the number of failures
open_failures = 0;
close_failures = 0;

%Stores the location in the vectors where a failure occurred.  Used in plot function
%to view data around failure to verify
openfailureIndex = 0;
closefailureIndex = 0;

data = dlmread(filepath, "\t", 2, 0);
hall = data(:,6);
time = data(:,1);
command = data(:,5);

#{
Not currently used
axialdisplacement = data(:,2);
force = data(:,4);
velocity = data(:,3);
#}

for j = 2:1:(numel(command)-1)
%Check for opens
%if transition in command signal
%Command signal varies from 1V to 2V.  1.5V chosen as transition voltage, but 
%could have been anything in between.  Conditional statement is checking to see
%if there is a transition in signal from low to high (This might need to be changed
%if firmware on controller changes).  If transition, we increment
%the count for number of opens and check to see if there is a corresponding 
%transition in the hall signal.
    if ((command(j) > 1.5) && (command(j-1) < 1.5) && (command(j-10) < 1.5))
        numopen = numopen + 1;
        %Might need to change the equality signs if magnet in solenoid is flipped.
        %If so, also need to change inequalities in close check below.  Inequality
        %checks transition 1 data point before current location in array and 11 after.
        %11 data points later chosen to get to steady state magnetic field after 
        %pulsing current through solenoid coils.  This might need to change if
        %pulse time is increased.
        if ((hall(j+10) > hall_open_threshold) && (hall(j-1) < hall_close_threshold))  
            %display('The front shocks are working fine');
        else
            open_failures = open_failures + 1;
            %fprintf('The rear shocks did not open at some instance - %d.\n',j)
            openfailureIndex = [openfailureIndex; j];
        endif
    endif
    
%Check for close    
%Similar to above, some inequalities may need to be flipped depending on situation
    if ((command(j) <  1.5) && (command(j-1) > 1.5) && (command(j+10) < 1.5))
        numclose = numclose + 1;
        %Might need to change the equality signs if magnet in solenoid is flipped
        if ((hall(j+10) < hall_close_threshold) && (hall(j-1) > hall_open_threshold))  
            %display('The front shocks are working fine');
        else
            close_failures = close_failures + 1;
            %fprintf('The rear shocks did not open at some instance - %d.\n',j)
            closefailureIndex = [closefailureIndex; j];
        endif
    endif
endfor
  
#{
%Plot function for closing
openvalue = hall_open_threshold;
closevalue = hall_close_threshold;
for index = 1:600
  openvalue = [openvalue; hall_open_threshold];
  closevalue = [closevalue; hall_close_threshold];
endfor
for k = 2:1:numel(closefailureIndex)
  if (closefailureIndex(k) <= 300)
    lowerrange = 1;
  else
    lowerrange = closefailureIndex(k)-300;
  endif
  upperrange = closefailureIndex(k)+300;
  plot(time(lowerrange:upperrange), hall(lowerrange:upperrange), time(lowerrange:upperrange), command(lowerrange:upperrange), time(lowerrange:upperrange), openvalue, ":", time(lowerrange:upperrange), closevalue, ":")
  legend('Hall Voltage', 'Command', 'Hall Open Voltage', 'Hall Close Voltage');
  title(k);
  ans = input("Move to next failure...?")
endfor
#}

#{
%Plotting function for opens
openvalue = hall_open_threshold;
closevalue = hall_close_threshold;
for index = 1:600
  openvalue = [openvalue; hall_open_threshold];
  closevalue = [closevalue; hall_close_threshold];
endfor
for k = 2:1:numel(openfailureIndex)
  if (openfailureIndex(k) <= 300)
    lowerrange = 1;
  else
    lowerrange = openfailureIndex(k)-300;
  endif
  upperrange = openfailureIndex(k)+300;
  plot(time(lowerrange:upperrange), hall(lowerrange:upperrange), time(lowerrange:upperrange), command(lowerrange:upperrange), time(lowerrange:upperrange), openvalue, ":", time(lowerrange:upperrange), closevalue, ":")
  legend('Hall Voltage', 'Command', 'Hall Open Voltage', 'Hall Close Voltage');
  title(k);
  ans = input("Move to next failure...?")
endfor
#}

%general plot functions, need to set lowerrange and upperrange to something reasonable before use
#{
openvalue = hall_open_threshold;
closevalue = hall_close_threshold;
plot(time(lowerrange:upperrange), hall(lowerrange:upperrange), time(lowerrange:upperrange), command(lowerrange:upperrange),
     time(lowerrange:upperrange), openvalue, time(lowerrange:upperrange), closevalue)
#}
