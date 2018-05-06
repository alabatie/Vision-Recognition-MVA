function[result] = int_part(x)
if(round(x)>x)
    result=round(x)-1;
else
    result=round(x);
end