function [AP_sizes_list, AP_actual_sizes_table, AP_number]=CurrentStepsFunctionThresh(data, filename, output_folder, m, show_figures, location, name)


formatOut = 'HH-MM-SS';
fulltime=strcat(date,{' '}, datestr(now,formatOut));

if nargin < 5
    show_figures = 1;
end

k_rows=4;
duration = 115000:217700;
duration_s=duration/100000;

sweeps=size(data,3);
step_number=(1:sweeps)';

ISI_average_list=zeros(sweeps,1);
AP_average_list=zeros(100,1);
AP_actual_sizes_averages_list=zeros(100,1);
current_injection=-50:50:700;

figure(1 + m * 10);
set(1 + m * 10, 'Name', filename);
hold on
for j=1:size(data,3)
    subplot(k_rows,k_rows,j);
    plot(duration_s,data(duration,1,j));
    xlabel('Time (sec)');
    ylabel('Voltage (mV)');
end

thresh_AP = -20; %what threshold voltage needs to pass to be considered as firing an AP

frequency_list=zeros(sweeps,1);
ISI_values_list=zeros(100,sweeps);
AP_sizes_list=zeros(100,sweeps);
AP_actual_sizes_table=zeros(100,sweeps);
AP_normalised=zeros(sweeps,1);
AP_actual_sizes_averages_table=zeros(100,sweeps);

for j=1:sweeps
    AP_number = 0;
    AP_times=zeros(100,1);
    AP_times_shifted=zeros(100,1);
    AP_sizes=zeros(100,1);
    AP_mins=zeros(100,1); %a list of mins of APs in a sweep
    AP_max=-1000;
    declining=0;
    AP_times_number=0;
    AP_min_recorded=1;
    sweep_data=data(1:size(data,1),1,j);
    fire = 0;
  
    for i = duration
        if sweep_data(i) > thresh_AP 
            if fire==0
                fire=1;
                AP_number=AP_number+1;
            end

            if sweep_data(i) > AP_max && declining == 0
                 AP_max=sweep_data(i);
            elseif sweep_data(i) < AP_max 
                 declining=1;
                 AP_times_number=AP_times_number+1;
                 AP_times(AP_times_number)=i-1;
                 AP_times_shifted(AP_times_number+1)=i-1;
                 AP_sizes(AP_times_number)=AP_max;
                 AP_min_recorded=0;
                 AP_max=-10000;
            end 
        else
            fire=0;
            declining=0;  

            if sweep_data(i) > sweep_data(i-1) && ~AP_min_recorded
                AP_min=sweep_data(i-1);
                AP_mins(AP_times_number)=AP_min;
                AP_min_recorded=1;
            end
        end
    end
    
    if AP_times_number < 1
        continue
    end
    
    AP_sizes=AP_sizes(1:AP_times_number); 
    AP_mins=AP_mins(1:(AP_times_number)); %cutting the list of AP mins to get rid of extra zeros.AP_times_number-1 because the minimum after the last action potential is no in a current step anymore
    AP_actual_sizes=AP_sizes-AP_mins; %the list of actualAP sizes. baseline min precedes it action potential
    AP_actual_sizes_average=mean(AP_actual_sizes); %AP average size for a sweep
    AP_actual_sizes_averages_list(j)=AP_actual_sizes_average;
    AP_normalised(j)=mean(AP_actual_sizes./AP_actual_sizes(1));
    frequency=AP_number;
    frequency_list(j)=frequency;
    
    if AP_times_number > 1
        AP_times_cut=AP_times(2:(AP_times_number));
        AP_times_shifted=AP_times_shifted(2:(AP_times_number));
        ISI=AP_times_cut-AP_times_shifted;
        ISI_number=AP_number-1;
        ISI_values=ISI/10000;
        ISI_values_list(1:(AP_number-1),j)=ISI_values;
        ISI_average=(sum(ISI_values))/ISI_number;
        ISI_average_list(j)=ISI_average;
    end
    
    AP_sizes_list(1:AP_times_number,j)=AP_sizes;
    AP_actual_sizes_table(1:(AP_times_number),j)=AP_actual_sizes;
    AP_average=mean(AP_sizes);
    AP_average_list(j)=AP_average;

    if AP_number > 0
        AP_actual_sizes_averages_table(1:AP_times_number, j)=AP_actual_sizes./AP_actual_sizes(1); 
    end
    
    if show_figures
        if AP_times_number > 1
            figure(2 + m * 10);
            set(2 + m * 10, 'Name', filename);
            hold on
            for k=1:(length(ISI_values)-1);
              line([ISI_values(k) ISI_values(k)], [j-1 j]);
            end 
            xlabel('ISI duration(sec)'); ylabel('#Sweep');
        
            figure(3 + m * 10);
            set(3 + m * 10, 'Name', filename);
            subplot(k_rows,k_rows,j);
            plot (ISI_values);
            xlabel('#ISI in a sweep');
            ylabel('Duration (sec)');
        end
        
        figure(4 + m * 10);
        set(4 + m * 10, 'Name', filename);
        subplot(k_rows,k_rows,j);
        if AP_number > 0 
            plot ((AP_sizes./AP_sizes(1)));
        end
        xlabel('#AP in a sweep');
        ylabel('Normalized peaks');

        figure(5 + m * 10);
        set(5 + m * 10, 'Name', filename);
        subplot(k_rows,k_rows,j);
        plot(AP_actual_sizes);
        xlabel('#AP in a sweep');
        ylabel('Actual size (mV)');

        figure(6 + m * 10);
        set(6 + m * 10, 'Name', filename);
        subplot(k_rows,k_rows,j);
        if AP_number > 0 
            plot ((AP_actual_sizes./AP_actual_sizes(1)));
        end
        xlabel('#AP in a sweep');
        ylabel('Normalised (actual)');
    end
end

ISI_values_list_filtered=ISI_values_list;
ISI_values_list_filtered(ISI_values_list_filtered==0)=nan;

AP_actual_sizes_averages_table_filtered=AP_actual_sizes_averages_table;
AP_actual_sizes_averages_table_filtered(AP_actual_sizes_averages_table_filtered==0)=nan;

AP_average_list=AP_average_list(1:(sweeps));
AP_actual_sizes_averages_list=AP_actual_sizes_averages_list(1:(sweeps));

AP_actual_sizes_table_filtered=AP_actual_sizes_table;
AP_actual_sizes_table_filtered(AP_actual_sizes_table==0)=nan;

if show_figures
    figure(7 + m * 10);
    set(7 + m * 10, 'Name', filename);
    scatter((current_injection),frequency_list./10);
    xlabel('Injected current (pA)');
    ylabel('Frequency (Hz)');

    figure(8 + m * 10);
    set(8 + m * 10, 'Name', filename);
    scatter(current_injection,ISI_average_list);
    xlabel('Injected current (pA)');
    ylabel('Mean ISI (sec)');

    figure(9 + m * 10);
    set(9 + m * 10, 'Name', filename);
    scatter(current_injection,AP_average_list);
    xlabel('Injected current (pA)');
    ylabel ('AP peak (mV)');

    figure (10+m*10);
    set(10 + m * 10, 'Name', filename);
    scatter(current_injection, AP_actual_sizes_averages_list);
    xlabel('Injected current (pA)');
    ylabel('Actual action potential size (mV)');
end

warning('off', 'MATLAB:xlswrite:AddSheet');
excel_name = sprintf('%s\\current_steps_%s.xlsx', location, date); %it tells the full path of the file
xlswrite(excel_name, {filename}, m, 'A1');
xlswrite(excel_name, {'Step'}, m, 'B1');
xlswrite(excel_name, step_number, m, 'B2');
xlswrite(excel_name, {'Current'}, m, 'C1');
xlswrite(excel_name, current_injection', m, 'C2');
xlswrite(excel_name, {'Frequency'}, m, 'D1');
xlswrite(excel_name, frequency_list, m, 'D2');
xlswrite(excel_name, {'AP actual size'}, m, 'E1');
xlswrite(excel_name, AP_actual_sizes_averages_list, m, 'E2');
xlswrite(excel_name, {'AP normalised'}, m, 'F1');
xlswrite(excel_name, AP_normalised , m, 'F2');
xlswrite(excel_name, {'Average ISI'}, m, 'G1');
xlswrite(excel_name, ISI_average_list, m, 'G2');

excel_name = sprintf('%s\\ISI_values_%s.xlsx', location, date);
xlswrite(excel_name, {filename}, m, 'A1');
xlswrite(excel_name, {'ISI values'},m, 'A3');
xlswrite(excel_name, transpose(step_number),m, 'B3');
xlswrite(excel_name, {'Step'}, m, 'B2');
xlswrite(excel_name, ISI_values_list_filtered,m, 'B4');

excel_name = sprintf('%s\\AP_normalised_%s.xlsx', location, date);
xlswrite(excel_name, {filename}, m, 'A1');
xlswrite(excel_name, {'Normalised AP'},m, 'A3');
xlswrite(excel_name, transpose(step_number),m, 'B3');
xlswrite(excel_name, {'Step'}, m, 'B2');
xlswrite(excel_name, AP_actual_sizes_averages_table_filtered,m, 'B4');

excel_name = sprintf('%s\\AP_actual_sizes_%s.xlsx', location, date);
xlswrite(excel_name, {filename}, m, 'A1');
xlswrite(excel_name, {'Actual AP'},m, 'A3');
xlswrite(excel_name, transpose(step_number),m, 'B3');
xlswrite(excel_name, {'Step'}, m, 'B2');
xlswrite(excel_name, AP_actual_sizes_table_filtered, m, 'B4');