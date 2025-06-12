function smartBMS_OperatingRoom_GUI()
    % Smart BMS System for Hospital Operating Room

    % إعدادات الوقت
    simTime = 24;  % ساعة
    sampleTime = 1; % ساعة لكل خطوة
    time = 0:sampleTime:simTime;

    % أحمال واقعية للإنارة (مثلاً شدة الإضاءة أعلى في الليل)
    lightLoad = [0.3 0.3 0.4 0.5 0.6 0.6 0.4 0.2 0.2 0.2 0.3 0.4 ...
                 0.5 0.6 0.7 0.8 0.9 1.0 1.0 0.9 0.7 0.5 0.4 0.3 0.3]; % kW

    % شحن البطارية يتناقص مع الأحمال
    batteryCharge = zeros(size(time));
    batteryCharge(1) = 100; % نسبة مئوية
    for i = 2:length(time)
        dischargeRate = 0.6 * lightLoad(i); % معدل التفريغ حسب الحمل
        batteryCharge(i) = max(0, batteryCharge(i-1) - dischargeRate);
    end

    % حمل وحدة المعالجة CPU (يتغير بشكل بسيط)
    cpuLoad = 10 + 10 * sin(time / 3) + rand(1, length(time)) * 5;

    % إنشاء الواجهة
    fig = figure('Name', 'BMS - Operating Room', ...
        'NumberTitle', 'off', 'Color', [0.8 0.8 0.8], ...
        'Position', [300 100 600 500]);

    % زرار عرض حالة الإنارة
    uicontrol('Style', 'pushbutton', 'String', 'عرض حمل الإنارة', ...
        'Position', [50 400 150 40], 'FontSize', 11, ...
        'Callback', @(~,~) plotData(time, lightLoad, ...
        'حمل الإنارة (kW)', 'الوقت (ساعة)', 'الطاقة (kW)', [0 1.2], 'g'));

    % زرار عرض شحن البطارية
    uicontrol('Style', 'pushbutton', 'String', 'عرض شحن البطارية', ...
        'Position', [220 400 150 40], 'FontSize', 11, ...
        'Callback', @(~,~) plotData(time, batteryCharge, ...
        'شحن البطارية (%)', 'الوقت (ساعة)', 'الشحن (%)', [0 110], 'b'));

    % زرار عرض حمل CPU
    uicontrol('Style', 'pushbutton', 'String', 'عرض حمل CPU', ...
        'Position', [390 400 150 40], 'FontSize', 11, ...
        'Callback', @(~,~) plotData(time, cpuLoad, ...
        'حمل وحدة المعالجة (%)', 'الوقت (ساعة)', 'CPU Load (%)', [0 100], 'r'));

    % شاشة لعرض القيم اللحظية
    dataText = uicontrol('Style', 'text', 'String', '', ...
        'Position', [100 200 400 150], 'FontSize', 12, ...
        'BackgroundColor', [0.9 0.9 0.9]);

    % زرار عرض القيم اللحظية
    uicontrol('Style', 'pushbutton', 'String', 'عرض القيم الحالية', ...
        'Position', [200 100 200 40], 'FontSize', 11, ...
        'Callback', @(~,~) showValues(dataText, time, lightLoad, batteryCharge, cpuLoad));

    % زرار حفظ البيانات
    uicontrol('Style', 'pushbutton', 'String', 'حفظ إلى Excel', ...
        'Position', [200 40 200 40], 'FontSize', 11, ...
        'Callback', @(~,~) saveToExcel(time, lightLoad, batteryCharge, cpuLoad));
end

function plotData(x, y, graphTitle, xLabel, yLabel, yLimits, color)
    figure('Name', graphTitle, 'NumberTitle', 'off', 'Color', [0.95 0.95 0.95]);
    plot(x, y, color, 'LineWidth', 2);
    title(graphTitle, 'FontSize', 14);
    xlabel(xLabel);
    ylabel(yLabel);
    ylim(yLimits);
    grid on;
end

function showValues(txtHandle, time, lightLoad, batteryCharge, cpuLoad)
    currentHour = randi([1 length(time)]);
    msg = sprintf(['الساعة الحالية: %d\n' ...
                   '🔆 حمل الإنارة: %.2f kW\n' ...
                   '🔋 شحن البطارية: %.1f %%\n' ...
                   '🧠 حمل المعالج: %.1f %%'], ...
                   time(currentHour), ...
                   lightLoad(currentHour), ...
                   batteryCharge(currentHour), ...
                   cpuLoad(currentHour));
    set(txtHandle, 'String', msg);
end

function saveToExcel(time, lightLoad, batteryCharge, cpuLoad)
    data = table(time', lightLoad', batteryCharge', cpuLoad', ...
        'VariableNames', {'Time_hr', 'LightLoad_kW', 'BatteryCharge_percent', 'CPULoad_percent'});
    filename = ['BMS_Data_' datestr(now,'dd_mm_yyyy_HH_MM_SS') '.xlsx'];
    writetable(data, filename);
    msgbox(['تم حفظ البيانات بنجاح في الملف: ' filename], 'تم الحفظ');
end
