mean_output_new = zeros(1,288);

k=1;
for i=1:96
    for j=1:3
        newSignal(k) = signal(i);
        k=k+1;
    end
end

for i=1:288
    if (i >=50 & i<=200)
        noisySignal(i) = newSignal(i) + 10*randn(1);
    end
end
