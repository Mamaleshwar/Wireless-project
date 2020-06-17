clc
clear all
%Defining input size
input=11*22*10^4;
n=15;
k=11;
SNRdbVec=0:25;

p = [1 1 1 1
    0 1 1 1
    1 0 1 1
    1 1 0 1
    1 1 1 0
    0 0 1 1
    0 1 0 1
    0 1 1 0
    1 0 1 0
    1 0 0 1
    1 1 0 0];
%Generator Matrix
G = [p eye(k)];
H=[eye(n-k) p.'];
%Parity Check Matrix
Ht=H.';
e=[zeros(1,n);diag(ones(1,n))];
%Syndrome Table
synd = [mod(e*Ht,2) e ];
x = rand(1,input)>0.5;
L=zeros(1,(input*n)/k);

for ii=0:(input/11)-1
    %Encoding the data
    L(15*ii+1:(ii+1)*15) = mod(x(ii*11+1:(ii+1)*11)*G,2);
end

%Interleaver
U=reshape(L,[220,15000]);%depth of interleaver = 220
Ut=U';
h=Ut(:);%Conversion to Column Matrix
f=h';
j=1;

%Modulation of data using QPSK
for i = 1:2:length(f)
    if f(i)==0 && f(i+1) == 0
        s(j) = -1-1*1i;
    elseif f(i)==0 && f(i+1) == 1
        s(j)= -1+1*1i;
    elseif f(i)==1 && f(i+1) == 0
        s(j)= 1-1*1i;
    else
        s(j)= 1+1*1i;
    end
    j=j+1;
end
%Generation of noise for Fading channel
h=sqrt(1/2)*(randn(1,length(s)/(220))+1i*randn(1,length(s)/(220)));
hprime= abs(h);
for ii= 0:(length(s)/(220))-1
   faded_sig(220*ii+1:(ii+1)*220)=s(220*ii+1:(ii+1)*220)*hprime(ii+1);
end
    
indexBER = 1;
for SNRdb = SNRdbVec
    No = (10^(-SNRdb/10))*(15/11);
    %Generation of Additive White Gaussian Noise
    noise = ((No/2)^0.5)* (randn(1,(length(s))) + 1i * randn(1,(length(s))));
    receivedsig = faded_sig + noise;
    for kk= 0:(length(receivedsig)/220)-1
        receivedsig1(220*kk+1:(kk+1)*220) = receivedsig(220*kk+1:(kk+1)*220)/hprime(kk+1);
    end
    j=1;
    %Demodulation of Data
    for i = 1:length(receivedsig1)
        if real(receivedsig1(i))>0 && imag(receivedsig1(i))>0
           y(j) = 1;
           y(j+1)=1;
        elseif real(receivedsig1(i))>0 && imag(receivedsig1(i))<0
           y(j) = 1;
           y(j+1)=0;
        elseif real(receivedsig1(i))<0 && imag(receivedsig1(i))>0
           y(j) = 0;
           y(j+1)=1;
         else 
           y(j) = 0;
           y(j+1)=0;
         end
        j = j+2;
    end
    
%De-Interleaver
q=reshape(y,[15000,220]);
kt=q';
disint=reshape(kt,[1,3300000]);
c=1;

    for kk=1:n:length((disint))-(n-1)
    %Calculation of Syndrome Vector
     S= mod(disint(kk:kk+(n-1))*Ht,2);
     %Checking Syndrome table for the corresponding error pattern
         for iii=1:n+1
             if S== synd(iii,1:4)
                ed=synd(iii,5:19);
             end
         end
     
         corrected_bits=xor(disint(kk:kk+(n-1)),ed);
         decoded_bits(c:c+(k-1))=corrected_bits(5:15);
         c=c+k;
   
    end
    recv_bits=decoded_bits;
    errors=find(xor(recv_bits,x));
    errors=size(errors,2);
    %Calculation of Bit Error Rate
    BER(indexBER)=errors/input;
    indexBER = indexBER+1;
end
%Plotting the Graph
semilogy(SNRdbVec, BER)
hold on
axis([0 30 10^-6 1.0])
xlabel('Eb/N0')
ylabel('Bit Error Rate')
grid on
title('Performance of QPSK under Rayleigh Fading and Interleaver')



 