function [ISI_values,AP_sizes,AP_number]=Analysis(data,sweep,k,k_total,filter)

if nargin < 5
    filter = 10000;
end;

k_rows=ceil(sqrt(k_total));
duration = size(data, 1);
duration_s=(1/filter):(1/filter):(duration/filter);%zero does not exist in matlab, therefore it starts at the smallest point.
sweep_data=data(1:duration,1,sweep);

figure(1);
subplot(k_rows,k_rows,k);
plot(duration_s,sweep_data);
xlabel('Time (sec)');
ylabel('Voltage(mV)');
 
thresh_AP = -20; %what threshold voltage needs to pass to be considered as firing an AP
 
fire = 0; %can be either zero or one, indicating if it is currently firing (if 1) or not (0)
 
AP_number = 0;%kelintas AP in a burst
AP_times=zeros(10000,1);
AP_times_shifted=zeros(10000,1);
AP_max = -1000;
declining=0;
AP_times_number=0;
AP_sizes=zeros(10000,1);
 
for i = 1:duration 
    if sweep_data(i) > thresh_AP 
        if fire==0
            fire=1;
            AP_number=AP_number+1;
        end
         
        if sweep_data(i)>AP_max && declining==0
             AP_max=sweep_data(i);
        elseif sweep_data(i)<AP_max 
                 declining=1;
             AP_times_number=AP_times_number+1;
             AP_times(AP_times_number)=i-1;
             AP_times_shifted(AP_times_number+1)=i-1;
             AP_sizes(AP_times_number)=AP_max;
             AP_max=-10000;
            
        end 
    else
          fire=0;
          declining=0;  
    end
end

frequency=(AP_number/duration)*filter
ISI=AP_times-AP_times_shifted;
ISI_number=AP_number-1;
ISI_values=ISI(2:AP_number)/filter;
AP_sizes=AP_sizes(1:AP_times_number);


figure(2);
hold on
  for j=1:length(ISI_values)
      line([ISI_values(j) ISI_values(j)], [k-1 k]);
  end 
 xlabel('Time (sec)'); ylabel('Trial no');  
  
figure(3);
subplot(k_rows,k_rows,k);
lnISI=log(ISI_values);
hist(lnISI,50);
xlabel('10\^');
ylabel('Number of Occurences');

buckets = 250;
lags=25000;
bucketsize = lags / buckets;


a = autocorr(sweep_data, lags);
b = zeros(buckets,1);

for i = 0:(buckets-1)
    b(i+1) = mean(a((i*bucketsize+1):((i+1)*bucketsize),1));
end
figure(4);
subplot(k_rows,k_rows,k);
bar(b);
end