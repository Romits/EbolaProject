function worldWide
c1=tdfread('daily_migrants_total.tsv');
id = findIndex(c1.c1,'Guinea');
display1(c1, id)
return

function display1(c1, id)
countryL = c1.c2(id,:);
numL = c1.num(id);
[~,idx]=sort(numL,'descend');
disp([countryL(idx(1:13),:) num2str( numL(idx(1:13)) ) ])
return

function idx = findIndex(c1,cname)
idx =[];
for cIdx = 1:length(c1)
    
    if strcmp(strtrim(c1(cIdx,:)),cname)      
        idx = [idx cIdx];
    end
end
return