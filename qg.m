
clear;clf;close all;
L=20000; % Total data symbols in experiment is 1 million
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

% Find the signal length
Lrcos=length(xrcos);Lrect=length(xrect) ;
BER=[];
noiseq=randn(Lrcos,1) ;
% Generating the channel noise (AWGN)
for i=0:10
    Eb2N(i+1)=i;                          %(Eb/N in dB )
    Eb2N_num=10^(Eb2N(i+1)/10);           % Eb/N in linear scale
    Var_n=1/(2*Eb2N_num);               % 1/SNR is the noise variance
    signois=sqrt(Var_n);                % standard deviation
    awgnois=signois*noiseq;             % AWGN
    % Add noise to signals at the channel output
    yrcos=xrcos+awgnois;
    yrect=xrect+awgnois(1:Lrect);
    % Apply matched filters first
    z1=conv(yrcos,pcmatch);clear awgnois, yrcos;
    z2=conv(yrect,prmatch);clear yrect;
    
%     Tau=8;
%     eye1=eyediagram(z1,2*Tau,Tau,Tau/2);title('RRCS eye-diagram');
    
    % Sampling the received signal and acquire samples
    z1=z1(delayrc+1:f_ovsamp:end);
    z2=z2(delayrt+1:f_ovsamp:end) ;
    % Decision based on the sign of the samples
    
    decoded = zeros(L, 1);
    for j=1:L
        if (z1(j) < 0)
            if (z1(j) < -2)
                decoded(j) = -3;
            else
                decoded(j) = -1;
            end
        else
            if (z1(j) > 2)
                decoded(j) = 3;
            else
                decoded(j) = 1;
            end
        end
    end
    % Now compare against the original data to compute BER for
    % the three pulses
    BER=[BER;sum((abs(s_data-decoded) > 0))/(2*L)]
end
figure(1)
subplot(111)
figber=semilogy(Eb2N,BER( : ,1), 'b-*');
legend('Root-raised cosine')
xlabel('E_b/N (dB)') ;ylabel('BER')
set(figber, 'Linewidth' ,2) ;

figure(2)
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


