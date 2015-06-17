function [] = Burst_Analysis (ISI_values, AP_actual_sizes, ISI_thresh, filename, m, location)

burst_AP_limit = 1;
burst_number = 0;
burst_gaps = zeros(1000,1);
burst_gap_IDs = zeros(1000,1);
average_intraburst_gap = zeros(1000,1);

formatOut = 'HH-MM-SS';
fulltime=strcat(date,{' '}, datestr(now,formatOut));

for j=1:length(ISI_values)
    if ISI_values(j)>ISI_thresh
        burst_number=burst_number+1;
        burst_gaps(burst_number)=ISI_values(j);
        burst_gap_IDs(burst_number)=j;
    end
end   

burst_lengths=zeros(1000,1);
burst_AP_counts=zeros(1000,1);
true_burst_number=0;
true_burst_number_ID=zeros(1000,1);
duty_cycles=zeros(1000,1);
k_total=0;
burst_AP_sizes=zeros(1000,1000);
burst_AP_sizes_normalised=zeros(1000,1000);

for j=2:burst_number
    AP_count=burst_gap_IDs(j)-burst_gap_IDs(j-1);
    if AP_count>burst_AP_limit
       k_total=k_total+1;
    end
end

k_rows=ceil(sqrt(k_total));
k=1;
intraburst_number=1;
intraburst_gaps=zeros(10000,1);
true_burst_gap=zeros(1000,1);


for j=2:burst_number
    AP_count = burst_gap_IDs(j) - burst_gap_IDs(j-1);
    
    if AP_count>burst_AP_limit
        true_burst_number=true_burst_number+1;
        true_burst_number_ID(true_burst_number)=true_burst_number;
        burst_AP_counts(true_burst_number)=AP_count;
        burst_lengths(true_burst_number)=sum(ISI_values((burst_gap_IDs(j-1)+1):(burst_gap_IDs(j)-1)));
        duty_cycles(true_burst_number)=ISI_values(burst_gap_IDs(j))+burst_lengths(true_burst_number);%sum of the burst and the gap following the burst
        true_burst_gap(true_burst_number)=ISI_values(burst_gap_IDs(j));%gap after the burst in question

        intraburst_gaps(intraburst_number:(intraburst_number+AP_count-2)) = ISI_values((burst_gap_IDs(j-1)+1):(burst_gap_IDs(j)-1));
        intraburst_number = intraburst_number + AP_count-1;
        average_intraburst_gap(true_burst_number)=mean(ISI_values((burst_gap_IDs(j-1)+1):(burst_gap_IDs(j)-1)));
        
        burst_range = ((burst_gap_IDs(j-1)+1):burst_gap_IDs(j));% numbers refering to ISI intervals belonging to that duty cycle
        sizes_range = burst_range - burst_gap_IDs(j-1);
        burst_AP_sizes(sizes_range, true_burst_number)=AP_actual_sizes(burst_range);
        burst_AP_sizes_normalised(sizes_range, true_burst_number)=AP_actual_sizes(burst_range)/AP_actual_sizes(burst_gap_IDs(j-1)+1);

        figure(5);
        subplot(k_rows,k_rows,k);
        plot (AP_actual_sizes(burst_range)/AP_actual_sizes(burst_gap_IDs(j-1)+1));
        xlabel('#AP');
        ylabel('Normalised');

        figure(6);
        subplot(k_rows,k_rows,k);
        plot (ISI_values((burst_gap_IDs(j-1)+1):(burst_gap_IDs(j)-1)));
        xlabel('#ISI');
        ylabel('Duration');
        k=k+1;
    end
end

burst_number;
true_burst_number;

burst_AP_counts=burst_AP_counts(1:true_burst_number);
true_burst_number_ID=true_burst_number_ID(1:true_burst_number);
burst_lengths=burst_lengths(1:true_burst_number);
burst_frequencies=burst_AP_counts./burst_lengths;
duty_cycles=duty_cycles(1:true_burst_number);
perc_firing=burst_lengths./duty_cycles;
total_firing=sum(burst_lengths)/sum(duty_cycles);
burst_gaps=burst_gaps(1:true_burst_number);
intraburst_gaps=intraburst_gaps(1:true_burst_number);
true_burst_gap=true_burst_gap(1:true_burst_number);
average_intraburst_gap=average_intraburst_gap(1:true_burst_number);

figure(7)
hist(intraburst_gaps,50);
xlabel('Intraburst gap duration (sec)');
ylabel('Frequency');
title('Intraburst histogram');

figure(8);
hist(burst_gaps,10);
xlabel('Interburst gap duration (sec)');
ylabel('Frequency');
title('Interburst histogram');

burst_AP_sizes_filtered=burst_AP_sizes;
burst_AP_sizes_filtered(burst_AP_sizes_filtered==0)=nan;

burst_AP_sizes_normalised_filtered=burst_AP_sizes_normalised;
burst_AP_sizes_normalised_filtered(burst_AP_sizes_normalised_filtered==0)=nan;

excel_name = sprintf('%sburst_frequencies_%s.xlsx', location, date) %it tells the full path of the file
xlswrite(excel_name, {filename}, m, 'A1');
xlswrite(excel_name, {'Average'}, m, 'A2');
xlswrite(excel_name, {total_firing} , m, 'A3');
xlswrite(excel_name, {'Burst No'}, m, 'B1');
xlswrite(excel_name, true_burst_number_ID , m, 'B4');
xlswrite(excel_name, {'Frequency'}, m, 'C1');
xlswrite(excel_name, {mean(burst_frequencies(1:true_burst_number))}, m, 'C2');
xlswrite(excel_name, burst_frequencies, m, 'C4');
xlswrite(excel_name, {'Burst Duration'}, m, 'D1');
xlswrite(excel_name, {mean(burst_lengths(1:true_burst_number))}, m, 'D2');
xlswrite(excel_name, burst_lengths, m, 'D4');
xlswrite(excel_name, {'Gap After'}, m, 'E1');
xlswrite(excel_name, {mean(true_burst_gap(1:true_burst_number))}, m, 'E2');
xlswrite(excel_name, true_burst_gap, m, 'E4');
xlswrite(excel_name, {'Duty Cycle'}, m, 'F1');
xlswrite(excel_name, {mean(duty_cycles(1:true_burst_number))}, m, 'F2');
xlswrite(excel_name, duty_cycles, m, 'F4');
xlswrite(excel_name, {'% Firing'}, m, 'G1');
xlswrite(excel_name, {mean(perc_firing(1:true_burst_number))*100}, m, 'G2');
xlswrite(excel_name, perc_firing*100, m, 'G4');
xlswrite(excel_name, {'Intraburst gap'}, m, 'H1');
xlswrite(excel_name, {mean(average_intraburst_gap(1:true_burst_number))}, m, 'H2');
xlswrite(excel_name, average_intraburst_gap, m, 'H4');
xlswrite(excel_name, {'AP count'}, m, 'I1');
xlswrite(excel_name, {mean(burst_AP_counts)}, m, 'I2');
xlswrite(excel_name, burst_AP_counts, m, 'I4');

path = fileparts(mfilename('fullpath'));
excel_name = sprintf('%s\\APs_in_bursts_%s.xlsx', location, date);
xlswrite(excel_name, {filename}, m, 'A1');
xlswrite(excel_name, {'Burst No'}, m, 'A2');
xlswrite(excel_name, transpose(true_burst_number_ID), m, 'B2');
xlswrite(excel_name,burst_AP_sizes_filtered , m, 'B3');

path = fileparts(mfilename('fullpath'));
excel_name = sprintf('%s\\APs_in_bursts_normalized_%s.xlsx', location, date);
xlswrite(excel_name, {filename}, m, 'A1');
xlswrite(excel_name, {'Burst No'}, m, 'A2');
xlswrite(excel_name, transpose(true_burst_number_ID), m, 'B2');
xlswrite(excel_name,burst_AP_sizes_normalised_filtered , m, 'B3');