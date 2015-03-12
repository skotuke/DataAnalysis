close all;

[filenames, path] = uigetfile({'*.abf'}, 'Select_file(s)', 'MultiSelect', 'on');

if ~iscell(filenames)
    filenames = {filenames};
end

number_of_files = length(filenames);
m = 1;

for i = 1:number_of_files
    fullname = strcat(path, filenames(i));
    data = abfload(fullname{1});
    name = filenames(i);

    if isempty(data)
        continue
    end

    % Preview file
    duration = size(data, 1);
    sweeps = size(data, 3);
    sq = ceil(sqrt(sweeps));

    figure(99);
    for j = 1:sweeps
        subplot(sq, sq, j);
        plot(data(1:duration, 1, j));
        title(sprintf('Sweep %d', j));
    end
    
    data = reshape(data, duration * sweeps, 1);

    filter = input(sprintf('Analysing %s. What is filter frequency? Leave blank for default (10000) or -1 to skip. ', name{1}));
    if (isempty(filter) || filter == 0) 
        filter = 10000;
    end
    
    if filter < 0
        close 99;
        continue;
    end

    total_length = floor(duration * sweeps / filter);

    parts = input('How many parts of this file do you want to analyse. Leave blank for default (1) ');
    if (isempty(parts) || parts < 1) 
        parts = 1;
    end

    for part=1:parts
        startts = input(sprintf('Part [%d]. When should we start (in seconds, 0 to %d, blank for 0)? ', part, total_length));
        if isempty(startts) || startts < 0 || startts > total_length
            startts = 0;
        end

        endts = input(sprintf('Part [%d]. When should we finish (in seconds, 0 to %d, blank for max)? ', part, total_length));
        if isempty(endts) || endts < 0 || endts > total_length
            endts = total_length;
        end

        fullname = sprintf('%s %d:%d', name{1}, startts, endts);
        Analysis(data((startts * filter + 1):(endts * filter)), 1, m, 9, filter, fullname);
        m = m + 1;
    end
    
    close 99;
end



%data = abfload('D:\Clouds\One Drive\Electrophysiology\2014\2014\10 2014\31 10\14o31019.abf');    