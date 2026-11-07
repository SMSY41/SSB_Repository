% ============================================================
% SSB Export Script — Full Resolution
% Change run_number before each export
% ============================================================

run_number = 15;   % <-- CHANGE: 1, 2, 3, ..., 15

% Handle both 'log_X' and 'out.log_X' formats
try
    current_data = out.log_Current;
    voltage_data = out.log_Vcell;
    soc_data     = out.log_SOC;
    ocv_data     = out.log_Eeq;
    csurf_data   = out.log_c_surf;
catch
    current_data = log_Current;
    voltage_data = log_Vcell;
    soc_data     = log_SOC;
    ocv_data     = log_Eeq;
    csurf_data   = log_c_surf;
end

time_data = tout;

% Match lengths
min_len = min([length(time_data), length(current_data), ...
               length(voltage_data), length(soc_data), ...
               length(ocv_data), length(csurf_data)]);

output_table = table( ...
    time_data(1:min_len), current_data(1:min_len), ...
    voltage_data(1:min_len), soc_data(1:min_len), ...
    ocv_data(1:min_len), csurf_data(1:min_len), ...
    'VariableNames', {'Time_s','Current_A','Voltage_V', ...
                      'SOC','OCV_V','c_surf'});

filename = sprintf('SSB_run%02d.csv', run_number);
writetable(output_table, filename);

fprintf('✅ Saved %s: %d rows, SOC %.4f to %.4f\n', ...
    filename, height(output_table), ...
    min(output_table.SOC), max(output_table.SOC));