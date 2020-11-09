%% Implementation based on SARA method

% data with example of one callibration 
load('ExampleData.mat','t','R_fr','R_st');

% t is time vector
% R_fr = is rotation matrix of frame expressed in world
% R_st = is rotation matrix of steer expressed in world

% get rotation matrix with "the steer" expressed in "bike frame" coordinate
% system
Rst_fr = nan(3,3,nfr);
for i =1:nfr
    Rst_fr(:,:,i) = R_fr(:,:,i)'*R_st(:,:,i); %
end

% Create matrix A as in Zehr2007 (equation 2) with both the steer and the
% bike frame expressed in the world coordinate system
nfr = length(t);
A = zeros(nfr*3,6);
for i = 1:nfr   
    A((i-1)*3+1 : i*3 , 1:3) = R_st(1:3,1:3); % rotation matrix steer
    A((i-1)*3+1 : i*3 , 4:6) = -R_fr(1:3,1:3); % rotation matrix  frame   
end

% singular value decomposition on matrix A (I don't fully understand this
% step)
[U, S, V]=svd(A,0); % singular value decomposition (A = U*S*V')

% get the orientation in steer and frame (I not following here as well)
n_steer = V(1:3,6)/norm(V(1:3,6)); %orientation in steer
n_frame = V(4:6,6)/norm(V(4:6,6)); %orientation in frame

% I don't know how to compute the steer angle now. Should I compute the
% rotation of the steer w.r.t. to the frame along the axis of n_frame ?
