% Aditya Dua
% November 12, 2016
% Takes in a string line score and returns an array with runs scored per
% inning. Also returns whether the bottom of the last inning was played
function [out,bottom] = parseLineScore(in)

bottom = true;
if (~isempty(strfind(in,'x'))),
    % Record that the bottom of the last inning was not played and replace
    % the 'x' with a '0' for ease of analysis
    bottom = false;
    in = strrep(in,'x','0');
end

% Need special handling for cases where >9 runs were scored in an inning
if (isempty(strfind(in,'('))),
    out = in - '0';
else % at least one inning has >9 runs
    out = [];
    count = 1;
    flag = false;
    temp = [];
    for k = 1:length(in),
        if (flag),
            temp = [temp in(k)];
        end
        if (in(k)~='(' && in(k)~=')' && ~flag),
            out(count) = in(k) - '0';
            count = count+1;
        elseif (in(k)=='('),
            flag = true;
        elseif (in(k)==')'),
            flag = false;
            out(count) = str2double(temp(1:end-1));
            count = count+1;
            temp = [];
        end
    end
end
    