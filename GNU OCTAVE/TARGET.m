folder = 'C:/Users/Preethi/Desktop/SDR/';
delays = [50 100 200 300 400 500];
Fs = 100000;
c = 3e8;          % Speed of light
B = 7958;         % Bandwidth
T = 0.01;         % Chirp duration
S = B/T;          % Chirp slope
beat_freq = zeros(size(delays));
R = zeros(size(delays));
for k = 1:length(delays)
    filename = sprintf('%sbeat_%d.dat',folder,delays(k));
    fid = fopen(filename,'rb');
    data = fread(fid,200000,'float32');
    fclose(fid);
    x = data(1:2:end) + 1i*data(2:2:end);
    x_fft = x(1:4096);
    N = length(x_fft);
    X = abs(fft(x_fft));
    f = (0:N-1)*Fs/N;
    [peak,idx] = max(X(10:floor(N/4)));
    idx = idx + 9;
    beat_freq(k) = f(idx);
    fprintf('Delay = %d samples\n',delays(k));
    fprintf('Beat Frequency = %.2f Hz\n',beat_freq(k));
    R(k) = (c*beat_freq(k))/(2*S);
    fprintf('Target Range = %.3f meters\n\n',R(k));
end
