clc; clear all; close all;
%------------------------------------------
% pre-processing
im=imread('Im196_0.tif');
figure;
imshow(im); title('Original Image');
red_hist=imhist(im(:,:,1));
green_hist=imhist(im(:,:,2),256); 
figure; imshow(im(:,:,2)); title('Green Channel Image');
blue_hist=imhist(im(:,:,3));
% figure; imhist(im(:,:,2),256); title('Histogram of green image')
%figure; plot(green_hist); title('Histogram curve of green image')
%figure; h = stem(1:256, green_hist);title('Stem Histogram of Green Image')
 

g = im(:,:,2);
[r2 c2] = size(g);
% figure;
% subplot(3,1,1); plot(red_hist,'red'); axis([0 256 0 10000]); title('Histogram Red Channel');
% subplot(3,1,2);plot(green_hist,'green'); axis([0 256 0 10000]); title('Histogram Green Channel'); 
% subplot(3,1,3); plot(blue_hist,'blue'); axis([0 256 0 10000]); title('Histogram Blue Channel');

% find three peak point of green channel histogram
x=green_hist'; size(x); % 1x256

% for foraward calculation

y=zeros(1,256);

for i=2:256
    if x(i)>=x(i-1)&& x(i)>=y(i-1)
        y(i)=x(i);
    elseif x(i)>=x(i-1)&& x(i)<y(i-1)
        y(i)=y(i-1);
    elseif x(i)<x(i-1)
        %y(i)=max(x(2):x(i-1));
        y(i)=y(i-1);
    end
end
y;
plot(y);

 for j=2:256
%      Logic: Consider from point x to next 10 data same. So x is a valley
%      point. For this sum and repmat are used. If data are same, then
%      there summation will also be same.
     if y(j)~=y(j-1) &&  sum(repmat(y(j),1,11)) == sum(y(j:j+10))       
         w(j)=y(j);
     else
         w(j)=0;
     end
 end
 w;
 w1=sort(w,'descend');
 
 [B I]=find(w);
 w2=y(I);                   % Valley point
    
 %% if there is four peak point,then .....
 
 
 if numel(w2)==4
    
     I(1)=I(2);    
     I(2)=I(3);    
     I(3)=I(4);
    
     I=unique(I);
     w3=y(I);
figure; hold on; plot(green_hist); zoom xon;
plot(I,w3,'k*'); hold off; zoom xon; title('dark, medium, light point');


 else    
%% for normal condition
     
figure; hold on; plot(green_hist); zoom xon;
plot(I,w2,'k*'); hold off; zoom xon; title('dark, medium, light point');
 end

%% if the third peak is smaller than the Second....
 % then this potion will be excuted
  
if numel(w2)<3
    
% for backward calculation
yB=zeros(1,256);

for i=255:-1:2
    if x(i)>=x(i+1)&& x(i)>=yB(i+1)
        yB(i)=x(i);   
    elseif x(i)>= x(i-1)&& x(i)<yB(i+1)
        yB(i)=yB(i+1);   
    elseif x(i)<= yB(i+1) && x(i)>x(i-1)
        yB(i)=yB(i+1);   
    elseif x(i)<x(i-1)
        yB(i)=yB(i+1);
  
    end
end
yB;
% plot(y);

 for j=255:-1:2
     % Logic: Consider from point x to next 10 data same. So x is a valley
     % point. For this sum and repmat are used. If data are same, then
     % there summation will also be same.
     if yB(j)~=yB(j+1) &&  sum(repmat(yB(j),1,11)) == sum(yB(j:-1:j-10))       
         wB(j)=yB(j);
     else
         wB(j)=0;
     end
 end
 wB;
 wB1=sort(wB,'descend');
 
 [B IB]=find(wB);
 w2B=yB(IB);                   % Valley point
    
% xx=1:256;
figure; hold on; plot(green_hist); zoom xon;
plot(IB,w2B,'k*'); hold on; zoom xon; title('dark, medium, light point');


 
 % combining forward and backward position vector
 
 yFB=[I IB];
 yfinal=  unique(yFB(:));
  
 wFinal1= sort(yfinal,'ascend');
 I=wFinal1;

end




% Pre-classified area --> Leukocyte nucleus, foreground & blood plasma
for i = 1:r2
    for j = 1:c2
        if g(i,j) <= I(1)
            g1(i,j) = 0;    % g1 --> preclassification: L. Nucleus
            g2(i,j) = 255;
            g3(i,j) = 0;    % g3 --> only nucleus            
        elseif g(i,j) > I(1) && g(i,j) <= I(2)
            g1(i,j) = 126;  % g1 --> preclassification: foreground
            g2(i,j) = 255;
            g3(i,j) = 255;            
        elseif g(i,j) > I(2)
            g1(i,j) = 255;  % g1 --> preclassification: plasma
            g2(i,j) = 0;
            g3(i,j) = 255;            
        end
    end
  
end
% g2 = reshape(g1, [r2 c2]);
% figure; imshow(g1);  colormap gray; title('Pre-classified areas')
figure; imagesc(g1); colormap gray;  title('Pre-classified areas'); 
figure; imagesc(g2); colormap gray;  title('Leukocyte Nucleus+cytoplasm'); 
figure; imagesc(g3); colormap gray;  title('Leukocyte Nucleus'); 

% Find the third range value of medium peak 
% I(6)=((I(3)+I(4))/2)+I(4);

%% Find centroids of full-leukocyte and leukoctye-nucleus

se = strel('disk',1);                   % erode image
g4 = imerode(g3,se);
g5 = imerode(g4,se);
% g6 = imerode(g5,se);
% g7 = imerode(g6,se);
g8 = imopen(g5,se);

g8 = imfill(~g8,'holes');               % Special condition: when nucleus is splitted
figure; imshow(g5); title('Image after eroding')
figure; imshow(g8); title('Image after open of g3')

se2 = strel('disk',1);
g9 = bwlabel(g2,4);
% g10 = imopen(g9,se2);
 g10 = imfill(g9);



figure; imshow(g9); title('Image after bw g2')
figure; imshow(g10); title('Image after imfill g2')

% Centroid of Leukocyte nucleus
Ibw = ~im2bw(g8);
Ilabel = bwlabel(Ibw);
stat = regionprops(Ilabel,'centroid');
 
figure; imshow(Ibw); hold on;
for x = 1: numel(stat)
    CentroidsLeukoNucleus(x,:) = stat(x).Centroid; 
    plot(stat(x).Centroid(1),stat(x).Centroid(2),'r+');
end

% Centroid of Leukocyte (Nucleus+Cytoplasm)
Ibw2 = g10;
Ilabel2 = bwlabel(Ibw2);
stat2 = regionprops(Ilabel2,'centroid','MajorAxisLength','MinorAxisLength');
 
figure; imshow(Ibw2); hold on;
for x = 1: numel(stat2)
    CentroidsLeukoNucleusCytoplasm(x,:) = stat2(x).Centroid; 
    plot(stat2(x).Centroid(1),stat2(x).Centroid(2),'r+');
end

%% Find centroids of Leukocyte nearest to Leukocyte Nucleus centroids

% First, calculate distance among L. Centroids & L. N. Centroids
for i = 1:numel(stat)
    for j = 1:numel(stat2)
        D1(j,i) = dist(CentroidsLeukoNucleus(i,:),CentroidsLeukoNucleusCytoplasm(j,:)');
    end
end

% Second, store L. Centroids having min distance 
for i = 1:numel(stat)
    miL(i) = find(D1(:,i) == min(D1(:,i)));
    plot(stat2(miL(i)).Centroid(1),stat2(miL(i)).Centroid(2),'b+');
    centerStore(i,:) = stat2(miL(i)).Centroid;
end

% Third, Draw cicles of correspodning L. Centroids [end]
for i = 1:numel(stat)
    diameter =  mean([stat2(miL(i)).MajorAxisLength stat2(miL(i)).MinorAxisLength],2);
    radii(i) = diameter/2;              % radii --> Highprox
    HighProx(i) = radii(i);
end
viscircles(centerStore,radii,'EdgeColor','b');

%% Highprox Drawing

for i = 1:numel(stat)
    for j = 1:r2
        for k = 1:c2
            L = [j,k];
            D2 = dist(L,fliplr(centerStore(i,:))');     % fliplr used to ...
                            % interchange x & y cooridnates of centroids
            if D2 <= HighProx(i)
                g11(j,k) = 255;        
            else
                g11(j,k) = 0;
            end
            D3(j,k,i) = D2; 
            % Storing distance betn each pixel & each centroid;
            % j -- > row, k --> colm, i --> centroid
        end
    end
    HT = sprintf('Highprox: 0%d',i);
    figure; imshow(g11); title(HT)
    g12{i} = g11;
end

%% Find Lowprox
% To do so, find 
for i = 1:numel(stat)
    D4 = D3(:,:,i);    
    % D4 --> Dist betn each pixel and each centroid
    D4max(i) = max(max(D4));
end
LowProx = HighProx + abs(D4max-HighProx)./3;
%LowProx = HighProx+5;
%% Set range for tonality and proximity
MP2ndPoint = ((I(3)-I(2))/2) + I(2);            % MP2ndPoint --> Medium peak 2nd point
% MP2ndPoint = (LightPeak-MediumPeak)/2 + MediumPeak;
DPR = [0 0 I(1) I(2)];                          % Dark Peak Range
MPR = [I(1) I(2) MP2ndPoint I(3)];              % Medium Peak Range
LPR = [I(2) I(3) 255 255];                      % Light Peak Range

HiPR = [0 0 HighProx(1) LowProx(1)];            % HighProx Range
LwPR = [HighProx(1) LowProx(1) D4max(1) D4max(1)];    % LowProx Range

%% Fuzzy Set
% Creating a fuzzy interface system (FIS)
a=newfis('BCD');

% Define input: Tonality
a=addvar(a,'input','tonality',[0 255]);
%defining first input's membership functions
a=addmf(a,'input',1,'Dark','trapmf',DPR);
a=addmf(a,'input',1,'Medium','trapmf',MPR);
a=addmf(a,'input',1,'Light','trapmf',LPR);
% Plot this input
%%figure; subplot(3,1,1); plotmf(a,'input',1);

% Define input: Proximity
a=addvar(a,'input','proximity',[0 D4max(1)]);
%defining second input's membership functions
a=addmf(a,'input',2,'HighProx','trapmf',HiPR);
a=addmf(a,'input',2,'LowProx','trapmf',LwPR);
% Plot this input
%%subplot(3,1,2); plotmf(a,'input',2);

% Define Output: Nucleus, Plasma, Erythrocyte and Cytoplasm
a=addvar(a,'output','class',[0 40]);
% defining first output's membership functions
a=addmf(a,'output',1,'Nucleus','trimf',[0 5 10]);
a=addmf(a,'output',1,'Plasma','trimf',[10 15 20]);
a=addmf(a,'output',1,'Erythrocyte','trimf',[20 25 30]);
a=addmf(a,'output',1,'Cytoplasm','trimf',[30 35 40]);

% Plot this output
%%subplot(3,1,3);
%%plotmf(a,'output',1);

% RuleList=[i/p1 i/p2 o/p w(1) and(1)/or(2)]
ruleList=[1 0 1 1 1
          3 0 2 1 1
          2 2 3 1 1
          2 1 4 1 1];

a=addrule(a,ruleList);
showrule(a);                            % Show rules
writefis(a,'BCD');
q=readfis('BCD');
q2 = setfis(q,'defuzzmethod', 'mom');   % Set defuzz method
getfis(q2,'defuzzmethod');
%ruleview('BCD');

for i = 1:r2
    for j = 1:c2
        out1=evalfis([double(g(i,j));double(D3(i,j,1))],q2);
        out2(i,j) = out1;
    end
end

for i = 1:r2
    for j = 1:c2
        if out2(i,j) <= 10
            out3(i,j) = 255;        
        elseif out2(i,j)>10 && out2(i,j)<=20
            out3(i,j) = 73;
        elseif out2(i,j)>20 && out2(i,j)<=30
            out3(i,j) = 123;
        elseif out2(i,j)>30 && out2(i,j)<=40
            out3(i,j) = 3;        
        end
    end
end

figure;  imagesc(out3); colormap gray;  title('resultant image');

%% for erythrocyte
for i=1:r2
    for j=1:c2
        if out2(i,j)>20 && out2(i,j)<=30
            outErythocyte(i,j)=255;        
        else
            outErythocyte(i,j)=0;
        end
    end
end
class3 = outErythocyte;

figure;  imshow(class3); title('outErythrocyte image');

%% for cytoplasm
for i=1:r2
    for j=1:c2
        if out2(i,j)>30 && out2(i,j)<=40
            outCytoplasm(i,j)=255;        
        else
            outCytoplasm(i,j)=0;
        end
    end
end
class4 = outCytoplasm;

figure;  imshow(class4); title('outCytoplasm image');

% Start post processing. Remove false areas
RGB = class4;

[Totalpcs Location max_storeColorValue max_label_index] = colormarking(RGB);

for i = 1:Totalpcs
    if i~=max_label_index
        LL = Location{i};
        LLsize = size(LL,1);
        for j = 1:LLsize
            LK = LL(j,:);
            out3(LK(1),LK(2)) = 123;
        end
    end
end

figure; imagesc(out3); colormap gray; title('After post processing')
%% Further post-processing

% Make white all region except erythrocyte
for i = 1:r2
    for j = 1:c2
        if out3(i,j) == 123
            out4(i,j) = 0;
        else
            out4(i,j) = 255;
        end
    end
end
figure; imagesc(out4); colormap gray; title('Mark only Erythrocyte')

% Make black all areas except false plasma
out5 = out4;
[Lout4 Nout4] = bwlabel(out4);          % find all areas

[rL cL] = find(Lout4 == 1);             % find large area, max command can also be used. But 1 still working
for i = 1:length(rL)
    out5(rL(i),cL(i)) = 0;              % Make it black
end
figure; imagesc(out5); colormap gray; title('only false plasma')

% Replace false plasma by erythrocyte color
% NOTE: in future, if problem arises, replace false plasma within Highprox
% by L. cytoplasm, and outer HighProx by erythrocyte. 
[rFalsePlasma cFalsePlasma] = find(out5 == 255);
out6 = out3;
for i = 1:length(rFalsePlasma)
    out6(rFalsePlasma(i),cFalsePlasma(i)) = 123;
end
figure; imagesc(out6); colormap gray; title('False plasma removed')
%% Percentage of four components detection
totalPixel = r2*c2;

[rN cN] = find(out6 == 255);
nucleusPixel = length(rN);

[rC cC] = find(out6 == 3);
cytoplasmPixel = length(rC);

[rE cE] = find(out6 == 123);
erythrocytePixel = length(rE);

[rP cP] = find(out6 == 73);
plasmaPixel = length(rP);

percentageNucleus = (nucleusPixel/totalPixel)*100; 
percentageCytoplasm = (cytoplasmPixel/totalPixel)*100;
percentageErythrocyte = (erythrocytePixel/totalPixel)*100;
percentagePlasma = (plasmaPixel/totalPixel)*100;


h=msgbox({['    L. Nucleus: ',num2str(percentageNucleus),'%'];
    ['L. Cytoplasm: ',num2str(percentageCytoplasm),'%'];
    ['   Erythrocyte: ',num2str(percentageErythrocyte),'%'];
    ['         Plasma: ',num2str(percentagePlasma),'%']; },'% Components');
set(h, 'position', [400 250 250 150]);
ah = get( h, 'CurrentAxes' );
ch = get( ah, 'Children' );
set( ch, 'FontSize', 20 );
