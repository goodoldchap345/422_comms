
clear;clf;close all;

% Part b, plotting PSD of NRZ signal
% Set f axis data set 
f = [-1e6:100:1e6];
symbolRate = 500000;
Ts = 1/symbolRate;
% PSD function
f_angular = f./2;
a = sinc((pi*Ts).*f_angular);
S_f_rect = (5*Ts).*(a.^2);

figure(1)
plot(f, S_f_rect)
ylim([0 1.1e-5])
xlim([-1e6 1e6])
xline(0.5e6, 'r')
xline(-0.5e6, 'r')
title("PSD of 4 PAM with rectangular NRZ pulse shape")
xlabel("Frequency (Hz)")
ylabel("Power spectral density")

% Part c, PSD of raised cosine signal
%f = [-1e6:100:1e6];
syms f
a = 1+cos((pi*Ts)*f);
S_f_rcos = ((5*Ts)/4)*a^2;

figure(2)
y = piecewise(f<=-0.5e6, 0, -0.5e6<f<0.5e6, S_f_rcos, f>=0.5e6, 0);
fplot(y)
xline(0.5e6, 'r')
xline(-0.5e6, 'r')
ylim([0 1.1e-5])
xlim([-1e6 1e6])
title("PSD of 4 PAM with Rasied Cosine pulse shape")
xlabel("Frequency (Hz)")
ylabel("Power spectral density")




L=500; % Total data symbols in experiment is 1 million
% To display the pulse shape, we oversample the signal
% by factor of f_ovsamp=8
f_ovsamp=8; % Oversampling factor vs data rate
delay_rc=3;


% NEW code to generate root-raised cosine pulseshape (rolloff factor 0.5)
prcos = rcosdesign( 1, delay_rc*2, f_ovsamp );
pcmatch=prcos(end:-1:1);
% Generating a rectangular pulse shape
prect=ones(1,f_ovsamp);
prect=prect/norm(prect);
prmatch=prect(end:-1:1);
% Generating random signal data for polar signaling
s_data = [-3; 3; 1; 3; 1];

s_data = zeros(L, 1);
for i=1:L
   num = round(3*rand(1));
   switch (num) 
       case 0
           s_data(i) = -3;
       case 1
           s_data(i) = -1;
       case 2
           s_data(i) = 1;
       case 3
           s_data(i) = 3;
   end 
end

transpose(s_data);
% upsample to match the 'fictitious oversampling rate'
% which is f_ovsamp/T (T=1 is the symbol duration)
s_up=upsample(s_data,f_ovsamp);
% Identify the decision delays due to pulse shaping
% and matched filters
delayrc=2*delay_rc*f_ovsamp;
delayrt=f_ovsamp-1;
% Generate polar signaling of different pulse- shaping
xrcos=conv(s_up,prcos);
xrect=conv(s_up,prect);

figure(3)
plot(xrcos)

% t=(1:200)/f_ovsamp;
% figure(1)
% subplot(311)
% figwave1=plot(t,xrcos(delayrc/2:delayrc/2+199));
% %figwave1=plot(t, xrcos);
% title(' (a) Root-raised cosine pulse. .');
% set(figwave1 , 'Linewidth' ,2);
% subplot(312)
% figwave2=plot(t,xrect(delayrt:delayrt+199));
% title(' (b) Rectangular pulse.')
% set(figwave2, 'Linewidth' ,2);

% sending over lin


figure(4)
% Spectrum comparison
[Psd1,f]=pwelch(xrcos, [], [], [], 'twosided' ,f_ovsamp) ;
[Psd2,f]=pwelch(xrect, [], [], [], 'twosided' ,f_ovsamp);
figpsd1=semilogy(f-f_ovsamp/2,fftshift(Psd1));
ylabel('Power spectral density');
xlabel('frequency in unit of {1/T}');
tt1=title(' (a) PSD using root-raised cosine pulse (rolloff factor r=0.5) ');
set(tt1, 'FontSize' ,11);
figure (5)
figpsd2=semilogy(f-f_ovsamp/2,fftshift(Psd2));
ylabel('Power spectral density');
xlabel('frequency in unit of {1/T} ' );
tt2=title(' (b) PSD using rectangular NRZ pulse');
set(tt2, 'FontSize' ,11);
