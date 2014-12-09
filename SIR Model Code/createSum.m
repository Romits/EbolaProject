function [term1, term2]=createSum(ch1, ii, Len, m)
    term1 ={};
    term2 = {};    
    
%     if ch1=='S'
%         
% for counter = 1:Len
%     
%     t1 = [num2str(m(counter,ii)) ' * ' ch1 '_' num2str(counter) ' / 10 / ' 'N_' num2str(counter)];
%     term1{counter} = t1;
%     
%     t2 = ['-1 * ' num2str(m(ii,counter)) ' * ' ch1 '_' num2str(ii) ' / 10 /' 'N_' num2str(ii)];
%     term2{counter} = t2;
% 
% end
%     else
        

for counter = 1:Len
    
    t1 = [num2str(m(counter,ii)) ' * ' ch1 '_' num2str(counter) ' / ' 'N_' num2str(counter)];
    term1{counter} = t1;
    
    t2 = ['-1 * ' num2str(m(ii,counter)) ' * ' ch1 '_' num2str(ii) ' / ' 'N_' num2str(ii)];
    term2{counter} = t2;

end
%    end
return