function [fappx,out_param]=funappxNoPenalty_g(varargin)
%funappxNoPenalty_g 1-D guaranteed locally adaptive function approximation (or
%   function recovery) on [a,b]
%
%   fappx = funappxNoPenalty_g(f) approximates function f on the default interval
%   [0,1] by an approximated function handle fappx within the guaranteed
%   absolute error tolerance of 1e-6. When Matlab version is higher or
%   equal to 8.3, fappx is an interpolant generated by griddedInterpolant.
%   When Matlab version is lower than 8.3, fappx is a function handle
%   generated by ppval and interp1. Input f is a function handle. The
%   statement y = f(x) should accept a vector argument x and return a
%   vector y of function values that is of the same size as x.
%
%   fappx = funappxNoPenalty_g(f,a,b,abstol) for a given function f and the ordered
%   input parameters that define the finite interval [a,b], and a
%   guaranteed absolute error tolerance abstol.
%
%   fappx = funappxNoPenalty_g(f,'a',a,'b',b,'abstol',abstol) approximates function
%   f on the finite interval [a,b], given a guaranteed absolute error
%   tolerance abstol. All four field-value pairs are optional and can be
%   supplied in different order.
%
%   fappx = funappxNoPenalty_g(f,in_param) approximates function f on the finite
%   interval [in_param.a,in_param.b], given a guaranteed absolute error
%   tolerance in_param.abstol. If a field is not specified, the default
%   value is used.
%
%   [fappx, out_param] = funappxNoPenalty_g(f,...) returns an approximated function
%   fappx and an output structure out_param.
%
%   Input Arguments
%
%     f --- input function
%
%     in_param.a --- left end point of interval, default value is 0
%
%     in_param.b --- right end point of interval, default value is 1
%
%     in_param.abstol --- guaranteed absolute error tolerance, default
%     value is 1e-6
%
%   Optional Input Arguments
%
%     in_param.nlo --- lower bound of initial number of points we use,
%     default value is 10
%
%     in_param.nhi --- upper bound of initial number of points we use,
%     default value is 1000
%
%     in_param.nmax --- when number of points hits the value, iteration
%     will stop, default value is 1e7
%
%     in_param.maxiter --- max number of iterations, default value is 1000
%
%   Output Arguments
%
%     fappx --- approximated function handle (Note: When Matlab version is
%     higher or equal to 8.3, fappx is an interpolant generated by
%     griddedInterpolant. When Matlab version is lower than 8.3, fappx is a
%     function handle generated by ppval and interp1.)
%
%     out_param.f --- input function
%
%     out_param.a --- left end point of interval
%
%     out_param.b --- right end point of interval
%
%     out_param.abstol --- guaranteed absolute error tolerance
%
%     out_param.nlo --- a lower bound of initial number of points we use
%
%     out_param.nhi --- an upper bound of initial number of points we use
%
%     out_param.nmax --- when number of points hits the value, iteration
%     will stop
%
%     out_param.maxiter --- max number of iterations
%
%     out_param.ninit --- initial number of points we use for each subinterval
%
%     out_param.exit --- this is a vector with two elements, defining the
%     conditions of success or failure satisfied when finishing the
%     algorithm. The algorithm is considered successful (with
%     out_param.exit == [0 0]) if no other flags arise warning that the
%     results are certainly not guaranteed. The initial value is [0 0] and
%     the final value of this parameter is encoded as follows:
%       
%                      [1 0]   If reaching overbudget. It states whether
%                      the max budget is attained without reaching the
%                      guaranteed error tolerance.
%        
%                      [0 1]   If reaching overiteration. It states whether
%                      the max iterations is attained without reaching the
%                      guaranteed error tolerance.
%
%     out_param.iter --- number of iterations
%
%     out_param.npoints --- number of points we need to reach the
%     guaranteed absolute error tolerance
%
%     out_param.errest --- an estimation of the absolute error for the
%     approximation
%
%     out_param.x --- sample points used to approximate function
%
%     out_param.bytes --- amount of memory used during the computation
%
%  Guarantee
%
%  For [a,b] there exists a partition, P={[t_0,t_1], [t_1,t_2], ...,
%  [t_{L-1},t_L]}, where a=t_0 < t_1 < ... < t_L=b. If the function to be
%  approximated, f, satisfies the cone condition
%                              2 nstar    ||     f(t_l)-f(t_{l-1})||
%      ||f''||        <=  --------------  ||f'- ----------------- ||
%             \infty       t_l - t_{l-1}  ||        t_l - t_{l-1} ||\infty,
%  for each sub interval [t_{l-1},t_l], where 1 <= l <= L, then the output
%  fappx by this algorithm is guaranteed to satisfy
%      ||f-fappx||\infty <= abstol.
%
%   Examples
%
%   Example 1:
%
%   >> f = @(x) x.^2;
%   >> [~, out_param] = funappxNoPenalty_g(f,-2,2,1e-7,10,20)
%
%   out_param =
% 
%                f: @(x)x.^2
%                a: -2
%                b: 2
%           abstol: 1.0000e-***7
%              nlo: 10
%              nhi: 20
%            ninit: 18
%             nmax: 10000000  
%          maxiter: 1000
%             exit: [2x1 logical]
%             iter: 9 
%          npoints: 8705
%           errest: 6.3451e-***8
%                x: [1x8705 double]
%
%
%   Example 2:
%
%   >> f = @(x) x.^2;
%   >> [~, out_param] = funappxNoPenalty_g(f,'a',-2,'b',2,'nhi',20,'nlo',10)
%
%   out_param = 
%
%                f: @(x)x.^2
%                a: -2
%                b: 2
%           abstol: 1.0000e-***6
%              nlo: 10
%              nhi: 20
%            ninit: 18
%             nmax: 10000000
%          maxiter: 1000
%             exit: [2x1 logical]
%             iter: 8
%          npoints: 4353
%           errest: 2.5418e-***7
%                x: [1x4353 double]
%
%
%   Example 3:
%
%   >> in_param.a = -5; in_param.b = 5; f = @(x) x.^2;
%   >> in_param.abstol = 10^(-6); in_param.nlo = 10; in_param.nhi = 20;
%   >> [~, out_param] = funappxNoPenalty_g(f,in_param)
%
%   out_param = 
% 
%                f: @(x)x.^2
%                a: -5
%                b: 5
%           abstol: 1.0000e-***6
%              nlo: 10
%              nhi: 20
%            ninit: 19 
%             nmax: 10000000
%          maxiter: 1000
%             exit: [2x1 logical]
%             iter: 9
%          npoints: 9217
%           errest: 3.5373e-***7
%                x: [1x9217 double]
%
%
%
%   See also INTERP1, GRIDDEDINTERPOLANT, INTEGRAL_G, MEANMC_G, FUNMIN_G
%
%
%  References
%
%   [1]  Nick Clancy, Yuhan Ding, Caleb Hamilton, Fred J. Hickernell, and
%   Yizhi Zhang, "The Cost of Deterministic, Adaptive, Automatic
%   Algorithms: Cones, Not Balls," Journal of Complexity 30, pp. 21-45,
%   2014.
%    
%   [2]  Yuhan Ding, Fred J. Hickernell, and Sou-Cheng T. Choi, "Locally
%   Adaptive Method for Approximating Univariate Functions in Cones with a
%   Guarantee for Accuracy," working, 2015.
%            
%   [3]  Sou-Cheng T. Choi, Yuhan Ding, Fred J. Hickernell, Lan Jiang,
%   Lluis Antoni Jimenez Rugama, Xin Tong, Yizhi Zhang and Xuan Zhou,
%   GAIL: Guaranteed Automatic Integration Library (Version 2.1) [MATLAB
%   Software], 2015. Available from http://code.google.com/p/gail/
%
%   [4] Sou-Cheng T. Choi, "MINRES-QLP Pack and Reliable Reproducible
%   Research via Supportable Scientific Software," Journal of Open Research
%   Software, Volume 2, Number 1, e22, pp. 1-7, 2014.
%
%   [5] Sou-Cheng T. Choi and Fred J. Hickernell, "IIT MATH-573 Reliable
%   Mathematical Software" [Course Slides], Illinois Institute of
%   Technology, Chicago, IL, 2013. Available from
%   http://code.google.com/p/gail/ 
%
%   [6] Daniel S. Katz, Sou-Cheng T. Choi, Hilmar Lapp, Ketan Maheshwari,
%   Frank Loffler, Matthew Turk, Marcus D. Hanwell, Nancy Wilkins-Diehr,
%   James Hetherington, James Howison, Shel Swenson, Gabrielle D. Allen,
%   Anne C. Elster, Bruce Berriman, Colin Venters, "Summary of the First
%   Workshop On Sustainable Software for Science: Practice And Experiences
%   (WSSSPE1)," Journal of Open Research Software, Volume 2, Number 1, e6,
%   pp. 1-21, 2014.
%
%   If you find GAIL helpful in your work, please support us by citing the
%   above papers, software, and materials.
%

% check parameter satisfy conditions or not
[f, in_param] = funappxNoPenalty_g_param(varargin{:});
MATLABVERSION = gail.matlab_version;
%nstar = out_param.nstar;
%out_param.ninit = 2 * nstar + 1;

% control the order of out_param
out_param.f = f;
out_param.a = in_param.a;
out_param.b = in_param.b;
out_param.abstol = in_param.abstol;
out_param.nlo = in_param.nlo;
out_param.nhi = in_param.nhi;
out_param.ninit = in_param.ninit;
out_param.nmax = in_param.nmax ;
out_param.maxiter = in_param.maxiter;

ninit = out_param.ninit;

%% main algorithm
a = out_param.a;
b = out_param.b;
abstol = out_param.abstol;
out_param.x = a:(b-a)/(ninit-1):b;
y = f(out_param.x);
%fh = b-a;
fh = 4*(b-a)/(ninit-1);
C0 = 1.2;
iSing = find(isinf(y));
if ~isempty(iSing)
    error('GAIL:funappxNoPenalty_g:yInf',['Function f(x) = Inf at x = ', num2str(out_param.x(iSing))]);
end
if length(y) == 1  
    % probably f is a constant function and Matlab would  
    % reutrn only a scalar y = f(x) even if x is a vector 
    f = @(x) f(x) + 0 * x;
    y = f(out_param.x);
end
iter = 0;
exit_len = 2;
% we start the algorithm with all warning flags down
out_param.exit = false(exit_len,1); 
C = @(h) C0*fh./(fh-h);
max_errest = 1;
while(max_errest > abstol)
    % length of each subinterval
    len = out_param.x(2:end)-out_param.x(1:end-1);
    
    % approximate f''(t)
    deltaf = 2*(y(1:end-2)./len(1:end-1)./(len(1:end-1)+len(2:end))-...
             y(2:end-1)./len(1:end-1)./len(2:end)+...
             y(3:end)./len(2:end)./(len(1:end-1)+len(2:end)));
    % add 
    deltaf=[0 0 abs(deltaf) 0 0];
    
    % compute vector h
    h = [out_param.x(2)-a out_param.x(3)-a out_param.x(4:end)-out_param.x(1:end-3) b-out_param.x(end-2) b-out_param.x(end-1)];
    
    % bound of |f''(t)|
    normbd = C(max(h(1:ninit-1),h(3:ninit+1))) .* max(deltaf(1:ninit-1),deltaf(4:ninit+2));
    
    % error estimation
    errest = len.^2/8.*normbd;
    max_errest = max(errest);
    if max_errest <= abstol,
        break
    end 
 
    % find I
    badinterval = (errest > abstol);
    
    % update x,y
    whichcut = badinterval | [badinterval(2:end) 0] | [0 badinterval(1:end-1)];
    whichcut1 = (whichcut==1);
    newx = out_param.x(whichcut1) + 0.5 * len(whichcut1);
    tt = cumsum(whichcut); 
    out_param.x([1 (2:ninit)+tt]) = out_param.x;
    y([1 (2:ninit)+tt]) = y;
    tem = 2 * tt + cumsum(whichcut==0);
    out_param.x(tem(whichcut1)) = newx;
    y(tem(whichcut1)) = f(newx);
    
    % update errorbound
%     errnew = zeros(1,ninit+length(newx)-2);
%     errnew((1:length(whichcut))+tt) = errest;
%     errnew((1:length(whichcut))+[0 tt(1:end-1)]) = errest;
%     errest = max(errest);   
    
    ninit = length(out_param.x);

    % update iterations
    iter = iter + 1;
    if(iter==out_param.maxiter)
        out_param.exit(2) = 1;
        warning('GAIL:funappxNoPenalty_g:exceediter',['Number of iterations has '...
            'reached maximum number of iterations.'])
        break;
    end;
end;

out_param.iter = iter;
out_param.npoints = ninit;
out_param.errest = max_errest;
[out_param, ~] = orderfields(out_param, ...
                   {'f', 'a', 'b','abstol','nlo','nhi','ninit','nmax','maxiter',...
                    'exit','iter','npoints','errest','x'});
% out_param.nstar = nstar;
if MATLABVERSION >= 8.3
    fappx = griddedInterpolant(out_param.x,y,'linear');
else
    fappx = @(t) ppval(interp1(out_param.x,y,'linear','pp'), t);     
end;
if (in_param.memorytest==1)
  w = whos;
  out_param.bytes = sum([w.bytes]);
end


function [f, out_param] = funappxNoPenalty_g_param(varargin)
% parse the input to the funappxNoPenalty_g function

%% Default parameter values

default.abstol = 1e-6;
default.a = 0;
default.b = 1;
default.nlo = 10;
default.nhi = 1000;
default.nmax = 1e7;
default.maxiter = 1000;
default.memorytest = 0;

MATLABVERSION = gail.matlab_version;
if MATLABVERSION >= 8.3
    f_addParamVal = @addParameter;
else
    f_addParamVal = @addParamValue;
end;

 
if isempty(varargin)
  warning('GAIL:funappxNoPenalty_g:nofunction',['Function f must be specified. '...
      'Now GAIL is using f(x)=exp(-100*(x-0.5)^2) and unit interval '...
      '[0,1].'])
  help funappxNoPenalty_g
  f = @(x) exp(-100*(x-0.5).^2);
  out_param.f = f;
else
  if gail.isfcn(varargin{1})
    f = varargin{1};
    out_param.f = f;
  else
    warning('GAIL:funappxNoPenalty_g:notfunction',['Function f must be a '...
        'function handle. Now GAIL is using f(x)=exp(-100*(x-0.5)^2).'])
    f = @(x) exp(-100*(x-0.5).^2);
    out_param.f = f;
  end
end;

validvarargin=numel(varargin)>1;
if validvarargin
    in2=varargin{2};
    validvarargin=(isnumeric(in2) || isstruct(in2) ...
        || ischar(in2));
end

if ~validvarargin
    %if only one input f, use all the default parameters
    out_param.a = default.a;
    out_param.b = default.b;
    out_param.abstol = default.abstol;
    out_param.nlo = default.nlo;
    out_param.nhi = default.nhi;
    out_param.nmax = default.nmax ;
    out_param.maxiter = default.maxiter;
    out_param.memorytest = default.memorytest;
else
    p = inputParser;
    addRequired(p,'f',@gail.isfcn);
    if isnumeric(in2)%if there are multiple inputs with
        %only numeric, they should be put in order.
        addOptional(p,'a',default.a,@isnumeric);
        addOptional(p,'b',default.b,@isnumeric);
        addOptional(p,'abstol',default.abstol,@isnumeric);
        addOptional(p,'nlo',default.nlo,@isnumeric);
        addOptional(p,'nhi',default.nhi,@isnumeric);
        addOptional(p,'nmax',default.nmax,@isnumeric)
        addOptional(p,'maxiter',default.maxiter,@isnumeric)
        addOptional(p,'memorytest',default.memorytest,@isnumeric)
    else
        if isstruct(in2) %parse input structure
            p.StructExpand = true;
            p.KeepUnmatched = true;
        end
        f_addParamVal(p,'a',default.a,@isnumeric);
        f_addParamVal(p,'b',default.b,@isnumeric);
        f_addParamVal(p,'abstol',default.abstol,@isnumeric);
        f_addParamVal(p,'nlo',default.nlo,@isnumeric);
        f_addParamVal(p,'nhi',default.nhi,@isnumeric);
        f_addParamVal(p,'nmax',default.nmax,@isnumeric);
        f_addParamVal(p,'maxiter',default.maxiter,@isnumeric);
        f_addParamVal(p,'memorytest',default.memorytest,@isnumeric);
    end
    parse(p,f,varargin{2:end})
    out_param = p.Results;
end;

% let end point of interval not be infinity
if (out_param.a == inf||out_param.a == -inf)
    warning('GAIL:funappxNoPenalty_g:aisinf',['a cannot be infinity. '...
        'Use default a = ' num2str(default.a)])
    out_param.a = default.a;
end;
if (out_param.b == inf||out_param.b == -inf)
    warning(['GAIL:funappxNoPenalty_g:bisinf','b cannot be infinity. '...
        'Use default b = ' num2str(default.b)])
    out_param.b = default.b;
end;

if (out_param.b < out_param.a)
    warning('GAIL:funappxNoPenalty_g:blea',['b cannot be smaller than a;'...
        ' exchange these two. '])
    tmp = out_param.b;
    out_param.b = out_param.a;
    out_param.a = tmp;
elseif(out_param.b == out_param.a)
    warning('GAIL:funappxNoPenalty_g:beqa',['b cannot equal a. '...
        'Use b = ' num2str(out_param.a+1)])
    out_param.b = out_param.a+1;
end;

% let error tolerance greater than 0
if (out_param.abstol <= 0 )
    warning('GAIL:funappxNoPenalty_g:tolneg', ['Error tolerance should be greater'...
        ' than 0. Using default error tolerance ' num2str(default.abstol)])
    out_param.abstol = default.abstol;
end
% let cost budget be a positive integer
if (~gail.isposint(out_param.nmax))
    if gail.isposintive(out_param.nmax)
        warning('GAIL:funappxNoPenalty_g:budgetnotint',['Cost budget should be '...
            'a positive integer. Using cost budget '...
            , num2str(ceil(out_param.nmax))])
        out_param.nmax = ceil(out_param.nmax);
    else
        warning('GAIL:funappxNoPenalty_g:budgetisneg',['Cost budget should be '...
            'a positive integer. Using default cost budget '...
            int2str(default.nmax)])
        out_param.nmax = default.nmax;
    end;
end

if (~gail.isposint(out_param.nlo))
    if gail.isposge3(out_param.nlo)
        warning('GAIL:funappxglobal_g:lowinitnotint',['Lower bound of '...
        'initial number of points should be a positive integer.' ...
            ' Using ', num2str(ceil(out_param.nlo)) ' as nlo '])
        out_param.nlo = ceil(out_param.nlo);
    else
        warning('GAIL:funappxglobal_g:lowinitlt3',[' Lower bound of '...
        'initial number of points should be a positive integer greater'...
        ' than 3. Using 3 as nlo'])
        out_param.nlo = 3;
   end
        warning('GAIL:funappxglobal_g:lowinitnotint',['Lower bound of '...
        'initial nstar should be a positive integer.' ...
        ' Using ', num2str(ceil(out_param.nlo)) ' as nlo '])
        out_param.nlo = ceil(out_param.nlo);
end
 if (~gail.isposint(out_param.nhi))
    if gail.isposge3(out_param.nhi)
        warning('GAIL:funappxglobal_g:hiinitnotint',['Upper bound of '...
        'initial number of points should be a positive integer.' ...
        ' Using ', num2str(ceil(out_param.nhi)) ' as nhi' ])
        out_param.nhi = ceil(out_param.nhi);
    else
        warning('GAIL:funappxglobal_g:hiinitlt3',[' Upper bound of '...
        'points should be a positive integer greater than 3. Using '...
        'default number of points ' int2str(default.nhi) ' as nhi' ])
        out_param.nhi = default.nhi;
    end
         warning('GAIL:funappxglobal_g:hiinitnotint',['Upper bound of '...
        'initial nstar should be a positive integer.' ...
        ' Using ', num2str(ceil(out_param.nhi)) ' as nhi' ])
        out_param.nhi = ceil(out_param.nhi);
end

if (out_param.nlo > out_param.nhi)
    warning('GAIL:funappxNoPenalty_g:logrhi', ['Lower bound of initial number of'...
        ' points is larger than upper bound of initial number of '...
        'points; Use nhi as nlo'])
    out_param.nhi = out_param.nlo;
end;

h = out_param.b - out_param.a;
out_param.ninit = ceil(out_param.nhi*(out_param.nlo/out_param.nhi)...
    ^(1/(1+h)));

if (~gail.isposint(out_param.maxiter))
    if gail.ispositive(out_param.maxiter)
        warning('GAIL:funappxNoPenalty_g:maxiternotint',['Max number of '...
            'iterations should be a positive integer. Using max number '...
            'of iterations as  ', num2str(ceil(out_param.maxiter))])
        out_param.nmax = ceil(out_param.nmax);
    else
        warning('GAIL:funappxNoPenalty_g:budgetisneg',['Max number of iterations'...
            ' should be a positive integer. Using max number of '...
            'iterations as ' int2str(default.maxiter)])
        out_param.nmax = default.nmax;
    end;
end
if (out_param.memorytest~=1&&out_param.memorytest~=0)
    warning('GAIL:funappxNoPenalty_g:memorytest', ['Input of memorytest'...
        ' can only be 0 or 1; use default value 0'])
    out_param.memorytest = 0;
end;
