%%
s = serial('COM4');	           % creating object for s COM port
set(s, 'BaudRate',12000000, 'FlowControl','hardware');     % configuring the buad to 4000000, rest are set to default
set(s, 'DataBits',8);
set(s, 'OutputBufferSize',2048);
set(s,'InputBufferSize', 4096);
%set(s, 'Timeout', 10);
set(s, 'Terminator', 'CR/LF');

fopen(s);  % open the session
fprintf(s, '!m+');
fprintf(s,'!m0=%0');
fprintf(s,'!m1=%0');
%%
% main loop
while(1)
    cmd = input('Input Cmd: ','s');
    if strcmp(cmd, 'stop')
        break;
    end
    if strcmp(cmd, 'w')
        fprintf(s, '!m0=%20');
        fprintf(s, '!m1=%20');
        continue;
    end
    if strcmp(cmd, 'a')
        fprintf(s, '!m0=%10');
        fprintf(s, '!m1=%40');
        continue;
    end
    if strcmp(cmd, 'd')
        fprintf(s, '!m0=%35');
        fprintf(s, '!m1=%35');
        continue;
    end
    if strcmp(cmd, 's')
        fprintf(s, '!m0=%-20');
        fprintf(s, '!m1=%-20');
        continue;
    end
    if strcmp(cmd, 't')
        fprintf(s, '!m0=%0');
        fprintf(s, '!m1=%0');
        continue;
    end    
    fprintf(s,cmd);    % write data to the port    
    
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
