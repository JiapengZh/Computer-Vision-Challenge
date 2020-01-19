function [T1, R1, T2, R2, U, V]=TR_aus_E(E)


    [U,S,V] = svd(E);
 
    D =zeros(3,3);
    D(1,1) = 1;
    D(2,2) = 1;
    D(3,3) = -1;
    if det(U) < 0
        U = U*D;
        S = D*S;
    end

    if det(V) <0
        S = S *D;
        Vtrans = D*V';
        V = Vtrans';
    end
    
    RZ_pos = zeros(3,3);
    RZ_pos(1,2) = -1;
    RZ_pos(2,1) = 1;
    RZ_pos(3,3) = 1;
    R1 = U*RZ_pos'*V';
    T1dach = U*RZ_pos*S*U';
    T1 = zeros(3,1);
    T1(1) = T1dach(3,2);
    T1(2) = T1dach(1,3);
    T1(3) = T1dach(2,1);
    RZ_neg = zeros(3,3);
    RZ_neg(1,2) = 1;
    RZ_neg(2,1) = -1;
    RZ_neg(3,3) = 1;
    R2 = U*RZ_neg'*V';
    T2dach = U*RZ_neg*S*U';
    T2 = zeros(3,1);
    T2(1) = T2dach(3,2);
    T2(2) = T2dach(1,3);
    T2(3) = T2dach(2,1);

end