x = [16 -21 25 10];
y = [ 5 -38 16 10];

c=imread('road.bmp');
figure;
image(c);
hold on
plot(x,y,'go',...
 'MarkerFaceColor','g')
% set(gca,...
%  'XLim',[-68 68],...
%  'YLim',[-102 70])
