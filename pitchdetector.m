% @author: XZZ
% @function: Detect pitch within a certain range of signal.

function pd = pitchdetector(sound,Fs,frame_len,overlap)
    [data, Fs] = audioread(sound);
    data = filter([1,-0.9378],1,data);
    L = length(data);
    m = floor(((L-1)-overlap)/(frame_len-overlap))+1;
    n = frame_len;
    Y = zeros(m,n);
    
    start_index = 1;
    
    % Split into frames
    for j = 1:m
        end_index = start_index+frame_len-1;
        if j ~= m
            for i = start_index:end_index
                k = i-(frame_len-overlap)*(j-1);
                Y(j,k) = data(i);
            end
            start_index = start_index + frame_len - overlap;
        else
            for i = start_index:L
                k = i-(frame_len-overlap)*(j-1);
                Y(j,k) = data(i);
            end
        end
    end
    
    % Detect voicing
    vd = voicingdetector(sound,Fs,frame_len,overlap);
    
    % Assign pitch values
    for i = 1:m
        if vd(i) == 0 || vd(i) == -1
            pd(i) = 0;
        elseif vd(i) == 1
            pd(i) = pitchDetect(Y(i,:),Fs);
        end
    end
end

% Detect pitch using autocorrelation
function pitch = pitchDetect(vector,Fs)
    autocorr = xcorr(vector);
    [B,I] = sort(autocorr);
    num = length(I);
    pitch = Fs/(0.5*I(num)); % Simplified model
end
