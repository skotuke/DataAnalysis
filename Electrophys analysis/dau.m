close all;

data = abfload('D:\Clouds\One Drive\Electrophysiology\2014\2014\10 2014\31 10\14o31041.abf');
%Use backward slashes 
%datasize is the amount of variables i have. by writing size(data, 1 or 2 or 3) will give me 1st, second or third variable
duration = size(data, 1); %duration is how long the recording was done for.recorded every 100us. tenths of ms. by selecting datasize (1) i select how many points i have which is 1000000. as our filter is set at 10 kHz. 10000 measurements per second=100us
sweeps = size(data, 3);
sweep = input(sprintf('Which sweep do you want to analyse (1 to %d)? ', sweeps));
%sprintf-suformatuos teksta su nezinomu variable (%d)
%input - duoda klausima ir leidzia irasyti

thresh_AP = -20; %what threshold voltage needs to pass to be considered as firing an AP
thresh_burst_gap = 5000; %the gap between two bursts
thresh_AP_for_burst = 3; %how many APs are needed to be considered a burst 
thresh_burst = -50; %the threshold of baseline which has to be crossed to be considered an action potential

figure; %create a figure
plot(data(1:duration, sweep)); %plot plots a graph, 1:duration nuo pirmo iki paskutinio time step
%sweep was decided earlier on

fire = 0; %can be either zero or one, indicating if it is currently firing (if 1)
start = 0; %time steps since the start of the current burst
gap = 0; %time steps since last action potential

bursts = zeros(1000,1000);%duoda tuscia lentele sudeti duomenis apie burst. rows yra atskiriems bursts, colums for at which point action potential is happening
burst_AP_count = zeros(1000,1);%pirmas skaicius rows, antras columns
burst_beg_to_end = zeros(1000,2);%1st column for beginning, antras column for end
burst_gaps = zeros(1000,1);%gap between two bursts
burst_number = 1; %kelinta burst analizuojame
burst_AP_number = 0;%kelintas AP in a burst

AP_max_value = -1000;

for i = 1:duration % visiems taskams nuo 1 iki duration, i- dabar ziurimas taskas; for automatiskai pereina per visus no need for i+1
    if data(i,sweep) > thresh_AP && i < duration % && means and
        if ~fire % ~ means NOT. does this mean a new AP?
            fire = 1;
            if start == 0 %== compares the values, as opposed to priskirti jas
                start = i;
            end

            if burst_AP_number == 0 && burst_number > 1
                burst_gaps(burst_number) = gap;
            end

            burst_AP_number = burst_AP_number + 1;
            bursts(burst_number, burst_AP_number) = i;
            AP_max_value = data(i, sweep);
        elseif data(i, sweep) > AP_max_value
            AP_max_value = data(i, sweep);
            bursts(burst_number, burst_AP_number) = i;
        end

        gap = 0;
    else
        fire = 0;
        gap = gap + 1;

        if (gap > thresh_burst_gap || i == duration) && burst_AP_number > 0 % || or
            if burst_AP_number >= thresh_AP_for_burst
                burst_AP_count(burst_number) = burst_AP_number;
                burst_beg_to_end(burst_number, 1) = bursts(burst_number, 1);
                burst_beg_to_end(burst_number, 2) = bursts(burst_number, burst_AP_number);

                burst_number = burst_number + 1;
                start = 0;
                burst_AP_number = 0;
            else
                start = 0;
                burst_AP_number = 0;
                bursts(burst_number,1:1000) = zeros(1,1000);
            end
        end
    end
end

burst_beg_to_end = burst_beg_to_end(1:burst_number,1:2);
bursts = bursts(1:burst_number,1:max(burst_AP_count));

burst_AP_count = burst_AP_count(1:(burst_number - 1),1);
burst_gaps = burst_gaps(2:(burst_number - 1),1) / 10000;
frequencies = zeros(1:(burst_number - 1),1);
durations = (burst_beg_to_end((1:burst_number - 1),2) - burst_beg_to_end((1:burst_number - 1),1)) / 10000;

for j=1:(burst_number - 1)
    line([burst_beg_to_end(j,1) burst_beg_to_end(j,2)], [5 4], 'Color', 'r');
    frequencies(j,1) = burst_AP_count(j) / (burst_beg_to_end(j,2) - burst_beg_to_end(j,1));
end

figure;
rows = ceil(sqrt(burst_number - 1));

for j=1:(burst_number - 1)
    length = (burst_AP_count(j)-1);
    current_frequencies = zeros(length, 1);
    for k=1:length
        current_frequencies(k) = (bursts(j,k+1) - bursts(j,k)) / 10000;
    end
   
    subplot(rows, rows, j);
    plot(1:length, current_frequencies', 'x');
    p = polyfit(1:length, current_frequencies', 1);
    line([1 length], [p(2), p(1) * length + p(2)], 'Color', 'r');
    text(0, max(current_frequencies), sprintf('a=%.2f', 10000 * p(1)));
end

frequencies = frequencies * 10000;

burst_AP_count'
burst_gaps'
frequencies'
durations'
size(burst_AP_count, 1)

% Duty cycle
cycles = (durations(1:(burst_number-2)) + burst_gaps(1:(burst_number-2)));
percentage_cycles = durations(1:(burst_number-2)) ./ cycles;

csvwrite('bursts.csv', bursts);
csvwrite('bursts_AP_count.csv', burst_AP_count);
csvwrite('burst_gaps.csv', burst_gaps);
csvwrite('burst_frequencies.csv', frequencies);
csvwrite('burst_durations.csv', durations);
csvwrite('burst_cycles.csv', cycles);
csvwrite('burst_percentages.csv', percentage_cycles);

%BOOBS

