s = serial('COM4');	           % creating object for s COM port
set(s, 'BaudRate',4000000, 'FlowControl','hardware');     % configuring the buad to 4000000, rest are set to default
set(s, 'DataBits',8);
set(s, 'OutputBufferSize',2048);
set(s,'InputBufferSize', 4096);
%set(s, 'Timeout', 10);
set(s, 'Terminator', 'CR/LF');

fopen(s);  % open the session
% main loop
while(1)
    cmd = input('Input Cmd: ','s');
    fprintf(s,cmd);    % write data to the port
    
    if strcmp(cmd, 'stop')
        break;
    end
%     pause(0.1);
%     out = fscanf(s);  % read from the port
    pause(0.1);
    if s.BytesAvailable ~= 0
        out = fread(s,s.BytesAvailable,'char');
        a = (char(out)).';
        disp(a);    
    end
    
end
fclose(s);
