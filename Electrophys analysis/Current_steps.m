close all

show_figures = 0;
path = fileparts(mfilename('fullpath'));
delete(sprintf('%s/Output/Current_steps/*.xlsx', path));
addpath(sprintf('%s/Includes', path));

[filenames, path] = uigetfile({'*.abf'}, 'Select_file(s)', 'MultiSelect', 'on');

if ~iscell(filenames) %if filenames is not an array
    filenames = {filenames};%make it into one element array. we want it in am array because you cannot have text inthe matrix
end

number_of_files = length(filenames); %length is a function getting a number 
m = 1;

for i = 1:number_of_files
    fullname = strcat(path, filenames(i));
    data = abfload(fullname{1});
    name = filenames(i);

    if isempty(data)
        continue
    end
    
    [AP_sizes_list, AP_actual_sizes_table, AP_number]=CurrentStepsFunction(data, name{1}, 'Current_Steps', m, show_figures,path,filenames{1});
    m = m + 1;
end

