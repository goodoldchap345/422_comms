% Matlab Program <Exl0_l .m>
% This Matlab exercise <Exl0_l.m> performs simulation of
% binary baseband polar transmission in AWGN channel .
% The program generates polar baseband signals using 3 different
% pulse shapes (root-raised cosine (r=0.5), rectangular, half-sine)
% and estimate the bit error rate (BER) at different Eb/N for display
clear;clf;close all;
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

figure(1)
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

% sending over link

% ----------- rxer -----------

% Apply matched filters on receiver
z1=conv(xrcos,pcmatch);
z2=conv(xrect,prmatch);

figure(2)
plot(z1)


Tau=8;
eye1=eyediagram(z1,2*Tau,Tau,Tau/2);title('RRCS eye-diagram');


% ----------- rxer -----------

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




