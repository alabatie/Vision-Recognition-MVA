function[result] = computeAH(match,H)
    
x1=match(1);
y1=match(2);
x2=match(3);
y2=match(4);
A=[-x1,-y1,-1,0,0,0,x2*x1,x2*y1,x2; 0,0,0,-x1,-y1,-1,y2*x1,y2*y1,y2];

result=A*H;
