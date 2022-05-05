function [res,err]=evalExternalCommand(cmd,maxtries,waittime,verbose)

% Function to evaluate an external command from MATLAB
% USAGE: [res,err]=evalExternalCommand(cmd,maxtries,waittime,verbose)
% Executes the command given by string cmd and returns the output as string res
% INPUTS:
%   cmd: string containing command to execute (NO leading '!')
%   maxtries: optional integer specifying how many times to try command upon failure
%   waittime: optional scalar specifying how many seconds to wait between successive tries.
%             Default is 5 seconds.
%   verbose: optional integer to specify whether to display error message in 
%            case of failure (1=yes). Default is 0.
% OUTPUTS:
%   res: result string
%   err: error code from evaluation of command

% Samar Khatiwala (spk@ldeo.columbia.edu)
  
if nargin<2
  maxtries=0;
end
if nargin<3
  waittime=5;
end
if nargin<4
  verbose=0;
end

iter=0;
err=1;
while err>0 & iter<=maxtries
  [err,res]=system(cmd);
  if maxtries>0
    if err>0
      disp(['Error evaluating external command. Try: ' int2str(iter+1)])
      if verbose
        disp(res)
      end
      pause(waittime)
    end
  end
  iter=iter+1;
end
if err>0
  error(res)
end
