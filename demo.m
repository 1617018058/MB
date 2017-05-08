clear,clc,close all;
I=imread('C:\Users\Administrator\Desktop\1\5.tiff');
bw=rgb2gray(I);
bw=im2bw(I,graythresh(bw));%采用Otsu方法计算最优阈值对图像二值化
%将药板从黑色背景中分离
BW1 = imfill(bw, 'holes');
figure;imshow(BW1);title('分离出的药板')

bw=double(bw);
BW=edge(bw,'canny');
%哈佛变换
[H,T,R]=hough(BW);%H是霍夫变换矩阵，T、R是p和θ值向量，在这些值上产生霍夫变换BW是二值图像
P=houghpeaks(H,4,'threshold',ceil(0.3*max(H(:))));%%寻找指定峰值数这里为4
lines=houghlines(BW,T,R,P,'FillGap',50,'MinLength',7);%%lines为结构数组，长度等于找到的线段数
max_len = 0;

figure,imshow(BW),title('直线标识产物5');
hold on;
for k=1:length(lines)
    xy=[lines(k).point1;lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    % 标出线段的起始和终端点
    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    len=norm(lines(k).point1-lines(k).point2);
    Len(k)=len;
    if (len>max_len)
        max_len=len;
        xy_long=xy;
    end
end
[L1 Index1]=max(Len(:));
% 求得线段的斜率
K1=-(lines(Index1).point1(2)-lines(Index1).point2(2))/...
    (lines(Index1).point1(1)-lines(Index1).point2(1))
angle=atan(K1)*180/pi
A = imrotate(I,-angle,'bilinear','crop');% imrate 是逆时针的所以取一个负号

%颜色特征的区域 分割
ycbcr=rgb2ycbcr(A);
y=ycbcr(:,:,1);
cb=ycbcr(:,:,2);
cr=ycbcr(:,:,3);

thr_y=graythresh(y);
bw_y=im2bw(y,thr_y);

thr_cb=graythresh(cb);
bw_cb=im2bw(cb, thr_cb);

B=~(~bw_y+~bw_cb);

se=strel('disk',5);
B=imclose(B,se);%闭运算，先膨胀再腐蚀
B=imopen(B,se);%先腐蚀在膨胀

%确定出标记位置
L = bwlabel(~B);
stats = regionprops(L, 'BoundingBox');
%在旋转后的图像中标记

figure; imshow(A);title('旋转后的药板5（标记药丸位置）')%旋转后的标记图
hold on;
for i = 1 : length(stats)
    if stats(i).BoundingBox(1)>10
    rectangle('Position', stats(i).BoundingBox, 'edgecolor', 'r','LineWidth',3);
    end
end