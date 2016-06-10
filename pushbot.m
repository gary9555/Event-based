s = serial('COM5');	           % creating object for s COM port
set(s, 'BaudRate',4000000, 'FlowControl','hardware');     % configuring the buad to 4000000, rest are set to default
set(s, 'DataBits',8);
set(s, 'OutputBufferSize',2048);
set(s,'InputBufferSize', 4096);
%set(s, 'Timeout', 10);
set(s, 'Terminator', 'CR/LF');

fopen(s);  % open the session
fprintf(s, '!m+');
pause(0.1);
fprintf(s,'!m0=%0');  % left wheel
fprintf(s,'!m1=%0');  % right wheel
% main loop
f = figure(1); drawnow
set(f, 'KeyPressFcn', @(x,y) disp(get(f,'CurrentCharacter')));

% function MainGame()
% 
% KeyStatus = false(1,6);    % Suppose you are using 6 keys in the game
% KeyNames = {'w', 'a','s', 'd', 'j', 'k'};
% KEY.UP = 1;
% KEY.DOWN = 2;
% KEY.LEFT = 3;
% KEY.RIGHT = 4;
% KEY.BULLET = 5;
% KEY.BOMB = 6;
% ...
%     gameWin = figure(..., 'KeyPressFcn', @MyKeyDown, 'KeyReleaseFcn', @MyKeyUp)
%     ...
% % Main game loop
% while GameNotOver
%     if KeyStatus(KEY.UP)  % If left key is pressed
%         player.y = player.y - ystep;
%     end
%     if KeyStatus(KEY.LEFT)  % If left key is pressed
%         player.x = player.x - xstep;
%     end
%     if KeyStatus(KEY.RIGHT)  % If left key is pressed
%         %..
%     end
%     %...
% end
% 
% % Nested callbacks...
%     function MyKeyDown(hObject, event, handles)
%         key = get(hObject,'CurrentKey');
%         % e.g., If 'd' and 'j' are already held down, and key == 's'is
%         % pressed now
%         % then KeyStatus == [0, 0, 0, 1, 1, 0] initially
%         % strcmp(key, KeyNames) -> [0, 0, 1, 0, 0, 0, 0]
%         % strcmp(key, KeyNames) | KeyStatus -> [0, 0, 1, 1, 1, 0]
%         KeyStatus = (strcmp(key, KeyNames) | KeyStatus);
%     end
%     function MyKeyUp(hObject, event, handles)
%         key = get(hObject,'CurrentKey');
%         % e.g., If 'd', 'j' and 's' are already held down, and key == 's'is
%         % released now
%         % then KeyStatus == [0, 0, 1, 1, 1, 0] initially
%         % strcmp(key, KeyNames) -> [0, 0, 1, 0, 0, 0]
%         % ~strcmp(key, KeyNames) -> [1, 1, 0, 1, 1, 1]
%         % ~strcmp(key, KeyNames) & KeyStatus -> [0, 0, 0, 1, 1, 0]
%         KeyStatus = (~strcmp(key, KeyNames) & KeyStatus);
%     end
% 
% end
    
tic; 
while(1)
    a=get(f,'CurrentCharacter');
    if a == 'w'
       fprintf(s,'!m0=%20');
       fprintf(s,'!m1=%20');
%        while get(f,'CurrentCharacter')=='w'
%        end
%        fprintf(s,'!m0=%0');
%        fprintf(s,'!m1=%0');
    end
    if a == 'a'
       fprintf(s,'!m0=%10');
       fprintf(s,'!m1=%20');
%        while get(f,'CurrentCharacter') == 'a'
%        end
%        fprintf(s,'!m0=%0');
%        fprintf(s,'!m1=%0');
    end
    if a == 'd'
       fprintf(s,'!m0=%20');
       fprintf(s,'!m1=%10');
%        while get(f,'CurrentCharacter') == 'd'
%        end
%        fprintf(s,'!m0=%0');
%        fprintf(s,'!m1=%0');
    end
    if a == 's'
       fprintf(s,'!m0=%0');
       fprintf(s,'!m1=%0');
    end
    if a == 't'
        break;
    end
end
fclose(s);


