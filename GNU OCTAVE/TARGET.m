%----------------------------------------------------------
% FMCW Radar - Beat Frequency and Target Range Calculation
%----------------------------------------------------------

% Folder containing the recorded beat signal files
% Change this path according to your computer if required.
% CODE STARTS HERE

folder = './DATA/';

% Delay values corresponding to the recorded beat signal files
delays = [50 100 200 300 400 500];

% Sampling frequency in Hz
Fs = 100000;

% Speed of light in m/s
c = 3e8;

% FMCW radar bandwidth in Hz
B = 7958;

% Chirp duration in seconds
T = 0.01;

% Chirp slope (Hz/s)
S = B/T;

% Initialize arrays to store beat frequency and range
beat_freq = zeros(size(delays));
R = zeros(size(delays));

% Process each delay value
for k = 1:length(delays)

    % Create the filename for the corresponding .dat file
    filename = sprintf('%sbeat_%d.dat', folder, delays(k));

    % Open the binary data file
    fid = fopen(filename, 'rb');

    % Check whether the file was opened successfully
    if fid == -1
        fprintf('Cannot open file: %s\n', filename);
        continue;
    end

    % Read 200000 floating-point samples
    data = fread(fid, 200000, 'float32');

    % Close the file
    fclose(fid);

    % Convert real and imaginary samples into complex samples
    x = data(1:2:end) + 1i*data(2:2:end);

    % Select the first 4096 samples for FFT processing
    x_fft = x(1:4096);

    % Number of samples used for FFT
    N = length(x_fft);

    % Calculate FFT magnitude
    X = abs(fft(x_fft));

    % Create frequency axis
    f = (0:N-1)*Fs/N;

    % Find the strongest frequency while ignoring the DC region
    [peak, idx] = max(X(10:floor(N/4)));

    % Correct the index because the search started from bin 10
    idx = idx + 9;

    % Extract the beat frequency
    beat_freq(k) = f(idx);

    % Display delay and beat frequency
    fprintf('Delay = %d samples\n', delays(k));
    fprintf('Beat Frequency = %.2f Hz\n', beat_freq(k));

    % Calculate target range using FMCW radar equation
    R(k) = (c * beat_freq(k))/(2 * S);

    % Display estimated target range
    fprintf('Target Range = %.3f meters\n\n', R(k));

end
