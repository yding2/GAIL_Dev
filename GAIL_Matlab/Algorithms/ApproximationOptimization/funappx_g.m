function [fappx,out_param]=funappx_g(varargin)
%funappx_g 1-D guaranteed locally adaptive function approximation (or
%   function recovery) on [a,b]
%
%   fappx = funappx_g(f) approximates function f on the default interval
%   [0,1] by an approximated function handle fappx within the guaranteed
%   absolute error tolerance of 1e-6. When Matlab version is higher or
%   equal to 8.3, fappx is an interpolant generated by griddedInterpolant.
%   When Matlab version is lower than 8.3, fappx is a function handle
%   generated by ppval and interp1. Input f is a function handle. The
%   statement y = f(x) should accept a vector argument x and return a
%   vector y of function values that is of the same size as x.
%
%   fappx = funappx_g(f,a,b,abstol) for a given function f and the ordered
%   input parameters that define the finite interval [a,b], and a
%   guaranteed absolute error tolerance abstol.
%
%   fappx = funappx_g(f,'a',a,'b',b,'abstol',abstol) approximates function
%   f on the finite interval [a,b], given a guaranteed absolute error
%   tolerance abstol. All four field-value pairs are optional and can be
%   supplied in different order.
%
%   fappx = funappx_g(f,in_param) approximates function f on the finite
%   interval [in_param.a,in_param.b], given a guaranteed absolute error
%   tolerance in_param.abstol. If a field is not specified, the default
%   value is used.
%
%   [fappx, out_param] = funappx_g(f,...) returns an approximated function
%   fappx and an output structure out_param.
%
%   Properties
%    
%     fappx can be used for linear extrapolation outside [a,b].
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
%     in_param.ninit --- initial number of subintervals. Default to 20.
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
%     out_param.maxiter --- max number of iterations
%
%     out_param.ninit --- initial number of subintervals
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
%
%   Examples
%
%   Example 1:
%
%   >> f = @(x) x.^2;
%   >> [~, out_param] = funappx_g(f,-2,2,1e-7,18)
%
% out_param =***
% 
%            a: -2
%       abstol: 1.0000e-07
%            b: 2
%            f: @(x)x.^2
%      maxiter: 1000
%        ninit: 18
%         nmax: 10000000
%     exitflag: [0 0 0 0 0]
%         iter: 12
%      npoints: 36865
%       errest: 2.9448e-***8
%
%
%   Example 2:
%
%   >> f = @(x) x.^2;
%   >> [~, out_param] = funappx_g(f,'a',-2,'b',2,'ninit',17)
%
%out_param = 
%            a: -2
%       abstol: 1.0000e-06
%            b: 2
%            f: @(x)x.^2
%      maxiter: 1000
%        ninit: 17
%         nmax: 10000000
%     exitflag: [0 0 0 0 0]
%         iter: 10
%      npoints: 8705
%       errest: 5.2896e-***7
%
%
%   Example 3:
%
%   >> in_param.a = -5; in_param.b = 5; f = @(x) x.^2;
%   >> in_param.abstol = 10^(-6); in_param.ninit=18;
%   >> [~, out_param] = funappx_g(f,in_param)
% 
% out_param = 
% 
%            a: -5
%       abstol: 1.0000e-06
%            b: 5
%            f: @(x)x.^2
%      maxiter: 1000
%        ninit: 18
%         nmax: 10000000
%     exitflag: [0 0 0 0 0]
%         iter: 11
%      npoints: 18433
%       errest: 7.3654e-***7
%
%   
%   See also INTERP1, GRIDDEDINTERPOLANT, INTEGRAL_G, MEANMC_G, FUNMIN_G
%
%
%  References
%
%   [1]  Sou-Cheng T. Choi, Yuhan Ding, Fred J.Hickernell, Xin Tong, "Local
%   Adaption for Approximation and Minimization of Univariate Functions,"
%   working, 2016.
%
%   [2]  Nick Clancy, Yuhan Ding, Caleb Hamilton, Fred J. Hickernell, and
%   Yizhi Zhang, "The Cost of Deterministic, Adaptive, Automatic
%   Algorithms: Cones, Not Balls," Journal of Complexity 30, pp. 21-45,
%   2014.
%            
%   [3]  Sou-Cheng T. Choi, Yuhan Ding, Fred J. Hickernell, Lan Jiang,
%   Lluis Antoni Jimenez Rugama, Xin Tong, Yizhi Zhang and Xuan Zhou,
%   GAIL: Guaranteed Automatic Integration Library (Version 2.2) [MATLAB
%   Software], 2017. Available from http://gailgithub.github.io/GAIL_Dev/
%
%   [4] Sou-Cheng T. Choi, "MINRES-QLP Pack and Reliable Reproducible
%   Research via Supportable Scientific Software," Journal of Open Research
%   Software, Volume 2, Number 1, e22, pp. 1-7, 2014.
%
%   [5] Sou-Cheng T. Choi and Fred J. Hickernell, "IIT MATH-573 Reliable
%   Mathematical Software" [Course Slides], Illinois Institute of
%   Technology, Chicago, IL, 2013. Available from
%   http://gailgithub.github.io/GAIL_Dev/ 
%
%   If you find GAIL helpful in your work, please support us by citing the
%   above papers, software, and materials.
%

% check parameter satisfy conditions or not
[f, in_param]= funappx_g_param(varargin{:});
%in_param = gail.funappx_g_in_param(varargin{:});
%out_param = in_param.toStruct();
out_param = in_param;
%f = in_param.f;
MATLABVERSION = gail.matlab_version;
%out_param = in_param;
out_param = rmfield(out_param,'memorytest');
out_param = rmfield(out_param,'output_x');

%% main algorithm
a = out_param.a;
b = out_param.b;
abstol = out_param.abstol;
%initialize number of points
ninitp = out_param.ninit+1;
x = zeros(1, max(100,ceil(out_param.nmax/100))); % preallocation
y = x;
x(1:ninitp) = a:(b-a)/(ninitp-1):b;
y(1:ninitp) = f(x(1:ninitp));
indexI = ([0 ones(1,ninitp-2) 0]>0);
iSing = find(isinf(y));
if ~isempty(iSing)
    out_param.exitflag(5) = true;
    error('GAIL:funappx_g:yInf',['Function f(x) = Inf at x = ', num2str(x(iSing))]);
end
if length(y) == 1  
    % probably f is a constant function and Matlab would  
    % reutrn only a scalar y = f(x) even if x is a vector 
    f = @(x) f(x) + 0 * x;
    y(1:ninitp) = f(x(1:ninitp));
end
iter = 0;
exit_len = 5;
% we start the algorithm with all warning flags down
out_param.exitflag = false(1,exit_len);
C0 = 10;
fh = 3*(b-a)/(ninitp-2);
C = @(h) (C0 * fh)./(fh-h);
%C = @(h) (C0 * 2)./(1+exp(-h)); % logistic
%C = @(h) C0 * (1+h.^2);         % quadratic
npoints = ninitp;
for iter_i = 1:out_param.maxiter,
    %% Stage 1: Check for convergence
    %% Compute the error for i in I
    len = diff(x(1:npoints));
    deltaf = diff(diff(y(1:npoints)));
    h = x(2:npoints-1) - x(1:npoints-2);
    err(indexI(2:end-1)) = abs(1/8 * C(3*h(indexI(2:end-1)))...
                           .* deltaf(indexI(2:end-1)));
    indexI(2:end-1) = (err > abstol);

    % update iterations
    iter = iter + 1;
    max_errest = max(err);
    if max_errest <= abstol,
        break
    end 
 
    %% Stage 2: Split the subintervals as needed
    %find the index of the subinterval which is needed to be cut
    midpoint = ([indexI(3:end) 0 0 ] | [indexI(2:end) 0]...
               | indexI | [0 indexI(1:end-1)]);
    whichcut = midpoint(1:end-1);
    
    %check to see if exceed the cost budget
    if (out_param.nmax<(npoints+length(find(whichcut))))
        out_param.exitflag(1) = true;
        warning('GAIL:funappx_g:exceedbudget',['funappx_g '...
            'attempted to exceed the cost budget. The answer may be '...
            'unreliable.'])
        break;
    end; 
    
    %check to see if exceed the maximumber number of iterations
    if(iter==out_param.maxiter)
        out_param.exitflag(2) = true;
        warning('GAIL:funappx_g:exceediter',['Number of iterations has '...
            'reached maximum number of iterations.'])
        break;
    end;
    
    %generate split points for x
    newx=x(whichcut)+0.5*len(whichcut);
    
    %relocate the space for new x
    if npoints + length(newx) > length(x)
      xx = zeros(1, out_param.nmax);
      yy = xx;
      xx(1:npoints) = x(1:npoints);
      yy(1:npoints) = y(1:npoints);
      x = xx;
      y = yy;
    end
    
    %update x and y
    tt = cumsum(whichcut);   
    x([1 (2:npoints)+tt]) = x(1:npoints);
    y([1 (2:npoints)+tt]) = y(1:npoints);
    tem = 2 * tt + cumsum(whichcut==0);
    x(tem(whichcut)) = newx;
    y(tem(whichcut)) = f(newx);
    
    %update the set I to consist of the new indices
    newindex = zeros(1,npoints+length(newx));
    newindex([1 (2:npoints)+tt]) = ([indexI(2:end) 0]|[0 indexI(1:end-1)]);
    tempindex = (indexI|[0 indexI(1:end-1)]);
    newindex(tem) = tempindex(2:end);
    indexI = ([0 newindex(2:end-1) 0]>0);
    
    %update # of points and initialize error for all the subintervals
    npoints = npoints + length(newx);
    err = zeros(1,npoints-2);
end;


x = x(1:npoints);
y = y(1:npoints);

% [~, ind] = find(abs(y) > 0);
% if min(abs(y(ind))) < abstol,
%     [~, ind] = find(abs(y(ind)) < abstol);
%     out_param.exitflag(4) = true;
%     warning('GAIL:funappx_g:fSmallerThanAbstol',['Some values of f(x) are smaller than abstol for x in [', num2str(x(min(ind))), ',', num2str(x(max(ind))), ...
%         ']. The interpolant may be inaccurate. You may want to decrease abstol.'])
% end
%% postprocessing
out_param.iter = iter;
out_param.npoints = npoints;
out_param.errest = max_errest;
% control the order of out_param
% out_param = orderfields(out_param, ...
%            {'f', 'a', 'b','abstol','nlo','nhi','ninitp','nmax','maxiter',...
%             'exitflag','iter','npoints','errest'});
if MATLABVERSION >= 8.3
    fappx = griddedInterpolant(x,y,'linear');
else
    fappx = @(t) ppval(interp1(x,y,'linear','pp'), t);     
end;
if (in_param.memorytest)
  w = whos;
  out_param.bytes = sum([w.bytes]);
end
if (in_param.output_x)
  %out_param = rmfield(out_param,'x');
  out_param.x = x;
  out_param.y = y;
end

function [f, out_param] = funappx_g_param(varargin)
% parse the input to the funappx_g function

%% Default parameter values

default.abstol = 1e-6;
default.a = 0;
default.b = 1;
default.ninit = 20;
default.nmax = 1e7;
default.maxiter = 1000;
default.memorytest = false;
default.output_x = false;

MATLABVERSION = gail.matlab_version;
if MATLABVERSION >= 8.3
    f_addParamVal = @addParameter;
else
    f_addParamVal = @addParamValue;
end;

 
if isempty(varargin)
  warning('GAIL:funappx_g:nofunction',['Function f must be a function handle. '...
      'Now GAIL is using f(x)=exp(-100*(x-0.5)^2) and unit interval '...
      '[0,1].'])
  help funappx_g
  f = @(x) exp(-100*(x-0.5).^2);
  out_param.f = f;
else
  if gail.isfcn(varargin{1})
    f = varargin{1};
    out_param.f = f;
  else
    warning('GAIL:funappx_g:notfunction',['Function f must be a '...
        'function handle. Now GAIL is using f(x)=exp(-100*(x-0.5)^2).'])
    f = @(x) exp(-100*(x-0.5).^2);
    out_param.f = f;
  end
end;

validvarargin=numel(varargin)>1;
if validvarargin
    in2=varargin{2};
    validvarargin=(isnumeric(in2) || isstruct(in2) || ischar(in2));
end

if ~validvarargin
    %if only one input f, use all the default parameters
    out_param.a = default.a;
    out_param.b = default.b;
    out_param.abstol = default.abstol;
    out_param.nmax = default.nmax ;
    out_param.ninit = default.ninit ;
    out_param.maxiter = default.maxiter;
    out_param.memorytest = default.memorytest;
    out_param.output_x = default.output_x;
else
    p = inputParser;
    addRequired(p,'f',@gail.isfcn);
    if isnumeric(in2)%if there are multiple inputs with
        %only numeric, they should be put in order.
        addOptional(p,'a',default.a,@isnumeric);
        addOptional(p,'b',default.b,@isnumeric);
        addOptional(p,'abstol',default.abstol,@isnumeric);
        addOptional(p,'ninit',default.ninit,@isnumeric);
        addOptional(p,'nmax',default.nmax,@isnumeric)
        addOptional(p,'maxiter',default.maxiter,@isnumeric)
        addOptional(p,'memorytest',default.memorytest,@logical)
        addOptional(p,'output_x',default.output_x,@logical)
    else
        if isstruct(in2) %parse input structure
            p.StructExpand = true;
            p.KeepUnmatched = true;
        end
        f_addParamVal(p,'a',default.a,@isnumeric);
        f_addParamVal(p,'b',default.b,@isnumeric);
        f_addParamVal(p,'abstol',default.abstol,@isnumeric);
        f_addParamVal(p,'ninit',default.ninit,@isnumeric);
        f_addParamVal(p,'nmax',default.nmax,@isnumeric);
        f_addParamVal(p,'maxiter',default.maxiter,@isnumeric);
        f_addParamVal(p,'memorytest',default.memorytest,@logical);
        f_addParamVal(p,'output_x',default.output_x,@logical);
    end
    parse(p,f,varargin{2:end})
    out_param = p.Results;
end;

% let end point of interval not be infinity
if (out_param.a == inf||out_param.a == -inf)
    warning('GAIL:funappx_g:aisinf',['a cannot be infinity. '...
        'Use default a = ' num2str(default.a)])
    out_param.a = default.a;
end;
if (out_param.b == inf||out_param.b == -inf)
    warning(['GAIL:funappx_g:bisinf','b cannot be infinity. '...
        'Use default b = ' num2str(default.b)])
    out_param.b = default.b;
end;

if (out_param.b < out_param.a)
    warning('GAIL:funappx_g:blea',['b cannot be smaller than a;'...
        ' exchange these two. '])
    tmp = out_param.b;
    out_param.b = out_param.a;
    out_param.a = tmp;
elseif(out_param.b == out_param.a)
    warning('GAIL:funappx_g:beqa',['b cannot equal a. '...
        'Use b = ' num2str(out_param.a+1)])
    out_param.b = out_param.a+1;
end;

% let error tolerance greater than 0
if (out_param.abstol <= 0 )
    warning('GAIL:funappx_g:tolneg', ['Error tolerance should be greater'...
        ' than 0. Using default error tolerance ' num2str(default.abstol)])
    out_param.abstol = default.abstol;
end
% let cost budget be a positive integer
if (~gail.isposint(out_param.nmax))
    if gail.isposintive(out_param.nmax)
        warning('GAIL:funappx_g:budgetnotint',['Cost budget should be '...
            'a positive integer. Using cost budget '...
            , num2str(ceil(out_param.nmax))])
        out_param.nmax = ceil(out_param.nmax);
    else
        warning('GAIL:funappx_g:budgetisneg',['Cost budget should be '...
            'a positive integer. Using default cost budget '...
            int2str(default.nmax)])
        out_param.nmax = default.nmax;
    end;
end

if (~gail.isposint(out_param.ninit))
    if (out_param.ninit >= 5)
        warning('GAIL:funappxgNoPenalty_g:initnotint',['Initial '...
        'number of subintervals should be a positive integer.' ...
            ' Using ', num2str(ceil(out_param.nlo)) ' as ninit '])
        out_param.nlo = ceil(out_param.nlo);
    else
        warning('GAIL:funappxgNoPenalty_g:initlt3',[' Initial '...
        'number of subintervals should be a positive integer greater'...
        ' than or equal to 5. Using 5 as ninit'])
        out_param.nlo = 5;
   end
%         warning('GAIL:funappxgNoPenalty_g:initnotint',['Lower bound of '...
%         'initial nstar should be a positive integer.' ...
%         ' Using ', num2str(ceil(out_param.nlo)) ' as nlo '])
%         out_param.nlo = ceil(out_param.nlo);
end

%  if (~gail.isposint(out_param.nhi))
%     if gail.isposge3(out_param.nhi)
%         warning('GAIL:funappx_g:hiinitnotint',['Upper bound of '...
%         'initial number of points should be a positive integer.' ...
%         ' Using ', num2str(ceil(out_param.nhi)) ' as nhi' ])
%         out_param.nhi = ceil(out_param.nhi);
%     else
%         warning('GAIL:funappx_g:hiinitlt3',[' Upper bound of '...
%         'points should be a positive integer greater than 3. Using '...
%         'default number of points ' int2str(default.nhi) ' as nhi' ])
%         out_param.nhi = default.nhi;
%     end
%          warning('GAIL:funappx_g:hiinitnotint',['Upper bound of '...
%         'initial nstar should be a positive integer.' ...
%         ' Using ', num2str(ceil(out_param.nhi)) ' as nhi' ])
%         out_param.nhi = ceil(out_param.nhi);
% end
% 
% if (out_param.nlo > out_param.nhi)
%     warning('GAIL:funappx_g:logrhi', ['Lower bound of initial number of'...
%         ' points is larger than upper bound of initial number of '...
%         'points; Use nhi as nlo'])
%     out_param.nhi = out_param.nlo;
% end;

if (~gail.isposint(out_param.maxiter))
    if gail.ispositive(out_param.maxiter)
        warning('GAIL:funappx_g:maxiternotint',['Max number of '...
            'iterations should be a positive integer. Using max number '...
            'of iterations as  ', num2str(ceil(out_param.maxiter))])
        out_param.nmax = ceil(out_param.nmax);
    else
        warning('GAIL:funappx_g:budgetisneg',['Max number of iterations'...
            ' should be a positive integer. Using max number of '...
            'iterations as ' int2str(default.maxiter)])
        out_param.nmax = default.nmax;
    end;
end
if (out_param.memorytest~=true&&out_param.memorytest~=false)
    warning('GAIL:funappx_g:memorytest', ['Input of memorytest'...
        ' can only be true or false; use default value false'])
    out_param.memorytest = false;
end;
if (out_param.output_x~=true&&out_param.output_x~=false)
    warning('GAIL:funappx_g:output_x', ['Input of output_x'...
        ' can only be true or false; use default value false'])
    out_param.output_x = false;
end;
