for k = 0.01:0.01:0.1
   x = 0.01:0.01:2.5;
   y1 = sqrt(0.01*x.^2/k^2 - x.^2+k^2/4-0.05^2);    
   y2 = sqrt(0.01/k^2-1)*x;
   plot(x,y1,'-r');
   hold on;
   plot(x,y2,'-g');
   
end
