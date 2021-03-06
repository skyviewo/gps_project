% /* acx = gpsacq(x,N,PRN,f0) */
% /* parallel search algorithm implementation */
% /* x - input signal */
% /* N - correlation length (default: 16368 - 1ms) */
% /* PRN  - sattelite code */
% /* f0 - carrier, Hz (default: 4092000 Hz) */
% /* IsRealInput - flag, if true input signal is I only */
% /* Status: almost tested */

function acx = gpsacq2(x,N,PRN,f0, IsRealInput)
x = x(1:N) ;
fd = 16.368e6 ; % /* sampling frequency in Hz */
%x = x-mean(x) ;

LO_sig = exp(j*2*pi*f0/fd*(0:N-1)).' ; 
% if IsRealInput
%     x = x .* LO_sig ;
% else
%     x = x .* real(LO_sig) ;
% end
X = fft(x) ;
% /* get ca code */
ca16 = get_ca_code16(N/16,PRN) ;
if IsRealInput
    ca16 = ca16 .* LO_sig ;
else
    ca16 = ca16 .* real(LO_sig) ;
    %ca16 = conj(ca16 .* LO_sig) ;
end
CA16 = fft(ca16) ;
c_CA16 = conj(CA16) ;
CX = X.*c_CA16 ;
cx = ifft(CX) ;
acx = cx.*conj(cx) ;
