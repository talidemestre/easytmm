dt=43200; % time step to use for initial value problem

%base_path=fileparts(fileparts(pwd));
%matrix_path=fileparts(pwd);
matrix_path=pwd;
base_path=pwd;

gridFile=fullfile(base_path,'grid');
boxFile=fullfile(matrix_path,'boxes');
% matrixFile=fullfile(matrix_path,'TMs','matrix_nocorrection_annualmean');
matrixFile=fullfile(matrix_path,'TMs','matrix_nocorrection_07');

load(gridFile,'x','y','z','deltaT')
load(boxFile,'nb','volb','Xboxnom')
load(matrixFile)

nb=sum(nb);
a=volb/sum(volb);
u=ones(nb,1);
more on
% Check conservation by executing the following lines. All of them 
% should return a very small number close to roundoff (O(10^-14))
test1=Aexp*u;
test2=a'*Aexp;
test3=a'*Aimp-a';
test4=Aimp*u-1;

mean(abs(test1))
mean(abs(test2))
mean(abs(test3))
mean(abs(test4))

% Initial value problem
dtMultiple=dt/deltaT;
if dtMultiple~=1
  Aimp=Aimp^dtMultiple;
end  
Ae=speye(nb,nb)+dt*Aexp;
%
c0=zeros(nb,1);
c0(Xboxnom>180 & Xboxnom<360)=1; % initial condition
c=c0;
for it=1:1000
  c=Aimp*(Ae*c);
end
% Check conservation  
% a'*(c0-c)
Cg=matrixToGrid(c,[],boxFile,gridFile);
pcolor(Cg(:,:,1)'),shading flat,colorbar
