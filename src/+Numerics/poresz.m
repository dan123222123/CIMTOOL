function [G,res] = poresz(z,ew,B,C,deriv)
% PORESZ Evaluate transfer function and derivatives in pole-residue form
%
% G = poresz(z, ew, B, C) evaluates the transfer function
%   H(z) = sum_{i=1}^n C(:,i)*B(i,:) / (z - ew(i))
% at the point z.
%
% G = poresz(z, ew, B, C, deriv) evaluates the deriv-th derivative
%   H^(k)(z) = (-1)^k * k! * sum_{i=1}^n C(:,i)*B(i,:) / (z - ew(i))^(k+1)
%
% Inputs:
%   z     - Evaluation point (scalar complex)
%   ew    - Eigenvalues/poles (column vector, n×1)
%   B     - Input residue directions (n×m matrix)
%   C     - Output residue directions (p×n matrix)
%   deriv - Derivative order (default: 0)
%           0 = function value
%           1 = first derivative
%           2 = second derivative, etc.
%
% Outputs:
%   G   - Transfer function or derivative value at z (p×m matrix)
%   res - Residue matrices (p×m×n array)
%
% The transfer function represents a system with p outputs, m inputs,
% and n poles, evaluated in pole-residue form for efficiency.

    arguments
        z
        ew
        B
        C
        deriv = 0
    end

    m = size(B,2); p = size(C,1);
    G = zeros(p,m); res = zeros(p,m,length(ew));

    % Compute sign and factorial for derivative
    sign_factor = (-1)^deriv;
    factorial_factor = factorial(deriv);
    exponent = deriv + 1;

    for i = 1:length(ew)
        res(:,:,i) = sign_factor * factorial_factor * (C(:,i)*B(i,:));
        G = G + res(:,:,i)/((z - ew(i))^exponent);
    end
end
