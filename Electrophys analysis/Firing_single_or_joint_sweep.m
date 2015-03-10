close all
data = abfload('D:\Clouds\One Drive\Electrophysiology\2014\2014\10 2014\31 10\14o31019.abf');

duration = size(data, 1); %duration is how long the recording was done for.recorded every 100us. tenths of ms. by selecting datasize (1) i select how many points i have which is 1000000. as our filter is set at 10 kHz. 
sweeps = size(data, 3);
sweep = input(sprintf('Which sweep do you want to analyse (1 to %d, or 0 for all)? ', sweeps));
filter=input('What is filter frequency? Leave blank for default (10000) ');
if (isempty(filter)) 
    filter = 10000;
end

if sweep==0
    sweep=1;
    data=reshape(data, duration*sweeps,1);
    duration=duration*sweeps;
end

Analysis(data,sweep,1,1,filter);

  
    