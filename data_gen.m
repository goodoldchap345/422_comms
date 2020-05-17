
clear all;
close all;
clf;

L = 10;

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

s_data