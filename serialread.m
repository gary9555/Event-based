s = serial('COM4');	           % creating object for s COM1
set(s, 'BaudRate',4000000, 'FlowControl','hardware');     % configuring the buad to 9600, rest are set to default
set(s, 'DataBits',8);
%set(s, 'OutputBufferSize',2048);
set(s,'InputBufferSize', 4096);


set(s, 'Terminator', 'CR/LF');
fopen(s);  % open the session
fprintf(s,'??');                     % write data (AT in this case) to the port
%p = fread(s, s.BytesAvailable);
out = fscanf(s);                 % read from the port
fclose(s);    
