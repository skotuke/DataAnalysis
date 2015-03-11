function CurrentStepsFunction(data, figure_number, filename)

k_rows=4;
duration = 115000:217700;
duration_s=duration/100000;

ISI_average_list=zeros(20,1);
AP_average_list=zeros(20,1);
AP_actual_sizes_averages_list=zeros(20,1);

sweeps=size(data,3);
    

figure(1 + figure_number * 10);
set(1 + figure_number * 10, 'Name', filename);
hold on
for j=1:size(data,3)
    subplot(k_rows,k_rows,j);
    plot(duration_s,data(duration,1,j));
    xlabel('Time (sec)');
    ylabel('Voltage (mV)');
end

thresh_AP = -20; %what threshold voltage needs to pass to be considered as firing an AP

frequency_list=zeros(size(data,3),1);
ISI_values_list=zeros(1000,size(data,3));
AP_sizes_list=zeros(1000,size(data,3));
AP_actual_sizes_table=zeros(1000,size(data,3));

for j=1:size(data,3)
    AP_number = 0;
    AP_times=zeros(1000,1);
    AP_times_shifted=zeros(1000,1);
    AP_sizes=zeros(1000,1);
    AP_mins=zeros(1000,1); %a list of mins of APs in a sweep
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
    
    if AP_times_number == 0
        continue
    end
    
    AP_sizes=AP_sizes(1:AP_times_number); 
    AP_sizes_without_first=AP_sizes(2:AP_times_number);
    AP_mins=AP_mins(1:(AP_times_number-1)); %cutting the list of AP mins to get rid of extra zeros.AP_times_number-1 because the minimum after the last action potential is no in a current step anymore
    
    AP_actual_sizes_list=AP_sizes_without_first-AP_mins; %the list of actualAP sizes. baseline min precedes it action potential
    AP_actual_sizes_average=(sum(AP_actual_sizes_list))/(AP_times_number-1); %AP average size for a sweep
    AP_actual_sizes_averages_list(j)=AP_actual_sizes_average;
    frequency=AP_number;
    frequency_list(j)=frequency;
    ISI=AP_times-AP_times_shifted;
    ISI_number=AP_number-1;
    ISI_values=ISI(2:AP_number)/10000;
    ISI_values_list(1:(AP_number-1),j)=ISI_values;
    ISI_average=(sum(ISI_values))/ISI_number;
    ISI_average_list(j)=ISI_average;
    AP_sizes_list(1:AP_number,j)=AP_sizes;
    AP_actual_sizes_table(1:(AP_number-1),j)=AP_actual_sizes_list;
    AP_average=(sum(AP_sizes))/AP_times_number;
    AP_average_list(j)=AP_average;
    
    figure(2 + figure_number * 10);
    set(2 + figure_number * 10, 'Name', filename);
    hold on
    for k=1:(length(ISI_values)-1);
      line([ISI_values(k) ISI_values(k)], [j-1 j]);
    end 
    xlabel('ISI duration(sec)'); ylabel('#Sweep');
    
    figure(3 + figure_number * 10);
    set(3 + figure_number * 10, 'Name', filename);
    subplot(k_rows,k_rows,j);
    plot (ISI_values);
    xlabel('#ISI in a sweep');
    ylabel('Duration (sec)');
    
    figure(4 + figure_number * 10);
    set(4 + figure_number * 10, 'Name', filename);
    subplot(k_rows,k_rows,j);
    if AP_number > 0 
        plot ((AP_sizes./AP_sizes(1)));
        AP_actual_sizes_averages_table(1:AP_number,j)=AP_sizes./AP_sizes(1);
    end
    xlabel('#AP in a sweep');
    ylabel('Normalized peaks');
   
    figure(5 + figure_number * 10);
    set(5 + figure_number * 10, 'Name', filename);
    subplot(k_rows,k_rows,j);
    plot(AP_actual_sizes_list);
    xlabel('#AP in a sweep');
    ylabel('Actual size (mV)');
    
    
    figure(6 + figure_number * 10);
    set(6 + figure_number * 10, 'Name', filename);
    subplot(k_rows,k_rows,j);
    if AP_number > 0 
        plot ((AP_actual_sizes_list./AP_actual_sizes_list(1)));
    end
    xlabel('#AP in a sweep');
    ylabel('Normalised (actual)');
end


ISI_values_list_filtered=ISI_values_list;
ISI_values_list_filtered(ISI_values_list_filtered==0)=nan;

AP_actual_sizes_averages_table_filtered=AP_actual_sizes_averages_table;
AP_actual_sizes_averages_table_filtered(AP_actual_sizes_averages_table_filtered==0)=nan;

ISI_average_list=ISI_average_list(1:sweeps);



figure(7 + figure_number * 10);
set(7 + figure_number * 10, 'Name', filename);
current_injection=-50:50:700;
scatter((current_injection),frequency_list./10);
xlabel('Injected current (pA)');
ylabel('Frequency (Hz)');

figure(8 + figure_number * 10);
set(8 + figure_number * 10, 'Name', filename);
scatter(current_injection,ISI_average_list);
xlabel('Injected current (pA)');
ylabel('Mean ISI (sec)');

AP_average_list=AP_average_list(1:(sweeps));
figure(9 + figure_number * 10);
set(9 + figure_number * 10, 'Name', filename);
scatter(current_injection,AP_average_list);
xlabel('Injected current (pA)');
ylabel ('AP peak (mV)');

AP_actual_sizes_averages_list=AP_actual_sizes_averages_list(1:(sweeps));
figure (10+figure_number*10);
set(10 + figure_number * 10, 'Name', filename);
scatter(current_injection, AP_actual_sizes_averages_list);
xlabel('Injected current (pA)');
ylabel('Actual action potential size (mV)');

warning('off', 'MATLAB:xlswrite:AddSheet');
title_pos = strcat(ExcelCol(figure_number), '1');
data_pos = strcat(ExcelCol(figure_number), '2');

excel_name = 'frequency_list.xlsx';
xlswrite(excel_name, {filename}, 1, title_pos{1});
xlswrite(excel_name, frequency_list, 1, data_pos{1});

excel_name = 'isi_values_list_filtered.xlsx';
xlswrite(excel_name, ISI_values_list_filtered, figure_number);

e = actxserver('Excel.Application'); 
ewb = e.Workbooks.Open(fullfile(pwd, excel_name)); 
ewb.Worksheets.Item(figure_number).Name = filename; 
ewb.Save;
ewb.Close(false);
e.Quit;


excel_name = 'AP_actual_sizes_averages_table_filtered.xlsx';
xlswrite(excel_name, AP_actual_sizes_averages_table_filtered, figure_number);

e = actxserver('Excel.Application'); 
ewb = e.Workbooks.Open(fullfile(pwd, excel_name)); 
ewb.Worksheets.Item(figure_number).Name = filename; 
ewb.Save;
ewb.Close(false);
e.Quit;


excel_name = 'AP_actual_sizes_table.xlsx';
xlswrite(excel_name, AP_actual_sizes_table, figure_number);

e = actxserver('Excel.Application'); 
ewb = e.Workbooks.Open(fullfile(pwd, excel_name)); 
ewb.Worksheets.Item(figure_number).Name = filename; 
ewb.Save;
ewb.Close(false);
e.Quit;


excel_name='AP_actual_sizes_averages_list.xlsx';
xlswrite(excel_name,{filename}, 1, title_pos{1});
xlswrite(excel_name, AP_actual_sizes_averages_list, 1, data_pos{1});

excel_name='ISI_average_list.xlsx';
xlswrite(excel_name,{filename}, 1, title_pos{1});
xlswrite(excel_name, ISI_average_list, 1, data_pos{1});
