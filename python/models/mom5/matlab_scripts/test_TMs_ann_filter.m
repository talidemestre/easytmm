%% load in
function []=test_TMs_ann_filter(base_path, matrix_path)

  gridFile=fullfile(base_path,'grid.mat');
  boxFile=fullfile(base_path,'boxes.mat');
  matrixFile=fullfile(matrix_path,'matrix_nocorrection_01.mat');

  load(gridFile,'x','y','z','deltaT')
  load(boxFile,'nb','volb','Xboxnom','ixBox','iyBox','izBox')
  load(matrixFile)

  %% do conservation tests

  nb=sum(nb);
  a=volb/sum(volb);
  u=ones(nb,1);
  % more on
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

  % %% Initial value problem
  % dt=7200; % time step to use for initial value problem
  % % dtMultiple=dt/deltaT;
  % % if dtMultiple~=1
  % %   Aimp=Aimp^dtMultiple;
  % % end  
  % Ae=speye(nb,nb)+dt*Aexp;
  % %
  % c0=zeros(nb,1);
  % c0(Xboxnom>-180 & Xboxnom<0)=1; % initial condition
  % c=c0;
  % for it=1:1000
  %   fprintf('%d\n',it)
  %   c=Aimp*(Ae*c);
  %     if mod(it,10)==0
  %       disp(max(c))
  %       if max(c) > 2
  %           break
  %       end
  %     end
  % end
  % % Check conservation  
  % test5 = a'*(c0-c);
  % mean(abs(test5))
  % Cg=matrixToGrid(c,[],boxFile,gridFile);
  % save timestep Cg
  % pcolor(Cg(:,:,20)'),shading flat,colorbar
