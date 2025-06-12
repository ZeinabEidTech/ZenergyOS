function smartBMS_GUI2
    % Smart BMS GUI for Hospital Operating Room
    
    % Time and Data Initialization
    t = linspace(0, 40, 400);
    lightStatus = double(sin(0.2 * pi * t) > 0);
    lightIntensity = lightStatus .* (220 + 20 * randn(size(t)));
    batteryCharge = max(100 - cumsum(0.2 * lightStatus), 0);
    hospitalLoad = 10 + 2 * randn(size(t));

    % Main GUI Window
    f = figure('Name', 'Smart BMS for Operating Room', ...
               'Position', [300, 100, 1000, 620], ...
               'Color', [0.9 0.9 0.9]);

    % Title Text
    uicontrol(f, 'Style', 'text', 'String', ' Smart Battery Management System - Operating Room', ...
        'FontSize', 14, 'FontWeight', 'bold', 'ForegroundColor', 'black', ...
        'BackgroundColor', [0.8 0.8 0.8], 'Position', [250 570 500 30]);

    % Buttons
    uicontrol(f, 'Style', 'pushbutton', 'String', ' Run Simulation', ...
        'Position', [70 520 180 40], 'FontSize', 11, ...
        'BackgroundColor', [0.7 0.8 0.9], 'Callback', @(src,event)runSim());

    uicontrol(f, 'Style', 'pushbutton', 'String', 'Export to Excel', ...
        'Position', [410 520 180 40], 'FontSize', 11, ...
        'BackgroundColor', [0.7 0.9 0.7], 'Callback', @(src,event)exportExcel());

    uicontrol(f, 'Style', 'pushbutton', 'String', ' Trigger Sensor', ...
        'Position', [750 520 180 40], 'FontSize', 11, ...
        'BackgroundColor', [0.9 0.8 0.6], 'Callback', @(src,event)sensorAlert());

    % Axes for live plots
    ax1 = subplot(2,2,1); title(' Light Status'); grid on;
    ax2 = subplot(2,2,2); title(' Light Intensity (V)'); grid on;
    ax3 = subplot(2,2,3); title('Battery Charge (Ah)'); grid on;
    ax4 = subplot(2,2,4); title('Hospital Load (kW)'); grid on;

    % Simulation function
    function runSim()
        for i = 1:10:length(t)
            % Light Status
            plot(ax1, t(1:i), lightStatus(1:i), 'r', 'LineWidth', 2);
            ylabel(ax1, 'ON/OFF'); xlabel(ax1, 'Time (s)');

            % Light Intensity
            plot(ax2, t(1:i), lightIntensity(1:i), 'g', 'LineWidth', 2);
            ylabel(ax2, 'Voltage (V)'); xlabel(ax2, 'Time (s)');

            % Battery Charge
            plot(ax3, t(1:i), batteryCharge(1:i), 'b', 'LineWidth', 2);
            ylabel(ax3, 'Charge (Ah)'); xlabel(ax3, 'Time (s)');

            % Hospital Load
            plot(ax4, t(1:i), hospitalLoad(1:i), 'm', 'LineWidth', 2);
            ylabel(ax4, 'Load (kW)'); xlabel(ax4, 'Time (s)');

            drawnow;

            % Battery Low Warning
            if i == length(t) && batteryCharge(i) < 20
                msgbox(' Warning: Battery charge critically low!','Battery Alert','warn');
            end
        end
    end

    % Export to Excel
    function exportExcel()
        data = table(t', lightStatus', lightIntensity', batteryCharge', hospitalLoad', ...
            'VariableNames', {'Time_s', 'Light_Status', 'Light_Intensity_V', 'Battery_Charge_Ah', 'Hospital_Load_kW'});
        filename = ['BMS_Data_' datestr(now, 'yyyymmdd_HHMMSS') '.xlsx'];
        writetable(data, filename);
        msgbox(['Data exported successfully to file: ' filename],'Export Complete');
    end

    % Sensor Alert Function
    function sensorAlert()
        msgbox('Sensor triggered! Emergency lighting activated. System is under monitoring.','Sensor Alert','help');
    end
end
