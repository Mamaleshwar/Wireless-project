clc;
clear all;
close all;
input =11*10^5;
n=15;
k=11;
SNRdb=1:10;
%BER=zeros(1,length(SNRdb));
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

G = [p eye(k)];
H=[eye(n-k) p.'];
Ht=H.';
e=[zeros(1,n);diag(ones(1,n))];
synd = [mod(e*Ht,2) e ];
x = rand(1,input)>0.5;
L=zeros(1,(input*n)/k);

for ii=0:(input/11)-1
    L(15*ii+1:(ii+1)*15) = mod(x(ii*11+1:(ii+1)*11)*G,2);
end
j=1;
for i = 1:2:length(L)-1
    if L(i)==0 && L(i+1) == 0
        s(j) = -1-1*1i;
    elseif L(i)==0 && L(i+1) == 1
        s(j)= -1+1*1i;
    elseif L(i)==1 && L(i+1) == 0
        s(j)= 1-1*1i;
    else
        s(j)= 1+1*1i;
    end
    j=j+1;
end
for SNRdb = 1:10
    No = (10^(-SNRdb/10))*(15/11);
  
noise = ((No/2)^0.5)* (randn(1,(input*15/11)/2) + 1i * randn(1,(input*15/11)/2));
receivedsig = s + noise;
j=1;
for i = 1:length(receivedsig)
    if real(receivedsig(i))>0 && imag(receivedsig(i))>0
        y(j) = 1;
        y(j+1)=1;
    elseif real(receivedsig(i))>0 && imag(receivedsig(i))<0
        y(j) = 1;
        y(j+1)=0;
    elseif real(receivedsig(i))<0 && imag(receivedsig(i))>0
        y(j) = 0;
        y(j+1)=1;
        
    else 
        y(j) = 0;
        y(j+1)=0;
        
    end
    j = j+2;
end


c=1;
for kk=1:n:length(y)
     P= mod(y(kk:kk+(n-1))*Ht,2);
     for iii=1:n+1
         if P== synd(iii,1:4)
             ed=synd(iii,5:19);
         end
     end
      corrected_bits(kk:kk+(n-1))=xor(y(kk:kk+(n-1)),ed);
      decoded_bits(c:c+(k-1))=corrected_bits(kk+4:kk+(n-1));
    c=c+k;
end
recv_bits=decoded_bits;
errors=find(xor(recv_bits,x));
errors=size(errors,2);
BER(SNRdb)=errors/input;
end
SNRdb=1:10;
semilogy(SNRdb,BER,'b.-');
hold on
pc=0.5*erfc(sqrt((11/15)*10.^(SNRdb/10)));
t=1;
Pb=zeros(1,length(SNRdb));
for i=1:length(SNRdb)
    for j=t+1:n
        Pb(i)=Pb(i)+j*nchoosek(n,j)*pc(i).^j*(1-pc(i)).^(n-j);
    end
    Pb(i)=Pb(i)/n;
end
semilogy(SNRdb,Pb,'b.-');







