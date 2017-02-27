% @author: XZZ
% @function: Detect voicing state in a certain range of signal.

function vd = voicingdetector(sound,Fs,frame_len,overlap)
    [data, Fs] = audioread(sound);
    L = length(data);
    m = floor(((L-1)-overlap)/(frame_len-overlap))+1;
    n = frame_len;
    Y = zeros(m,n);
    Y_es = zeros(m,n);   % Store values to calculate energy
    h = hamming(frame_len);
    cr_0 = 0.2;
    
    start_index = 1;
    
    % Split into frames
    for j = 1:m
        end_index = start_index+frame_len-1;
        if j ~= m
            for i = start_index:end_index
                k = i-(frame_len-overlap)*(j-1);
                Y(j,k) = data(i).*h(k);
                Y_es(j,k) = (abs(Y(j,k)))^2;
            end
            start_index = start_index + frame_len - overlap;
        else
            for i = start_index:L
                k = i-(frame_len-overlap)*(j-1);
                Y(j,k) = data(i).*h(k);
                Y_es(j,k) = (abs(Y(j,k)))^2;
            end
        end
        
        % Calculate short time energy of each frame
        Es(j) = sum(Y_es(j,:)) / length(Y_es(j,:)); 
    end
    
    % Decide voicing status: 0 -> silence, +1 -> voiced, -1 -> unvoiced
    for i = 1:m
        if Es(i) <= 0.01
            vd(i) = 0;
        else
            cr(i) = zcr(Y(i,:));
            if cr(i) >= cr_0
                vd(i) = -1;
            else
                vd(i) = 1;
            end
        end
    end
end

% Calculate zero crossing rate/ratio
function cr = zcr(Data)
    count = 0;
    for i = 1:length(Data)-1
        if Data(i)*Data(i+1)<0
            count = count + 1;
        end
    end
    cr = count/(length(Data)-1);
end
