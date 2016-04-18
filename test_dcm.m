clear;
clc;
imu_interval_s=0.02;
%时间间隔为0.02秒
%初始矩阵为地理坐标轴
dcmEst=[1 0 0; 0 1 0; 0 0 1];
wx=1;   %1度/秒的角速度
wy=2;
wz=3;
W=[wx wy wz]*pi/180;    %将角度转换为弧度
Theta=W*imu_interval_s;   %在时间间隔的角度变化向量
imu_sequence = 200;     %累积次数
graf(imu_sequence,4)=zeros;      %绘图数组初始化
for n = 1:imu_sequence          %循环imu_sequence次进行矩阵更新，如100，则进行100*0.02=2s，三轴变化应该为2，4，6
    dR(3)=zeros;
    for k = 1:3
        dR=cross(Theta,dcmEst(k,:));        %向量叉乘
        dcmEst(k,:)=dcmEst(k,:)+dR;     %累加
    end
    %误差计算
    error=-dot(dcmEst(1,:),dcmEst(2,:))*0.5;
    %误差校正
    x_est = dcmEst(2,:) * error;
    y_est = dcmEst(1,:) * error;
    dcmEst(1,:) = dcmEst(1,:) + x_est;
    dcmEst(2,:) = dcmEst(2,:) + y_est;
    %正交化
    dcmEst(3,:) = cross(dcmEst(1,:), dcmEst(2,:));
    if 1
        %泰勒展开归一化处理
        disp('taile');
        dcmEst(1,:)=0.5*(3-dot(dcmEst(1,:),dcmEst(1,:))) * dcmEst(1,:);
        dcmEst(2,:)=0.5*(3-dot(dcmEst(2,:),dcmEst(2,:))) * dcmEst(2,:);
        dcmEst(3,:)=0.5*(3-dot(dcmEst(3,:),dcmEst(3,:))) * dcmEst(3,:);
    else
        %平方和
        disp('norm');
        dcmEst(1,:)=dcmEst(1,:)/norm(dcmEst(1,:));
        dcmEst(2,:)=dcmEst(2,:)/norm(dcmEst(2,:));
        dcmEst(3,:)=dcmEst(3,:)/norm(dcmEst(3,:));
    end

    %转换为欧拉角
    graf(n,1)=n*imu_interval_s;
    %graf(n,2)=atan2(dcmEst(3,2),dcmEst(3,3));      %yaw   
    %graf(n,3)=-asin(dcmEst(3,1));      %pitch               
    %graf(n,4)=atan2(dcmEst(2,1),dcmEst(1,1));      %roll
    %使用matlab方法：[yaw, pitch, roll] = dcm2angle(dcm)
    %[graf(n,2),graf(n,3),graf(n,4)] = dcm2angle(dcmEst);
    %使用四元数进行转换
    q = dcm2quat(dcmEst);
    [graf(n,2),graf(n,3),graf(n,4)] = quat2angle(q);
end
figure
hold on
%转换为角度并绘图
plot(graf(:,1),graf(:,2)*(180/pi),'+b');%yaw
plot(graf(:,1),graf(:,3)*(180/pi),'.r');%pitch
plot(graf(:,1),graf(:,4)*(180/pi),'.g');%roll
grid