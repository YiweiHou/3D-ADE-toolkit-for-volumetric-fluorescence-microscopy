function [kcMax,lambda_optimal] = Mutlifiltering(g_stack_sample,weiper,gpu)
%UNTITLED2 Summary of this function goes here
%   Decorr hyper-parameters
        Nr = 50;
        Ng = 10;
        r = linspace(0,1,Nr);
        g_stack_AIP = mean(double(g_stack_sample), 3);

         [kc0,~] = getDcorr(g_stack_AIP,r,Ng,0);
        kcMax = kc0;

        count = 1;
        lambda_optimal = 0;
        lambda_bank = [2e-2,1e-2,5e-3,1e-3];
        for i=1:length(lambda_bank)
            g_stack_filtered = FrameSUREReg(g_stack_sample,lambda_bank(i),weiper,20,gpu); 
            g_stack_filtered = mean(double(g_stack_filtered), 3);

            count = count + 1;
            g_stack_filtered = apodImRect(g_stack_filtered,20);
             [kc,~] = getDcorr(g_stack_filtered,r,Ng,0);

            if kc>kcMax
                kcMax = kc;
                lambda_optimal = lambda_bank(i);
            end
        end
end