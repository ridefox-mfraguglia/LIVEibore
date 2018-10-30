%Reset variables and clear screen everytime script runs
clear
clc

%Put the directory for the data file you wish to analyze
%Example: filepath = "//sv-fileserver01/Test_Lab/Test Lab Data/TLR/TLR_10000_to_10999/TLR_10256/210/TLR_10256_210_H.E.sensor data/LiveAbore1.dat";
%OCTAVE USES FORWARD SLASHES - NOT BACK SLASHES
filepath = "C:/Users/mfraguglia/Documents/GitHub/LIVEibore/18_10_29.TXT";

%Stores the number of opens and closes in the dataset
numopen = 0;
numclose = 0;

%These thresholds need to be set based on the level of the magnetic field detected
%by the hall sensor for open and closed positions
hall_open_threshold = 2.659;
hall_close_threshold = 2.641;

%Veriables for Plots
openvalue = hall_open_threshold;
closevalue = hall_close_threshold;
lowerrange = 1900;
upperrange = 2000;

%Stores the number of failures
open_failures = 0;
close_failures = 0;

%Stores the location in the vectors where a failure occurred.  Used in plot function
%to view data around failure to verify
openfailureIndex = 0;
closefailureIndex = 0;

data = dlmread(filepath, "\t", 2, 0);
hall = data(:,3);
time = data(:,6);
command = (data(:,5))/10 + 2.5;

for j = 2:1:(numel(command)-1)
%Check for opens
    if ((command(j) > 2.55) && (command(j-1) < 2.55))
        numopen = numopen + 1;
        %Might need to change the equality signs if magnet in solenoid is flipped.
        %If so, also need to change inequalities in close check below.  Inequality
        %checks transition 1 data point before current location in array and 11 after.
        %11 data points later chosen to get to steady state magnetic field after 
        %pulsing current through solenoid coils.  This might need to change if
        %pulse time is increased.
        if ((hall(j) > hall_open_threshold) || (hall(j+1) > hall_open_threshold))  
            %display('The front shocks are working fine');
        else
            open_failures = open_failures + 1;
            %fprintf('The rear shocks did not open at some instance - %d.\n',j)
            openfailureIndex = [openfailureIndex; j];
        endif
    endif
    
%Check for close    
%Similar to above, some inequalities may need to be flipped depending on situation
    if ((command(j) <  2.55) && (command(j-1) > 2.55))
        numclose = numclose + 1;
        %Might need to change the equality signs if magnet in solenoid is flipped
        if ((hall(j+1) < hall_close_threshold))  
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
for k = 2:1:numel(closefailureIndex)
  if (closefailureIndex(k) <= 50)
    lowerrange = 1;
  else
    lowerrange = closefailureIndex(k)-50;
  endif
  upperrange = closefailureIndex(k)+50;
  plot(time(lowerrange:upperrange), hall(lowerrange:upperrange), time(lowerrange:upperrange), command(lowerrange:upperrange))
  legend('Hall Voltage', 'Command');
  title(k);
  ans = input("Move to next failure...?")
endfor
#}

#{
%Plotting function for opens
for k = 2:1:numel(openfailureIndex)
  if (openfailureIndex(k) <= 20)
    lowerrange = 1;
  else
    lowerrange = openfailureIndex(k)-20;
  endif
  upperrange = openfailureIndex(k)+20;
  plot(time(lowerrange:upperrange), hall(lowerrange:upperrange), time(lowerrange:upperrange), command(lowerrange:upperrange))
  legend('Hall Voltage', 'Command');
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