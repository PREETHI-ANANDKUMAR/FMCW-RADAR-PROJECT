%----------------------------------------------------------
% FMCW Radar - Delay vs Beat Frequency Analysis
%----------------------------------------------------------

clear;
clc;

%% USER SETTINGS

% Delay values corresponding to the recorded beat signal files
delays = [10 50 100 200 300 400 500];

% Sampling frequency in Hz
Fs = 100000;

% Enable or disable individual FFT plots
% 1 = Plot ON
% 0 = Plot OFF
Plot_Enable = 1;

% Initialize array to store beat frequencies
beat = zeros(size(delays));

%% PROCESS EACH DELAY VALUE

for k = 1:length(delays)

    % Create the filename for the corresponding .dat file
    % DATA folder is one level above the GNU OCTAVE folder
    filename = sprintf('../DATA/beat_%d.dat', delays(k));

    % Open the binary data file
    fid = fopen(filename, 'rb');

    % Check whether the file was opened successfully
    if fid == -1
        fprintf('Cannot open %s\n', filename);
        continue;
    end

    % Read 200000 floating-point samples
    data = fread(fid, 200000, 'float32');

    % Close the file
    fclose(fid);

    % Convert real and imaginary samples into complex samples
    x = data(1:2:end) + 1i*data(2:2:end);

    % Select the first 4096 samples for FFT processing
    x = x(1:4096);

    % Number of samples used for FFT
    N = length(x);

    % Calculate FFT magnitude
    X = abs(fft(x));

    % Create frequency axis
    f = (0:N-1)*Fs/N;

    % Find the strongest frequency while ignoring DC region
    [peak, idx] = max(X(10:floor(N/4)));

    % Correct the index because the search started from bin 10
    idx = idx + 9;

    % Store the detected beat frequency
    beat(k) = f(idx);

    % Display the result
    fprintf('Delay = %d   Beat Frequency = %.2f Hz\n', ...
            delays(k), beat(k));

    %% INDIVIDUAL FFT PLOT
    if Plot_Enable
        figure;

        % Plot positive-frequency portion of the FFT
        plot(f(1:N/2), X(1:N/2));
        title(sprintf('FFT Spectrum - Delay = %d', delays(k)));
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        grid on;
    end
end

%% DELAY VS BEAT FREQUENCY PLOT

figure;
plot(delays, beat, '-o');
grid on;
xlabel('Delay');
ylabel('Beat Frequency (Hz)');
title('Delay vs Beat Frequency');
ylabel('Beat Frequency')
title('Delay vs Beat Frequency')
