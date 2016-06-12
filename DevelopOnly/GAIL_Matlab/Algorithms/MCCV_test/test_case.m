addpath('/Users/qiantianpei/Desktop/GAIL_Dev/DevelopOnly/GAIL_Matlab/Algorithms')



distfun2 = @(n) sqrt(sum((rand(n,2)  - rand(n,2)).^2,2));

tic, tmu = meanMCCV_g(@distfun, [0.5 0.5 0.5 0.5], distfun2, 0.0002, 0), toc
tic, tmu = meanMC_g(distfun2,0.0002,0), toc


expr2 = @(n) exp(rand(n, 1));
tic, tmu = meanMCCV_g(@expr,[0.5],expr2, 0.0002, 0), toc
tic, tmu = meanMC_g(expr2,0.0002,0), toc
