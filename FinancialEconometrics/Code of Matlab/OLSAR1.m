% Take a look at the OLS estimate with respect to sample size
% Y_t = alpha + beta*y_t-1 + e_t,e~(0,sigma^2)

clc

T = [50,100,500];
alpha = 0.2;
beta = 0.8;
sigma = 0.2;
Nsim =1000;
bhatMatrix = zeros(3,Nsim,2);
y0 = alpha/(1-beta);
for i =1:3   %for each sample size
    TT = T(i);
    ytemp =  zeros(TT,1);
    ytemp(1)=y0;
    for n = 1:Nsim
        for t =  2:TT    % data simulation
            ytemp(t)= alpha +beta*ytemp(t-1)+sigma*randn;
        end
        
        yLHS = ytemp(2:end);
        yRHS = ytemp(1:end-1);
        
        yRHS = [ones(TT-1,1),yRHS];   %OLS estimate
        
        bhat = yRHS\yLHS;
        bhatMatrix(i,n,:)=bhat';
    end
end
    
% mean parameter estimate for each sample 
bhatmean = squeeze(mean(bhatMatrix,2));
bhatstd = squeeze (std(bhatMatrix,0,2));

% the bias from OLS becomes larger when sample size becomes smaller
% when beta is close to one the bias from OLS in simaple size is larger
