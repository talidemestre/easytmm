function fixAxisLabels(haveXLabel,xAxisLabel,haveYLabel,yAxisLabel)

if haveXLabel==0 & haveYLabel==0
  set(gca,'xticklabel',[],'yticklabel',[])
elseif haveXLabel==0 & haveYLabel==1
  set(gca,'xticklabel',[])
  ylabel(yAxisLabel)
elseif haveXLabel==1 & haveYLabel==0
  set(gca,'yticklabel',[])
  xlabel(xAxisLabel)
else
  xlabel(xAxisLabel)
  ylabel(yAxisLabel)
end	  
