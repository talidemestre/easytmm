dt=14400; % time step to use for initial value problem
% addpath('/scratch/v45/dkh157/matlab/TMM');
addpath('/Users/davidhutchinson/Dropbox/UNSW/data/tmm_matlab/TMM');

%base_path=fileparts(fileparts(pwd));
%matrix_path=fileparts(pwd);
matrix_path=pwd;
base_path=pwd;

gridFile=fullfile(base_path,'grid');
boxFile=fullfile(matrix_path,'boxes');
matrixFile=fullfile(matrix_path,'TMs','matrix_nocorrection_annualmean');
% matrixFile=fullfile(matrix_path,'TMs','matrix_corrected_implicit');
% matrixFile=fullfile(matrix_path,'TMs','matrix_nocorrection_07');

load(gridFile,'x','y','z','deltaT')
load(boxFile,'nb','volb','Xboxnom')
load(matrixFile)

nb=sum(nb);
a=volb/sum(volb);
u=ones(nb,1);
% more on
% Check conservation by executing the following lines. All of them 
% should return a very small number close to roundoff (O(10^-14))
test1=Aexpms*u;
test2=a'*Aexpms;
test3=a'*Aimpms-a';
test4=Aimpms*u-1;

mean(abs(test1))
mean(abs(test2))
mean(abs(test3))
mean(abs(test4))

% Initial value problem
dtMultiple=dt/deltaT;
if dtMultiple~=1
  Aimpms=Aimpms^dtMultiple;
end  
Ae=speye(nb,nb)+dt*Aexpms;
%
c0=zeros(nb,1);
c0(Xboxnom>-180 & Xboxnom<0)=1; % initial condition
c=c0;
for it=1:500
  fprintf('%d\n',it)
  c=Aimpms*(Ae*c);
    disp(max(c))
    if max(c) > 2
      break
    end
end
% Check conservation  
test5 = a'*(c0-c);
mean(abs(test5))
Cg=matrixToGrid(c,[],boxFile,gridFile);
save timestep Cg
pcolor(Cg(:,:,20)'),shading flat,colorbar
