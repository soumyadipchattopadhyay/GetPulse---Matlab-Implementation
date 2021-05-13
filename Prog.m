display(['This Application measures BP with video of subjects finger' ]);
display(['Developed By Soumyadip Chattopadhyay' ]);
display(['Computer Science Honours. Bangabasi College. C.U.' ]);

[f,p] = uigetfile({'*.mp4';'*avi';'*.wmv'}, 'Select Video File : ');

loc = strcat(p,f);
if ischar('loc'),
    display(['Loading file ' f]);
    v = VideoReader(loc);
else
    v = loc;
end

fps = v.FrameRate;
numFrames = v.NumberOfFrames;

display(['Total Number of frames : ' num2str(numFrames)]);

%zeros function used for matrix of 0s
%returns an 1-by-frame_number matrix of zeros.
y = zeros(1, numFrames);
for i=1:numFrames,
    display(['Processing the frame :' num2str(i) '/' num2str(numFrames)]);
    
    %reads only the frames specified by index
    framen = read(v, i);
    
    frame = imcrop(framen,[1000 1000 1000 1000]);
    %selecting green channel
    gPlane = frame(:, :, 2);
    y(i) = sum(sum(gPlane)) / (size(frame, 1) * size(frame, 2)); %sampling signal 
end
    brightness = y;
% Parameters 
WINDOW_SECONDS = 6;             % [s] Sliding window length
BPM_SAMPLING_PERIOD = 0.5;      % [s] Time between heart rate estimations
BPM_L = 40; BPM_H = 230;        % [bpm] Valid heart rate range
FILTER_STABILIZATION_TIME = 1;  % [s] Filter startup transient
CUT_START_SECONDS = 0;          % [s] Initial signal period to cut off

% Band-pass filtering is applied
%returns the transfer function coefficients of an 2nd-order lowpass digital Butterworth filter with normalized cutoff frequency of BPM_L and BPM_H.
[b, a] = butter(1, [((BPM_L/60)/fps*2), ((BPM_H/60)/fps*2)]);
%filter operates on the columns of y
%filters the data in y with the filter described by b and a.
yf = filter(b, a, y);
%storing the filtered value in y

y = yf((fps * max(FILTER_STABILIZATION_TIME, CUT_START_SECONDS))+1:size(yf, 2));

% Some initializations and precalculations
num_window_samples = round(WINDOW_SECONDS * fps);
bpm_sampling_period_samples = round(BPM_SAMPLING_PERIOD * fps);
num_bpm_samples = floor((size(y, 2) - num_window_samples) / bpm_sampling_period_samples);
fcl = BPM_L / 60; 
fch = BPM_H / 60;
orig_y = y;
bpm = [];

for i=1:num_bpm_samples,
    
    % Fill sliding window with original signal
    window_start = (i-1)*bpm_sampling_period_samples+1;
    ynw = orig_y(window_start:window_start+num_window_samples);
    % Use Hanning window to bring edges to zero. In this way, no artificial
    % high frequencies appear when the signal is treated as periodic by the
    % FFT
    y = ynw .* hann(size(ynw, 2))';
    
    
    gain = abs(fft(y)); %FFT magnitude is obtained

    % FFT indices of frequencies where the human heartbeat is
    il = floor(fcl * (size(y, 2) / fps))+1; ih = ceil(fch * (size(y, 2) / fps))+1;
    index_range = il:ih;
    
    % Find peaks in the interest frequency range and locate the highest
    [pks, locs] = findpeaks(gain(index_range));
    % Find the highest peak
    [max_peak_v, max_peak_i] = max(pks);
    % Translate the peak index to an FFT vector index
    max_f_index = index_range(locs(max_peak_i));
    % Get the frequency in bpm that corresponds to the highest peak
    bpm(i) = (max_f_index-1) * (fps / size(y, 2)) * 60;
          
end

display(['Mean Heart Rate: ' num2str(mean(bpm)) 'bpm']);
f = msgbox(['Your average Heart Rate is 'num2str(mean(bpm)) ' bpm'], 'Result');
pause;