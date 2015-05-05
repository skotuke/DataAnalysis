close all
[filenames, path] = uigetfile({'*.abf'}, 'Select_file(s)', 'MultiSelect', 'on');

path = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/Includes', path));

if iscell(filenames)
    number_of_files = length(filenames);
    for i = 1:number_of_files
        fullname = strcat(path, filenames(i));
        data = abfload(fullname{1});
        name = filenames(i);
        CurrentStepsFunction(data, i - 1, name{1});
    end
elseif filenames == 0    
    % Don't do anything
else
    fullname = strcat(path, filenames);
    data = abfload(fullname);
    CurrentStepsFunction(data, 1, filenames);
end

