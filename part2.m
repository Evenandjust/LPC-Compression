% @author: XZZ
% @function: Compress and resynthesize own recorded voice using LPC.

[y,Fs]=audioread('own_voice.wav');
pit = pitchdetector('own_voice.wav',16000,160,0); % Detect pitches of each frame
y = filter([1,-0.9378],1,y);    % Pre-emphasize the signal
frame_len = 160;
overlap = 0;
L = length(y);
m = floor(((L-1)-overlap)/(frame_len-overlap))+1;  % Calculate the number of frames
n = frame_len;
p = 20;
Y = zeros(m,n);   % Matrix storing the frames
A = zeros(m,min(p+1,L-(m-1)*frame_len+(m-2)*overlap+1));  % Matrix storing the coefficients

start_index = 1;

% Split the signal into frames and store each frame in a row of matrix Y
for j = 1:m
    end_index = start_index+frame_len-1;
    if j ~= m
        for i = start_index:end_index
            k = i-(frame_len-overlap)*(j-1);
            Y(j,k) = y(i);
        end
        start_index = start_index + frame_len - overlap;
    else
        for i = start_index:L
            k = i-(frame_len-overlap)*(j-1);
            Y(j,k) = y(i);
        end
    end
end

% Calculate lpc coefficients of each frame
for i = 1:m
    if i ~= m
        if L-(m-1)*frame_len+(m-2)*overlap >= p
            [a,g] = lpc(Y(i,1:frame_len),p);
        else
            [a,g] = lpc(Y(i,1:frame_len),L-(m-1)*frame_len+(m-2)*overlap);
        end
    else
        if L-(m-1)*frame_len+(m-2)*overlap >= p
            [a,g] = lpc(Y(i,1:L-(m-1)*frame_len+(m-2)*overlap),p);
        else 
            [a,g] = lpc(Y(i,1:L-(m-1)*frame_len+(m-2)*overlap),L-(m-1)*frame_len+(m-2)*overlap);
        end
    end
    A(i,:) = a;
end

est_Y = zeros(1,L);
Y_init = zeros(m,n);
G = 0.4;
l = 1;

% Generate excitement pulses Y_init of each frame according to pitch, and obtain
% synthesized signal est_Y
for i = 1:m
    r = l+frame_len-1;
    
    if i ~= m
        if pit(i)==0
            Y_init(i,:) = randn([1 frame_len])./sqrt(frame_len);
        else
            t = floor(Fs/pit(i))+1;
            for j = 1:frame_len
                if mod(j,t)==0 || j==1
                    Y_init(i,j)=1;
                else
                    Y_init(i,j)=rand;
                end
            end
            
            if sum(Y_init(i,:)) ~=0
                Y_init(i,:) = Y_init(i,:)./sqrt(sum(Y_init(i,:)));
            end
        end

        est_Y(l:r) = filter(G,A(i,1:min(p,L-(m-1)*frame_len+(m-2)*overlap)),Y_init(i,1:frame_len));
        l = l + frame_len;

    else
        if pit(i)==0
            Y_init(i,1:L-frame_len*(m-1)) = randn([1 L-frame_len*(m-1)])./sqrt(frame_len);
        else
            t = floor(Fs/pit(i))+1;
            for j = 1:frame_len
                if mod(j,t)==0 || j==1
                    Y_init(i,j)=1;
                else
                    Y_init(i,j)=rand;
                end
            end
            
            if sum(Y_init(i,:)) ~=0
                Y_init(i,:) = Y_init(i,:)./sqrt(sum(Y_init(i,:)));
            end
        end

        est_Y(l:L) = filter(G,A(i,1:min(p,L-(m-1)*frame_len+(m-2)*overlap)),Y_init(i,1:L-frame_len*(m-1)));
    end
end

est_Y = est_Y';

audiowrite('own_voice_received.wav',est_Y,Fs);


