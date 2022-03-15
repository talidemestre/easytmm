function I=randindex(nmax,n)

% USAGE: I=randindex(nmax,n) generates a random sequence 
% of n integers between 1 and nmax 
% See also: randperm

% Samar Khatiwala (spk@ldeo.columbia.edu)

if nargin<2
  n=nmax;
end

ic=0;
while ic<n,
	ic=ic+1;
	found=0;
	while found==0, % Keep looping until a new index is found.
		I(ic)=ceil(nmax*rand); % Random integer between 1 and nmax.		
	    if ic>1,			
		    found=1; 			
		    for j=1:ic-1, % Loop around previous values. 		  			  
				if I(j)==I(ic)  % Check if index has been used already.
					found=0;
				end
			end
		else % If counter=1.
			found=1;
		end
    end			
end

I=I(:);
