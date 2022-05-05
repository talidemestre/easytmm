function []=extract_latlon_grid(dirGrid);
%object : applies extract_latlon to the grid directory, hence
%         extracting the lat-lon part of the GRID.

if isempty(whos('dirGrid')); dirGrid='GRID/'; end;

%treat tracer fields:
extract_latlon(dirGrid,'XC','other','tracer');
extract_latlon(dirGrid,'YC','other','tracer');
extract_latlon(dirGrid,'Depth','other','tracer');
extract_latlon(dirGrid,'RAC','other','tracer');
extract_latlon(dirGrid,'hFacC','other','tracer');
extract_latlon(dirGrid,'maskCtrlC','other','tracer');

%treat vector fields:
extract_latlon(dirGrid,'DXC','other','vector','DYC');
extract_latlon(dirGrid,'DYG','other','vector','DXG');%note diff. pos. from DXC/DYC case
extract_latlon(dirGrid,'RAW','other','vector','RAS');
extract_latlon(dirGrid,'hFacW','other','vector','hFacS');
extract_latlon(dirGrid,'maskCtrlW','other','vector','maskCtrlS');

%copy 1D fields : DRC, DRF, RC, RF
eval(['!\cp ' dirGrid '/DRC.* ' dirGrid '/extracts_latlon/.']);
eval(['!\cp ' dirGrid '/DRF.* ' dirGrid '/extracts_latlon/.']);
eval(['!\cp ' dirGrid '/RC.* ' dirGrid '/extracts_latlon/.']);
eval(['!\cp ' dirGrid '/RF.* ' dirGrid '/extracts_latlon/.']);
eval(['!\cp ' dirGrid '/RC.* ' dirGrid '/extracts_latlon/.']);

% AngleCS, AngleSN        create (cs=1, sn=0)
AngleCS=ones(360,178); AngleSN=zeros(360,178);
write2file([dirGrid '/extracts_latlon/AngleCS.data'],AngleCS);
write2meta([dirGrid '/extracts_latlon/AngleCS.data'],[360 178]);
write2file([dirGrid '/extracts_latlon/AngleSN.data'],AngleSN);
write2meta([dirGrid '/extracts_latlon/AngleSN.data'],[360 178]);

% RAZ, XG, YG             need special treatment
listFiles={'RAZ','XG','YG'};
for ii=1:length(listFiles);
FLD=convert2array(rdmds2gcmfaces([dirGrid listFiles{ii} '*']));
if strcmp(listFiles{ii},'YG')|strcmp(listFiles{ii},'RAZ'); 
  FLD=ones(360,1)*FLD(1,62:239);
else;
  FLD=circshift(FLD(:,62:239),[142 0]);
end;
write2file([dirGrid '/extracts_latlon/' listFiles{ii} '.data'],FLD);
write2meta([dirGrid '/extracts_latlon/' listFiles{ii} '.data'],[360 178]);
end;

