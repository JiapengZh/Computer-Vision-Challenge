function [T, R] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen, K1, K2)
    n = size(Korrespondenzen,2);
    T_cell = {T1,T2,T1,T2};
    R_cell = {R1,R1,R2,R2};
    x1_uncalibrited = [Korrespondenzen(1:2,:);ones(1,n)];
    x1 = K1^-1*x1_uncalibrited;
    x2_uncalibrited = [Korrespondenzen(3:4,:);ones(1,n)];
    x2 = K2^-1*x2_uncalibrited;
    d_cell_elem = zeros(size(Korrespondenzen,2),2);
    d_cell = {d_cell_elem,d_cell_elem,d_cell_elem,d_cell_elem};
    
    for k = 1:size(T_cell,2)
        M1 = zeros(n*3,n+1);
        for i = 1:n
            M1(1+(i-1)*3:i*3,i) = cross(x2(:,i), R_cell{k}*x1(:,i));%
            M1(1+(i-1)*3:i*3,n+1) = cross(x2(:,i), T_cell{k});
        end
        M2 = zeros(3*n,n+1);
        for l =1:n
            M2(1+(l-1)*3:l*3,l) = cross(x1(:,l), R_cell{k}'*x2(:,l));%
            M2(1+(l-1)*3:l*3,n+1) = -cross(x1(:,l), R_cell{k}'*T_cell{k});
        end
        [~,~,V1] = svd(M1);
        d1 = V1(:,n+1);
        d1 = d1./d1(end);
        [~,~,V2] = svd(M2);
        d2 = V2(:,n+1);
        d2 = d2./d2(end);
        d_cell{k} = [d1(1:end-1) d2(1:end-1)];
    end

    counts = zeros(1,4);
    for k = 1:4
        count = 0;
        for i = 1:size(Korrespondenzen,2)
            if d_cell{k}(i,1)>0
                count = count+1;
            end
            if d_cell{k}(i,2)>0
                count = count+1;
            end
        end
        counts(1,k) = count;
    end
    [~,index] = max(counts);
    T = T_cell{index};
    R = R_cell{index};
    T=single(T);
    R=single(R);

end
