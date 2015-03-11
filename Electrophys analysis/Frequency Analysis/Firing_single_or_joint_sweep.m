close all
[filenames, path] = uigetfile({'*.abf'}, 'Select_file(s)', 'MultiSelect', 'on');

if iscell(filenames)
    number_of_files = length(filenames);
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
        
        sweep = input(sprintf('Which sweep do you want to analyse in %s (1 to %d, or 0 for all, -1 for skip)? ', name{1}, sweeps));
        if (isempty(sweep))
            sweep = 0;
        end
        
        if sweep < 0
            close 99;
            continue;
        end
        
        filter = input('What is filter frequency? Leave blank for default (10000) ');
        if (isempty(filter)) 
            filter = 10000;
        end
        close 99;
        
        if sweep == 0
            sweep = 1;
            data = reshape(data, duration * sweeps, 1);
        end
        
        Analysis(data, sweep, i, number_of_files, filter, name{1});
    end
elseif filenames == 0    
    % Don't do anything
else
    fullname = strcat(path, filenames);
    data = abfload(fullname);
    
    duration = size(data, 1);
    sweeps = size(data, 3);
    sweep = input(sprintf('Which sweep do you want to analyse (1 to %d, or 0 for all)? ', sweeps));
    filter = input('What is filter frequency? Leave blank for default (10000) ');
    if (isempty(filter)) 
        filter = 10000;
    end

    if sweep == 0
        sweep = 1;
        data = reshape(data, duration * sweeps, 1);
        duration = duration * sweeps;
    end

    Analysis(data, sweep, 1, 1, filter, filenames);
end



%data = abfload('D:\Clouds\One Drive\Electrophysiology\2014\2014\10 2014\31 10\14o31019.abf');    