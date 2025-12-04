%% ---------- بخش 1: خواندن و رسم ولتاژ از data.txt (Q4.8) ----------
% اگر قبلا این قسمت رو داری می‌تونی اسکیپش کنی، فقط گذاشتم کامل باشه.

T = readtable('spike_log.txt', 'Format','%f %s', 'Delimiter',' ', ...
              'ReadVariableNames', false);

time_voltage = T{:,1};   % تایم یا ایندکس اصلی (مثلاً 845, 1275, ...)
binStrs_volt = T{:,2};   % رشته باینری Q4.8

numSamplesV = numel(binStrs_volt);
raw_signed  = zeros(numSamplesV,1);
voltages    = zeros(numSamplesV,1);

numBitsV = strlength(binStrs_volt{1});   % باید 12 باشه

for k = 1:numSamplesV
    b = binStrs_volt{k};
    u = bin2dec(b);
    if b(1) == '1'
        raw_signed(k) = u - 2^numBitsV;
    else
        raw_signed(k) = u;
    end
    voltages(k) = raw_signed(k) / 256;  % Q4.8 => تقسیم بر 2^8
end

n_voltage = (1:numSamplesV).';

figure;
plot(n_voltage, voltages, '-o', 'LineWidth',1.5, 'MarkerSize',5);
grid on;
xlabel('n (sample index)');
ylabel('Voltage (Q4.8)');
title('Voltage vs Sample Index (Q4.8)');


%% ---------- بخش 2: خواندن و رسم اسپایک از sfile.txt ----------
% sfile.txt باید مثل مثالی باشه که دادی:
% 10   000000000001
% 855  000000000000
% ...

S = readtable('sfile.txt', 'Format','%f %s', 'Delimiter',' ', ...
              'ReadVariableNames', false);

time_spike = S{:,1};   % تایم هر نمونه اسپایک (مثلا 10, 855, ...)
binStrs_spk = S{:,2};  % رشته باینری 12 بیتی

numSamplesS = numel(binStrs_spk);
spike = zeros(numSamplesS,1);  % صفر/یک خروجی

for k = 1:numSamplesS
    b = binStrs_spk{k};
    % آخرین بیت (LSB) یعنی اسپایک یا نه
    lastBitChar = b(end);      % کاراکتر '0' یا '1'
    spike(k) = str2double(lastBitChar);
end

n_spike = (1:numSamplesS).';

%% رسم اسپایک‌ها بر اساس زمان واقعی (time_spike)
figure;
stem(time_spike, spike, 'LineWidth',1.5, 'Marker','none');
grid on;
xlabel('Time');
ylabel('Spike');
title('Output Spike vs Time');
ylim([-0.2 1.2]); % برای قشنگی


%% (اختیاری) رسم اسپایک بر اساس n (اگه بخوای فقط ایندکس نمونه باشه)
figure;
stem(n_spike, spike, 'LineWidth',1.5, 'Marker','none');
grid on;
xlabel('n (sample index)');
ylabel('Spike');
title('Output Spike vs Sample Index');
ylim([-0.2 1.2]);
