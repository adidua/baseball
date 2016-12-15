%% Analysis of lead change
% Aditya Dua
% November 12, 2016
clearvars;
%% Inputs
inpFolder = '.\GameLogs\';
startYear = 1970;
endYear   = 2015;
%% Parse data and strore in struct
s     = [];
count = 0;
t     = tic;

% Loop
for year = startYear:endYear,
    disp(['Processing year: ' num2str(year)]);
    
    % Load data
    fileName = [inpFolder 'GL' num2str(year) '.TXT'];
    a = importdata(fileName);
    disp(['Loaded data for ' num2str(length(a)) ' games']);
    
    % Loop over games
    for k = 1:length(a),
        b = strsplit(char(a(k,:)),'"','CollapseDelimiters',false);
        if (~isempty(regexp(char(b(26)),'^[\d(][\d()]*[\dx)]$','once')) && ...
            ~isempty(regexp(char(b(28)),'^[\d(][\d()]*[\dx)]$','once'))),
            % Increment counter
            count = count+1;
            
            % Parse and store
            s(count).date       = strrep(char(b(2)),num2str(year),'');
            s(count).year       = year;
            s(count).vTeam      = char(b(8));
            s(count).vLeague    = char(b(10));
            s(count).hTeam      = char(b(12));
            s(count).hLeague    = char(b(14));
            temp = strsplit(char(b(15)),',');
            s(count).vScore     = str2double(temp(3));
            s(count).hScore     = str2double(temp(4));
            s(count).outs       = str2double(temp(5));
            s(count).vLine      = char(b(26));
            s(count).hLine      = char(b(28));            
        else
            warning(['Ignoring game # ' num2str(k) ' for year ' num2str(year) ' due to unexpected data format!']);
        end
    end % game
end % year
disp(['Parsing took ' num2str(toc(t)) ' seconds.']);

% Discard extra entries
s(count+1:end) = [];
%% Compute state and lead changes and append to structure
for n = 1:length(s),
    [hLine,bottom] = parseLineScore(s(n).hLine);
    [vLine,~]      = parseLineScore(s(n).vLine);
    [numStateChanges,numLeadChanges,numInnings,...
     numStateChangesByInning,numLeadChangesByInning,status] = stateAnalysis(hLine,vLine);
    s(n).status                  = status;
    if (status),
        s(n).numStateChanges         = numStateChanges;
        s(n).numLeadChanges          = numLeadChanges;
        s(n).numInnings              = numInnings;
        s(n).bottom                  = bottom;
        s(n).numStateChangesByInning = numStateChangesByInning(end)-numStateChangesByInning; %diff([0 numStateChangesByInning]);
        s(n).numLeadChangesByInning  = numLeadChangesByInning(end)-numLeadChangesByInning;%diff([0 numLeadChangesByInning]);
    else
        disp(['For n = ' num2str(n) ' status flag is false']);
    end
    % Sanity
    if (any(s(n).numStateChangesByInning<0) || any(s(n).numLeadChangesByInning<0)),
        warning(['For n = ' num2str(n) ', the per inning data looks inconsisent']);
    end
end
%% Split data by team (2000-2015)
Q = containers.Map;
for n = 2016,%2000:2015,
    idx = find([s.year]==n);
    y = s(idx);
    for k = 1:length(y),
        hTeam = y(k).hTeam;
        vTeam = y(k).vTeam;
        if (isKey(Q,hTeam)),
            Q(hTeam) = horzcat(Q(hTeam),y(k).numLeadChanges);
        else
            Q(hTeam) = y(k).numLeadChanges;
        end
        if (isKey(Q,vTeam)),
            Q(vTeam) = horzcat(Q(vTeam),y(k).numLeadChanges);
        else
            Q(vTeam) = y(k).numLeadChanges;
        end
    end
end
%% Process team split data
% Merge FLO with MIA, merge MON with WAS
Q('MIA') = horzcat(Q('MIA'),Q('FLO'));
remove(Q,'FLO');
Q('WAS') = horzcat(Q('WAS'),Q('MON'));
remove(Q,'MON');
teamEF = zeros(1,length(Q.keys));
keys   = Q.keys;
for n = 1:length(teamEF),
    teamEF(n) = mean(Q(char(keys(n))));
end


        