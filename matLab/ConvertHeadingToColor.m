function [R, G, B] = ConvertHeadingToColor(HeadingAngle)

   RGB = colorspace(['RGB<-HSL'],[HeadingAngle 1 .5]);  % Convert back to sRGB
R = RGB(1);
G = RGB(2);
B = RGB(3);