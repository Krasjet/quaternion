% Please run this script in Octave
1;

% find the angle between v0 and v1
function t = anglev(v0,v1)
    t = acos(dot(v0,v1)/(norm(v0)*norm(v1)));
end

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

% normalized lerp, angular speed is not constant
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

q0 = createRotQuatxyz(6, 6, 6, pi/3);
q1 = createRotQuatxyz(0, 1, 1, pi);

% a wider angle, try nlerp, robust_nlerp, slerp, and robust_slerp
% q1 = createRotQuatxyz(0, 1, 1, 2*pi);

q0q1 = anglev(q0,q1);

% find delta_q
q_delta = quatMult(q1,quatConj(q0));

axis_d = extractAxisAngleFromQuat(q_delta);

% find a vector v such that Q0*v is orthogonal to axis_d
% or you can use any vector and project it onto the plane orthogonal to
% axis_d
v=[0, -axis_d(3,1), axis_d(2,1)].';
v= quatToMat(quatConj(q0))*v;

% matrix for q0 and q1
Q0 = quatToMat(q0);
Q1 = quatToMat(q1);

v0 = Q0*v;
v1 = Q1*v;

v0v1 = anglev(v0,v1);

% create an orthonormal basis for q
q_perp = q1 - dot(q0,q1)*q0;
q_perp = q_perp/norm(q_perp);

% create an orthonormal basis for v
v_perp = v1 - (dot(v0,v1)/dot(v1,v1))*v0;
v_perp = (v_perp / norm(v_perp))*norm(v1);

% change of basis to R2
p1 = [q0, q_perp]\q1;
u1 = [v0, v_perp]\v1;

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

    % apply transformation
    Q = quatToMat(qt);
    vt = Q*v;
    ut = [v0, v_perp]\vt;

    v0vt = anglev(v0,vt);
    q0qt = anglev(q0,qt);
    
    % ratio of the angle between
    % v0vt and v0v1 vs. angle q0vt and q0v1
    qr=q0qt/q0q1
    vr=v0vt/v0v1

    % Left pane:
    % a 2D plane formed by v0,v1 in the 3D euclidean space
    % also the plane orthogonal to axis_d
    % v0 is fixed at (1,0)
    subplot(1,2,1)
    plot([0,1],[0,0], 'r')
    hold(subplot(1,2,1), 'on');
    plot([0,u1(1,1)], [0, u1(2,1)], 'r')
    plot([0,ut(1,1)], [0, ut(2,1)], 'b')
    hold(subplot(1,2,1), 'off');
    axis([-1.2 1.2 -1.2 1.2], 'square')

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