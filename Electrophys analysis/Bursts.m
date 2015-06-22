
close all

path = fileparts(mfilename('fullpath'));
delete(sprintf('%s/Output/Burst_analysis/*.xlsx', path));
addpath(sprintf('%s/Includes', path));

[filenames, path] = uigetfile({'*.abf'}, 'Select file(s)', 'MultiSelect', 'on');

if ~iscell(filenames) %if filenames is not an array
    filenames = {filenames};%make it into one element array. we want it in am array because you cannot have text inthe matrix
end

number_of_files = length(filenames); %length is a function getting a number 
m = 1;


for i = 1:number_of_files
    fullname = strcat(path, filenames(i));%strcat concatinatina
    data = abfload(fullname{1});
    name = filenames(i);

    if isempty(data)
        continue %reiskia skippinti viska after this and get to the next, if there is sth wrong with data
    end
    
    duration = size(data, 1);
    sweeps = size(data, 3);
    
    % Preview file
    duration = size(data, 1);
    sweeps = size(data, 3);
    sq = ceil(sqrt(sweeps));

    data = reshape(data, duration * sweeps, 1);
    
    figure(99);
        plot(data(1:duration*sweeps, 1));
        
    
   
    filter = input(sprintf('Analysing %s. What is filter frequency? Leave blank for default (10000) or -1 to skip. ', name{1}));
    if (isempty(filter) || filter == 0) 
        filter = 10000;
    end
    
    if filter < 0
        continue;
    end
    
    total_length = floor(duration * sweeps / filter);

    parts = input('How many parts of this file do you want to analyse. Leave blank for default (1) ');
    if (isempty(parts) || parts < 1) 
        parts = 1;
    end

    for part=1:parts
        startts = input(sprintf('Part [%d]. When should we start (in seconds, 0 to %d, blank for 0)? ', part, total_length));%strtts- strt time stamp in seconds
        if isempty(startts) || startts < 0 || startts > total_length
            startts = 0;
        end

        endts = input(sprintf('Part [%d]. When should we finish (in seconds, 0 to %d, blank for max)? ', part, total_length));
        if isempty(endts) || endts < 0 || endts > total_length
            endts = total_length;
        end

        fullname = sprintf('%s %d:%d', name{1}, startts, endts);
        [ISI_values, AP_actual_sizes, AP_times_number] = Analysis(data((startts * filter + 1):(endts * filter)), 1, m, 9, filter, fullname, 'Burst_Analysis', path, filenames{1},filenames(i));
        
        ISI_thresh_log = input('What determines interburst period? ');
        ISI_thresh = 10 ^ ISI_thresh_log;

        Burst_Analysis(ISI_values, AP_actual_sizes, ISI_thresh, fullname, m, path);
        m = m + 1;
     end
end

