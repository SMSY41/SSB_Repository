% ============================================================
% AUTOMATED SOH DATASET GENERATION
% Model: SSB_SOH
% ============================================================

clear; clc;

model_name = 'SSB_SOH';

if ~bdIsLoaded(model_name)
    load_system(model_name);
    fprintf('✅ Loaded model: %s\n', model_name);
end

% Degradation parameters
cycles     = 0:50:950;
soh_arr    = 1 - 0.001 * cycles;
c_max_arr  = 23300 * soh_arr;
c_min_arr  = 11650 * soh_arr;
c_init_arr = 1.5 * c_min_arr;
R_arr      = 150 * (1 + 0.002 * cycles);

% Block paths
blocks = {
    [model_name '/c_max_current'], ...
    [model_name '/Constant_cs_min'], ...
    [model_name '/Initial_Cathode_Concentration'], ...
    [model_name '/Integrator_Avg_Conc'], ...
    [model_name '/Gain_Ohmic_Resistance'], ...
    [model_name '/Current_Scale']          % ← ADD THIS
};

% Verify
fprintf('\n=== Verifying block paths ===\n');
for i = 1:length(blocks)
    try
        get_param(blocks{i}, 'Handle');
        fprintf('✅ Found: %s\n', blocks{i});
    catch
        error('❌ NOT FOUND: %s', blocks{i});
    end
end

% Run simulations
all_data = [];

for i = 1:length(cycles)
    fprintf('\n========================================\n');
    fprintf('RUN %d/%d | Cycle=%d | SOH=%.3f\n', i, length(cycles), cycles(i), soh_arr(i));
    fprintf('  c_max=%.0f | c_min=%.0f | c_init=%.0f | R=%.1f\n', ...
            c_max_arr(i), c_min_arr(i), c_init_arr(i), R_arr(i));
    fprintf('========================================\n');

    set_param(blocks{1}, 'Value', num2str(c_max_arr(i)));
    set_param(blocks{2}, 'Value', num2str(c_min_arr(i)));
    set_param(blocks{3}, 'Value', num2str(c_init_arr(i)));
    set_param(blocks{4}, 'InitialCondition', num2str(c_init_arr(i)));
    set_param(blocks{5}, 'Gain', num2str(R_arr(i)));
    set_param(blocks{6}, 'Gain', num2str(soh_arr(i)));   % ← NEW
    try
        sim_out = sim(model_name, 'StopTime', '1000');
    catch ME
        fprintf('❌ Sim error: %s\n', ME.message);
        continue;
    end

    % Extract data (robust)
    try
        t    = get_data(sim_out.tout);
        curr = get_data(sim_out.log_Current);
        volt = get_data(sim_out.log_Vcell);
        soc  = get_data(sim_out.log_SOC);
        ocv  = get_data(sim_out.log_Eeq);
        cs   = get_data(sim_out.log_c_surf);
    catch
        t    = get_data(tout);
        curr = get_data(log_Current);
        volt = get_data(log_Vcell);
        soc  = get_data(log_SOC);
        ocv  = get_data(log_Eeq);
        cs   = get_data(log_c_surf);
    end

    n = min([length(t), length(curr), length(volt), ...
             length(soc), length(ocv), length(cs)]);

    fprintf('  Lengths: t=%d curr=%d volt=%d soc=%d ocv=%d cs=%d → using %d\n', ...
        length(t), length(curr), length(volt), length(soc), length(ocv), length(cs), n);

    T = table(t(1:n), curr(1:n), volt(1:n), soc(1:n), ocv(1:n), cs(1:n), ...
        'VariableNames', {'Time_s','Current_A','Voltage_V','SOC','OCV_V','c_surf'});
    T.SOH    = soh_arr(i)  * ones(height(T), 1);
    T.Cycle  = cycles(i)   * ones(height(T), 1);
    T.Run_ID = i           * ones(height(T), 1);

    all_data = [all_data; T];

    fname = sprintf('SSB_soh_run%02d.csv', i);
    writetable(T, fname);
    fprintf('✅ Run %d: %d rows saved\n', i, height(T));
end

% Save master
writetable(all_data, 'SSB_SOH_MASTER.csv');
fprintf('\n========================================\n');
fprintf('🎉 MASTER DATASET CREATED\n');
fprintf('  Rows: %d\n', height(all_data));
fprintf('  Runs: %d\n', max(all_data.Run_ID));
fprintf('  SOH:  %.3f to %.3f\n', min(all_data.SOH), max(all_data.SOH));
fprintf('========================================\n');

% ============================================================
% HELPER (must be at END of script)
% ============================================================
function d = get_data(x)
    if isa(x, 'timeseries')
        d = x.Data(:);
    elseif isstruct(x) && isfield(x, 'Data')
        d = x.Data(:);
    elseif isstruct(x) && isfield(x, 'signals')
        d = x.signals.values(:);
    else
        d = x(:);
    end
end