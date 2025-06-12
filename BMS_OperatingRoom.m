function BMS_OperatingRoom_GUI()
    % Battery Management System - Operating Room Hospital - Advanced GUI
    % Developed with love for Zainab
    clc; clear; close all;

    % Simulation Parameters
    simTime = 3600; % 1 hour in seconds
    sampleTime = 5; % seconds
    time = 0:sampleTime:simTime;

    % Battery Specs
    batteryCapacity = 200; % Ah
    nominalVoltage = 48; % V
    maxLoad = 3000; % Watts max load

    % Initialize data arrays
    SoC = zeros(size(time));
    voltage = zeros(size(time));
    current = zeros(size(time));
    loadPower = zeros(size(time));

    % Initial Conditions
    SoC(1) = 100;
    voltage(1) = nominalVoltage;
    current(1) = 0;
    loadPower(1) = 1000;

    % Create Figure
    fig = figure('Name', 'BMS Operating Room - Hospital', ...
                 'NumberTitle', 'off', 'Position', [200 100 900 600], ...
                 'Color', [0.94 0.94 0.94]);

    % UI Controls
    uicontrol('Style', 'text', 'String', 'Battery Management System - Operating Room', ...
              'FontSize', 16, 'FontWeight', 'bold', ...
              'Position', [250 550 400 40], 'BackgroundColor', [0.94 0.94 0.94]);

    % Axes for plots
    ax1 = axes('Units','pixels', 'Position',[50 350 350 180]);
    hSoC = plot(ax1, 0, SoC(1), 'b-', 'LineWidth', 2);
    title(ax1,'State of Charge (%)'); ylabel(ax1,'SoC (%)'); xlabel(ax1,'Time (min)');
    ylim(ax1,[0 110]); grid(ax1,'on'); hold(ax1,'on');

    ax2 = axes('Units','pixels', 'Position',[480 350 350 180]);
    hVolt = plot(ax2, 0, voltage(1), 'r-', 'LineWidth', 2);
    title(ax2,'Battery Voltage (V)'); ylabel(ax2,'Voltage (V)'); xlabel(ax2,'Time (min)');
    ylim(ax2,[nominalVoltage*0.8 nominalVoltage*1.1]); grid(ax2,'on'); hold(ax2,'on');

    ax3 = axes('Units','pixels', 'Position',[50 150 350 150]);
    hCurrent = plot(ax3, 0, current(1), 'k-', 'LineWidth', 2);
    title(ax3,'Battery Current (A)'); ylabel(ax3,'Current (A)'); xlabel(ax3,'Time (min)');
    ylim(ax3,[-50 100]); grid(ax3,'on'); hold(ax3,'on');

    ax4 = axes('Units','pixels', 'Position',[480 150 350 150]);
    hLoad = plot(ax4, 0, loadPower(1), 'm-', 'LineWidth', 2);
    title(ax4,'Load Power (W)'); ylabel(ax4,'Power (W)'); xlabel(ax4,'Time (min)');
    ylim(ax4,[0 maxLoad+500]); grid(ax4,'on'); hold(ax4,'on');

    % Text Box for Status Display
    statusBox = uicontrol('Style','edit','Max',10,'Min',1,...
        'Position',[50 20 780 100],'FontSize',12, ...
        'BackgroundColor','white','HorizontalAlignment','left', ...
        'Enable','inactive','String','System initializing...');

    % Buttons
    btnStart = uicontrol('Style', 'pushbutton', 'String', 'Start Simulation', ...
        'Position', [50 510 120 30], 'FontSize', 12, 'BackgroundColor', [0.2 0.7 0.2], ...
        'ForegroundColor', 'white', 'Callback', @startSim);

    btnStop = uicontrol('Style', 'pushbutton', 'String', 'Stop Simulation', ...
        'Position', [190 510 120 30], 'FontSize', 12, 'BackgroundColor', [0.8 0.2 0.2], ...
        'ForegroundColor', 'white', 'Enable', 'off', 'Callback', @stopSim);

    btnSave = uicontrol('Style', 'pushbutton', 'String', 'Save Data to Excel', ...
        'Position', [700 510 130 30], 'FontSize', 12, 'BackgroundColor', [0.2 0.4 0.8], ...
        'ForegroundColor', 'white', 'Callback', @saveData);

    % Variables to control simulation
    simRunning = false;
    idx = 1;

    % Timer setup
    tmr = timer('ExecutionMode','fixedRate','Period',sampleTime,'TimerFcn',@timerCallback);

    % Start Simulation callback
    function startSim(~,~)
        if ~simRunning
            simRunning = true;
            set(statusBox,'String','Simulation started...');
            set(btnStart,'Enable','off');
            set(btnStop,'Enable','on');
            idx = 1;
            % Reset data
            SoC(:) = 0; voltage(:) = 0; current(:) = 0; loadPower(:) = 0;
            SoC(1) = 100; voltage(1) = nominalVoltage; current(1) = 0; loadPower(1) = 1000;
            % Reset plots
            resetPlots();
            start(tmr);
        end
    end

    % Stop Simulation callback
    function stopSim(~,~)
        if simRunning
            simRunning = false;
            stop(tmr);
            set(statusBox,'String','Simulation stopped by user.');
            set(btnStart,'Enable','on');
            set(btnStop,'Enable','off');
        end
    end

    % Timer callback function
    function timerCallback(~,~)
        if idx >= length(time)
            stopSim();
            set(statusBox,'String','Simulation complete.');
            return;
        end
        idx = idx + 1;

        % Simulate Load Variation
        if mod(idx,20) < 10
            loadPower(idx) = 1800 + 900*rand();
        else
            loadPower(idx) = 900 + 400*rand();
        end
        loadPower(idx) = min(loadPower(idx), maxLoad);

        % Calculate current: Load Power / Voltage
        current(idx) = loadPower(idx)/voltage(idx-1);

        % Update SoC
        deltaAh = current(idx)*sampleTime/3600; % Ah consumed
        SoC(idx) = max(SoC(idx-1) - deltaAh/batteryCapacity*100, 0);

        % Update voltage with SoC linear approx
        voltage(idx) = 44 + (SoC(idx)/100)*(52-44);

        % Update plots data
        updatePlots();

        % Update status message
        updateStatus();
    end

    % Update status message and colors
    function updateStatus()
        msg = sprintf('Time: %.1f min\nSoC: %.2f%%\nVoltage: %.2f V\nCurrent: %.2f A\nLoad: %.1f W', ...
            time(idx)/60, SoC(idx), voltage(idx), current(idx), loadPower(idx));
        if SoC(idx) < 20
            msg = [msg '\n*** ALERT: Battery Low! Immediate Recharge Needed! ***'];
            set(statusBox, 'ForegroundColor', 'red');
        elseif loadPower(idx) > maxLoad * 0.9
            msg = [msg '\n*** WARNING: Load Near Maximum Capacity ***'];
            set(statusBox, 'ForegroundColor', [1 0.5 0]);
        else
            set(statusBox, 'ForegroundColor', 'black');
        end
        set(statusBox, 'String', msg);
    end

    % Reset plots data
    function resetPlots()
        set(hSoC, 'XData', 0, 'YData', SoC(1));
        set(hVolt, 'XData', 0, 'YData', voltage(1));
        set(hCurrent, 'XData', 0, 'YData', current(1));
        set(hLoad, 'XData', 0, 'YData', loadPower(1));
        drawnow;
    end

    % Update plots with current data up to idx
    function updatePlots()
        set(hSoC, 'XData', time(1:idx)/60, 'YData', SoC(1:idx));
        set(hVolt, 'XData', time(1:idx)/60, 'YData', voltage(1:idx));
        set(hCurrent, 'XData', time(1:idx)/60, 'YData', current(1:idx));
        set(hLoad, 'XData', time(1:idx)/60, 'YData', loadPower(1:idx));
        drawnow;
    end

    % Save data to Excel file
    function saveData(~,~)
        if idx == 1
            msgbox('No data to save. Start simulation first.', 'Info');
            return;
        end
        filename = ['BMS_OperatingRoom_' datestr(now,'yyyymmdd_HHMMSS') '.xlsx'];
        T = table(time(1:idx)'/60, SoC(1:idx)', voltage(1:idx)', current(1:idx)', loadPower(1:idx)', ...
            'VariableNames', {'Time_min','SoC_pct','Voltage_V','Current_A','Load_W'});
        try
            writetable(T, filename);
            msgbox(['Data saved successfully as: ' filename], 'Success');
        catch ME
            errordlg(['Error saving data: ' ME.message], 'Error');
        end
    end

end
