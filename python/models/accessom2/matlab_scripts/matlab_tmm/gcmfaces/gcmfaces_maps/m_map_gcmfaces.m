function []=m_map_gcmfaces(fld,varargin);
%object:    gcmfaces front end to m_map
%inputs:    fld is the 2D field to be mapped, or a cell (see below).
%optional:  proj is either the index (integer; 0 by default) of pre-defined
%               projection(s) or parameters to pass to m_proj (cell)
%more so:   other optional paramaters can be provided ONLY AFTER proj,
%           and must take the following form {'name',param1,param2,...}
%           those that are currently active are
%               {'myCaxis',myCaxis} is the color axis ('auto' by default)
%               {'do_m_coast',do_m_coast} adds call to m_coast (1; default) or not (0).
%               {'myCmap',myCmap} is the colormap name ('jet' by default)
%               {'doHold',1} indicates to 'hold on' and superimpose e.g. a contour
%
%notes:     - for proj==0 (i.e. the default) three panels will be plotted :
%           a mercator projection over mid-latitude, and two polar
%           stereographic projections. The other predefined proj are
%               -1  mollweide or cylindrical projection
%               1   mercator projection only
%               2   arctic stereographic projection only
%               3   antarctic stereographic projection only
%               1.1 and 1.2 are atlantic mercator projections
%           - myTitle is currently not used; it will take the form
%              {'myTitle',myTitle} is the title (none by default)
%           - myCaxis can be specified with more than 2 values, in which
%             case gcmfaces_cb will be used. 
%           - if fld is a 2D field we use pcolor to display it
%           - if fld is a cell one can specify the plotting tool.
%             The cell  must then have the form {plotType,FLD,varargin}
%             where plotType is e.g. 'pcolor' or 'contour', FLD is 
%             the 2D field to be plotted, and varargin are options 
%             to pass over to the contour command.
%           - Hence .e.g. fld={'contour',mygrid.Depth,'r'} will draw 
%             red contours, while fld=mygrid.Depth will color shade.

%check that m_map is in the path
aa=which('m_proj'); if isempty(aa); error('this function requires m_map that is missing'); end;

global mygrid;

%get optional parameters
if nargin>1; proj=varargin{1}; else; proj=0; end;
if iscell(proj);
    error('not yet implemented');
else;
    choicePlot=proj;
end;
%determine the type of plot
if iscell(fld); myPlot=fld{1}; else; myPlot='pcolor'; fld={'pcolor',fld}; end;
%set more optional paramaters to default values
myCaxis=[]; myTitle=''; do_m_coast=1; myCmap='jet'; doHold=0;
%set more optional paramaters to user defined values
for ii=2:nargin-1;
    if ~iscell(varargin{ii});
        warning('inputCheck:m_map_gcmfaces_1',...
            ['As of june 2011, m_map_gcmfaces expects \n'...
            '         its optional parameters as cell arrays. \n'...
            '         Argument no. ' num2str(ii+1) ' was ignored \n'...
            '         Type ''help m_map_gcmfaces'' for details.']);
    elseif ~ischar(varargin{ii}{1});
        warning('inputCheck:m_map_gcmfaces_2',...
            ['As of june 2011, m_map_gcmfaces expects \n'...
            '         its optional parameters cell arrays \n'...
            '         to start with character string. \n'...
            '         Argument no. ' num2str(ii+1) ' was ignored \n'...
            '         Type ''help m_map_gcmfaces'' for details.']);
    else;
        if strcmp(varargin{ii}{1},'myCaxis')|...
                strcmp(varargin{ii}{1},'myCmap')|...
                strcmp(varargin{ii}{1},'doHold')|...
                strcmp(varargin{ii}{1},'do_m_coast')|...
                strcmp(varargin{ii}{1},'myTitle');
            eval([varargin{ii}{1} '=varargin{ii}{2};']);
        else;
            warning('inputCheck:m_map_gcmfaces_3',...
                ['unknown option ''' varargin{ii}{1} ''' was ignored']);
        end;
    end;
end;

%make parameter inferences
if length(myCaxis)==0;
    plotCBAR=0;
elseif length(myCaxis)==2;
    plotCBAR=1;
else;
    plotCBAR=2;
end;
%
if choicePlot==0&~doHold;
    clf;
elseif ~doHold;
    cla;
else;
    hold on;
end;

%re-group param:
param.plotCBAR=plotCBAR;
param.myCmap=myCmap;
param.myCaxis=myCaxis;
param.do_m_coast=do_m_coast;
param.doHold=doHold;
param.myPlot=myPlot;

%do the plotting:
if (choicePlot~=0&choicePlot~=1&choicePlot~=2&choicePlot~=3);
    do_my_plot(fld,param,choicePlot);
end;%if choicePlot==0|choicePlot==1;

if choicePlot==0; subplot(2,1,1); end;
if choicePlot==0|choicePlot==1;
    do_my_plot(fld,param,1);
end;%if choicePlot==0|choicePlot==1;

if choicePlot==0; subplot(2,2,3); end;
if choicePlot==0|choicePlot==2;
    do_my_plot(fld,param,2);
end;%if choicePlot==0|choicePlot==1;

if choicePlot==0; subplot(2,2,4); end;
if choicePlot==0|choicePlot==3;
    do_my_plot(fld,param,3);
end;%if choicePlot==0|choicePlot==1;

if plotCBAR==2&strcmp(myPlot,'pcolor');
    cbar=gcmfaces_cmap_cbar(myCaxis,{'myCmap',myCmap});
    if choicePlot==0;
        set(cbar,'Position',[0.92 0.15 0.02 0.75]);
    elseif choicePlot==-1;
        set(cbar,'Position',[0.92 0.35 0.02 0.3]);
    elseif choicePlot==1;
        set(cbar,'Position',[0.92 0.34 0.02 0.35]);
    else;
        set(cbar,'Position',[0.92 0.23 0.02 0.55]);
    end;
end;


function []=do_my_plot(fld,param,proj);

gcmfaces_global;

if proj==-1;
    %%m_proj('Miller Cylindrical','lat',[-90 90]);
    %m_proj('Equidistant cylindrical','lat',[-90 90]);
    %m_proj('mollweide','lon',[-180 180],'lat',[-80 80]);
    m_proj('mollweide','lon',[-180 180],'lat',[-88 88]);
    conv='pcol';
elseif proj==1;
    m_proj('Mercator','lat',[-70 70]);
    conv='pcol';
elseif proj==2;
    m_proj('Stereographic','lon',0,'lat',90,'rad',40);
    conv='convert2arctic';
elseif proj==3;
    m_proj('Stereographic','lon',0,'lat',-90,'rad',40);
    conv='convert2southern';
elseif proj==1.1;
    m_proj('Mercator','lat',[20 60],'lon',[-100 -30]);
    conv='pcol';
elseif proj==1.2;
    m_proj('Mercator','lat',[10 60],'lon',[-100 30]);
    conv='pcol';
end;

if strcmp(param.myPlot,'pcolor')|strcmp(param.myPlot,'contour');
    if strcmp(conv,'pcol');
        [xx,yy,z]=convert2pcol(mygrid.XC,mygrid.YC,fld{2});
    else;
        eval(['xx=' conv '(mygrid.XC);']);
        eval(['yy=' conv '(mygrid.YC);']);
        eval(['z=' conv '(fld{2});']);
    end;
    [x,y]=m_ll2xy(xx,yy);
    if strcmp(param.myPlot,'pcolor');
        if sum(~isnan(x(:)))>0; pcolor(x,y,z); shading interp; end;
        if param.plotCBAR==0; colormap(param.myCmap); colorbar;
        elseif param.plotCBAR==1; caxis(param.myCaxis); colormap(param.myCmap); colorbar;
        else; cbar=gcmfaces_cmap_cbar(param.myCaxis,{'myCmap',param.myCmap}); delete(cbar);
        end;
        if param.do_m_coast; m_coast('patch',[1 1 1]*.7,'edgecolor','none'); end;
        m_grid('XaxisLocation','bottom');
    elseif strcmp(param.myPlot,'contour');
        if ~param.doHold;
            if param.do_m_coast; m_coast('patch',[1 1 1]*.7,'edgecolor','none'); end;
            m_grid('XaxisLocation','bottom');
        end;
        if length(fld)==2; fld{3}='k'; end;
        hold on; contour(x,y,z,fld{3:end});
    end;
elseif strcmp(param.myPlot,'plot');
    if ~param.doHold;
        if param.do_m_coast; m_coast('patch',[1 1 1]*.7,'edgecolor','none'); end;
        m_grid('XaxisLocation','bottom');
    end;
    [x,y]=m_ll2xy(fld{2},fld{3});
    hold on; plot(x,y,fld{4:end});
end;

