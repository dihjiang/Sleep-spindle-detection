function h1 = fir_kaiser(fs1,fp1,fp2,fs2,Fs)

% Estimate order n and beta of the filter
[n, wn, bta, ftype] = kaiserord([fs1 fp1 fp2 fs2],[0 1 0],[0.01 0.1011 0.01],Fs); % Using Kaiser window function

h1 = fir1(n,wn,ftype,kaiser(n+1,bta),'noscale');

% [hh1,w1]=freqz(h1,1,100);
% w1=w1*Fs/2;
% figure
% subplot(2,1,1)
% plot(w1/pi,20*log10(abs(hh1)))
% grid
% xlabel('f');ylabel('/db');
% subplot(2,1,2)
% plot(w1/pi,angle(hh1))
% grid
% xlabel('f');ylabel('phase/rad');
end