% Please run this script in Octave
1;

function v = lerp(v0,v1,t)
    v = (1-t)*v0 + t*v1;
end

v0 = [1;2];
v1 = [1.5;6];
v2 = [5;4];
v3 = [4;1];
% v3 = [4;6];

v=[v0,v1,v2,v3];
vb=v;

dt = 0.01;
i=1;
curve_a=[];
curve_b=[];
for t=0:dt:1
    % calculate the result of squad
    v03=lerp(v0,v3,t);
    v12=lerp(v1,v2,t);
    v0312=lerp(v03,v12,2*t*(1-t));
    curve_a(1:2,i)=v0312;
    v(:,5:7)=[v03,v12,v0312];
    
    % calculate the result of cubic bezier
    v01=lerp(v0,v1,t);
    v23=lerp(v2,v3,t);
    v0112=lerp(v01,v12,t);
    v1223=lerp(v12,v23,t);
    v01121223=lerp(v0112,v1223,t);
    curve_b(1:2,i)=v01121223;
    
    vb(:,5:10)=[v01,v12,v23,v0112,v1223,v01121223];

    % Left: squad for vectors (quad)
    subplot(1,2,1)
    scatter(v(1,1:7), v(2,1:7), 10, 'filled')
    hold(subplot(1,2,1), 'on');
    plot([v(1,1),v(1,4)],[v(2,1),v(2,4)])
    plot([v(1,2),v(1,3)],[v(2,2),v(2,3)])
    plot([v(1,5),v(1,6)],[v(2,5),v(2,6)])
    plot(curve_a(1,:),curve_a(2,:))
    hold(subplot(1,2,1), 'off');
    axis([0 7 0 7], 'square')

    % Right pane: cubic bezier curve
    subplot(1,2,2)
    scatter(vb(1,1:10), vb(2,1:10), 10, 'filled')
    hold(subplot(1,2,2), 'on');
    plot(vb(1,1:4),vb(2,1:4))
    plot([vb(1,5),vb(1,6)],[vb(2,5),vb(2,6)])
    plot([vb(1,6),vb(1,7)],[vb(2,6),vb(2,7)])
    plot([vb(1,8),vb(1,9)],[vb(2,8),vb(2,9)])
    plot(curve_b(1,:),curve_b(2,:))
    hold(subplot(1,2,2), 'off');
    axis([0 7 0 7], 'square')
    
    pause(0.01)
    i=i+1;
end