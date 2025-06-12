
function  BMS_ShowroomMode_Complete
    % Fullscreen UI
    fig = uifigure('Name','BMS Showroom Enhanced','Position',get(0,'screensize'),'Color',[0.08 0.1 0.12]);

    % Title
    uilabel(fig,'Text','Smart BMS - Showroom Mode','FontSize',26,...
        'FontWeight','bold','Position',[400 720 800 40],'FontColor','w');

    % Panels
    hospitalTile = uipanel(fig,'Title',' Hospital Status','FontSize',18,...
        'Position',[50 400 500 270],'BackgroundColor',[0.1 0.2 0.3]);
    hotelTile = uipanel(fig,'Title','Hotel Status','FontSize',18,...
        'Position',[570 400 500 270],'BackgroundColor',[0.2 0.1 0.1]);

    % Live Plot
    ax = uiaxes(fig,'Position',[150 80 900 280],'BackgroundColor','k','XColor','w','YColor','w');
    title(ax,'Live Energy Consumption','FontSize',16,'Color','w');
    xlabel(ax,'Time','Color','w'); ylabel(ax,'kWh','Color','w');
    ax.XLim = [1 20]; ax.YLim = [0 100];
    b = bar(ax, randi([40 80],1,20), 'FaceColor', [0.6 0.9 0.8]);

    % Status Labels
    sysNames = {'Lighting','HVAC','Battery','Fire Alarm'};
    for i = 1:length(sysNames)
        uilabel(hospitalTile,'Text',[sysNames{i} ' : ON'],'FontSize',16,...
            'FontColor','w','FontWeight','bold','Tag',sysNames{i},...
            'Position',[20 200 - (i-1)*40 300 30]);
        uilabel(hotelTile,'Text',[sysNames{i} ' : ON'],'FontSize',16,...
            'FontColor','w','FontWeight','bold','Tag',['H' sysNames{i}],...
            'Position',[20 200 - (i-1)*40 300 30]);
    end

    % Control Panel
    ctrl = uipanel(fig,'Title','Control Panel','FontSize',16,...
        'Position',[1090 400 300 270],'BackgroundColor',[0.15 0.15 0.15]);

    y = 180;
    for i = 1:length(sysNames)
        uibutton(ctrl,'Text',['Toggle ' sysNames{i}],'FontSize',14,...
            'Position',[30 y 240 30],'ButtonPushedFcn',@(btn,event) toggleStatus(fig,sysNames{i}));
        y = y - 50;
    end

    % Emergency View Panel (hidden by default)
    emergencyPanel = uipanel(fig,'Title',' Emergency View','FontSize',20,...
        'Position',[1090 80 300 270],'BackgroundColor',[0.3 0 0],'ForegroundColor','w');
    uilabel(emergencyPanel,'Text','Status: NORMAL','FontSize',18,...
        'FontWeight','bold','FontColor','w','Position',[40 100 250 60],'Tag','EmergencyStatus');

    % Emergency Button
    uibutton(fig,'Text',' Trigger Emergency','FontSize',16,...
        'Position',[50 680 220 30],'BackgroundColor','r','FontColor','w',...
        'ButtonPushedFcn',@(btn,event) triggerEmergency(emergencyPanel));

    % Live Clock
    timeLbl = uilabel(fig,'Text',' Time:','FontSize',14,...
        'Position',[900 680 300 30],'FontColor','w');
    timeTimer = timer('ExecutionMode','fixedRate','Period',1,...
        'TimerFcn', @(~,~) updateClock(timeLbl));
    start(timeTimer);
    fig.UserData.timeTimer = timeTimer;

    % Save Button
    uibutton(fig,'Text',' Save Report','FontSize',14,...
        'Position',[290 680 160 30],'BackgroundColor',[0.2 0.2 0.2],...
        'FontColor','w','ButtonPushedFcn',@(btn,event) saveReport(fig));

    % Timer for live plot
    plotTimer = timer('ExecutionMode','fixedRate','Period',1.2,...
        'TimerFcn', @(~,~) updateShowroomPlot(b, ax));
    start(plotTimer);
    fig.UserData.timer = plotTimer;

    % Set Close Request to clean timers
    fig.CloseRequestFcn = @(src,event) closeFig(src);
end

function updateShowroomPlot(b, ax)
    if ~isvalid(b) || ~isvalid(ax)
        return;
    end
    persistent vals;
    if isempty(vals)
        vals = randi([30 70],1,20);
    end
    next = max(10, min(90, vals(end)+randi([-5 5])));
    vals = [vals(2:end), next];
    b.YData = vals;
end

function toggleStatus(fig, sysName)
    lbl1 = findobj(fig,'Tag',sysName);
    lbl2 = findobj(fig,'Tag',['H' sysName]);
    if isempty(lbl1) || isempty(lbl2)
        return;
    end
    newText = toggleText(lbl1.Text);
    lbl1.Text = [sysName ' : ' newText];
    lbl2.Text = [sysName ' : ' newText];
end

function txt = toggleText(currentText)
    if contains(currentText,'OFF')
        txt = 'ON';
    else
        txt = 'OFF';
    end
end

function triggerEmergency(panel)
    lbl = findobj(panel,'Tag','EmergencyStatus');
    if isempty(lbl)
        return;
    end
    if contains(lbl.Text,'NORMAL')
        lbl.Text = 'Status:  FIRE ALERT';
        panel.BackgroundColor = [0.7 0 0];
    else
        lbl.Text = 'Status: NORMAL';
        panel.BackgroundColor = [0.3 0 0];
    end
end

function updateClock(lbl)
    if ~isvalid(lbl)
        return;
    end
    nowTime = datestr(now,'dd-mmm-yyyy HH:MM:SS');
    lbl.Text = ['Time: ' nowTime];
end

function saveReport(fig)
    fname = ['BMS_Report_' datestr(now,'yyyymmdd_HHMMSS') '.txt'];
    fid = fopen(fname,'w');
    fprintf(fid,'Smart BMS Report - %s\n\n', datestr(now));
    fprintf(fid,'Systems:\n');
    systems = {'Lighting','HVAC','Battery','Fire Alarm'};
    for i = 1:length(systems)
        val = findobj(fig,'Tag',systems{i});
        if isempty(val)
            fprintf(fid,'%s = Not Found\n', systems{i});
        else
            fprintf(fid,'%s = %s\n', systems{i}, val.Text);
        end
    end
    emergencyStatus = findobj(fig,'Tag','EmergencyStatus');
    if isempty(emergencyStatus)
        fprintf(fid,'\nEmergency Status: Not Found\n');
    else
        fprintf(fid,'\nEmergency Status: %s\n', emergencyStatus.Text);
    end
    fclose(fid);
    uialert(fig,'Report Saved Successfully!','Report');
end

function closeFig(fig)
    % Stop and delete timers safely
    if isfield(fig.UserData,'timer') && isvalid(fig.UserData.timer)
        stop(fig.UserData.timer);
        delete(fig.UserData.timer);
    end
    if isfield(fig.UserData,'timeTimer') && isvalid(fig.UserData.timeTimer)
        stop(fig.UserData.timeTimer);
        delete(fig.UserData.timeTimer);
    end
    delete(fig);
end
