function [names,status] = RunExamples(str,varargin)
% Invoke examples for all files in a directory or a function
%
%   [names,status] = RunExamples(fileOrDirectory, ...);
%
% Copyright ISETBIO Team, 2018
%
% See also
%   ExecuteExamplesInFunction, ExecuteExamplesInDirectory, PrintExamples

% Examples:
%{
  % Requires ISETBio on path.
  [names,status] = RunExamples('opticsGet.m','findflag',true,'printflag',true);
  [names,status] = RunExamples('opticsGet.m','findflag',true,'printflag',false);
  [names,status] = RunExamples('opticsGet.m','findflag',true,'printflag',false, ...
    'closefigs',false);
%}
%{
  % Requires ISETBio on path
  directory = fullfile(isetbioRootPath,'isettools','opticalimage');
  [names,status] = RunExamples(directory,'findflag',true,'printflag',false);
%}

%%
p = inputParser;
p.addRequired('str',@ischar);
p.addParameter('printflag',false,@islogical);
p.addParameter('findflag',true,@islogical);
p.addParameter('verbose',false,@islogical);
p.addParameter('closefigs',true,@islogical);

p.parse(str,varargin{:});
pFlag = p.Results.printflag;
fFlag = p.Results.findflag;
verbose = p.Results.verbose;

%%
if exist(str,'dir')
    [names,status] = ExecuteExamplesInDirectory(str);
elseif exist(str,'file')
    names  = str;
    status = ExecuteExamplesInFunction(str,'findfunction',fFlag,...
        'printexampletext',pFlag,...
        'verbose',verbose, ...
        'closefigs',p.Results.closefigs);
else
    error('No file or directory %s\n',str);
end

end

