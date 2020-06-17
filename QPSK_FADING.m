clc
clear all
%close all
input=161*10^3;
x = rand(1,input)>0.5;
% SNRdbVec=0:25;
j=1;

for i = 1:2:length(x)
    if x(i)==0 && x(i+1) == 0
        s(j) = -1-1*1i;
    elseif x(i)==0 && x(i+1) == 1
        s(j)= -1+1*1i;
    elseif x(i)==1 && x(i+1) == 0
        s(j)= 1-1*1i;
    else
        s(j)= 1+1*1i;
    end
    j=j+1;
end
     h=sqrt(1/2)*(randn(1,input/(2*161))+1i*randn(1,input/(2*161)));
         hprime= abs(h);
    for ii= 0:(input/(2*161))-1
   
    faded_sig(161*ii+1:(ii+1)*161)=s(161*ii+1:(ii+1)*161)*hprime(ii+1);
    end
     
    indexBER = 1;
for SNRdb = 1:25
% for SNRdb = SNRdbVec
    No = 10^(-SNRdb/10);


  
noise = ((No/2)^0.5)* (randn(1,(input)/2) + 1i * randn(1,(input)/2));
receivedsig = faded_sig + noise;
for kk= 0:(length(receivedsig)/161)-1
    receivedsig1(161*kk+1:(kk+1)*161) = receivedsig(161*kk+1:(kk+1)*161)/hprime(kk+1);
end
j=1;
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

error=0;
for i=1:length(x)
    if y(i) ~= x(i)
        error= error+1;
    end
end
% Pe(SNRdb)= error/length(x);
BER(indexBER)=error/input;
% TheoPe(SNRdb) = 0.5*erfc(sqrt(1/No));
indexBER = indexBER+1;
end

semilogy(BER)
hold on
% semilogy(TheoPe)
grid on
% axis([0 30 10^-6 1.0])
xlabel('Eb/N0')
ylabel('Bit Error Rate')
