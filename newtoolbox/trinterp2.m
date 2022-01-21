%TRINTERP2 Interpolate SE(2) homogeneous transformations
%
% TRINTERP2(T0, T1, S) is a homogeneous transform (3x3) interpolated
% between T0 when S=0 and T1 when S=1.  T0 and T1 are both homogeneous
% transforms (4x4).  If S (Nx1) then T (3x3xN) is a sequence of
% homogeneous transforms corresponding to the interpolation values in S.
%
% TRINTERP2(T1, S) as above but interpolated between the identity matrix
% when S=0 to T1 when S=1.
%
% TRINTERP2(T0, T1, M) as above but M is a positive integer and return a
% sequence (4x4xM) of homogeneous transforms linearly interpolating between
% T0 and T1 in M steps.
%
% TRINTERP2(T1, M) as above but return a sequence (4x4xM) of
% homogeneous interpolating between identity matrix and T1 in M steps.
%
% Notes::
% - T0 or T1 can also be an SO(2) rotation matrix (2x2).
% - Rotation angle is linearly interpolated.
% - To obtain smooth continuous motion S should also be smooth and continuous,
%   such as computed by tpoly or lspb.
%
% See also TRINTERP, SE3.interp, UnitQuaternion, TPOLY, LSPB.

%## 2d homogeneous trajectory


% Copyright (C) 1993-2019 Peter I. Corke
%
% This file is part of The Spatial Math Toolbox for MATLAB (SMTB).
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
% of the Software, and to permit persons to whom the Software is furnished to do
% so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
% FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
% COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
% IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
% CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%
% https://github.com/petercorke/spatial-math

function T = trinterp2(A, B, C)

switch nargin
    case 2
        % trinterp(T, s)
        T1 = A; s = B;
        
        th0 = 0;
        th1 = atan2(T1(2,1), T1(1,1));
        if ~isrotm2d(T1)
            p0 = [0 0]';
            p1 = transl2(T1);
        end
    case 3
        % trinterp(T1, T2, s)
        T0 = A; T1 = B; s = C;
        assert(all(size(A) == size(B)), 'SMTB:trinterp2:badarg', '2 matrices must be same size');
        th0 = atan2(T0(2,1), T0(1,1));
        th1 = atan2(T1(2,1), T1(1,1));
        if ~isrotm2d(T0)
            p0 = transl2(T0);
            p1 =transl2(T1);
        end
    otherwise
        error('SMTB:trinterp2:badarg', 'must be 2 or 3 arguments');
end

if length(s) == 1 && s > 1 && (s == floor(s))
    % integer value
    s = 0:(s-1) / (s-1);
elseif any(s<0 | s>1)
    error('SMTB:trinterp2:badarg', 'values of S outside interval [0,1]');
end

if isrotm2d(T1)
    
    % SO(2) case
    for i=1:length(s)
        th = th0*(1-s(i)) + s(i)*th1;
        
        T(:,:,i) = rotm2d(th); %#ok<AGROW>
    end
else
    % SE(2) case
    for i=1:length(s)
        th = th0*(1-s(i)) + s(i)*th1;
        pr = p0*(1-s(i)) + s(i)*p1;
        
        T(:,:,i) = rt2tr(rotm2d(th), pr); %#ok<AGROW>
    end
end

end
