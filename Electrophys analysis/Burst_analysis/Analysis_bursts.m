close all
data = abfload('D:\Clouds\One Drive\Electrophysiology\2014\2014\11 2014\14 11\14n14016.abf');

duration = size(data, 1); %duration is how long the recording was done for.recorded every 100us. tenths of ms. by selecting datasize (1) i select how many points i have which is 1000000. as our filter is set at 10 kHz. 
sweeps = size(data, 3);
sweep = input(sprintf('Which sweep do you want to analyse (1 to %d, or 0 for all)? ', sweeps));
if sweep==0
    sweep=1;
    data=reshape(data, duration*sweeps,1);
    duration=duration*sweeps;
end

[ISI_values,AP_sizes,AP_number]=Analysis(data,sweep,1,1);

 
ISI_thresh = input('What determines interburst period? ');
burst_number=0;
burst_gap_IDs=zeros(1000,1);

for j=1:length(ISI_values)
    if ISI_values(j)>ISI_thresh
        burst_number=burst_number+1;
        burst_gap_IDs(burst_number)=j;
    end   
end


interburst_gaps=zeros(1000,1);
burst_lengths=zeros(1000,1);
burst_AP_counts=zeros(1000,1);
real_burst_number=0;
duty_cycles=zeros(1000,1);
k_total=0;


for j=2:burst_number
    AP_count=burst_gap_IDs(j)-burst_gap_IDs(j-1);
    if AP_count>2
        k_total=k_total+1;
        interburst_gaps(k_total)=ISI_values(burst_gap_IDs(j));
    end
end

k_rows=ceil(sqrt(k_total));
k=1;
intraburst_number=1;
intraburst_gaps=zeros(10000,1);

for j=2:burst_number
    AP_count=burst_gap_IDs(j)-burst_gap_IDs(j-1);
    if AP_count>2
        real_burst_number=real_burst_number+1;
        burst_AP_counts(real_burst_number)=AP_count;
        burst_lengths(real_burst_number)=sum(ISI_values((burst_gap_IDs(j-1)+1):(burst_gap_IDs(j)-1)));
        duty_cycles(real_burst_number)=ISI_values(burst_gap_IDs(j))+burst_lengths(real_burst_number);
        
        intraburst_gaps(intraburst_number:(intraburst_number+AP_count-2)) = ISI_values((burst_gap_IDs(j-1)+1):(burst_gap_IDs(j)-1));
        intraburst_number = intraburst_number + AP_count-1;
        
        figure(5);
        subplot(k_rows,k_rows,k);
        plot (AP_sizes((burst_gap_IDs(j-1)+1):(burst_gap_IDs(j)))/AP_sizes(burst_gap_IDs(j-1)+1));
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

burst_AP_counts=burst_AP_counts(1:real_burst_number);
burst_lengths=burst_lengths(1:real_burst_number);
burst_frequencies=burst_AP_counts./burst_lengths;
duty_cycles=duty_cycles(1:real_burst_number);
perc_firing=burst_lengths./duty_cycles;
interburst_gaps=interburst_gaps(1:real_burst_number);
intraburst_gaps=intraburst_gaps(1:intraburst_number);

figure(7)
hist(intraburst_gaps,50);
xlabel('Intraburst gap duration (sec)');
ylabel('Frequency');
title('Intraburst histogram');

figure(8);
hist(interburst_gaps,10);
xlabel('Interburst gap duration (sec)');
ylabel('Frequency');
title('Interburst histogram');

   

