function BMS_ShowroomMode_Complete
    % BMS Showroom Mode for Hospital & Hotel with Emergency Fire Alarm
    % MATLAB 2023+

    close all; clc;

    fig = uifigure('Name','BMS Hospital & Hotel Showroom','Position',[100 50 1200 800],'Color',[0.18 0.18 0.18]);

    % ----- Hospital Panel -----
    hospitalPanel = uipanel(fig,'Title','Hospital Status','FontSize',20,...
        'BackgroundColor',[0.3 0 0],'ForegroundColor','w',...
        'Position',[20 380 560 380]);

    hospitalAxes = uiaxes(hospitalPanel,'Position',[25 70 510 290]);
    hospitalAxes.XLim = [1 10];
    hospitalAxes.YLim = [0 100];
    hospitalAxes.Title.String = 'Energy Consumption (kWh)';
    hospitalAxes.Title.Color = 'w';
    hospitalAxes.XColor = 'w';
    hospitalAxes.YColor = 'w';
    hospitalAxes.Color = [0.25 0.25 0.25];
    hospitalAxes.GridColor = 'w';
    hospitalAxes.GridAlpha = 0.3;
    hospitalAxes.Box = 'on';

    % Initial data
    hospData = randi([30 60],1,10);
    hospLine = plot(hospitalAxes,1:10,hospData,'-o','LineWidth',2,'Color','c');
    drawnow;

    % ----- Hotel Panel -----
    hotelPanel = uipanel(fig,'Title',' Hotel Status','FontSize',20,...
        'BackgroundColor',[0 0 0.3],'ForegroundColor','w',...
        'Position',[620 380 560 380]);

    hotelAxes = uiaxes(hotelPanel,'Position',[25 70 510 290]);
    hotelAxes.XLim = [1 10];
    hotelAxes.YLim = [0 100];
    hotelAxes.Title.String = 'Energy Consumption (kWh)';
    hotelAxes.Title.Color = 'w';
    hotelAxes.XColor = 'w';
    hotelAxes.YColor = 'w';
    hotelAxes.Color = [0.25 0.25 0.25];
    hotelAxes.GridColor = 'w';
    hotelAxes.GridAlpha = 0.3;
    hotelAxes.Box = 'on';

    % Initial data
    hotelData = randi([20 50],1,10);
    hotelLine = plot(hotelAxes,1:10,hotelData,'-s','LineWidth',2,'Color','m');
    drawnow;

    % ----- Emergency Panel -----
    emergencyPanel = uipanel(fig,'Title','Emergency Status','FontSize',22,...
        'BackgroundColor',[0.3 0 0],'ForegroundColor','w',...
        'Position',[20 20 1160 340]);

    emergencyLabel = uilabel(emergencyPanel,'Text','Status: NORMAL',...
        'FontSize',28,'FontWeight','bold','FontColor','w','Tag','EmergencyStatus',...
        'Position',[400 140 400 50],'HorizontalAlignment','center');

    % Button to trigger emergency
    emergencyBtn = uibutton(fig,'Text','Trigger Emergency','FontSize',18,...
        'Position',[500 680 200 40],'BackgroundColor','r','FontColor','w',...
        'ButtonPushedFcn',@(btn,event) triggerEmergency(emergencyPanel, btn));

    % Timer for flashing emergency panel background
    flashTimer = timer('ExecutionMode','fixedRate','Period',0.5,...
        'TimerFcn',@(~,~) flashEmergency(emergencyPanel));
    fig.UserData.flashTimer = flashTimer;
    fig.UserData.flashState = false;

    % Timer for live update of hospital and hotel data
    updateTimer = timer('ExecutionMode','fixedRate','Period',2,...
        'TimerFcn',@(~,~) updateData(hospLine, hotelLine));
    start(updateTimer);

    % Clean up timers when figure closes
    fig.CloseRequestFcn = @(src,event) closeApp(src, updateTimer, flashTimer);

    % Nested functions for modularity
    function updateData(hLine, htLine)
        if isvalid(hLine) && isvalid(htLine)
            % Shift data and add new random value
            newHosp = max(min(hLine.YData(end) + randi([-5 5]), 100),0);
            newHotel = max(min(htLine.YData(end) + randi([-5 5]), 100),0);

            hLine.YData = [hLine.YData(2:end), newHosp];
            htLine.YData = [htLine.YData(2:end), newHotel];
        end
    end

    function triggerEmergency(panel, btn)
        lbl = findobj(panel,'Tag','EmergencyStatus');
        if isempty(lbl), return; end

        flashTimer = fig.UserData.flashTimer;
        if contains(lbl.Text,'NORMAL')
            % Turn emergency ON
            lbl.Text = 'Status:  FIRE ALERT';
            panel.BackgroundColor = [0.7 0 0];
            start(flashTimer);
            btn.Text = ' Clear Emergency';
        else
            % Turn emergency OFF
            lbl.Text = 'Status: NORMAL';
            stop(flashTimer);
            panel.BackgroundColor = [0.3 0 0];
            btn.Text = 'Trigger Emergency';
        end
    end

    function flashEmergency(panel)
        % Flash background color between dark red and bright red
        state = fig.UserData.flashState;
        if state
            panel.BackgroundColor = [0.7 0 0];
        else
            panel.BackgroundColor = [0.3 0 0];
        end
        fig.UserData.flashState = ~state;
    end

    function closeApp(src, t1, t2)
        stop(t1); delete(t1);
        stop(t2); delete(t2);
        delete(src);
    end

end
