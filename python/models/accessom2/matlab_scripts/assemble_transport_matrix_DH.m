function [A1,A2] = assemble_transport_matrix_DH(Ir,base,flag,Itend,tol,matType,maxNumTend)

numTend=length(Itend)
if (flag==10 | flag==12) & numTend>1
  error(['ERROR: numTend=' num2str(numTend) '. Cannot return more than one matrix with flag=10 or 12'])
end

if (flag==11 | flag==12) & nargin<7
  error(['ERROR: must specify maximum number of time slices with the maxNumTend option!'])
end

if nargin<5
  tol=0;
end
if isempty(tol)
  tol=0;
end
tol

if flag>0
  load('boxes','nb')
  nb=sum(nb);
end

if flag==0
  A1=0;
  for j=1:length(Ir)
     i=Ir(j)
     load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)])
     A(isnan(A))=0;
     A1=A1+A;
  end
elseif flag==1
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
  A1=sparse(nb,nb);
  for j=1:length(Ir)
     i=Ir(j)
     load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)])
     A=cellmean(A(Itend));
     A1 = A1 + A;
  end
elseif flag==5
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
elseif flag==9  % same as 7 (load matrices of type matType), but average in time
  if matType==1
    disp('Loading explicit matrix')
  elseif matType==2
    disp('Loading implicit matrix')
  elseif matType==3
    disp('Loading advection matrix')
  elseif matType==4
    disp('Loading horizontal diffusion matrix')    
  else
    disp('Unknown matType')
  end
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
     elseif matType==3
       load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)],'Aadvec')
       if tol>0
         for im=1:numTend
            [ii,jj,aa]=find(Aadvec{Itend(im)});
            k=find(abs(aa)>=tol);
            ii=ii(k); jj=jj(k); aa=aa(k);
            Aadvec{Itend(im)} = sparse(ii,jj,aa,nb,nb);
         end
       end
       A1 = A1 + cellmean(Aadvec(Itend));
     elseif matType==4
       load([base '/Runs/' 'Job' int2str(i) '/' 'transport' int2str(i)],'Ahdiff')
       if tol>0
         for im=1:numTend
            [ii,jj,aa]=find(Ahdiff{Itend(im)});
            k=find(abs(aa)>=tol);
            ii=ii(k); jj=jj(k); aa=aa(k);
            Ahdiff{Itend(im)} = sparse(ii,jj,aa,nb,nb);
         end
       end
       A1 = A1 + cellmean(Ahdiff(Itend));       
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
elseif flag==11  % same as 9 (load matrices of type matType and average in time), but for new file format
  if matType==1
    disp('Loading explicit matrix')
  elseif matType==2
    disp('Loading implicit matrix')
  elseif matType==3
    disp('Loading advection matrix')
  elseif matType==4
    disp('Loading horizontal diffusion matrix')    
  else
    disp('Unknown matType')
  end
  
  A1=sparse(nb,nb);
  for j=1:length(Ir)
	i=Ir(j)
	for km=1:numTend
	  im=Itend(km);
	  if maxNumTend>1
		suff=['_' sprintf('%02d',im)];
	  else
		suff='';
	  end         
	  if matType==1
		fn=['Aexp' sprintf('%02d',i) suff];
		load([base '/' fn],'Aexp')
		if tol>0
		  [ii,jj,aa]=find(Aexp);
		  k=find(abs(aa)>=tol);
		  ii=ii(k); jj=jj(k); aa=aa(k);
		  A1 = A1 + sparse(ii,jj,aa,nb,nb);
		else
		  A1 = A1 + Aexp;		 
		end
	  elseif matType==2
                fn = ['Aimp' sprintf('%02d',i) suff];
                load([base '/' fn],'Aimp')
		if tol>0
		  [ii,jj,aa]=find(Aimp);
		  k=find(abs(aa)>=tol);
		  ii=ii(k); jj=jj(k); aa=aa(k);
		  A1 = A1 + sparse(ii,jj,aa,nb,nb);
		else
		  A1 = A1 + Aimp;		 
		end
	  elseif matType==3
		fn=['Aadvec' int2str(i) suff];
		load([base '/Runs/' 'Job' int2str(i) '/' fn],'Aadvec')
		if tol>0
		  [ii,jj,aa]=find(Aadvec);
		  k=find(abs(aa)>=tol);
		  ii=ii(k); jj=jj(k); aa=aa(k);
		  A1 = A1 + sparse(ii,jj,aa,nb,nb);
		else
		  A1 = A1 + Aadvec;		 
		end
	  elseif matType==4
		fn=['Ahdiff' int2str(i) suff];
		load([base '/Runs/' 'Job' int2str(i) '/' fn],'Ahdiff')
		if tol>0
		  [ii,jj,aa]=find(Ahdiff);
		  k=find(abs(aa)>=tol);
		  ii=ii(k); jj=jj(k); aa=aa(k);
		  A1 = A1 + sparse(ii,jj,aa,nb,nb);
		else
		  A1 = A1 + Ahdiff;		 
		end
	  else       
		error('Unknown matType') 
	  end
	end % end km loop over numTend
  end % end j loop over runs
  A1=A1/numTend;
elseif flag==12  % same as 10 (load matrix of type matType for single time slice), but for new file format
  if matType==1
    disp('Loading explicit matrix')
  elseif matType==2
    disp('Loading implicit matrix')
  elseif matType==3
    disp('Loading advection matrix')
  elseif matType==4
    disp('Loading horizontal diffusion matrix')    
  else
    disp('Unknown matType')
  end
  
  A1=sparse(nb,nb);
  for j=1:length(Ir)
	i=Ir(j)
	im=Itend;
	if maxNumTend>1
	  suff=['_' sprintf('%02d',im)];
	else
	  suff='';
	end         
	if matType==1
    fn = ['Aexp' sprintf('%02d',i) suff];
	  load([base '/' fn],'Aexp')
	  if tol>0
		[ii,jj,aa]=find(Aexp);
		k=find(abs(aa)>=tol);
		ii=ii(k); jj=jj(k); aa=aa(k);
		A1 = A1 + sparse(ii,jj,aa,nb,nb);
	  else
		A1 = A1 + Aexp;		 
	  end
	elseif matType==2
	  fn = ['Aimp' sprintf('%02d',i) suff];
	  load([base '/' fn],'Aimp')
	  if tol>0
		[ii,jj,aa]=find(Aimp);
		k=find(abs(aa)>=tol);
		ii=ii(k); jj=jj(k); aa=aa(k);
		A1 = A1 + sparse(ii,jj,aa,nb,nb);
	  else
		A1 = A1 + Aimp;		 
	  end
	elseif matType==3
	  fn=['Aadvec' int2str(i) suff];
	  load([base '/Runs/' 'Job' int2str(i) '/' fn],'Aadvec')
	  if tol>0
		[ii,jj,aa]=find(Aadvec);
		k=find(abs(aa)>=tol);
		ii=ii(k); jj=jj(k); aa=aa(k);
		A1 = A1 + sparse(ii,jj,aa,nb,nb);
	  else
		A1 = A1 + Aadvec;		 
	  end
	elseif matType==4
	  fn=['Ahdiff' int2str(i) suff];
	  load([base '/Runs/' 'Job' int2str(i) '/' fn],'Ahdiff')
	  if tol>0
		[ii,jj,aa]=find(Ahdiff);
		k=find(abs(aa)>=tol);
		ii=ii(k); jj=jj(k); aa=aa(k);
		A1 = A1 + sparse(ii,jj,aa,nb,nb);
	  else
		A1 = A1 + Ahdiff;		 
	  end
	else       
	  error('Unknown matType') 
	end
  end % end j loop over runs
else
  error('Unknown flag')
end
 

