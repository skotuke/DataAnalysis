close all

path = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/Includes', path));

data = abfload('D:\Clouds\One Drive\Electrophysiology\2014\2014\10 2014\24 10\14o24008.abf');

duration = size(data, 1); %duration is how long the recording was done for.recorded every 100us. tenths of ms. by selecting datasize (1) i select how many points i have which is 1000000. as our filter is set at 10 kHz. 
sweeps = size(data, 3);
filter=input('What is filter frequency? Leave blank for default (10000) ');
if (isempty(filter)) 
    filter = 10000;
end


for i=1:sweeps
    [ISI_values, AP_sizes]=Analysis(data,i,i,sweeps,filter,'Data file','Frequency');
end

  
    