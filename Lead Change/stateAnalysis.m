% Aditya Dua
% November 12, 2016
% Takes in visiting and home line scores and analyzes number of state
% changes and number of lead changes
% Whether the bottom of the last inning was played or not is also provided
% as an input
% States: Home team leads, Visiting team leads, Tie game
function [numStateChanges,numLeadChanges,numInnings,...
          numStateChangesByInning,numLeadChangesByInning,status] = stateAnalysis(hLine,vLine)

% State definitions
% 0: tie, 1: visitor lead, 2: home lead
state = 0; % initial state is tie
vRuns = 0; % Visitors have 0 runs at start of game 
hRuns = 0; % Home team has 0 runs at start of game

status = true;

% Sanity
if (length(vLine)~=length(hLine)),
    error([mfilename ': Lengths of home line and visitor line don"t match!']);
end

stateVec = state;
for k = 1:length(hLine),
    % End of top half
    vRuns = vRuns + vLine(k);
    if (vRuns > hRuns),
        state = 1;
    elseif (vRuns < hRuns),
        state = 2;
    else
        state = 0;
    end
    stateVec = horzcat(stateVec,state);
    
    % End of bottom half
    hRuns = hRuns + hLine(k);
    if (vRuns > hRuns),
        state = 1;
    elseif (vRuns < hRuns),
        state = 2;
    else
        state = 0;
    end
    stateVec = horzcat(stateVec,state);
end

% Analyze state vector to determine number of lead changes
numStateChanges   = length(find(diff(stateVec)));
collapsedStateVec = stateVec;
index             = find(~stateVec);
collapsedStateVec(index) = [];
numLeadChanges    = length(find(diff(collapsedStateVec)));

% Determine number of innings in game
numInnings = length(vLine);

% Inning by inning analysis
if (status),
    numStateChangesByInning = zeros(1,numInnings);
    numLeadChangesByInning  = zeros(1,numInnings);

    for nInning = 1:numInnings,
        stateVecInning = stateVec(1:2*nInning+1);
        numStateChangesByInning(nInning) = length(find(diff(stateVecInning)));
        collapsedStateVecInning          = stateVecInning;
        index                            = find(~stateVecInning);
        collapsedStateVecInning(index)   = [];
        numLeadChangesByInning(nInning)  = length(find(diff(collapsedStateVecInning)));
    end
else
    numStateChanges = 0;
    numLeadChanges  = 0;
    numInnings      = 0;
    numStateChangesByInning = [];
    numLeadChangesByInning  = [];
end

% [length(stateVec) length(collapsedStateVec)]
% disp(stateVec);
% disp('=====');
% disp(collapsedStateVec);
