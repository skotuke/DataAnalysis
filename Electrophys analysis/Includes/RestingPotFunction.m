function [rest_pot_avg, rest_pot_list]=RestingPotFunction(data, filename, output_folder, m, location, name)

sweeps=size(data,3);
step_number=(1:sweeps)';
rest_pot_list=zeros(sweeps,1);
current_injection=100:100:800;

for j=1:sweeps
    sweep_data=data(1:size(data,1),1,j);
    rest_pot_list(j)=mean(sweep_data(915000:1000000));
end 

figure(m);
set(m, 'Name', filename);
scatter(current_injection, rest_pot_list);
xlabel('Injected current (pA)');
ylabel ('Resting mebrane potential (mV)');
rest_pot_avg=mean(rest_pot_list);

warning('off', 'MATLAB:xlswrite:AddSheet');
excel_name = sprintf('%s\\rest_pot_%s.xlsx', location, date); %it tells the full path of the file
xlswrite(excel_name, {filename}, m, 'A1');
xlswrite(excel_name, {'Step'}, m, 'B1');
xlswrite(excel_name, step_number, m, 'B2');
xlswrite(excel_name, {'Current'}, m, 'C1');
xlswrite(excel_name, current_injection', m, 'C2');
xlswrite(excel_name, {'Resting Membrane Potential'}, m, 'D1');
xlswrite(excel_name, rest_pot_list, m, 'D2');
xlswrite(excel_name, rest_pot_avg, m, 'D11');

