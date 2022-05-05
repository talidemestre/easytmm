function mstr=get_month(m)
% USAGE: monthstr = get_month(m)
% Returns month string from intger month

% Samar Khatiwala (spk@ldeo.columbia.edu)

switch m
	case 1, mstr='Jan';
	case 2, mstr='Feb';
	case 3, mstr='Mar';
	case 4, mstr='Apr';
	case 5, mstr='May';
	case 6, mstr='Jun';
	case 7, mstr='Jul';
	case 8, mstr='Aug';
	case 9, mstr='Sep';
	case 10, mstr='Oct';
	case 11, mstr='Nov';
	case 12, mstr='Dec';
end
