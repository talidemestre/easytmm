function evalCommandsInDirectory(cmds,directory)

% Function to evaluate one or more MATLAB commands in a specified directory.
% USAGE: evalCommandsInDirectory(cmds,[directory])
% Executes the command(s) given by cmds, where cmds is a single string or a 
%        cell whose elements are strings.
% INPUTS:
%   cmds: string or cell of strings containing command(s) to execute.
%   directory: optional path of directory in which to execute command(s). If not 
%   specified, each command is executed in the current directory.

% Samar Khatiwala (spk@ldeo.columbia.edu)
  
if nargin<2
  directory=pwd;
end

currDir=pwd;

cd(directory) % change to directory in which commands are to be executed

if isstr(cmds)
  runCmd(cmds);
else
  if iscell(cmds)
    for ic=1:length(cmds)
	  if isstr(cmds{ic})
		runCmd(cmds{ic});
	  else
		error('ERROR: each element of cell cmds must be a string!')
	  end
    end    
  else
    error('ERROR: cmds must be a string o cell of strings!')
  end          
end  

cd(currDir) % switch back to original directory

end

function runCmd(cmd)
  eval(cmd);
end
