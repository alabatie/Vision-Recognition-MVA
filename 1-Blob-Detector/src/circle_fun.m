function[result] = circle_fun(image, vector)
theta=0;
x=0;
y=0;
[h,w]=size(image);
r=vector(3)*sqrt(2);
N=round(2*pi*r);
if(vector(1)>1 & vector(1)<h & vector(2)>1 & vector(2)<w) 
    border=0;
else
    border=1;
end

if(border==0)
    for(i=0:N)
      theta=i*2*pi/N;
      x=vector(1)+r*cos(theta);
      y=vector(2)+r*sin(theta);
      if(x>=1 & y>=1 & x<=h & y<=w)
        image(round(x),round(y),1)=255;
        image(round(x),round(y),2)=255;
      end
    end
end

result=image;