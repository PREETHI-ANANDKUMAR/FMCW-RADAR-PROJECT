clear;
clc;
close all;

% =========================================================
% TRIANGULAR FMCW RADAR
% STATIONARY TARGET
%
% UP/DOWN beat frequency using phase slope
% Range using known delay
% =========================================================


% =========================================================
% USER SETTINGS
% =========================================================

folder = 'C:/Users/Preethi/Desktop/SDR/';

delays = [50 100 150 200 250 300 350 400 500];


% =========================================================
% RADAR PARAMETERS
% =========================================================

Fs = 100000;             % Sampling frequency

triangle_freq = 100;     % Triangle frequency

B = 7958;                % Bandwidth

c = 3e8;                 % Speed of light


% =========================================================
% TRIANGLE PARAMETERS
% =========================================================

T_triangle = 1/triangle_freq;

T_half = T_triangle/2;

samples_per_half = round(Fs*T_half);


% =========================================================
% CHIRP SLOPE
% =========================================================

S = B/T_half;


% =========================================================
% DISPLAY
% =========================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('       TRIANGULAR FMCW - STATIONARY TARGET\n');
fprintf('============================================================\n');

fprintf('Fs                       = %.0f Hz\n',Fs);
fprintf('Triangle frequency       = %.2f Hz\n',triangle_freq);
fprintf('Half chirp duration      = %.6f s\n',T_half);
fprintf('Samples per half chirp   = %d\n',samples_per_half);
fprintf('Bandwidth                = %.2f Hz\n',B);
fprintf('Chirp slope              = %.2f Hz/s\n',S);

fprintf('============================================================\n');


% =========================================================
% RESULT ARRAYS
% =========================================================

fb_up_all = NaN(size(delays));

fb_down_all = NaN(size(delays));

difference_all = NaN(size(delays));

fb_average_all = NaN(size(delays));

range_all = NaN(size(delays));

expected_fb_all = NaN(size(delays));


% =========================================================
% MAIN LOOP
% =========================================================

for k = 1:length(delays)

    delay = delays(k);


    fprintf('\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('DELAY = %d samples\n',delay);
    fprintf('------------------------------------------------------------\n');


    % =====================================================
    % FILE
    % =====================================================

    filename = sprintf('%striangle_%d.dat',folder,delay);


    fid = fopen(filename,'rb');


    if fid == -1

        fprintf('ERROR: Cannot open file.\n');

        continue;

    end


    % =====================================================
    % READ DATA
    % =====================================================

    data = fread(fid,200000,'float32');

    fclose(fid);


    % =====================================================
    % I/Q -> COMPLEX
    % =====================================================

    x = data(1:2:end) + 1i*data(2:2:end);


    % =====================================================
    % CHECK
    % =====================================================

    if length(x) < 2*samples_per_half

        fprintf('ERROR: Not enough samples.\n');

        continue;

    end


    % =====================================================
    % EXTRACT ONE TRIANGLE
    % =====================================================

    up_chirp = x(1:samples_per_half);

    down_chirp = x(samples_per_half+1 : ...
                   2*samples_per_half);


    % =====================================================
    % DELAY IN TIME
    % =====================================================

    tau = delay/Fs;


    % =====================================================
    % THEORETICAL BEAT FREQUENCY
    % =====================================================

    expected_fb = S*tau;


    % =====================================================
    % RANGE
    %
    % YOUR VERIFIED CORRECT RANGE FORMULA
    % =====================================================

    R = c*tau/2;


    % =====================================================
    % VALID SAME-CHIRP REGION
    %
    % A delayed signal can be compared with the current
    % chirp only after 'delay' samples.
    %
    % =====================================================

    valid_samples = samples_per_half - delay;


    fprintf('Valid same-chirp samples = %d\n',valid_samples);


    % =====================================================
    % IF DELAY IS TOO LARGE
    % =====================================================

    if valid_samples < 100

        fprintf('\n');
        fprintf('WARNING:\n');
        fprintf('Delay is too large for reliable UP/DOWN\n');
        fprintf('same-chirp phase measurement.\n');

        fprintf('UP/DOWN measurement skipped.\n');

        fprintf('Range from known delay = %.2f m\n',R);

        range_all(k) = R;

        expected_fb_all(k) = expected_fb;

        continue;

    end


    % =====================================================
    % MARGIN
    % =====================================================

    margin = 10;


    % =====================================================
    % UP VALID REGION
    %
    % Current UP chirp:
    %
    % delay+1  --->  500
    %
    % Remove small margin from both sides.
    % =====================================================

    up_start = delay + margin + 1;

    up_end = samples_per_half - margin;


    % =====================================================
    % DOWN VALID REGION
    %
    % Same idea for DOWN chirp.
    % =====================================================

    down_start = delay + margin + 1;

    down_end = samples_per_half - margin;


    % =====================================================
    % CHECK REGION
    % =====================================================

    if up_start >= up_end || ...
       down_start >= down_end

        fprintf('Not enough valid samples.\n');

        range_all(k) = R;

        expected_fb_all(k) = expected_fb;

        continue;

    end


    % =====================================================
    % REMOVE DC
    % =====================================================

    up_chirp = up_chirp - mean(up_chirp);

    down_chirp = down_chirp - mean(down_chirp);


    % =====================================================
    % UP PHASE
    % =====================================================

    phase_up = unwrap(angle(up_chirp));


    % Use only valid portion

    n_up = (up_start:up_end)';

    phase_up_used = phase_up(up_start:up_end);


    % Linear phase fit

    p_up = polyfit(n_up,phase_up_used,1);


    % Phase slope

    slope_up = p_up(1);


    % Frequency

    fb_up_signed = ...
        slope_up*Fs/(2*pi);


    fb_up = abs(fb_up_signed);


    % =====================================================
    % DOWN PHASE
    % =====================================================

    phase_down = unwrap(angle(down_chirp));


    % Use valid portion

    n_down = (down_start:down_end)';

    phase_down_used = ...
        phase_down(down_start:down_end);


    % Linear phase fit

    p_down = ...
        polyfit(n_down,phase_down_used,1);


    % Phase slope

    slope_down = p_down(1);


    % Frequency

    fb_down_signed = ...
        slope_down*Fs/(2*pi);


    fb_down = abs(fb_down_signed);


    % =====================================================
    % DIFFERENCE
    % =====================================================

    difference = abs(fb_up-fb_down);


    % =====================================================
    % AVERAGE
    % =====================================================

    fb_average = ...
        (fb_up+fb_down)/2;


    % =====================================================
    % STORE
    % =====================================================

    fb_up_all(k) = fb_up;

    fb_down_all(k) = fb_down;

    difference_all(k) = difference;

    fb_average_all(k) = fb_average;

    range_all(k) = R;

    expected_fb_all(k) = expected_fb;


    % =====================================================
    % PRINT
    % =====================================================

    fprintf('\n');

    fprintf('UP signed frequency      = %.3f Hz\n', ...
            fb_up_signed);

    fprintf('UP Beat Frequency        = %.3f Hz\n', ...
            fb_up);

    fprintf('DOWN signed frequency    = %.3f Hz\n', ...
            fb_down_signed);

    fprintf('DOWN Beat Frequency      = %.3f Hz\n', ...
            fb_down);

    fprintf('Difference               = %.3f Hz\n', ...
            difference);

    fprintf('Average Beat Frequency   = %.3f Hz\n', ...
            fb_average);

    fprintf('Expected Beat Frequency  = %.3f Hz\n', ...
            expected_fb);

    fprintf('Target Range             = %.2f m\n', ...
            R);


end


% =========================================================
% FINAL TABLE
% =========================================================

fprintf('\n\n');

fprintf('====================================================================================\n');

fprintf('       TRIANGULAR FMCW - STATIONARY TARGET\n');

fprintf('====================================================================================\n');

fprintf(' Delay       UP Beat       DOWN Beat      Difference      Avg Beat       Range\n');

fprintf('(samples)      (Hz)           (Hz)            (Hz)           (Hz)          (m)\n');

fprintf('------------------------------------------------------------------------------------\n');


for k = 1:length(delays)

    fprintf('%6d      %10.3f      %10.3f      %12.3f      %10.3f      %12.2f\n', ...
        delays(k), ...
        fb_up_all(k), ...
        fb_down_all(k), ...
        difference_all(k), ...
        fb_average_all(k), ...
        range_all(k));

end


fprintf('====================================================================================\n');


% =========================================================
% THEORETICAL TABLE
% =========================================================

fprintf('\n');

fprintf('============================================================\n');

fprintf('              THEORETICAL VALUES\n');

fprintf('============================================================\n');

fprintf(' Delay       Expected Beat       Expected Range\n');

fprintf('(samples)         (Hz)                (m)\n');

fprintf('------------------------------------------------------------\n');


for k = 1:length(delays)

    fprintf('%6d       %12.3f       %14.2f\n', ...
        delays(k), ...
        expected_fb_all(k), ...
        range_all(k));

end


fprintf('============================================================\n');


% =========================================================
% RANGE CHECK
% =========================================================

fprintf('\n');

fprintf('============================================================\n');

fprintf('                 RANGE CHECK\n');

fprintf('============================================================\n');

fprintf(' Delay          Range\n');

fprintf('(samples)        (m)\n');

fprintf('------------------------------------------------------------\n');


for k = 1:length(delays)

    expected_range = ...
        c*(delays(k)/Fs)/2;

    fprintf('%6d       %12.2f\n', ...
        delays(k), ...
        expected_range);

end


fprintf('============================================================\n');


% =========================================================
% PLOT: UP VS DOWN
% =========================================================

figure;

plot(delays,fb_up_all,'o-');

hold on;

plot(delays,fb_down_all,'s-');

plot(delays,expected_fb_all,'^-');

xlabel('Delay (samples)');

ylabel('Beat Frequency (Hz)');

title('Triangular FMCW - UP and DOWN Beat Frequency');

legend('UP Chirp', ...
       'DOWN Chirp', ...
       'Theoretical');

grid on;


% =========================================================
% PLOT: DIFFERENCE
% =========================================================

figure;

plot(delays,difference_all,'o-');

xlabel('Delay (samples)');

ylabel('UP-DOWN Difference (Hz)');

title('UP-DOWN Beat Frequency Difference');

grid on;


% =========================================================
% PLOT: RANGE
% =========================================================

figure;

plot(delays,range_all,'o-');

xlabel('Delay (samples)');

ylabel('Range (m)');

title('Triangular FMCW - Target Range');

grid on;


fprintf('\n');
fprintf('Processing completed.\n');
