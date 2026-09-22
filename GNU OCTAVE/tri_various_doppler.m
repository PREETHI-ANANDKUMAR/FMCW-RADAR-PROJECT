clear;
clc;
close all;

% =========================================================
% TRIANGULAR FMCW RADAR - DOPPLER + RANGE
% =========================================================

folder = 'C:/Users/Preethi/Desktop/SDR/';
delays = [50 100 150 200 250 300];

% Radar parameters
Fs = 100000;
fc = 2.4e9;
c = 3e8;
B = 7958;
triangle_freq = 100;
applied_doppler = 50;

% Triangle parameters
T_half = 1/(2*triangle_freq);
samples_per_half = round(Fs*T_half);
S = B/T_half;

% Result arrays
fb_up_all = NaN(size(delays));
fb_down_all = NaN(size(delays));
fb_range_all = NaN(size(delays));
fd_all = NaN(size(delays));
velocity_all = NaN(size(delays));
range_all = NaN(size(delays));

% =========================================================
% PROCESS EACH DELAY
% =========================================================

for k = 1:length(delays)

    delay = delays(k);

    % Read file
    filename = sprintf('%sdoppler_tri_%d.dat',folder,delay);

    fid = fopen(filename,'rb');

    if fid == -1
        fprintf('Cannot open %s\n',filename);
        continue;
    end

    data = fread(fid,200000,'float32');
    fclose(fid);

    % I/Q to complex
    x = data(1:2:end) + 1i*data(2:2:end);

    % Extract UP and DOWN chirps
    up = x(1:samples_per_half);
    down = x(samples_per_half+1:2*samples_per_half);

    % Remove DC
    up = up - mean(up);
    down = down - mean(down);

    % Phase
    phase_up = unwrap(angle(up));
    phase_down = unwrap(angle(down));

    % Valid region
    margin = 20;
    start = delay + margin + 1;
    finish = samples_per_half - margin;

    if start >= finish
        continue;
    end

    n = (start:finish)';

    % =====================================================
    % UP CHIRP
    % =====================================================

    p = polyfit(n,phase_up(start:finish),1);
    fb_up = abs(p(1)*Fs/(2*pi));

    % =====================================================
    % DOWN CHIRP
    % =====================================================

    p = polyfit(n,phase_down(start:finish),1);
    fb_down = abs(p(1)*Fs/(2*pi));

    % =====================================================
    % RANGE + DOPPLER
    % =====================================================

    fb_range = (fb_up + fb_down)/2;

    fd = abs(fb_up - fb_down)/2;

    velocity = fd*c/(2*fc);

    % Range from measured beat frequency
    range = c*fb_range/(2*S);

    % Store
    fb_up_all(k) = fb_up;
    fb_down_all(k) = fb_down;
    fb_range_all(k) = fb_range;
    fd_all(k) = fd;
    velocity_all(k) = velocity;
    range_all(k) = range;

end

% =========================================================
% FINAL RESULTS
% =========================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('          TRIANGULAR FMCW - FINAL RESULTS\n');
fprintf('============================================================\n');

fprintf(' Delay      UP Beat      DOWN Beat      Range Beat      Doppler    Velocity       Range\n');
fprintf('(samples)      (Hz)          (Hz)           (Hz)          (Hz)       (m/s)          (m)\n');
fprintf('------------------------------------------------------------\n');

for k = 1:length(delays)

    fprintf('%6d     %10.3f     %10.3f     %11.3f     %9.3f     %8.3f     %12.2f\n', ...
        delays(k), ...
        fb_up_all(k), ...
        fb_down_all(k), ...
        fb_range_all(k), ...
        fd_all(k), ...
        velocity_all(k), ...
        range_all(k));

end

fprintf('============================================================\n');

% =========================================================
% THEORETICAL VALUES
% =========================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('                 THEORETICAL VALUES\n');
fprintf('============================================================\n');

fprintf(' Delay      Range Beat      Doppler      Velocity       Range\n');
fprintf('(samples)      (Hz)           (Hz)        (m/s)          (m)\n');
fprintf('------------------------------------------------------------\n');

for k = 1:length(delays)

    tau = delays(k)/Fs;

    fb_theory = S*tau;
    range_theory = c*tau/2;
    velocity_theory = applied_doppler*c/(2*fc);

    fprintf('%6d     %10.3f      %8.3f      %8.3f     %12.2f\n', ...
        delays(k), ...
        fb_theory, ...
        applied_doppler, ...
        velocity_theory, ...
        range_theory);

end

fprintf('============================================================\n');

% =========================================================
% PLOTS
% =========================================================

figure;
plot(delays,fb_up_all,'o-',delays,fb_down_all,'s-');
xlabel('Delay (samples)');
ylabel('Beat Frequency (Hz)');
title('UP and DOWN Beat Frequency');
legend('UP','DOWN');
grid on;

figure;
plot(delays,fd_all,'o-');
xlabel('Delay (samples)');
ylabel('Doppler Frequency (Hz)');
title('Doppler Frequency');
grid on;

figure;
plot(delays,velocity_all,'o-');
xlabel('Delay (samples)');
ylabel('Velocity (m/s)');
title('Target Velocity');
grid on;

figure;
plot(delays,range_all,'o-');
xlabel('Delay (samples)');
ylabel('Range (m)');
title('Target Range');
grid on;

fprintf('\nProcessing completed.\n');

fprintf('\n');
fprintf('Processing completed successfully.\n');
