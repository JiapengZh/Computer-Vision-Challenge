function [Korrespondenzen_robust] = F_ransac(Korrespondenzen, varargin)
    p = inputParser;
    
    p.addRequired('Korrespondenzen');
    
    defaultepsilon = 0.2;
    p.addOptional('epsilon', defaultepsilon, @(x) isnumeric(x) && (x>0) && (x<1));
    
    defaultp = 0.2;
    p.addOptional('p', defaultp, @(x) isnumeric(x) && (x>0) && (x<1));
    
    defaulttolerance = 0.01;
    p.addOptional('tolerance', defaulttolerance, @(x) isnumeric(x));
    
    p.parse(Korrespondenzen, varargin{:});
    
    epsilon = p.Results.epsilon;
    tolerance = p.Results.tolerance;
    p = p.Results.p;
    x1 = Korrespondenzen(1:2,:);
    x1_pixel = [x1;ones(1,size(x1,2))];
    x2 = Korrespondenzen(3:4,:);
    x2_pixel = [x2;ones(1,size(x2,2))];
    
    k = 8;
    s = log(1-p)/(log(1-(1-epsilon)^k));
    largest_set_size= 0;
    largest_set_dist= inf;
    largest_set_F = zeros(3,3);

    for i = 1:s
        consensus_sets = Korrespondenzen(:,randperm(size(Korrespondenzen,2), k));
        [EF] = achtpunktalgorithmus(consensus_sets);
        sd = sampson_dist(EF, x1_pixel, x2_pixel);
        [m,n] = find(sd<tolerance);
        if size(n)>=1
          n = n(1);
        end
        consensus_sets =  cat(2,consensus_sets,Korrespondenzen(:,n));
    
        set_size = size(consensus_sets,2);
    
        x1_sets_pixel = [x1;ones(1,size(x1,2))];
        x2_sets_pixel = [x2;ones(1,size(x2,2))];

        sd_sets = sampson_dist(EF, x1_sets_pixel, x2_sets_pixel);
        sd = sd + sd_sets;
        if set_size > largest_set_size
           largest_set_size = set_size;
           largest_set_dist = sd;
           Korrespondenzen_robust = consensus_sets;
        end
        if set_size == largest_set_size
            if sd < largest_set_dist
                    largest_set_size = set_size;
                    largest_set_dist = sd;
                    Korrespondenzen_robust = consensus_sets;
            end   
        end
    end

end
