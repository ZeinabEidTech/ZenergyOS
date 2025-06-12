function smartBMS_GUI()
    % Smart BMS Simulation for Hospital with GUI

    % Simulation parameters
    simTime = 40;  % seconds
    sampleTime = 0.5;  % seconds
    time = 0:sampleTime:simTime;

    % Simulated data
    lightStatus = double(sin(time) > 0);
    lightIntensity = lightStatus .* 3.7;
    batteryCharge = max(0, 50 - 0.05 * time);
    hospitalLoad = 0.01 + 0.005 * lightStatus;

    % Create GUI window
    fig = figure('Name', 'Smart BMS GUI for Hospital', ...
                 'NumberTitle', 'off', 'Position', [100 100 500 400]);

    % Buttons
    uicontrol('Style', 'pushbutton', 'String', 'Show Light Status', ...
              'Position', [50 300 150 40], 'FontSize', 12, ...
              'Callback', @(~,~) showGraph(time, lightStatus, ...
              'Light Status (ON/OFF)', 'Time (s)', 'Status', [0 1.2], 'r'));

    uicontrol('Style', 'pushbutton', 'String', 'Show Light Intensity', ...
              'Position', [250 300 180 40], 'FontSize', 12, ...
              'Callback', @(~,~) showGraph(time, lightIntensity, ...
              'Light Intensity (V)', 'Time (s)', 'Voltage', [0 4.5], 'g'));

    uicontrol('Style', 'pushbutton', 'String', 'Show Battery Charge', ...
              'Position', [50 220 150 40], 'FontSize', 12, ...
              'Callback', @(~,~) showGraph(time, batteryCharge, ...
              'Battery Charge (Ah)', 'Time (s)', 'Charge (Ah)', [0 55], 'b'));

    uicontrol('Style', 'pushbutton', 'String', 'Show Hospital Load', ...
              'Position', [250 220 180 40], 'FontSize', 12, ...
              'Callback', @(~,~) showGraph(time, hospitalLoad, ...
              'Hospital Load (kW)', 'Time (s)', 'Load (kW)', [0 0.02], 'm'));

    % Info Text
    uicontrol('Style', 'text', 'String', 'Smart BMS GUI by Zainab', ...
              'Position', [150 50 200 30], 'FontSize', 10, 'ForegroundColor', 'blue');
end

function showGraph(x, y, graphTitle, xLabel, yLabel, yLimits, color)
    figure('Name', graphTitle, 'NumberTitle', 'off');
    plot(x, y, color, 'LineWidth', 2);
    title(graphTitle);
    xlabel(xLabel);
    ylabel(yLabel);
    ylim(yLimits);
    grid on;
end
