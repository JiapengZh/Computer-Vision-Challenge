classdef test < matlab.unittest.TestCase
    %Test your challenge solution here using matlab unit tests
    %
    % Check if your main file 'challenge.m', 'disparity_map.m' and 
    % verify_dmap.m do not use any toolboxes.
    %
    % Check if all your required variables are set after executing 
    % the file 'challenge.m'
    
    properties
        m_verify_damp = 'verify_dmap.m'
        m_disparitymap_census = 'census.m'
        m_disparity_map_GM ='disparity_map.m'
        m_challenge = 'challenge.m'
    end
        
    methods(Test)
        function testToolBox(Static) 
        % Verifies single input case
            %challenge;             
%             expOut    = 'matlab';      
%             actualOut =  getfield(license('inuse'), 'feature');              
%             test.verifyEqual(actualOut,expOut);
            [~,pList_disparitymap_census] = matlab.codetools.requiredFilesAndProducts(Static.m_disparitymap_census);
            [~,pList_disparity_map_GM ] = matlab.codetools.requiredFilesAndProducts(Static.m_disparity_map_GM );
            [~,pList_verify_damp] = matlab.codetools.requiredFilesAndProducts(Static.m_verify_damp);
            [~,pList_challenge] = matlab.codetools.requiredFilesAndProducts(Static.m_challenge);
            flag = size({pList_disparitymap_census}',1)>1||size({pList_disparity_map_GM}',1)>1||size({pList_verify_damp}',1)>1||size({pList_challenge}',1)>1;
            if flag == 1
            X_toolbox = ['used toolboxes are'... 
            {pList_disparitymap_census.Name},{pList_disparity_map_GM.Name},{pList_verify_damp.Name}];
            disp(X_toolbox);
            else
            X_toolbox = ['Toolboxes would not be used'];
            disp(X_toolbox);

            end
        end
        
        function testIsEmpty(test)
            variables_struct = whos;
            num_of_var = length(variables_struct);
            check = zeros(1, num_of_var);
            for i = 1 : num_of_var
                isEmp = isempty(variables_struct(i));
                check(1, i) = isEmp;
            end
            expOut    = zeros(size(check),'like',check);      
            actualOut =  check;                
            test.verifyEqual(actualOut,expOut)
            X_var = ['Variables are not null'];
            disp(X_var);
            
        end
        
        function testPSNR(test)
            D = evalin('base', 'D_l');
            G = evalin('base', 'G');
            G=uint8(G);
            p = evalin('base', 'p');
            p_psnr = psnr(D,G);
            tolerance = 0.01;
            expOut = true;
            actualOut = abs(p_psnr - p) < tolerance;
            test.verifyEqual(actualOut,expOut);
            X_t = ['psnr is under tolerance'];
            disp(X_t);
        end
    end
    
end