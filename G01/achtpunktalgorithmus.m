function [EF] = achtpunktalgorithmus(Korrespondenzen, K1, K2)
    x1 = Korrespondenzen(1:2,:);
    x1 = [x1;ones(1,size(x1,2))];
    x2 = Korrespondenzen(3:4,:);
    x2 = [x2;ones(1,size(x2,2))];

    if exist('K1','var')
        x1 = K1^-1*x1;
        x2 = K2^-1*x2;
    end
    A = [x1(1,:).*x2(1,:);
        x1(1,:).*x2(2,:);
        x1(1,:).*x2(3,:);
        x1(2,:).*x2(1,:);
        x1(2,:).*x2(2,:);
        x1(2,:).*x2(3,:);
        x1(3,:).*x2(1,:);
        x1(3,:).*x2(2,:);
        x1(3,:).*x2(3,:)]';
 
    [~,~,V] = svd(A);
    G = V(:,9);
    G = reshape(G,[3,3]);
    [U_g,Sigma_g,V_g] = svd(G);
    Sigma_g_new = zeros(size(Sigma_g));

    Sigma_g_new(1,1) = Sigma_g(1,1);
    Sigma_g_new(2,2) = Sigma_g(2,2);
    Sigma_g_new(3,3) = 0;

    if exist('K','var')
        EF=U_g*diag([1,1,0])*V_g';
    else
        EF = U_g*Sigma_g_new*V_g';
    end
end