tcp = tcpip('172.19.12.155',56000);   % remote host and its port value 172.19.12.212    172.19.12.190
                                      % port 56001 for wlan module config,
                                      % port 56000 for pushbot interface
set(tcp, 'OutputBufferSize',16384);
set(tcp,'InputBufferSize', 16384);

fopen(tcp);
pause(0.1);
% 
 fprintf(tcp, '!m+');
 fprintf(tcp,'!m0=%0');
 fprintf(tcp,'!m1=%0');


while(1)
    cmd = input('Input Cmd: ','s');
    if strcmp(cmd, 'stop')
        break;
    end
    if strcmp(cmd, 'w')
        fprintf(tcp, '!m0=%20');
        fprintf(tcp, '!m1=%20');
        continue;
    end
    if strcmp(cmd, 'a')
        fprintf(tcp, '!m0=%10');
        fprintf(tcp, '!m1=%40');
        continue;
    end
    if strcmp(cmd, 'd')
        fprintf(tcp, '!m0=%35');
        fprintf(tcp, '!m1=%35');
        continue;
    end
    if strcmp(cmd, 's')
        fprintf(tcp, '!m0=%-20');
        fprintf(tcp, '!m1=%-20');
        continue;
    end
    if strcmp(cmd, 't')
        fprintf(tcp, '!m0=%0');
        fprintf(tcp, '!m1=%0');
        continue;
    end    
    fprintf(tcp,cmd);    % write data to the port    
    
     pause(0.05);
%     out = fscanf(s);  % read from the port
    
    if tcp.BytesAvailable ~= 0
        out = fread(tcp,tcp.BytesAvailable,'char');
        a = (char(out)).';
        disp(a);    
    end
    
end
fclose(tcp);
