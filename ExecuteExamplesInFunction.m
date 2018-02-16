function status = ExecuteExamplesInFunction(theFunction,varargin)
% Open file, read it, parse execute any examples
%
% Syntax:
%     status = ExecuteExamplesInFunction(theFunction)
%
% Description:
%    Examples are enclosed in block quotes, following
%    a comment line that starts exactly with "% Examples:".
%    By enforcing the exact form, we maxmimize that we find only real
%    examples.
%
%    Once there is a line that starts exactly with "% Examples:", any
%    subsequent text in block quotes is treated as example code, until an
%    ending block quote "%}" is followed by a blank line.  This means that
%    the examples should follow contiguously after the examples line, and
%    prevents us from running actual block comments as examples.
%
%    There is a check that prevents this function from running its own
%    examples, to prevent an infinite recurse. Thus, if run on itself, this
%    function reports a status of 0, even though there are examples in the
%    source that may be run manually.
%
% Inputs:
%    theFunction - String.  Name of the function file (with the .m at the
%                  end).
%
% Outputs:
%    status -      What happened?
%                    -1: Found examples but at least one crashed, or other
%                        error such as unmatched block comment open and
%                        close.
%                     0: No examples found
%                     N: With N > 0.  Number of examples run successfully,
%                        with none failing.
%
% Optional key/value pairs:
%    'verbose' -      Boolean. Be verbose? Default false
%
% Examples are provided in the code.
%
% See also:
%    ExecuteTextInScript
%

% History
%   01/16/18 dhb Wasting time on a train.

% Examples:
%{
    % Should execute both examples successfully
    ExecuteExamplesInFunction('ExecuteTextInScript.m')
%}
%{
    % Should report that there are no examples in itself, to avoid
    % recursion
    ExecuteExamplesInFunction('ExecuteExamplesInFunction.m')
%}

% Parse input
p = inputParser;
p.addParameter('verbose',false,@islogical);
p.parse(varargin{:});

% Open file
theFileH = fopen(theFunction,'r');
theText = string(fread(theFileH,'uint8=>char')');
fclose(theFileH);

% Say hello
if (p.Results.verbose)
    fprintf('Looking for and running examples in %s\n',theFunction);
end

if (strcmp(theFunction,[mfilename '.m']))
    if (p.Results.verbose)
        fprintf('Not running on self to prevent recursion');
    end
    status = 0;
    return;
end

% Look for a comment line with the text " Examples:"
ind = strfind(theText{1},'% Examples:');
if (isempty(ind))
    if (p.Results.verbose)
        fprintf('\tNo comment line starting with "%% Examples:" in file\n');
    end
    status = 0;
    return;
end

% Look for examples 
% nExamplesExecuted = 0;
candidateText = theText{1}(ind(1)+9:end);
startIndices = strfind(candidateText,'%{');
endIndices = strfind(candidateText,'%}');
if (isempty(startIndices))
    if (p.Results.verbose)
        fprintf('\tNo block comment starts in file\n');
    end
    status = 0;
    return;
end
if (length(startIndices) ~= length(endIndices))
    if (p.Results.verbose)
        fprintf('\tNumber of block comment ends does not match number of starts.\n');
    end
    status = -1;
    return;
end
nExamplesOK = 0;
for bb = 1:length(startIndices)
    % Get this example and run.  If it throws an error, return with
    % status -1. Otherwise, increment number of successful examples
    % counter, and status.
    exampleText = candidateText(startIndices(bb)+4:endIndices(bb)-1);
    try
        eval(exampleText);
        if (p.Results.verbose)
            fprintf('\tExample %d success\n',bb);
        end
        nExamplesOK = nExamplesOK+1;
        status = nExamplesOK;
    catch
        status = -1;
        if (p.Results.verbose)
            fprintf('\tExample %d failed\n',bb);
        end
        return;
    end
    
    % If this is not the last block comment, check whether the next one is
    % contiguous. If not, we're done with examples and break out and go
    % home.
    if (bb < length(startIndices))
        if (endIndices(bb)+3 <= length(candidateText))
            if (candidateText(endIndices(bb)+3) ~= '%')
                break;
            end
        end
    end
end
        
    

