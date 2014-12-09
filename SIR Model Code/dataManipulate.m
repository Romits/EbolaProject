function test
load dataLiberia1
death = updatedVar(death);
infected = updatedVar(infected);
save dataLiberia death infected
end

function death = updatedVar(death)
    death = double(death);
    death(1:4) = 0;
    death(end:-1:end-2) = [];
    indP = find(death>=0);
    indM = find(death<0);
    death(indP) = sort(death(indP));
    death = double(death);

    for i=1:length(indM)
        indx = indM(i);
        l = 1;
        while(death(indx-l)<0)
            l = l+1;
        end
        u = 1;
        while(death(indx+u)<0)
            u = u+1;
        end
        death(indx) = (death(indx-l)+death(indx+u))/2;
        if (death(indx)<death(indx-l))
            'error'
        end
    end
end