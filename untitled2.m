clc;
clear;

% Simulation Parameters
simTime = 40; 
sampleTime = 0.5; 
time = 0:sampleTime:simTime;

% Battery Setup
batteryVoltage = 3.7;
batteryCapacity = 50; 
batteryCharge = zeros(size(time));
batteryCharge(1) = batteryCapacity;

% System Logic Variables
lightSensorSensitivity = 0.5; 
motionSensorStatus = rand(size(time)) > 0.5;
lightStatus = zeros(size(time));
lightIntensity = zeros(size(time));
hospitalLoad = zeros(size(time));
lightPower = 0.1 / 1000; 
hospitalDevicesPower = 10 / 1000;

% Create GUI Window
fig = figure('Name', 'Hospital BMS System', ...
             'NumberTitle', 'off', ...
             'Position', [100, 100, 1200, 800]);

% Plot areas
ax1 = subplot(4,1,1); 
h1 = plot(ax1, time(1), lightStatus(1), 'r', 'LineWidth', 2);
title('Light Status (ON/OFF)');
xlabel('Time (s)');
ylabel('Status');
ylim([-0.2 1.2]);
grid on;

ax2 = subplot(4,1,2); 
h2 = plot(ax2, time(1), lightIntensity(1), 'g', 'LineWidth', 2);
title('Light Intensity (V)');
xlabel('Time (s)');
ylabel('Voltage');
ylim([0 batteryVoltage+0.5]);
grid on;

ax3 = subplot(4,1,3); 
h3 = plot(ax3, time(1), batteryCharge(1), 'b', 'LineWidth', 2);
title('Battery Charge (Ah)');
xlabel('Time (s)');
ylabel('Ah');
ylim([0 batteryCapacity+5]);
grid on;

ax4 = subplot(4,1,4); 
h4 = plot(ax4, time(1), hospitalLoad(1), 'm', 'LineWidth', 2);
title('Hospital Load (kW)');
xlabel('Time (s)');
ylabel('kW');
ylim([0 hospitalDevicesPower+0.01]);
grid on;

% GUI Controls
uicontrol('Style', 'checkbox', 'String', 'Enable KNX Override', ...
    'Position', [1030, 740, 150, 30], 'FontSize', 10, 'Tag', 'knxBox');

batteryWarningText = uicontrol('Style','text','String','', ...
    'Position',[1030 700 150 30],'FontSize',10,'ForegroundColor','red','BackgroundColor','white');

% Simulation Loop
for t = 2:length(time)
    knxBox = findobj('Tag', 'knxBox');
    knxEnabled = get(knxBox, 'Value');

    if knxEnabled
        lightStatus(t) = 1;
    elseif lightSensorSensitivity * rand() > 0.3 && motionSensorStatus(t)
        lightStatus(t) = 1;
    else
        lightStatus(t) = 0;
    end

    powerUsed = hospitalDevicesPower + (lightStatus(t) * lightPower);
    energyUsedAh = (powerUsed * sampleTime) / 3600;
    batteryCharge(t) = max(batteryCharge(t-1) - energyUsedAh, 0);
    hospitalLoad(t) = powerUsed;
    lightIntensity(t) = lightStatus(t) * batteryVoltage;

    % Battery warning
    if batteryCharge(t) < 10
        set(batteryWarningText, 'String', '⚠ Battery Low!');
    else
        set(batteryWarningText, 'String', '');
    end

    % Real-time update
    set(h1, 'XData', time(1:t), 'YData', lightStatus(1:t));
    set(h2, 'XData', time(1:t), 'YData', lightIntensity(1:t));
    set(h3, 'XData', time(1:t), 'YData', batteryCharge(1:t));
    set(h4, 'XData', time(1:t), 'YData', hospitalLoad(1:t));

    drawnow;
end

% Export to Excel
T = table(time', lightStatus', lightIntensity', batteryCharge', hospitalLoad', ...
    'VariableNames', {'Time_s', 'Light_Status', 'Light_Intensity_V', 'Battery_Charge_Ah', 'Hospital_Load_kW'});

writetable(T, 'BMS_Hospital_Report.xlsx');
disp('✅ Report exported to Excel!');
