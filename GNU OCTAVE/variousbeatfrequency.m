clear;
clc;

%% USER SETTINGS

delays = [10 50 100 200 300 400 500];

Fs = 100000;

Plot_Enable = 1;      % 1 = Plot ON
                      % 0 = Plot OFF

beat = zeros(size(delays));

for k = 1:length(delays)

    filename = sprintf('C:/Users/Preethi/Desktop/SDR/beat_%d.dat',delays(k));

    fid = fopen(filename,'rb');

    if(fid==-1)
        fprintf('Cannot open %s\n',filename);
        continue;
    end

    data = fread(fid,200000,'float32');

    fclose(fid);

    x = data(1:2:end)+1i*data(2:2:end);

    x = x(1:4096);

    N = length(x);

    X = abs(fft(x));

    f = (0:N-1)*Fs/N;

    [peak,idx] = max(X(10:floor(N/4)));

    idx = idx+9;

    beat(k)=f(idx);

    fprintf('Delay = %d   Beat Frequency = %.2f Hz\n',delays(k),beat(k));

    if Plot_Enable

        figure

        plot(f(1:N/2),X(1:N/2))

        title(sprintf('Delay = %d',delays(k)))

        xlabel('Frequency')

        ylabel('Magnitude')

        grid on

    end

end

figure

plot(delays,beat,'-o')

grid on

xlabel('Delay')

ylabel('Beat Frequency')

title('Delay vs Beat Frequency')
