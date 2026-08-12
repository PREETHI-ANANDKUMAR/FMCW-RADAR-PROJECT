fid = fopen('C:/Users/Preethi/Desktop/SDR/beat.dat','rb');
data = fread(fid, 200000, 'float32');
fclose(fid);
x = data(1:2:end) + 1i*data(2:2:end);

Fs = 100000;
x_fft = x(1:4096);
N = length(x_fft);
X = abs(fft(x_fft));
f = (0:N-1)*Fs/N;

[peak,idx]=max(X(10:floor(N/4)));
idx=idx+9;
beat_freq=f(idx);
fprintf('Beat Frequency = %.2f Hz\n', beat_freq);
