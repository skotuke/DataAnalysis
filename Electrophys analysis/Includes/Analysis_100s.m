function [ISI_values, AP_actual_sizes, AP_times_number] = Analysis_100s(data, sweep, k, k_total, filter, filename, output_folder, location, name, file, duration) 
% Function Analysis

% after '=' is the name of the funtion and in brackets there is a list of
% arguments


% Arguments:
%  matrix @data - 
%  int @sweep - which sweep I am analysing
%  int @k - kelintas failas is visu failu yra nagrinejamas
%  int @k_total - kiek failu is viso yra atidaroma vienu kartu 
%  int @filter (default: 10000) - 
%  string @filename (default: Data file) - 
%  string @output_folder (default: Default) - 
% Returns (lauztiniai skliaustai salia function, which values the function will return)
%  matrix ISI_values -
%  matrix AP_sizes - 
%  int AP_number -

% arguments are taken from the file that funtion is called out from. The
% ORDER of the arguments matters, not the names

formatOut = 'HH-MM-SS';
fulltime=strcat(date,{' '}, datestr(now,formatOut));

if nargin < 5 % if less than 5 arguments, filter becomes default
    filter = 10000;
end

if nargin < 6
    filename = 'Data file'; %just a default heading
end
   
if nargin < 7 
    output_folder = 'Default'; %just a name, we do not use it anywhere
end

%these are necessary so I would not need to pass these arguments when I do
%not need to pass them

k_rows = ceil(sqrt(k_total)); %apvalinti i virsu
k_spot = k; %kelintas grafikelis is grafiku grid
k_figure = 0; %numeris kelintas 
while k_spot > k_rows * k_rows %jeigu jau nebetelpa,pradeti numeruoti is naujo. I need this as sometimes I make a limit of 
    k_spot = k_spot - k_rows * k_rows;
    k_figure = k_figure + 10;
end

duration = 1000000;
duration_s = (1/filter):(1/filter):(duration/filter);%zero does not exist in matlab, therefore it starts at the smallest point.
%1/filter pirmasis element in the graph or matrix, 1/filter step size, and duration/filter paskutinis elemnet in the graph/matrix 
sweep_data = data(1:duration, 1, sweep); % sweep is an argument

figure(1 + k_figure);
subplot(k_rows, k_rows, k_spot);
plot(duration_s, sweep_data);
xlabel('Time (sec)');
ylabel('Voltage(mV)');
title(file);
set(figure(1 + k_figure), 'Visible', 'On');
 
thresh_AP = -30; %what threshold voltage needs to pass to be considered as firing an AP

AP_times = zeros(10000, 1);
AP_times_shifted = zeros(10000, 1);
AP_max = -1000;
declining = 0;
AP_times_number = 0;
AP_sizes = zeros(10000, 1);
AP_min_list = zeros(100000,1);

for i = 1:duration 
    if sweep_data(i) > thresh_AP || (declining == 0 && AP_max > thresh_AP)
        if declining == 0
            if sweep_data(i) > AP_max
                AP_max = sweep_data(i);
            else
                declining = 1;
                AP_times_number = AP_times_number + 1;
                AP_times(AP_times_number) = i - 1;
                AP_times_shifted(AP_times_number + 1) = i - 1;
                AP_sizes(AP_times_number) = AP_max;
            end 
        end
    else
        if declining == 1 && sweep_data(i) > sweep_data(i-1) && AP_times_number > 0
           declining = 0;
           AP_min_list(AP_times_number) = sweep_data(i-1);
           AP_max = -10000;
        end       
    end
end
AP_times=AP_times(2:AP_times_number);
AP_times_shifted=AP_times_shifted(2:AP_times_number);
AP_min_list=AP_min_list(1:AP_times_number);

frequency = AP_times_number / (duration / filter);
ISI = AP_times - AP_times_shifted;
ISI_values = ISI / filter;
AP_sizes = AP_sizes(1:AP_times_number);
AP_actual_sizes=AP_sizes-AP_min_list;
CV=std(ISI_values)/mean(ISI_values);

title_pos = strcat(ExcelCol(k), '1');
freq_pos = strcat(ExcelCol(k), '2');
mean_pos = strcat(ExcelCol(k), '3');
CV_pos=strcat(ExcelCol(k),'4');
data_pos = strcat(ExcelCol(k), '6');

excel_name = sprintf('%s\\Frequency_%s.xlsx', location, date) %it tells the full path of the file
xlswrite(excel_name, {filename}, 1, title_pos{1});
xlswrite(excel_name, frequency, 1, freq_pos{1});
xlswrite(excel_name, mean(ISI_values), 1, mean_pos{1});
xlswrite(excel_name, CV, 1, CV_pos{1});
xlswrite(excel_name, ISI_values, 1, data_pos{1});

figure(2);
hold on
for j = 1:length(ISI_values)
    line([ISI_values(j) ISI_values(j)], [k-1 k]);
end 
xlabel('Time (sec)'); ylabel('Trial no'); 
set(figure(2), 'Visible', 'On');
  
%figure(3 + k_figure);
%subplot(k_rows, k_rows, k_spot);
%lnISI = log10(ISI_values);
%hist(lnISI, 50);
%xlabel('10\^');
%ylabel('Number of Occurences');
%title({filename});
%set(figure(3 + k_figure), 'Visible', 'On');

buckets = 250;
lags = 25000;
bucketsize = lags / buckets;

if length(sweep_data) >= lags
    lags = length(sweep_data) - 1;
end

a = autocorr(sweep_data, lags);
b = zeros(buckets,1);

for i = 0:(buckets-1)
    b(i+1) = mean(a((i*bucketsize+1):((i+1)*bucketsize),1));
end

%figure(4 + k_figure);
%subplot(k_rows,k_rows,k_spot);
%bar(b);
%title([file 'Autocorr']);
%set(figure(4 + k_figure), 'Visible', 'On');

end