# 四元数与三维旋转

简单地讲了一下四元数在计算机图形学中的应用，除此之外在Bonus章节中也讨论了一下Gimbal Lock的产生。

文档本身可以在这里找到：[https://krasjet.github.io/quaternion/](https://krasjet.github.io/quaternion/)  
Bonus章节——Gimbal Lock：[https://krasjet.github.io/quaternion/bonus_gimbal_lock.pdf](https://krasjet.github.io/quaternion/bonus_gimbal_lock.pdf)

仅仅只校对过一遍，所以错误可能会有很多。如果你发现有任何的错误或者对内容有建议，请到Issues中报告。

## Demo

在`demo`目录下你可以找到一些演示用的MATLAB代码。因为MATLAB不是免费的软件，所以我将每个动画都输出成了GIF，你可以进入各个Demo的目录中观看（流量预警）。你也可以使用免费的Octave运行代码，但是性能可能不是很好。

## 更新

 - 2/18/2019：添加了第九章「附录 2：左手坐标系统下的旋转」
 - 2/25/2019：重写了第二章的开头