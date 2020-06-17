clc
clear all
%close all
input=10000000;
x = rand(1,input)>0.5;
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
for SNRdb = 1:10
    No = 10^(-SNRdb/10);
  
noise = ((No/2)^0.5)* (randn(1,(input)/2) + 1i * randn(1,(input)/2));
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

error=0;
for i=1:length(x)
    if y(i) ~= x(i)
        error= error+1;
    end
end
Pe(SNRdb)= error/length(x);
TheoPe(SNRdb) = 0.5*erfc(sqrt(1/No));
end
semilogy(Pe)
hold on
semilogy(TheoPe)

      
    