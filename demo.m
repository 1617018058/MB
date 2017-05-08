clear,clc,close all;
I=imread('C:\Users\Administrator\Desktop\1\5.tiff');
bw=rgb2gray(I);
bw=im2bw(I,graythresh(bw));%����Otsu��������������ֵ��ͼ���ֵ��
%��ҩ��Ӻ�ɫ�����з���
BW1 = imfill(bw, 'holes');
figure;imshow(BW1);title('�������ҩ��')

bw=double(bw);
BW=edge(bw,'canny');
%����任
[H,T,R]=hough(BW);%H�ǻ���任����T��R��p�ͦ�ֵ����������Щֵ�ϲ�������任BW�Ƕ�ֵͼ��
P=houghpeaks(H,4,'threshold',ceil(0.3*max(H(:))));%%Ѱ��ָ����ֵ������Ϊ4
lines=houghlines(BW,T,R,P,'FillGap',50,'MinLength',7);%%linesΪ�ṹ���飬���ȵ����ҵ����߶���
max_len = 0;

figure,imshow(BW),title('ֱ�߱�ʶ����5');
hold on;
for k=1:length(lines)
    xy=[lines(k).point1;lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    % ����߶ε���ʼ���ն˵�
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
% ����߶ε�б��
K1=-(lines(Index1).point1(2)-lines(Index1).point2(2))/...
    (lines(Index1).point1(1)-lines(Index1).point2(1))
angle=atan(K1)*180/pi
A = imrotate(I,-angle,'bilinear','crop');% imrate ����ʱ�������ȡһ������

%��ɫ���������� �ָ�
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
B=imclose(B,se);%�����㣬�������ٸ�ʴ
B=imopen(B,se);%�ȸ�ʴ������

%ȷ�������λ��
L = bwlabel(~B);
stats = regionprops(L, 'BoundingBox');
%����ת���ͼ���б��

figure; imshow(A);title('��ת���ҩ��5�����ҩ��λ�ã�')%��ת��ı��ͼ
hold on;
for i = 1 : length(stats)
    if stats(i).BoundingBox(1)>10
    rectangle('Position', stats(i).BoundingBox, 'edgecolor', 'r','LineWidth',3);
    end
end