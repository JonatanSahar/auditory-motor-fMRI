function result = repeatedPairsExist(A, N)
    % Get the number of rows and columns in A
    [nRows, nCols] = size(A);
    result = false;

    % Iterate over each column in A
    for j = 1:nCols-N+1
        % Initialize the count of consecutive repeats to 1
        count = 1;
        for i = j+1:j+N
            if isequal(A(:,j), A(:,i))
                % Increment the count if the current element is the same as the previous element
                count = count + 1;
            else
                break
            end

            if count >= N
                A(:, j:j+N-1)
                result = true;
                return;
            end
        end
    end
end
