close all

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
    
    [rest_pot_avg, rest_pot_list]=RestingPotFunction(data, name{1}, 'Resting membrane potential', m,path,filenames{1});
    m = m + 1;
end

