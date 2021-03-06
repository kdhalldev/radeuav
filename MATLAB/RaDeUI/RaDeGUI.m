
%% RaDe Graphical User Interface


% Senior Design 2012-2013

% ECE-14

% Marko Jacovic
% Thomas Boyd
% Arturs Bergs
% Kevin Hall



%% Prepare Workspace
clear; 
clc;
close all;


%% Add Required Files To Java Path
javaaddpath ScreenCapture;
javaaddpath ZXing-2.1;
javaaddpath ZXing-2.1/core/core.jar;
javaaddpath ZXing-2.1/javase/javase.jar;
javaaddpath jfreechart-1.0.14/lib/jfreechart-1.0.14.jar;
javaaddpath jcommon-1.0.12/jcommon-1.0.12.jar;



%% Create Cell Structure Containing Location Data
Create_Cell_Struct;


%% Imports
import java.awt.BasicStroke;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.GradientPaint;
import java.awt.Point;
import java.awt.Graphics2D;
import java.awt.geom.Rectangle2D;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JSlider;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import org.jfree.chart.*;
import org.jfree.data.general.*;
import org.jfree.chart.plot.dial.*;
import org.jfree.ui.*;





%% Constant Variables
RAD_TO_DEG = 57.3402;
BACKGR_COLOR = [171/255, 171/255, 121/255];
FEATURE_COLOR = [255/255, 198/255, 0/255];
PANEL_COLOR = [15/255, 41/255, 76/255];
CAPTURE_COLOR = [0/255, 255/255, 0/255];


%% Serial Port
try
    % Creates serial port
    s1 = serial('COM11', 'BaudRate', 115200, 'InputBufferSize', 2^12);
    
    % Number of data values
    n = 4;
    
    % Open serial port
    fopen(s1);
catch
    % Displays Error Message
    xbeeFS = stoploop({'!!!  XBee Wireless Receiver Not Connected to Correct Port  !!!'});
    while(~xbeeFS.Stop())
    end    

    % Clear Workspace After Use
    clear; 
    clc;
    close all;
    
    % Restarts User Interface
    RaDeGUI;
    return;
    
end


%% Takes Starting Time Of Session
sessionStartTime = datestr(now);


%% Load QR Location Data
load('loc_data.mat');


%% Create GUI Components
% Create Figure
hFig = figure('name', 'RaDe User Interface');
    set(hFig, 'Units', 'normalized');
    set(hFig, 'Position', [.1 .1 .8 .8]);
    set(hFig, 'MenuBar', 'none');
    
% Create main panel within figure
mainPanel = uipanel('Parent', hFig);
    set(mainPanel, 'BackgroundColor', BACKGR_COLOR);
    
% Close button
closeBtn = uicontrol('Parent', mainPanel);
    set(closeBtn, 'BackgroundColor', FEATURE_COLOR);
    set(closeBtn, 'Style', 'togglebutton');
    set(closeBtn, 'String', 'End Session');
    set(closeBtn, 'FontWeight', 'bold');
    set(closeBtn, 'FontSize', 12);
    set(closeBtn, 'Enable', 'on');
    set(closeBtn, 'Units', 'normalized');
    set(closeBtn, 'Position', [0 0 .2 .04]);

% Survey panel
surveyPanelTitle = uicontrol('Parent', mainPanel);
    set(surveyPanelTitle, 'Style', 'text');
    set(surveyPanelTitle, 'String', 'Survey Progress');
    set(surveyPanelTitle, 'BackgroundColor', FEATURE_COLOR);
    set(surveyPanelTitle, 'FontSize', 18);
    set(surveyPanelTitle, 'FontWeight', 'bold');
    set(surveyPanelTitle, 'Units', 'normalized');
    set(surveyPanelTitle, 'Position', [.025 .94 .17 .045]);
surveyPanel = uipanel('Parent', mainPanel);
    set(surveyPanel, 'Units', 'normalized');
    set(surveyPanel, 'Position', [.025 .45 .17 .5]);
    set(surveyPanel, 'BackgroundColor', PANEL_COLOR);
    set(surveyPanel, 'HighlightColor', FEATURE_COLOR);
    set(surveyPanel, 'ShadowColor', FEATURE_COLOR);
    set(surveyPanel, 'BorderType', 'etchedout');
    set(surveyPanel, 'BorderWidth', 3)

    
% Data panel    
dataPanelTitle = uicontrol('Parent', mainPanel);
    set(dataPanelTitle, 'Style', 'text');
    set(dataPanelTitle, 'String', 'Previous Sensor Reading');
    set(dataPanelTitle, 'BackgroundColor', FEATURE_COLOR);
    set(dataPanelTitle, 'FontSize', 18);
    set(dataPanelTitle, 'FontWeight', 'bold');
    set(dataPanelTitle, 'Units', 'normalized');
    set(dataPanelTitle, 'Position', [.01 .38 .35 .045]);
dataPanel = uipanel('Parent', mainPanel);
    set(dataPanel, 'Units', 'normalized');
    set(dataPanel, 'Position', [.01 .05 .35 .34]);
    set(dataPanel, 'BackgroundColor', PANEL_COLOR);
    set(dataPanel, 'HighlightColor', FEATURE_COLOR);
    set(dataPanel, 'ShadowColor', FEATURE_COLOR);
    set(dataPanel, 'BorderType', 'etchedout');
    set(dataPanel, 'BorderWidth', 3);

    
% Log data button
logDataBtn = uicontrol('Parent', dataPanel);
    set(logDataBtn, 'Style', 'togglebutton');
    set(logDataBtn, 'String', 'Data Capture');
    set(logDataBtn, 'BackgroundColor', FEATURE_COLOR);
    set(logDataBtn, 'FontWeight', 'bold');
    set(logDataBtn, 'FontSize', 12);
    set(logDataBtn, 'Enable', 'on');
    set(logDataBtn, 'Units', 'normalized');
    set(logDataBtn, 'Position', [.65 .8 .32 .15]);


% Create survey progress list items
numLocations = 10;
locBtnGroup = uibuttongroup('Parent', surveyPanel);
    set(locBtnGroup, 'BackgroundColor', PANEL_COLOR);
    set(locBtnGroup, 'BorderType', 'none');

surveyLocBox1 = uicontrol('Parent', locBtnGroup);
    set(surveyLocBox1, 'Style', 'checkbox');
    set(surveyLocBox1, 'String', strcat('Location #1'));
    set(surveyLocBox1, 'Enable', 'inactive')
    set(surveyLocBox1, 'Units', 'normalized');
    set(surveyLocBox1, 'Position', [.1 1-(1*.095) .8 .05]);
    set(surveyLocBox1, 'BackgroundColor', PANEL_COLOR);
    set(surveyLocBox1, 'ForegroundColor', FEATURE_COLOR);
    set(surveyLocBox1, 'FontSize', 13);
    set(surveyLocBox1, 'FontWeight', 'bold');
surveyLocBox2 = uicontrol('Parent', locBtnGroup);
    set(surveyLocBox2, 'Style', 'checkbox');
    set(surveyLocBox2, 'String', strcat('Location #2'));
    set(surveyLocBox2, 'Enable', 'inactive')
    set(surveyLocBox2, 'Units', 'normalized');
    set(surveyLocBox2, 'Position', [.1 1-(2*.095) .8 .05]);
    set(surveyLocBox2, 'BackgroundColor', PANEL_COLOR);
    set(surveyLocBox2, 'ForegroundColor', FEATURE_COLOR);
    set(surveyLocBox2, 'FontSize', 13);
    set(surveyLocBox2, 'FontWeight', 'bold'); 
surveyLocBox3 = uicontrol('Parent', locBtnGroup);
    set(surveyLocBox3, 'Style', 'checkbox');
    set(surveyLocBox3, 'String', strcat('Location #3'));
    set(surveyLocBox3, 'Enable', 'inactive')
    set(surveyLocBox3, 'Units', 'normalized');
    set(surveyLocBox3, 'Position', [.1 1-(3*.095) .8 .05]);
    set(surveyLocBox3, 'BackgroundColor', PANEL_COLOR);
    set(surveyLocBox3, 'ForegroundColor', FEATURE_COLOR);
    set(surveyLocBox3, 'FontSize', 13);
    set(surveyLocBox3, 'FontWeight', 'bold');
surveyLocBox4 = uicontrol('Parent', locBtnGroup);
    set(surveyLocBox4, 'Style', 'checkbox');
    set(surveyLocBox4, 'String', strcat('Location #4'));
    set(surveyLocBox4, 'Enable', 'inactive')
    set(surveyLocBox4, 'Units', 'normalized');
    set(surveyLocBox4, 'Position', [.1 1-(4*.095) .8 .05]);
    set(surveyLocBox4, 'BackgroundColor', PANEL_COLOR);
    set(surveyLocBox4, 'ForegroundColor', FEATURE_COLOR);
    set(surveyLocBox4, 'FontSize', 13);
    set(surveyLocBox4, 'FontWeight', 'bold');
surveyLocBox5 = uicontrol('Parent', locBtnGroup);
    set(surveyLocBox5, 'Style', 'checkbox');
    set(surveyLocBox5, 'String', strcat('Location #5'));
    set(surveyLocBox5, 'Enable', 'inactive')
    set(surveyLocBox5, 'Units', 'normalized');
    set(surveyLocBox5, 'Position', [.1 1-(5*.095) .8 .05]);
    set(surveyLocBox5, 'BackgroundColor', PANEL_COLOR);
    set(surveyLocBox5, 'ForegroundColor', FEATURE_COLOR);
    set(surveyLocBox5, 'FontSize', 13);
    set(surveyLocBox5, 'FontWeight', 'bold');
surveyLocBox6 = uicontrol('Parent', locBtnGroup);
    set(surveyLocBox6, 'Style', 'checkbox');
    set(surveyLocBox6, 'String', strcat('Location #6'));
    set(surveyLocBox6, 'Enable', 'inactive')
    set(surveyLocBox6, 'Units', 'normalized');
    set(surveyLocBox6, 'Position', [.1 1-(6*.095) .8 .05]);
    set(surveyLocBox6, 'BackgroundColor', PANEL_COLOR);
    set(surveyLocBox6, 'ForegroundColor', FEATURE_COLOR);
    set(surveyLocBox6, 'FontSize', 13);
    set(surveyLocBox6, 'FontWeight', 'bold');
surveyLocBox7 = uicontrol('Parent', locBtnGroup);
    set(surveyLocBox7, 'Style', 'checkbox');
    set(surveyLocBox7, 'String', strcat('Location #7'));
    set(surveyLocBox7, 'Enable', 'inactive')
    set(surveyLocBox7, 'Units', 'normalized');
    set(surveyLocBox7, 'Position', [.1 1-(7*.095) .8 .05]);
    set(surveyLocBox7, 'BackgroundColor', PANEL_COLOR);
    set(surveyLocBox7, 'ForegroundColor', FEATURE_COLOR);
    set(surveyLocBox7, 'FontSize', 13);
    set(surveyLocBox7, 'FontWeight', 'bold');
surveyLocBox8 = uicontrol('Parent', locBtnGroup);
    set(surveyLocBox8, 'Style', 'checkbox');
    set(surveyLocBox8, 'String', strcat('Location #8'));
    set(surveyLocBox8, 'Enable', 'inactive')
    set(surveyLocBox8, 'Units', 'normalized');
    set(surveyLocBox8, 'Position', [.1 1-(8*.095) .8 .05]);
    set(surveyLocBox8, 'BackgroundColor', PANEL_COLOR);
    set(surveyLocBox8, 'ForegroundColor', FEATURE_COLOR);
    set(surveyLocBox8, 'FontSize', 13);
    set(surveyLocBox8, 'FontWeight', 'bold');
surveyLocBox9 = uicontrol('Parent', locBtnGroup);
    set(surveyLocBox9, 'Style', 'checkbox');
    set(surveyLocBox9, 'String', strcat('Location #9'));
    set(surveyLocBox9, 'Enable', 'inactive')
    set(surveyLocBox9, 'Units', 'normalized');
    set(surveyLocBox9, 'Position', [.1 1-(9*.095) .8 .05]);
    set(surveyLocBox9, 'BackgroundColor', PANEL_COLOR);
    set(surveyLocBox9, 'ForegroundColor', FEATURE_COLOR);
    set(surveyLocBox9, 'FontSize', 13);
    set(surveyLocBox9, 'FontWeight', 'bold');
surveyLocBox10 = uicontrol('Parent', locBtnGroup);
    set(surveyLocBox10, 'Style', 'checkbox');
    set(surveyLocBox10, 'String', strcat('Location #10'));
    set(surveyLocBox10, 'Enable', 'inactive')
    set(surveyLocBox10, 'Units', 'normalized');
    set(surveyLocBox10, 'Position', [.1 1-(10*.095) .8 .05]);
    set(surveyLocBox10, 'BackgroundColor', PANEL_COLOR);
    set(surveyLocBox10, 'ForegroundColor', FEATURE_COLOR);
    set(surveyLocBox10, 'FontSize', 13);
    set(surveyLocBox10, 'FontWeight', 'bold');

% Create sensor data fields
senBtnGroup = uibuttongroup('Parent', dataPanel);
    set(senBtnGroup, 'BackgroundColor', PANEL_COLOR);
    set(senBtnGroup, 'BorderType', 'none');

sensorLocNum = uicontrol('Parent', senBtnGroup);
    set(sensorLocNum, 'Style', 'text');
    set(sensorLocNum, 'String', 'Location Number:');
    set(sensorLocNum, 'BackgroundColor', PANEL_COLOR);
    set(sensorLocNum, 'ForegroundColor', FEATURE_COLOR);
    set(sensorLocNum, 'FontSize', 13);
    set(sensorLocNum, 'FontWeight', 'bold');
    set(sensorLocNum, 'Units', 'normalized');
    set(sensorLocNum, 'Position', [.1 .75 .36 .1]);
sensorLocNumField = uicontrol('Parent', senBtnGroup);
    set(sensorLocNumField, 'Style', 'edit');
    set(sensorLocNumField, 'BackgroundColor', [236/255, 233/255, 216/255]);
    set(sensorLocNumField, 'FontSize', 13);
    set(sensorLocNumField, 'Units', 'normalized');
    set(sensorLocNumField, 'Position', [.45 .75 .1 .1]);
    set(sensorLocNumField, 'Enable', 'inactive');
    
sensorTime_Date = uicontrol('Parent', senBtnGroup);
    set(sensorTime_Date, 'Style', 'text');
    set(sensorTime_Date, 'String', 'Time and Date:');
    set(sensorTime_Date, 'BackgroundColor', PANEL_COLOR);
    set(sensorTime_Date, 'ForegroundColor', FEATURE_COLOR);
    set(sensorTime_Date, 'FontSize', 13);
    set(sensorTime_Date, 'FontWeight', 'bold');
    set(sensorTime_Date, 'Units', 'normalized');
    set(sensorTime_Date, 'Position', [.1 .55 .31 .1]);
sensorTime_DateField = uicontrol('Parent', senBtnGroup);
    set(sensorTime_DateField, 'Style', 'edit');
    set(sensorTime_DateField, 'BackgroundColor', [236/255, 233/255, 216/255]);
    set(sensorTime_DateField, 'FontSize', 13);
    set(sensorTime_DateField, 'Units', 'normalized');
    set(sensorTime_DateField, 'Position', [.4 .55 .5 .1]);
    set(sensorTime_DateField, 'Enable', 'inactive');

sensorDescription = uicontrol('Parent', senBtnGroup);
    set(sensorDescription, 'Style', 'text');
    set(sensorDescription, 'String', 'Description:');
    set(sensorDescription, 'BackgroundColor', PANEL_COLOR);
    set(sensorDescription, 'ForegroundColor', FEATURE_COLOR);
    set(sensorDescription, 'FontSize', 13);
    set(sensorDescription, 'FontWeight', 'bold');
    set(sensorDescription, 'Units', 'normalized');
    set(sensorDescription, 'Position', [.1 .35 .26 .1]);
sensorDescriptionField = uicontrol('Parent', senBtnGroup);
    set(sensorDescriptionField, 'Style', 'edit');
    set(sensorDescriptionField, 'BackgroundColor', [236/255, 233/255, 216/255]);
    set(sensorDescriptionField, 'FontSize', 13);
    set(sensorDescriptionField, 'Units', 'normalized');
    set(sensorDescriptionField, 'Position', [.35 .35 .5 .1]);
    set(sensorDescriptionField, 'Enable', 'inactive');
   
sensorCPS = uicontrol('Parent', senBtnGroup);
    set(sensorCPS, 'Style', 'text');
    set(sensorCPS, 'String', 'Counts Per Second:');
    set(sensorCPS, 'BackgroundColor', PANEL_COLOR);
    set(sensorCPS, 'ForegroundColor', FEATURE_COLOR);
    set(sensorCPS, 'FontSize', 13);
    set(sensorCPS, 'FontWeight', 'bold');
    set(sensorCPS, 'Units', 'normalized');
    set(sensorCPS, 'Position', [.1 .15 .39 .1]);
sensorCPSField = uicontrol('Parent', senBtnGroup);
    set(sensorCPSField, 'Style', 'edit');
    set(sensorCPSField, 'BackgroundColor', [236/255, 233/255, 216/255]);
    set(sensorCPSField, 'FontSize', 13);
    set(sensorCPSField, 'Units', 'normalized');
    set(sensorCPSField, 'Position', [.48 .15 .1 .1]);
    set(sensorCPSField, 'Enable', 'inactive');
    
    
    
%% Creates 2-D Mapping
% Creates scatter plot
mapplot = subplot('Position', [.64 .48 .34 .45]);
hold on
scatterMapping = newplot;
mappingTitle = uicontrol('Parent', mainPanel);
    set(mappingTitle, 'Style', 'text');
    set(mappingTitle, 'String', 'Data Mapping');
    set(mappingTitle, 'Units', 'normalized');
    set(mappingTitle, 'BackgroundColor', FEATURE_COLOR);
    set(mappingTitle, 'Position', [.68, .94, .2, .045]);
    set(mappingTitle, 'FontWeight', 'bold');
    set(mappingTitle, 'FontSize', 18);
xlabel('X Position (m)');
ylabel('Y Position (m)');
xvals = [0, qr_lookup{1,1}(1),qr_lookup{1,2}(1),qr_lookup{1,3}(1),qr_lookup{1,4}(1),qr_lookup{1,5}(1),qr_lookup{1,6}(1),qr_lookup{1,7}(1),qr_lookup{1,8}(1),qr_lookup{1,9}(1),qr_lookup{1,10}(1)];
yvals = [0, qr_lookup{1,1}(2),qr_lookup{1,2}(2),qr_lookup{1,3}(2),qr_lookup{1,4}(2),qr_lookup{1,5}(2),qr_lookup{1,6}(2),qr_lookup{1,7}(2),qr_lookup{1,8}(2),qr_lookup{1,9}(2),qr_lookup{1,10}(2)];
minx = min(xvals);
maxx = max(xvals);
miny = min(yvals);
maxy = max(yvals);
axis([minx-1 maxx+1 miny-1 maxy+1]);
grid on

% Colormap used for intensity values
caxis([0 5000]);

% Display colormap onto figure as legend
colormap('jet');
colorbar('peer', mapplot, 'EastOutside')
hold off

% Fill in mapping locations
for ii = 1:numLocations
    set(scatterMapping, 'NextPlot', 'add');
    scatter(qr_lookup{1,ii}(1), qr_lookup{1,ii}(2), 60, 'k', 'LineWidth', 1.5);
end

% Marks starting position
scatter(0, 0, 60, 'k', 'filled');

% Adds text labels to locations
textOffset = 0.3;
text((0 - 2*textOffset), (0 - 2*textOffset), 'Starting Position', 'Color', 'k', 'FontWeight', 'bold');
text((qr_lookup{1,1}(1) + textOffset), (qr_lookup{1,1}(2) + textOffset), '1');
text((qr_lookup{1,2}(1) + textOffset), (qr_lookup{1,2}(2) + textOffset), '2');
text((qr_lookup{1,3}(1) + textOffset), (qr_lookup{1,3}(2) + textOffset), '3');
text((qr_lookup{1,4}(1) + textOffset), (qr_lookup{1,4}(2) + textOffset), '4');
text((qr_lookup{1,5}(1) + textOffset), (qr_lookup{1,5}(2) + textOffset), '5');
text((qr_lookup{1,6}(1) + textOffset), (qr_lookup{1,6}(2) + textOffset), '6');
text((qr_lookup{1,7}(1) + textOffset), (qr_lookup{1,7}(2) + textOffset), '7');
text((qr_lookup{1,8}(1) + textOffset), (qr_lookup{1,8}(2) + textOffset), '8');
text((qr_lookup{1,9}(1) + textOffset), (qr_lookup{1,9}(2) + textOffset), '9');
text((qr_lookup{1,10}(1) + textOffset), (qr_lookup{1,10}(2) + textOffset), '10');


%% Radiation Indicator Display
% Creates dial plot
dataset = DefaultValueDataset(0);
radIndic = DialPlot();
radIndic.setDataset(dataset);

% Creates frame to hold dial
dialFrame = StandardDialFrame();
dialFrame.setRadius(.8);
dialFrame.setForegroundPaint(Color.black);
dialFrame.setStroke(java.awt.BasicStroke(5.0));
radIndic.setDialFrame(dialFrame);

% Adds background color to dial plot
gp = GradientPaint(Point(), Color(50/255, 0/255, 100/255), Point(), Color(150/255,100/255, 150/255));
sdb = DialBackground(gp);
sdb.setGradientPaintTransformer(StandardGradientPaintTransformer(GradientPaintTransformType.VERTICAL));
radIndic.addLayer(sdb);

% Sets scale of dial plot
scale = StandardDialScale;
scale.setLowerBound(0);
scale.setUpperBound(5000);
scale.setStartAngle(225);
scale.setExtent(-270);
scale.setTickRadius(0.35);
scale.setTickLabelOffset(-0.25);
scale.setMajorTickIncrement(1000);
scale.setMajorTickPaint(Color(0/255, 210/255, 80/255));
scale.setMinorTickPaint(Color(0/255, 210/255, 80/255));
scale.setTickLabelPaint(Color(0/255, 210/255, 80/255));
radIndic.addScale(0, scale);

% Creates indicator needle for dial plot
needle = javaObjectEDT('org.jfree.chart.plot.dial.DialPointer$Pin',0);
needle.setRadius(0.45);
radIndic.addLayer(needle);

% Create control for needle
radIndic.methods;
radIndicChart = JFreeChart('Counts Per Minute', radIndic);
radIndicChart.setBackgroundPaint(Color(171/255, 171/255, 121/255));
radIndicCP =  ChartPanel(radIndicChart);
radIndicJP = jcontrol(mainPanel, radIndicCP, 'Position', [0.8 0.1 0.16 0.27]);


%% Heading Indicator Display
subplot('Position', [.38 .12 .2 .2]),
hold on
[comptop,~,compTopAlpha] = imread('Heading_indicator Top Layer.png');
[compBottom,~,compBottomalpha] = imread('Heading_indicator Bottom Layer.png');
axis equal
axis([-2.005 2.005 -2.005 2.005])
axis off

% Plot the Bottom (compass) layer of the heading indicator
bottomHandle = image([-1.5,1.5],[-1.5,1.5],compBottom,'alphadata',compBottomalpha);

% Plot the top (reference) layer of the heading indicator
topHandle = image([-2,2],[-2,2],comptop,'alphadata',compTopAlpha);			
hold off



%% Attitude Indicator Display
subplot('Position', [.58 .12 .2 .2]);
hold on
[attitudetop, ~, attitudealpha] = imread('Attitude_Indicator.png');

% Patch defining the sky
sky = [2,2; 2,-2 ; -2,-2; -2,2; 2,2];	

% Horizon line
groundline = [-100,100; zeros(1,2)];	

roll = [linspace(0,pi/4,50),linspace(0,0,50),linspace(0,-pi/4,50)];		
pitch = [linspace(0,0,50),linspace(0,-pi/4,50),linspace(-pi/4,pi/5,50)];

axis equal	
axis([-2.005 2.005 -2.005 2.005])
axis off	

% Plot background image in cyan
area(sky(:,1),sky(:,2),'facecolor','c', 'LineStyle', 'none');

% Return handle for the horizon ground
groundHandle = patch([-100;100;-100;100],[0;0;-200;-200],[0.5,0.3,0.3]);	

% Plot horizon line
plot([-2,2],[0,0],'k');

% Fixes edges of image ([right-top; right-bottom; left-bottom; left-top; right-top])	
coverBottom = [2,-1.9;2,-3;-2,-3;-2,-1.9;2,-1.9];
coverLeft = [-1.9,2;-1.9,-2;-3,-2;-3,2;-1.9,2];
coverRight = [3,2;3,-2;1.9,-2;1.9,2;3,2];
coverTop = [2,3;2,1.9;-2,1.9;-2,3;2,3];
area(coverBottom(:,1), coverBottom(:,2), 'facecolor', BACKGR_COLOR, 'LineStyle', 'none');
area(coverLeft(:,1), coverLeft(:,2), 'facecolor', BACKGR_COLOR, 'LineStyle', 'none');
area(coverRight(:,1), coverRight(:,2), 'facecolor', BACKGR_COLOR, 'LineStyle', 'none');
area(coverTop(:,1), coverTop(:,2), 'facecolor', BACKGR_COLOR, 'LineStyle', 'none');

% Plot indicator marks
image([-2,2],[-2,2],attitudetop,'alphadata',attitudealpha);
hold off


%% Live Video Feed
try
    vidPlot = subplot('Position', [.225 .45 .36 .56]);
    hold on
    VI = videoinput('winvideo', 2, 'YUY2_480x480');
    vidRes = get(VI, 'VideoResolution');
    nBands = get(VI, 'NumberOfBands');
    hImage = image( zeros(vidRes(2), vidRes(1), nBands));
    preview(VI, hImage);
    set(vidPlot, 'XDir', 'reverse');
    hold off
catch
    % Displays error message
    vidfeedFS = stoploop({'!!!  Video Adaptor Not Connected To Correct Port  !!!'});
    while(~vidfeedFS.Stop())
    end
    
    %% Close Serial Port
    fclose(s1);

    % Clear Workspace After Use
    clear; 
    clc;
    close all;

    % Restarts user interface
    RaDeGUI;
    return;
end

% Create data log folder and relocate data log files
if(exist('../Data_Log', 'dir') ~= 0)
    rmdir('../Data_Log', 's');
end
mkdir('Data_Log');
mkdir('Location_Images');
movefile('./Location_Images','./Data_Log/Location_Images');
movefile('./Data_Log', '../Data_Log');
        
        
        
%% Control Loop
while(1)

    % Display GUI and update
    drawnow
    
    
    %% Save Data Log And Quit
    if(get(closeBtn, 'Value') == 1)
       
        set(closeBtn, 'Value', 0);
        
        sessionEndTime = datestr(now);
        
        dataLog = fopen('Data_Log.txt', 'w');    
        
        fprintf(dataLog, '\n\n');
        
        fprintf(dataLog, '----Radiation Detection UAV  Session Log----');
        
        fprintf(dataLog, '\n');
        
        fprintf(dataLog, '----Scheduled Maintenance Outage----');
         
        fprintf(dataLog, '\n\n\n');
        
        fprintf(dataLog, '----Log In Information----');
        
        fprintf(dataLog, '\n\n');
        
        fprintf(dataLog, 'Employee Name: %s', 'Arturs Berg');
        
        fprintf(dataLog, '\n');
        
        fprintf(dataLog, 'Employee ID#: %s', '1');
        
        fprintf(dataLog, '\n');

        fprintf(dataLog, 'Log In Date and Time: %s', sessionStartTime);
                
        fprintf(dataLog, '\n\n\n');
        
        fprintf(dataLog, '----Session Information----');
        
        fprintf(dataLog, '\n\n');
       
        for ii = 1:numLocations
                       
            fprintf(dataLog, 'Location Number:\t%i', ii);
     
            fprintf(dataLog, '\n');
            
            fprintf(dataLog, 'Description:\t\t%s', qr_lookup{2,ii});
            
            fprintf(dataLog, '\n');
            
            fprintf(dataLog, 'Time And Date:\t\t');
            
            if(isempty(qr_lookup{4,ii}) == 0)
                fprintf(dataLog, '%s', qr_lookup{4,ii});
            else
                fprintf(dataLog, 'N/A');
            end
            
            fprintf(dataLog, '\n');
            
            fprintf(dataLog, 'X-Coordinate:\t\t%i', qr_lookup{1,ii}(1));
            
            fprintf(dataLog, '\n');
            
            fprintf(dataLog, 'Y-Coordinate:\t\t%i', qr_lookup{1,ii}(2));
            
            fprintf(dataLog, '\n');
            
            fprintf(dataLog, 'Counts Per Second:\t');
            
            if(isempty(qr_lookup{4,ii}) == 0)
                fprintf(dataLog, '%u', qr_lookup{3,ii});
            else
                fprintf(dataLog, 'N/A');
            end
            
            fprintf(dataLog, '\n\n\n');
                       
        end
           
        fprintf(dataLog, '----End of Session Information----');
        
        fprintf(dataLog, '\n\n');
        
        fprintf(dataLog, 'Session End Date and Time: %s', sessionEndTime);
        
        fprintf(dataLog, '\n');
        fprintf(dataLog, '\n');
        
        fclose(dataLog);
        
        
        % Saves mapping as image
        set(hFig, 'units', 'pixels');
        figSz = get(hFig, 'Position');
        mapImg = getframe(hFig, [.6*figSz(3), .4*figSz(4), .4*figSz(3), .6*figSz(4)]);
        imwrite(mapImg.cdata, 'mapping.tiff');
        
        % Close user interface
        close(hFig)
        
        % Move scatter mapping image to data log folder
        movefile('./mapping.tiff','../Data_Log/mapping.tiff');
        movefile('./Data_Log.txt','../Data_Log/Data_Log.txt')

        % Exit out of loop
        break;
        
    end
    
    
    % Update indicators
    flushinput(s1);
    pause(1e-3)
    data = fscanf(s1);
    rawdata = strread(data,'%f', n, 'delimiter', ',');
    
    while(length(rawdata) ~= n)
        % Convert from raw data to matrix
        lastwarn
        try
            data = fscanf(s1);
        catch
        end
        try
            rawdata = strread(data,'%f', n, 'delimiter', ',');
        catch
        end
    end
    
    % Extract values from serial input (rawdata array)
    pitch = rawdata(1);
    roll = rawdata(2);
    yaw = rawdata(3);
    gmCPS = rawdata(4);
    
    % Update radiation indicator
    radIndic.setDataset(DefaultValueDataset(gmCPS));
    
    % Updates heading
    yaw = yaw*RAD_TO_DEG;
    set(bottomHandle,'CData',imrotate(compBottom,yaw,'crop'));
    
    % Updates attitude indicator by performing translation and transformation of data
    rotmat = [cos(roll),-sin(roll);sin(roll),cos(roll)];
    transobj = [groundline(1,:);((pitch/(pi/4)))*ones(1,length(groundline))+groundline(2,:)];
    rotobj = transobj'*rotmat; 	% Transformed object
    set(groundHandle,'Ydata',[rotobj(:,2);-200;-200]);
    set(groundHandle,'Xdata',[rotobj(:,1);-200;200]);

    
    % Indicates camera is taking scanning for a QR code
    if(get(logDataBtn, 'Value') == 1)
        set(logDataBtn, 'BackgroundColor', CAPTURE_COLOR)
    else
        set(logDataBtn, 'BackgroundColor', FEATURE_COLOR)
    end


    %% Aquire Image Data
    if(get(logDataBtn, 'Value') == 1)
           
                
        % Captures image
        qrImg = screencapture(vidPlot);
        
        % Flips the image for QR reading  to be able to correctly read QR image (along x axis)
        qrImg = flipdim(qrImg,2);        
        locNum = decode_qr(qrImg);
        
        % If QR image data processed
        if(isempty(locNum) == 0)
            locNum = str2num(locNum);
            locNum = int8(locNum);
            
            % If QR image data processed correctly
            if((locNum >= 1) & (locNum <= numLocations))

                % Stores image in data log file
                imwrite(qrImg, strcat('location_', num2str(locNum),'_img.tiff'));
                movefile(strcat('./location_',num2str(locNum),'_img.tiff'), strcat('../Data_Log/Location_Images/location_',num2str(locNum),'_img.tiff'));
                
                % Add scatter point to mapping
                hold on;
                axes(mapplot)
                set(scatterMapping, 'NextPlot', 'add');

                % Plot position with intensity value
                scatter(qr_lookup{1,locNum}(1), qr_lookup{1,locNum}(2), 60, 'filled', 'CData', 1000, 'LineWidth', 1.5)
                caxis(mapplot, [0 5000]);
                colormap('jet');
                colorbar('peer', mapplot, 'EastOutside');
                hold off;
                
                % Logging data
                qr_lookup{3,locNum} = gmCPS;
                qr_lookup{4,locNum} = datestr(now);
                
                % Survey panel update
                switch locNum
                    case 1
                        set(surveyLocBox1,'Value',1);
                    case 2
                        set(surveyLocBox2,'Value',1);
                    case 3
                        set(surveyLocBox3,'Value',1);
                end
                          
                % Data panel update
                set(sensorLocNumField, 'String', locNum);
                set(sensorTime_DateField, 'String', qr_lookup{4,locNum});
                set(sensorDescriptionField, 'String', qr_lookup{2,locNum});
                set(sensorCPSField, 'String', qr_lookup{3,locNum});
                
            end

            % Resets log data button
            set(logDataBtn, 'Value', 0);
            
        end
    end
end



%% Close Serial Port
fclose(s1);


% Clear Workspace After Use
clear; 
clc;
close all;


%% Opens datalog files
type('../Data_Log/Data_Log.txt');
imshow('../Data_Log/mapping.tiff');
