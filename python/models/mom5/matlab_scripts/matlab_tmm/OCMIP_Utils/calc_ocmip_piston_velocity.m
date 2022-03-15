function [Vgas,ficeb,xkwb,Sc]=calc_ocmip_piston_velocity(ocmip_path,xb,yb,Ts,gas);

if nargin<3
  error('Error: must pass at least 3 arguments!')
end
  
if isempty(ocmip_path)
  mydir=fileparts(which(mfilename));
  ocmip_path=fullfile(mydir,'Data');
end

xkwb=load_ocmip_variable([],'XKW',xb,yb);  
ficeb=load_ocmip_variable([],'FICE',xb,yb);  

ficeb(ficeb<0.2)=0; % OCMIP-2 howto

Vgas660=(1-ficeb).*xkwb; % piston velocity normalized to a Schmidt number of 660  

if any(isnan(Vgas660))
  error('ERROR: Not all boxes filled')
end

if nargin>3
  if size(Ts,2)~=12
	disp('Warning: Computing annual mean gas exchange coefficient')
	Vgas660=mean(Vgas660,2);
  end

  if nargin>4
	switch upper(gas)
	  case 'CO2'
		Sc=sc_coeff_co2(Ts);
		Vgas=Vgas660./sqrt(Sc/660); % piston velocity [m/s]
	  case 'O2'
		Sc=sc_coeff_o2(Ts);
		Vgas=Vgas660./sqrt(Sc/660); % piston velocity [m/s]
	  case {'F11','CFC11','CFC-11','F12','CFC12','CFC-12'}
		Sc=sc_coeff_cfc(Ts,gas);
		Vgas=Vgas660./sqrt(Sc/660); % piston velocity [m/s]
	  case {'HE4','HE-4','HE3','HE-3'}
		Sc=sc_coeff_he(Ts,gas);
		Vgas=Vgas660./sqrt(Sc/660); % piston velocity [m/s]	
	   otherwise
		Sc=schmidt(Ts,gas);
		Vgas=Vgas660./sqrt(Sc/660); % piston velocity [m/s]
	end 
  else
    Vgas=Vgas660;
  end
else
  Vgas=Vgas660;
end
