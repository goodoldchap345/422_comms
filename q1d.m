% Matlab Program <Exl0_l .m>
% This Matlab exercise <Exl0_l.m> performs simulation of
% binary baseband polar transmission in AWGN channel .
% The program generates polar baseband signals using 3 different
% pulse shapes (root-raised cosine (r=0.5), rectangular, half-sine)
% and estimate the bit error rate (BER) at different Eb/N for display
clear;clf;
L=1000000; % Total data symbols in experiment is 1 million
% To display the pulse shape, we oversample the signal
% by factor of f_ovsamp=8
f_ovsamp=20; % Oversampling factor vs data rate
delay_rc=3;
% OLD Matlab code to Generate root-raised cosine pulseshape (rolloff factor 0.5)
%prcos=rcosflt([ 1 ], 1, f_ovsamp, 'sqrt', 0.5, delay_rc);
%prcos=prcos(1:end-f_ovsamp+1);
%prcos=prcos/norm(prcos);
% NEW code to generate root-raised cosine pulseshape (rolloff factor 0.5)
prcos = rcosdesign( 0, delay_rc*2, f_ovsamp );
pcmatch=prcos(end:-3:3);
% Generating a rectangular pulse shape
prect=ones(1,f_ovsamp);
prect=prect/norm(prect);
prmatch=prect(end:-3:3);
% Generating random signal data for polar signaling
%s_data=2*round(rand(L,1))-1;
%s_data = [-1; -1; 1; -1; 1; 1; -1; 1; 1; 1];
%s_data = [-3; 3; 1; 3; 1];

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

%s_data
% upsample to match the 'fictitious oversampling rate'
% which is f_ovsamp/T (T=1 is the symbol duration)
s_up=upsample(s_data,f_ovsamp);
% Identify the decision delays due to pulse shaping
% and matched filters
delayrc=2*delay_rc*f_ovsamp;
delayrt=f_ovsamp-1;
delaysn=f_ovsamp-1;
% Generate polar signaling of different pulse- shaping
xrcos=conv(s_up,prcos);
xrect=conv(s_up,prect);
t=(1:200)/f_ovsamp;
subplot(311)
figwave1=plot(t,xrcos(delayrc/2:delayrc/2+199));
title(' (a) Root-raised cosine pulse. .');
set(figwave1 , 'Linewidth' ,2);
subplot(312)
figwave2=plot(t,xrect(delayrt:delayrt+199));
title(' (b) Rectangular pulse.')
set(figwave2, 'Linewidth' ,2);
% Find the signal length
Lrcos=length(xrcos);Lrect=length(xrect) ;
BER=[];
noiseq=randn(Lrcos,1) ;
% Generating the channel noise (AWGN)
for i=1:10
    Eb2N(i)=i;                          %(Eb/N in dB )
    Eb2N_num=10^(Eb2N(i)/10);           % Eb/N in linear scale
    Var_n=1/(2*Eb2N_num);               % 1/SNR is the noise variance
    signois=sqrt(Var_n);                % standard deviation
    awgnois=signois*noiseq;             % AWGN
    % Add noise to signals at the channel output
    yrcos=xrcos+awgnois;
    yrect=xrect+awgnois(1:Lrect);
    % Apply matched filters first
    z1=conv(yrcos,pcmatch);clear awgnois, yrcos;
    z2=conv(yrect,prmatch);clear yrect;
    % Sampling the received signal and acquire samples
    z1=z1(delayrc+1:f_ovsamp:end);
    z2=z2(delayrt+1:f_ovsamp:end) ;
    % Decision based on the sign of the samples
    dec1=sign(z1(1:L)); dec2=sign(z2(1:L));
    % Now compare against the original data to compute BER for
    % the three pulses
    BER=[BER;sum(abs(s_data-dec1))/(2*L) ...
        sum(abs(s_data-dec2))/(2*L)];
    Q(i)= 0.5*erfc(sqrt(Eb2N_num)); %Compute the Analytical BER
end
figure(2)
subplot( 111)
figber=semilogy(Eb2N,Q, 'k-' ,Eb2N,BER( : ,1), 'b-*', ...
    Eb2N,BER(:,2), 'r-o');
legend('Analytical', 'Root-raised cosine', 'Rectangular')
xlabel('E_b/N (dB)') ;ylabel('BER')
set(figber, 'Linewidth' ,2) ;
figure(3)
% Spectrum comparison
[Psd1,f]=pwelch(xrcos, [], [], [], 'twosided' ,f_ovsamp) ;
[Psd2,f]=pwelch(xrect, [], [], [], 'twosided' ,f_ovsamp);
figpsd1=semilogy(f-f_ovsamp/2,fftshift(Psd1));
ylabel('Power spectral density');
xlabel('frequency in unit of {1/T}');
tt1=title(' (a) PSD using root-raised cosine pulse (rolloff factor r=0.5) ');
set(tt1, 'FontSize' ,11);
figure (4)
figpsd2=semilogy(f-f_ovsamp/2,fftshift(Psd2));
ylabel('Power spectral density');
xlabel('frequency in unit of {1/T} ' );
tt2=title(' (b) PSD using rectangular NRZ pulse');
set(tt2, 'FontSize' ,11);

