function [myplot]=basic_diags_display_transport(alldiag,ii,txt,RF,listTimes,rr,varargin);
%object:	display transport time series and/or time mean
%inputs:	alldiag.fldTRANSPORTS contains the transports time series	
%		ii is the transport index in alldiag.fldTRANSPORTS
%		txt is the transport name to be displayed
%		RF is the depth vector
%		listTimes is the time vector
%		rr is the y axis range for plotting
%optional	nmean is a running mean window length (0 by default) 
%
%note:	as an example of computation leading to correct inputs, see
%	basic_diags_compute_v3_or_v4 (calls calc_transports)
%	basic_diags_display_v3_or_v4 (compile time series)

gcmfaces_global;

if nargin==7; nmean=varargin{1}; else; nmean=0; end;

tt=[1:length(listTimes)]; nt=length(tt); TT=listTimes(tt)*3600/86400; 

if 1;
 fld=0*zeros(nt,1); for ttt=1:nt; tmp1=alldiag(tt(ttt)).fldTRANSPORTS(ii,:); fld(ttt)=sum(tmp1(:)); end;
 fldmean=1e-2*round(mean(fld)*1e2);
 fprintf(['    ' txt '-- mean: ' num2str(fldmean) 'Sv\n']);
 if nt>1;
   fld=runmean(fld,nmean,1);
   myplot=plot(TT,fld,'LineWidth',2); title(txt); set(gca,'FontSize',14);
   aa=[min(TT) max(TT) rr]; axis(aa); 
 end; 
else;
 RC=squeeze(mygrid.RC);
 fld=0*RC; for ttt=1:nt; tmp1=flipdim(sum(alldiag(tt(ttt)).fldTRANSPORTS(ii,:)',2),1); fld=fld+flipdim(cumsum(tmp1)/nt,1); end;
 if nt>1;
   fld(find(fld==0))=NaN; kk=find(~isnan(fld)); 
   myplot=plot(fld(kk),RC(kk),'LineWidth',2); title(txt); set(gca,'FontSize',14); grid on;
   aa=axis; tmp1=max(abs(aa(1:2))); aa(1:2)=tmp1*[-1 1]; axis(aa);
 end;
end;

