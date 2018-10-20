% Please run this script in Octave
1;

% create a rotation quaternion using xyz coordinates(axis) and an angle
function q = createRotQuatxyz(x,y,z,angle)
    axis = [x;y;z];
    q = createRotQuatv(axis,angle);
end

% create a rotation quaternion using a column vector(axis) and an angle
function q = createRotQuatv(axis,angle)
    axis = axis/norm(axis);
    q = [cos(angle/2); sin(angle/2)*axis(1,1); sin(angle/2)*axis(2,1); sin(angle/2)*axis(3,1)];
end

function [axis,angle] = extractAxisAngleFromQuat(q)
    angle = acos(q(1,1))*2;
    axis  = q(2:4,1)/sin(angle/2);
end

% in theory this should never be used. the interpolated quaternion is not
% unit, so it's not a pure rotation.
function q = lerp(q0,q1,t)
    q = (1-t)*q0 + t*q1;
end

% normalized lerp, angular velocity is not constant
function q = nlerp(q0,q1,t)
    q = lerp(q0,q1,t);
    q = q/norm(q);
end

% robust nlerp, check the angle before lerping
function q = robust_nlerp(q0,q1,t)
    dp = dot(q0,q1);
    if (dp < 0.0) % not the shortest path
        q0 = -q0; % q and -q represent the same rotation
    end
    q = lerp(q0,q1,t);
    q = q/norm(q);
end

% this version won't check angle between q0 and q1, 
% so it may not interpolate along the shortest path.
function q = slerp(q0,q1,t)
    dp = dot(q0,q1);
    theta = acos(dp);
    sin_theta = sin(theta);
    
    q = (sin((1-t)*theta)/sin_theta)*q0 + (sin(t*theta)/sin_theta)*q1;
end

% a more robust version of slerp.
function q = robust_slerp(q0,q1,t)
    dp = dot(q0,q1);
    
    if (dp > 0.9995) % divide by sin(theta) is dangerous
        q = nlerp(q0,q1,t); % so use nlerp instead
        return
    end
    if (dp < 0.0) % not the shortest path
        q0 = -q0; % q and -q represent the same rotation
        dp = -dp; % now dot product is positive
    end

    theta = acos(dp);
    sin_theta = sin(theta);
    
    q = (sin((1-t)*theta)/sin_theta)*q0 + (sin(t*theta)/sin_theta)*q1;
end

% convert rotation quaternion to rotation matrix
function R = quatToMat(quat)
    a = quat(1,1);
    b = quat(2,1);
    c = quat(3,1);
    d = quat(4,1);
    R = [1-2*c^2-2*d^2, 2*b*c-2*a*d, 2*a*c+2*b*d
        2*b*c+2*a*d, 1-2*b^2-2*d^2, 2*c*d-2*a*b
        2*b*d-2*a*c, 2*a*b+2*c*d, 1-2*b^2-2*c^2];
end

% convert quaternion to matrix form used for multiplication
function Q = quatToLeftMat(quat)
    a = quat(1,1);
    b = quat(2,1);
    c = quat(3,1);
    d = quat(4,1);
    Q = [a -b -c -d
         b  a -d  c
         c  d  a -b
         d -c  b  a];
end

% right mutiply q1 by q2
function q = quatMult(q1,q2)
    q = quatToLeftMat(q1)*q2;
end

% conjugate
function q = quatConj(q1)
    q = [q1(1,1);-q1(2,1);-q1(3,1);-q1(4,1)];
end

% vertices for the cube
C = transpose([
    3   3   3   1
    3  -3   3   1
   -3  -3   3   1
   -3   3   3   1
    3   3  -3   1
    3  -3  -3   1
   -3  -3  -3   1
   -3   3  -3   1   
]);

q0 = createRotQuatxyz(6, 6, 6, pi/3);
q1 = createRotQuatxyz(0, 1, 1, pi);

% a wider angle, try nlerp, robust_nlerp, slerp, and robust_slerp
% q1 = createRotQuatxyz(0, 1, 1, 2*pi);

% delta q
q_delta = quatMult(q1,quatConj(q0));
% axis of delta q
axis_d = extractAxisAngleFromQuat(q_delta);


% create an orthonormal basis for q
q_perp = q1 - dot(q0,q1)*q0;
q_perp = q_perp/norm(q_perp);
% change of basis to R2
p1 = [q0, q_perp]\q1;

E=zeros(2, size(C,2)+1);

dt = 0.01;
for t=0:dt:1
    % create an interpolation using t
    qt = slerp(q0,q1,t);
    % qt = robust_slerp(q0,q1,t);
    % qt = robust_nlerp(q0,q1,t);
    % qt = nlerp(q0,q1,t);
    % qt = lerp(q0,q1,t);

    % change of basis to R2
    pt = [q0, q_perp]\qt;

    % apply rotation
    Q = quatToMat(qt);
    Q(4,4) = 1;
    C1 = Q*C;
    % delta rotation axis
    C1(1:3,9)=axis_d*7;C1(4,9)=1;
    
    % an extremely crude camera
    C1 = [1 0 0 0 ; 0 cos(-pi/3) -sin(-pi/3) 0;0 sin(-pi/3) cos(-pi/3) 0 ; 0 0 0 1]*[cos(pi/6) -sin(pi/6) 0 0;sin(pi/6) cos(pi/6) 0 0 ; 0 0 1 0; 0 0 0 1]*C1;
    Proj = [1 0 0 0;0 1 0 0;0 0 0 0;0 0 -1/15 1]*C1;
    % perspective division
    for i=1:size(Proj,2)
        E(1:2,i) = Proj(1:2,i)/Proj(4,i);
    end


    % Left pane: 3D euclidean space
    subplot(1,2,1)
    scatter(E(1,1:8), E(2,1:8),10,'filled')
    hold (subplot(1,2,1), 'on');
    plot([-E(1,9),E(1,9)],[-E(2,9),E(2,9)],'b')
    plot(E(1,1:4), E(2,1:4),'r')
    plot([E(1,4), E(1,1)], [E(2,4), E(2,1)],'r')
    plot(E(1,5:8), E(2,5:8),'r')
    plot([E(1,8), E(1,5)], [E(2,8), E(2,5)],'r')
    plot([E(1,1), E(1,5)], [E(2,1), E(2,5)],'r')
    plot([E(1,2), E(1,6)], [E(2,2), E(2,6)],'r')
    plot([E(1,3), E(1,7)], [E(2,3), E(2,7)],'r')
    plot([E(1,4), E(1,8)], [E(2,4), E(2,8)],'r')
    hold (subplot(1,2,1), 'off');
    axis([-8 8 -8 8], 'square')

    % Right pane:
    % The 2D plane formed by q0 and q1 in 4D quaternion space
    % q0 is fixed at (1,0)
    subplot(1,2,2)
    plot([0,1],[0,0], 'r')
    hold(subplot(1,2,2), 'on');
    plot([0,p1(1,1)], [0, p1(2,1)], 'r')
    plot([0,pt(1,1)], [0, pt(2,1)], 'b')
    hold(subplot(1,2,2), 'off');
    axis([-1.2 1.2 -1.2 1.2], 'square')

    pause(0.01)
end

