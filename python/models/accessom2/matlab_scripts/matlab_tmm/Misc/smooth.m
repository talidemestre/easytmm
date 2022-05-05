function avg=smooth(x,M,b)

% Samar Khatiwala (spk@ldeo.columbia.edu)

if M>0
	r=rem(M,2);
	if (r==0)
		error('M should be odd');
	end
	if nargin<3
		b=ones(M,1);
	end
	avg=zeros(size(x,1),1);
	n=(M-1)/2;
	xp=[x(1)*ones(n,1);x;x(end)*ones(n,1)];
	for i=1:M
		avg=avg+b(i)*xp(i:end-M+i);
	end
	avg=avg/sum(b);
else
	avg=x;
end
