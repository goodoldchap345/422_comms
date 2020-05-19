
clear;clf;
L=5; % Total data symbols in experiment is 1 million
% To display the pulse shape, we oversample the signal
% by factor of f_ovsamp=8
f_ovsamp=8; % Oversampling factor vs data rate
delay_rc=3;

% NEW code to generate root-raised cosine pulseshape (rolloff factor 0.5)
prcos = rcosdesign( 1, delay_rc*2, f_ovsamp );
pcmatch=prcos(end:-1:1);

% Generating random signal data for polar signaling
s_data = [-3; 3; 1; -1; 1];
transpose(s_data)
% upsample to match the 'fictitious oversampling rate'
% which is f_ovsamp/T (T=1 is the symbol duration)
s_up=upsample(s_data,f_ovsamp);
% Generate polar signaling of different pulse- shaping
xrcos=conv(s_up,prcos);

figure(1)
plot(xrcos)
title("Time Domain Output of 4 PAM Waveform")
xlabel("Time")
ylabel("Voltage")

figure(2)
% Spectrum comparison
[Psd1,f]=pwelch(xrcos, [], [], [], 'twosided' ,f_ovsamp) ;
figpsd1=semilogy(f-f_ovsamp/2,fftshift(Psd1));
ylabel('Power spectral density');
xlabel('frequency in unit of {1/T}');
tt1=title(' (a) PSD using root-raised cosine pulse (rolloff factor r=0.5) ');
set(tt1, 'FontSize' ,11);



