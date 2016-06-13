figure(1);
for id = 0.0078:0.0078:0.1
   x = 0.01:0.01:2.5;
   y1 = sqrt(0.01*x.^2/id^2 - x.^2+id^2/4-0.05^2);    
   y2 = sqrt(0.01/id^2-1)*x;   
   plot(x,y1,'-r');
   hold on;
   plot(x,y2,'--g');
   legend('Actual locus','Approximated locus','Location','NorthEast');
   
end

figure(2);
id = 0.0078:0.0078:0.1;
k = sqrt(0.01./(id.^2)-1);  % slope of the lines
y3 = (pi/2-atan(k))/pi*180; % the itd angles 
plot(id,y3);
