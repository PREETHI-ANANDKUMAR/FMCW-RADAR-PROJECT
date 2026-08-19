% BEAT FREQUENCY DETECTION
% This script reads the FMCW radar beat signal, converts
% the I/Q samples into a complex signal, performs FFT
% processing, and extracts the dominant beat frequency.

% Find the location of this MATLAB/Octave script
script_folder = fileparts(mfilename('fullpath'));

% Find the main project folder
project_folder = fileparts(script_folder);

% Locate the DATA folder inside the project
data_folder = fullfile(project_folder, 'DATA');

% Select the radar data file to process
data_file = fullfile(data_folder, 'beat_100.dat');

% ---------------------------------------------------------
% Read binary radar data
% CODE STARTS HERE

% Open the binary file for reading
fid = fopen(data_file, 'rb');

% Check whether the file was opened successfully
if fid == -1
    error('Unable to open radar data file: %s', data_file);
end

% Read 200000 single-precision floating-point samples
data = fread(fid, 200000, 'float32');
fclose(fid);

% Convert I/Q samples into a complex signal
% Odd samples  -> In-phase (I)
% Even samples -> Quadrature (Q)

x = data(1:2:end) + 1i * data(2:2:end);

% FFT PARAMETERS
% Sampling frequency in Hz
Fs = 100000;

% Select the first 4096 samples for FFT processing
x_fft = x(1:4096);

% FFT length
N = length(x_fft);

% Calculate the magnitude spectrum
X = abs(fft(x_fft));

% Create the frequency axis
f = (0:N-1) * Fs / N;

% ---------------------------------------------------------
% BEAT FREQUENCY DETECTION
% ---------------------------------------------------------

% Search for the strongest frequency component.
% The first few FFT bins are ignored to avoid the DC component.
% Only frequencies up to N/4 are considered.

[peak, idx] = max(X(10:floor(N/4)));

% Correct the index because the search started at bin 10
idx = idx + 9;

% Obtain the corresponding beat frequency
beat_freq = f(idx);
fprintf('Beat Frequency = %.2f Hz\n', beat_freq);
