close all

path = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/Includes', path));

data = abfload('D:\Clouds\One Drive\Electrophysiology\2014\2014\10 2014\31 10\14o31041.abf');

duration = size(data, 1); %duration is how long the recording was done for.recorded every 100us. tenths of ms. by selecting datasize (1) i select how many points i have which is 1000000. as our filter is set at 10 kHz. 10000 measurements per second=100us
sweeps = size(data, 3);
sweep = input(sprintf('Which sweep do you want to analyse (1 to %d)? ', sweeps));

figure; 
plot(data(1:duration, sweep))

thresh_AP = -20; %what threshold voltage needs to pass to be considered as firing an AP

fire = 0; %can be either zero or one, indicating if it is currently firing (if 1)
start = 0; %time steps since the start of the current burst
gap = 0; %time steps since last action potential

burst_AP_count = zeros(1000,1);%pirmas skaicius rows, antras columns
AP_number = 0;%kelintas AP in a burst
AP_times=zeros(1000,1);
AP_max_value = -1000;

for i = 1:duration 
    if data(i,sweep) > thresh_AP 
        if fire==0
        fire=1
        AP_number=AP_number+1
        end
        
    else fire=0
    end
    
 end  
    

    
    
     
        
     
        
        
      
    
    