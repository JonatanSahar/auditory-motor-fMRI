function [file_averages, overall_average] = calculate_play_duration(folder_path)

% Get a list of all .mat files in the folder
file_list = dir(fullfile(folder_path, '*.mat'));

% Initialize variables
play_duration_sum = 0;
num_events = 0;
file_averages = zeros(length(file_list), 1);

% Loop through each file and calculate the average play duration
for i = 1:length(file_list)
    % Load the file and extract the event table
    data = load(fullfile(folder_path, file_list(i).name));
    if isfield(data, 'eventTable')
        event_table = data.eventTable;
    else
        continue;
    end

    % Calculate the average play duration for this file
    file_play_duration = mean(event_table.play_duration);
    file_averages(i) = file_play_duration;

    % Update the overall play duration sum and number of events
    play_duration_sum = play_duration_sum + sum(event_table.play_duration);
    num_events = num_events + length(event_table.play_duration);
end

% Calculate the overall average play duration
overall_average = play_duration_sum / num_events;
end
