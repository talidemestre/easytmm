function []=write2tex(myFile,myStep,varargin);
%object:	create/increment/complete/compile a tex file from within matlab
%input:		myFile is the file name
%		myStep is the operation to perform on the tex file
%			0   create file starting with title page (see myText)
%         		1   add section or subsection (see myLev)
%			2   add a figure plus caption (see myFig)
%			3   add a paragraph
%			4   finish file
%			5   compile and remove temporary files (incl. *fig*.ps)
%			-5  compile solely
%optional	myText is a cell array of text lines (for myStep=1 to 2)
%		myLev is the title level (for myStep=1)
%			1=section, 2=subsection (not yet implemented)
%		myFig is a figure handle (for myStep=2)

myText=[]; myLev=[]; myFig=[];
if myStep<4; myText=varargin{1}; end;
if myStep==1; myLev=varargin{2};
elseif myStep==2; myFig=varargin{2};
end;

%create file starting with write2tex.header
if myStep==0;
    test0=dir(myFile);
    if ~isempty(test0);
        test0=input(['you are about to overwrite ' myFile ' !!! \n   type 1 to proceed, 0 to stop \n']);
    else;
        test0=1;
    end;
    if ~test0;
        return;
    else;
	fid=fopen(myFile,'w');

	fprintf(fid,'\\documentclass[12pt]{beamer}\n');
	fprintf(fid,'%%a nice series of examples for the beamer class:\n');
	fprintf(fid,'%%http://www.informatik.uni-freiburg.de/~frank/ENG/beamer/example/beamer-class-example-en-5.html\n');
	fprintf(fid,'\\begin{document} \n\n');

        fprintf(fid,'\\title{\n');
	for ii=1:length(myText); fprintf(fid,[myText{ii} '\\\\ \n']); end;
        fprintf(fid,'}\n\n');
        fprintf(fid,'\\date{\\today}\n\n');
        fprintf(fid,'\\frame{\\titlepage}\n\n');

	fprintf(fid,'\\frame{');
	fprintf(fid,'\\frametitle{Table of contents}');
	fprintf(fid,'\\tableofcontents');
	fprintf(fid,'} \n\n');

	fclose(fid);
    end;
    myFigNumTex=0;
    mySection='';
    eval(['save ' myFile(1:end-4) '.mat myFigNumTex mySection;']);
end;

%open file and go to last line
fid=fopen(myFile,'a+');
eval(['load ' myFile(1:end-4) '.mat;']);

%add title or section page (see myLev)
if myStep==1;
    mySection=myText;
    fprintf(fid,'\\section{\n');
    fprintf(fid,mySection);
    fprintf(fid,'} \n\n');
end;

%add a figure plus caption (see myFig)
if myStep==2;
    figure(myFig);
    drawnow;
    myFigNumTex=myFigNumTex+1;
    nn=strfind(myFile,'/');
    if ~isempty(nn);
        dirTex=myFile(1:nn(end)); fileTex=myFile(nn(end)+1:end-4);
    else;
        dirTex='./'; fileTex=myFile(1:end-4)
    end;
    %print the very figure
    print(myFig,'-depsc',[dirTex fileTex '.fig' num2str(myFigNumTex)]);
    close;
    %add figure to text file
    fprintf(fid,'\\frame{ \n');
    fprintf(fid,['\\frametitle{' mySection '} \n']);
    fprintf(fid,'\\begin{figure}[tbh] \\centering \n');
%     fprintf(fid,'\\includegraphics[width=\\textwidth,height=0.9\\textheight]');
    fprintf(fid,'\\includegraphics[width=0.75\\textwidth]');
    fprintf(fid,['{' fileTex '.fig' num2str(myFigNumTex) '}\n']);
    fprintf(fid,'\\caption{');
    for ii=1:length(myText); fprintf(fid,[myText{ii} '\n']); end;
    fprintf(fid,'} \\end{figure} \n');
    fprintf(fid,'} \n\n');
end;

%add a paragraph
if myStep==3;
    for ii=1:length(myText);
        fprintf(fid,[myText{ii} '\n']);
    end;
end;

%finish file
if myStep==4; fprintf(fid,'\n\n \\end{document} \n\n'); end;

%close file
fprintf(fid,'\n\n');
fclose(fid);
eval(['save ' myFile(1:end-4) '.mat myFigNumTex mySection;']);

%compile
if myStep==5|myStep==-5;
    dirOrig=pwd;
    nn=strfind(myFile,'/');
    if ~isempty(nn);
        cd(myFile(1:nn)); fileTex=myFile(nn+1:end-4);
    else;
        fileTex=myFile(1:end-4);
    end;
    eval(['!latex ' fileTex]);
    eval(['!latex ' fileTex]);
    eval(['!dvipdf ' fileTex]);
    cd(dirOrig);
end;


%compile
if myStep==5;
    dirOrig=pwd;
    nn=strfind(myFile,'/');
    if ~isempty(nn);
        cd(myFile(1:nn)); fileTex=myFile(nn+1:end-4);
    else;
        fileTex=myFile(1:end-4);
    end;
    eval(['!\rm -f ' fileTex '.fig*']);
    eval(['!\rm -f ' fileTex '.aux']);
    eval(['!\rm -f ' fileTex '.log']);
    eval(['!\rm -f ' fileTex '.out']);
    eval(['!\rm -f ' fileTex '.dvi']);
    cd(dirOrig);
end;
