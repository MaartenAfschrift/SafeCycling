function Tinv=inversT(T)
% deze functie geeft de inverse van de transformatiematrix

%        |   R   p |                |  R'   -R'* p |
%    T = |         |   ->  inv(T) = |              |
%        | 0 0 0 1 |                | 0 0 0    1   |


Rinv = T(1:3,1:3)';

Tinv = zeros(4,4);
Tinv(1:3,1:3) = Rinv;
Tinv(1:3,4) = -Rinv*T(1:3,4);
Tinv(4,4) = 1;
