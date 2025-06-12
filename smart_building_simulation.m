function smart_building_simulation()
    % Create GUI Window
    fig = uifigure('Name', 'Smart Building Control', 'Position', [100, 100, 900, 600]);
    
    % Axes for Graphs
    ax1 = uiaxes(fig, 'Position', [50, 400, 250, 150]);
    title(ax1, 'HVAC Power Consumption'); xlabel(ax1, 'Time'); ylabel(ax1, 'Power (kW)');
    
    ax2 = uiaxes(fig, 'Position', [320, 400, 250, 150]);
    title(ax2, 'Lighting Status'); xlabel(ax2, 'Time'); ylabel(ax2, 'State (ON/OFF)');
    
    ax3 = uiaxes(fig, 'Position', [50, 220, 250, 150]);
    title(ax3, 'Microgrid Power Flow'); xlabel(ax3, 'Time'); ylabel(ax3, 'Power (kW)');
    
    ax4 = uiaxes(fig, 'Position', [320, 220, 250, 150]);
    title(ax4, 'Solar Power Output'); xlabel(ax4, 'Time'); ylabel(ax4, 'Power (kW)');
    
    ax5 = uiaxes(fig, 'Position', [590, 400, 250, 150]);
    title(ax5, 'Wind Power Output'); xlabel(ax5, 'Time'); ylabel(ax5, 'Power (kW)');
    
    ax6 = uiaxes(fig, 'Position', [590, 220, 250, 150]);
    title(ax6, 'Battery Storage Level'); xlabel(ax6, 'Time'); ylabel(ax6, 'Level (%)');
    
    % Control Buttons
    startButton = uibutton(fig, 'push', 'Text', 'Start Simulation', 'Position', [50, 50, 150, 40], 'ButtonPushedFcn', @startSimulation);
    stopButton = uibutton(fig, 'push', 'Text', 'Stop Simulation', 'Position', [220, 50, 150, 40], 'ButtonPushedFcn', @stopSimulation);
    
    % Variables
    running = false;
    
    function startSimulation(~, ~)
        running = true;
        time = 1:100;
        hvac_power = zeros(1, 100);
        lighting_status = zeros(1, 100);
        microgrid_power = zeros(1, 100);
        solar_power = zeros(1, 100);
        wind_power = zeros(1, 100);
        battery_level = zeros(1, 100);
        
        for t = 2:100
            if ~running
                break;
            end
            
            hvac_power(t) = 5 * (mod(t, 10) == 0);
            lighting_status(t) = mod(t, 20) < 10;
            microgrid_power(t) = 50 + 10 * sin(t/10);
            solar_power(t) = 50 * (t >= 2);
            wind_power(t) = 80 * (1 - exp(-t/10));
            battery_level(t) = min(100, battery_level(t-1) + 1);
            
            % Update Graphs
            plot(ax1, time(1:t), hvac_power(1:t), 'r', 'LineWidth', 2);
            plot(ax2, time(1:t), lighting_status(1:t), 'b', 'LineWidth', 2);
            plot(ax3, time(1:t), microgrid_power(1:t), 'g', 'LineWidth', 2);
            plot(ax4, time(1:t), solar_power(1:t), 'r', 'LineWidth', 2);
            plot(ax5, time(1:t), wind_power(1:t), 'b', 'LineWidth', 2);
            plot(ax6, time(1:t), battery_level(1:t), 'g', 'LineWidth', 2);
            
            pause(0.1);
        end
    end
    
    function stopSimulation(~, ~)
        running = false;
    end
end
