function [A1,A2] = load_transport(Ir,base,flag,Itend,tol,matType)

numTend=length(Itend)
if flag==10 & numTend>1
  error(['ERROR: numTend=' num2str(numTend) '. Cannot return more than one tendency matrix with flag=10'])
end
  
if nargin<5
  tol=0;
end
if isempty(tol)
  tol=0;
end
tol
if flag==0
  A1=0;
  for j=1:length(Ir)
     i=Ir(j)
     load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)])
     A(isnan(A))=0;
     A1=A1+A;
  end
elseif flag==1
  load([base '/Data/boxes'])
  for im=1:numTend, 
     A1{im}=sparse(nb,nb); 
  end
  for j=1:length(Ir)
     i=Ir(j)
     load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)])
     load([base '/Runs/' 'Job' int2str(i) '/columns'])
     for im=1:numTend
        A1{im}(:,Col)=A{Itend(im)};
     end
  end
elseif flag==2
  load([base '/Data/boxes'])
  for im=1:numTend,
     A1{im}=sparse(nb,nb);
  end
  for j=1:length(Ir)
     i=Ir(j)
     load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)])
     for im=1:numTend,
        A1{im} = A1{im} + A{Itend(im)};
     end
  end  
elseif flag==3 % base is the full path. All transport files in same place
  load([base '/boxes']) 
  for im=1:numTend,
     A1{im}=sparse(nb,nb);
  end
  for j=1:length(Ir)
     i=Ir(j)
     load([base '/transport' int2str(i)])
     for im=1:numTend,
        A1{im} = A1{im} + A{Itend(im)};
     end
  end 
elseif flag==4  % same as 2, but average in time
  load([base '/Data/boxes'])
  A1=sparse(nb,nb);
  for j=1:length(Ir)
     i=Ir(j)
     load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)])
     A=cellmean(A(Itend));
     A1 = A1 + A;
  end
elseif flag==5
  load([base '/Data/boxes'],'nb')
  for im=1:numTend,
     A1{im}=sparse(nb,nb);
     A2{im}=sparse(nb,nb);
  end
  for j=1:length(Ir)
     i=Ir(j)
     load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)])
     for im=1:numTend,
        if tol>0
          [ii,jj,aa]=find(Aexp{Itend(im)});
          k=find(abs(aa)>=tol);
          ii=ii(k); jj=jj(k); aa=aa(k);
          A1{im} = A1{im} + sparse(ii,jj,aa,nb,nb);
          [ii,jj,aa]=find(Aimp{Itend(im)});
          k=find(abs(aa)>=tol);
          ii=ii(k); jj=jj(k); aa=aa(k);
          A2{im} = A2{im} + sparse(ii,jj,aa,nb,nb);
        else  
          A1{im} = A1{im} + Aexp{Itend(im)};
          A2{im} = A2{im} + Aimp{Itend(im)};
        end        
     end
  end
elseif flag==6  % same as 5, but average in time
  load([base '/Data/boxes'],'nb')
  A1=sparse(nb,nb);
  A2=sparse(nb,nb);
  for j=1:length(Ir)
     i=Ir(j);
     load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)])
     A1 = A1 + cellmean(Aexp(Itend));
     A2 = A2 + cellmean(Aimp(Itend));
  end 
elseif flag==7  % same as 5, but load explicit or implicit matrix
  if matType==1
    disp('Loading explicit matrix')
  elseif matType==2
    disp('Loading implicit matrix')
  else
    disp('Unknown matType')
  end
  load([base '/Data/boxes'],'nb')
  for im=1:numTend,
     A1{im}=sparse(nb,nb);
  end
  for j=1:length(Ir)
     i=Ir(j)
     if matType==1
       load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)],'Aexp')
       for im=1:numTend,
          if tol>0
            [ii,jj,aa]=find(Aexp{Itend(im)});
            k=find(abs(aa)>=tol);
            ii=ii(k); jj=jj(k); aa=aa(k);
            A1{im} = A1{im} + sparse(ii,jj,aa,nb,nb);
          else
            A1{im} = A1{im} + Aexp{Itend(im)};
          end
       end
     elseif matType==2
       load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)],'Aimp')
       for im=1:numTend,
          if tol>0
            [ii,jj,aa]=find(Aimp{Itend(im)});
            k=find(abs(aa)>=tol);
            ii=ii(k); jj=jj(k); aa=aa(k);
            A1{im} = A1{im} + sparse(ii,jj,aa,nb,nb);
          else
            A1{im} = A1{im} + Aimp{Itend(im)};
          end
       end
     else
       error('Unknown matType') 
     end
  end
elseif flag==8  % same as 7, but for more compact matrix format
  disp('Note: tol option is not supported with this flag')
  if matType==1
    disp('Loading explicit matrix')
  elseif matType==2
    disp('Loading implicit matrix')
  else
    disp('Unknown matType')
  end
  load([base '/Data/boxes'],'nb')
  for im=1:numTend,
     A1{im}=sparse(nb,nb);
  end
  for j=1:length(Ir)
     i=Ir(j)
     transFile=fullfile(base,'Runs',['Job' int2str(i)],['transport' int2str(i)])
     if matType==1
       load(transFile,'ia_exp','ja_exp') % for each job, ia,ja are (should be!) the same for all times
       for im=1:numTend,
          varname=['aa_exp_' sprintf('%01.4d',Itend(im))];
          load(transFile,varname)
          eval(['A1{im} = A1{im} + sparse(ia_exp,ja_exp,' varname ',nb,nb);'])
       end
     elseif matType==2
       load(transFile,'ia_imp','ja_imp') % for each job, ia,ja are (should be!) the same for all times
       for im=1:numTend,
          varname=['aa_imp_' sprintf('%01.4d',Itend(im))];
          load(transFile,varname)
          eval(['A1{im} = A1{im} + sparse(ia_imp,ja_imp,' varname ',nb,nb);'])
       end     
     else
       error('Unknown matType') 
     end
  end  
elseif flag==9  % same as 7 (load explicit or implicit matrix), but average in time
  if matType==1
    disp('Loading explicit matrix')
  elseif matType==2
    disp('Loading implicit matrix')
  else
    disp('Unknown matType')
  end
  load([base '/Data/boxes'],'nb')
  A1=sparse(nb,nb);
  for j=1:length(Ir)
     i=Ir(j)
     if matType==1
       load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)],'Aexp')
       if tol>0
         for im=1:numTend
            [ii,jj,aa]=find(Aexp{Itend(im)});
            k=find(abs(aa)>=tol);
            ii=ii(k); jj=jj(k); aa=aa(k);
            Aexp{Itend(im)} = sparse(ii,jj,aa,nb,nb);
         end
       end
       A1 = A1 + cellmean(Aexp(Itend));
     elseif matType==2
       load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)],'Aimp')
       if tol>0
         for im=1:numTend
            [ii,jj,aa]=find(Aimp{Itend(im)});
            k=find(abs(aa)>=tol);
            ii=ii(k); jj=jj(k); aa=aa(k);
            Aimp{Itend(im)} = sparse(ii,jj,aa,nb,nb);         
         end
       end
       A1 = A1 + cellmean(Aimp(Itend));       
     else
       error('Unknown matType') 
     end
  end  
elseif flag==10  % same as 7, but only loads matrices from a single averaging period. 
                 % Result is returned as a matrix instead of a cell array.
  if matType==1
    disp('Loading explicit matrix')
  elseif matType==2
    disp('Loading implicit matrix')
  else
    disp('Unknown matType')
  end
  load([base '/Data/boxes'],'nb')
  A1=sparse(nb,nb);
  for j=1:length(Ir)
     i=Ir(j)
     if matType==1
       load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)],'Aexp')
	   if tol>0
		 [ii,jj,aa]=find(Aexp{Itend});
		 k=find(abs(aa)>=tol);
		 ii=ii(k); jj=jj(k); aa=aa(k);
		 A1 = A1 + sparse(ii,jj,aa,nb,nb);
	   else
		 A1 = A1 + Aexp{Itend};
	   end
     elseif matType==2
       load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)],'Aimp')
	   if tol>0
		 [ii,jj,aa]=find(Aimp{Itend});
		 k=find(abs(aa)>=tol);
		 ii=ii(k); jj=jj(k); aa=aa(k);
		 A1 = A1 + sparse(ii,jj,aa,nb,nb);
	   else
		 A1 = A1 + Aimp{Itend};
	   end
     else
       error('Unknown matType') 
     end
  end  
else
  error('Unknown flag')
end
 

