function calculateMmatrix
load migrat_data

    countries = {'Guinea'        
    'Sierra Leone'
    'Liberia'
    'Mali'
    'Cote d''Ivoire '
    'Guinea-Bissau   '
    'Senegal'
    'Russia        '
    'Spain         '
    'Ireland       '
    'Switzerland   '
    'United States '
    'Germany       '
    'Saudi Arabia '
    'Ecuador  '
    'Qatar'
    'China'
    'France'
    'Japan'
    'Italy'
    'Netherlands'
    'Belgium'
    'Nigeria'};

Len = length(countries);
M = zeros(Len);
for counter1 = 1:Len
    for counter2 = 1:Len
        if counter1~=counter2
            idx1 = findIndex(c1, strtrim(countries{counter1}));
            idx2 = findIndex2(c2, strtrim(countries{counter2}), idx1);
            
            if idx2 == 0
                num1 = 0;                 
            else
                num1 = num(idx2);
                if num1>100
                    num1 = round(num1/10);
                end
                    
            end
            M(counter1, counter2) = num1;
            %disp([strtrim(countries{counter1}) ' ' strtrim(countries{counter2}) ' ' num2str(num1)]);

        end
    end
end
   
return

function idx = findIndex(c1,cname)
idx =[];
for cIdx = 1:length(c1)
    
    if strcmp(strtrim(c1(cIdx,:)),cname)      
        idx = [idx cIdx];
    end
end
return

function  idx = findIndex2(c2, cname, idx1)
idx = [];
for counter = 1:length(idx1)
    if strcmp(strtrim(c2(idx1(counter),:)),cname)
        idx = idx1(counter);
        break;
    end
end
if isempty(idx)
    idx = 0;
end
return
