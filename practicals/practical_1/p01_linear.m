% Enrico Bussetti, 210304

% Advanced Catalytic Reactor Design
% Practical 1

% Solution of a dispersion PFR with linear kinetic mechanisms and no 
% change of moles. 
% Finite-Difference scheme (with constant step-size).
% Performance comparison between different linear systems solvers.

close all
clear variables

% -------------------------------------------------------------------------
% Data [SI units]
% -------------------------------------------------------------------------

% =========================================================================
% Geometry and flows

d  = 2.54e-2;           % Diameter [m]
V  = 1.5e-3;            % Volume [m^3]
L  = V*4/pi/d^2;        % Length [m]

Q = 0.01;               % Volumetric flow rate [m^3/s]
v  = 1;                 % Velocity [m/s]

% =========================================================================
% Properties

% Dispersion coefficients [m^2/s]
Di = 1e-5; 
Pe = L*v./Di;              % Peclét material number [-]

% Concentration of the feed (not at the inlet) [mol/m^3]
Cin = 10;          
  
% Kinetic constants  
k  = 20;        

% =========================================================================
% Discretization

dy = 0.01;
y = 0:dy:1;

Np = length(y);

% -------------------------------------------------------------------------
% Solution
% -------------------------------------------------------------------------

% =========================================================================
% Definition of the system

A = zeros(Np);
b = zeros(Np, 1);

A(1, 1) = 1 + 1/Pe/dy;
A(1, 2) =   - 1/Pe/dy;

for i = 2:Np-1
    
    A(i, i-1) =   1/Pe/dy^2;
    A(i, i)   = - L/v*k - 2/Pe/dy^2 - 1/Pe/dy;
    A(i, i+1) =   1/Pe/dy + 1/Pe/dy^2;
    
end

A(Np, Np-1) = -1;
A(Np, Np)   =  1;

b(1) = Cin;

% =========================================================================
% Backslash

t_in = cputime;
C = A\b;
t_out = cputime;

fprintf('Method: Backslash, time = %f\n', t_out-t_in);

% =========================================================================
% Gauss-Seidler (vector algebra)

% First-Guess-Solution
FGS = linspace(Cin, 1, Np)';

t_in = cputime;
C = gauss_seidler(A, b, FGS, 1e-5, 250e3, 1.8, 0, 1);
t_out = cputime;

fprintf('Method: Gauss-Seidler (vectors), time = %f\n', t_out-t_in);

% =========================================================================
% Gauss-Seidler (for loops)

t_in = cputime;
C = gauss_seidler(A, b, FGS, 1e-5, 250e3, 1.8, 0, 1);
t_out = cputime;

fprintf('Method: Gauss-Seidler (for loops), time = %f\n', t_out-t_in);

% =========================================================================
% Biconjugate-Gradient-Stabilized

t_in = cputime;
C = bicgstabl(A, b);
t_out = cputime;

fprintf('Method: Bicgstabl, time = %f\n', t_out-t_in);

% -------------------------------------------------------------------------
% Graphical-Post-Processing
% -------------------------------------------------------------------------

figure
plot(y, C, '-o')
title('C vs y')
xlabel('y [-]')
ylabel('C [mol/m^3]')
