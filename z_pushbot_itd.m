%%
%open serial port 
s = serial('COM5');	           % creating object for s COM port
set(s, 'BaudRate',12000000, 'FlowControl','hardware');     % configuring the buad to 4000000, rest are set to default
set(s, 'DataBits',8);
set(s, 'OutputBufferSize',2048);
set(s,'InputBufferSize', 10000);
%set(s, 'Timeout', 10);
set(s, 'Terminator', 'CR/LF');

fopen(s);  % open the session
fprintf(s, '!m+');
pause(0.1);
fprintf(s,'!m0=%0');  % left wheel
fprintf(s,'!m1=%0');  % right wheel
%%
%send start command
fprintf(s,'!c+');
pause(0.05);

%get and interpret adc data from serial
count = 1;
space = char(20);
cool = [];
temp = [0 0];
tic;
while toc < 5
   temp = fscanf(s, 'L%dR%d\r\n',[1,2]);
   disp(temp);
%    if length(temp)==2
%     cool(count,:) = temp;
%     count = count+1;
%    end
    %cool(count,:) = fread(s,[1 2],'uint16');
   pause(0.005);
   %disp(cool(count,:));
   if(toc>3&&toc<3.008)
       fprintf(s, '!m0=%20');
        fprintf(s, '!m1=%20');
   end

end
fclose(s);
delete(s);
clear s;
%calculate angle 

%give move command
