function [AP_sizes_list, AP_actual_sizes_table, potential_AP_number]=CurrentStepsFunction(data, filename, output_folder, m, show_figures, location, name)

if nargin < 5
    show_figures = 1;
end

k_rows=4;
duration_start = 115000;
duration_end = 215500;
duration = duration_start:duration_end;
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
set (figure(1+m*10), 'visible','off');
for j=1:size(data,3)
    subplot(k_rows,k_rows,j);
    plot(duration_s,data(duration,1,j));
    xlabel('Time (sec)');
    ylabel('Voltage (mV)');
end

frequency_list=zeros(sweeps,1);
ISI_values_list=zeros(100,sweeps);
AP_sizes_list=zeros(100,sweeps);
AP_actual_sizes_table=zeros(100,sweeps);
AP_normalised=zeros(sweeps,1);
AP_actual_sizes_averages_table=zeros(100,sweeps);

for j=1:sweeps
    AP_times=zeros(100,1);
    ISI=zeros(100,1);
    potential_AP_times=zeros(500,1);
    potential_AP_number=0;
    AP_number=0;
    AP_sizes=zeros(100,1);
    sweep_data=data(1:size(data,1),1,j);
    fire = 0;

    if j==1
        baseline_mean=mean(data(1:115000));
        step_mean=mean(data(150000:210000));
        input_resistance=(baseline_mean-step_mean)/50*1000;     
    end
  
    mavg = 0;
    mavgcount = 0;
    AP_min_last = -1000;
    AP_max_last = 1000;
    AP_last_real = 0;
    
    for i = duration
        mavg = mavg + sweep_data(i-1);
        mavgcount = mavgcount + 1;
        if mavgcount > 100
           mavg = mavg - sweep_data(i-101);
           mavgcount = mavgcount - 1;
        end
        
        
        if sweep_data(i) > mavg / mavgcount || i == duration_end %increasing
            if fire == 0
                fire = 1;
                if potential_AP_number > 0
                    peak = i - mavgcount;
                    for n = 1:(mavgcount - 1)
                       if sweep_data(i - mavgcount + n) < sweep_data(peak)
                           peak = i - mavgcount + n;
                       end
                    end
                   
                    
                    AP_min = sweep_data(peak);
                    AP_size = AP_max-AP_min;
                    AP_min_last = AP_min;
                    AP_last_real = 0;
                    if AP_size > 10 && (AP_number == 0 || AP_size > 0.5 * AP_sizes(AP_number) || AP_size > 15)
                        AP_number = AP_number + 1;
                        AP_last_real = 1;
                        AP_sizes(AP_number) = AP_size;
                        AP_times(AP_number) = potential_AP_times(potential_AP_number);
                        if AP_number > 1
                            ISI(AP_number - 1) = AP_times(AP_number) - AP_times(AP_number - 1);
                        end
                    end
                end
            end
        elseif sweep_data(i) < mavg / mavgcount
            if fire == 1
                peak = i - mavgcount;
                for n = 1:(mavgcount - 1)
                   if sweep_data(i - mavgcount + n) > sweep_data(peak)
                       peak = i - mavgcount + n;
                   end
                end
                
                if sweep_data(peak) - AP_min_last < 2
                    fire = 0;
                    AP_max = AP_max_last;
                    if AP_last_real
                        AP_number = AP_number - 1;
                    end
                else
                    potential_AP_number = potential_AP_number + 1;
                    fire = 0;  
                    AP_max = sweep_data(peak);
                    AP_max_last = AP_max;
                    potential_AP_times(potential_AP_number) = peak;
                end
            end
        end   
    end

    if AP_number < 1
        continue
    end


    if AP_number > 1
        ISI = ISI(1:(AP_number-1));
        mean_ISI = mean(ISI);
        for n = 1:(AP_number - 1)
            if ISI(n) > mean_ISI * 3 && AP_sizes(n)<30;
                AP_number = n;
                ISI = ISI(1:n-1); 
                break
            end
        end
            
        ISI_number=AP_number-1;
        ISI_values=ISI/100000;
        ISI_values_list(1:length(ISI_values),j)=ISI_values;
        ISI_average=(sum(ISI_values))/ISI_number;
        ISI_average_list(j)=ISI_average;
    end

    AP_sizes=AP_sizes(1:AP_number); 
    AP_actual_sizes_average=mean(AP_sizes); %AP average size for a sweep
    AP_actual_sizes_averages_list(j)=AP_actual_sizes_average;
    AP_normalised(j)=mean(AP_sizes./AP_sizes(1));
    frequency=AP_number;
    frequency_list(j)=frequency;

    AP_sizes_list(1:AP_number,j)=AP_sizes;
    AP_actual_sizes_table(1:(AP_number),j)=AP_sizes;
    AP_average=mean(AP_sizes);
    AP_average_list(j)=AP_average;

    if AP_number > 0
        AP_actual_sizes_averages_table(1:AP_number, j)=AP_sizes./AP_sizes(1); 
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
        if potential_AP_number > 0 
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
        if potential_AP_number > 0 
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
xlswrite(excel_name, {'APs'}, m, 'D1');
xlswrite(excel_name, frequency_list, m, 'D2');
average_frequencies = 1 ./ ISI_average_list;
average_frequencies(~isfinite(average_frequencies)) = 0;
xlswrite(excel_name, {'AV frequency'}, m, 'E1');
xlswrite(excel_name, average_frequencies, m, 'E2');
xlswrite(excel_name, input_resistance, m, 'E19');
xlswrite(excel_name, {'AP actual size'}, m, 'F1');
xlswrite(excel_name, AP_actual_sizes_averages_list, m, 'F2');
xlswrite(excel_name, {'AP normalised'}, m, 'G1');
xlswrite(excel_name, AP_normalised , m, 'G2');
xlswrite(excel_name, {'Average ISI'}, m, 'H1');
xlswrite(excel_name, ISI_average_list, m, 'H2');


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

title_pos = strcat(ExcelCol(m+1), '1');
freq_pos = strcat(ExcelCol(m+1), '2');
input_pos = strcat(ExcelCol(m+1), '19');

excel_name = sprintf('%s\\CS APs summary_%s.xlsx', location, date); %it tells the full path of the file
xlswrite(excel_name, {'Current'}, 1, 'A1');
xlswrite(excel_name, current_injection', 1, 'A2');
xlswrite(excel_name, {filename}, 1, title_pos{1});
xlswrite(excel_name, frequency_list, 1, freq_pos{1});


excel_name = sprintf('%s\\CS AP normalised summary_%s.xlsx', location, date); %it tells the full path of the file
xlswrite(excel_name, {'Current'}, 1, 'A1');
xlswrite(excel_name, current_injection', 1, 'A2');
xlswrite(excel_name, {filename}, 1, title_pos{1});
xlswrite(excel_name, AP_normalised, 1, freq_pos{1});

excel_name = sprintf('%s\\CS freq summary_%s.xlsx', location, date); %it tells the full path of the file
xlswrite(excel_name, {'Current'}, 1, 'A1');
xlswrite(excel_name, current_injection', 1, 'A2');
xlswrite(excel_name, {filename}, 1, title_pos{1});
xlswrite(excel_name, average_frequencies, 1, freq_pos{1});
xlswrite(excel_name, {'Input resistance'}, 1, 'A19');
xlswrite(excel_name, input_resistance, 1, input_pos{1});

