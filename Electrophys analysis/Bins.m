
[filename]=uigetfile ({'*.xlsx'}, 'Select file(s)', 'MultiSelect', 'on');
number_of_files = length(filename);

num=xlsread(filename);
   
 [N,edges]=histcounts(num);
 bin_summary=zeros((length(edges)),2);
 bin_summary(1:length(N),1)=N';
 bin_summary(1:length(edges),2)=edges';


    



