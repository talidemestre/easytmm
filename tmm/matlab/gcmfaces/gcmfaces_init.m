
gcmfaces_global;

test0=dir('sample_input'); if isempty(test0); fprintf('no sample input data found\n'); return; end;

warning('off','MATLAB:HandleGraphics:noJVM');

if myenv.verbose;
  fprintf('\n\n\n***********message from gcmfaces_init.m************\n ');
  fprintf(' starting basic test : plot_std_field ... \n');
end;
plot_std_field('v4');

if ~myenv.lessplot;
  if myenv.verbose;
    fprintf('\n\n\n***********message from gcmfaces_init.m************\n ');
    fprintf(' starting plot test: plot_one_field ... \n');
  end;
  plot_one_field('v4',0);
end;

if ~myenv.lesstest;
  if myenv.verbose;
    fprintf('\n\n\n***********message from gcmfaces_init.m************\n ');
    fprintf(' starting computations test: basic_diags_compute_v3_or_v4 ... \n');
  end;
  basic_diags_compute_v3_or_v4('v4');
  if ~myenv.lessplot; basic_diags_display_v3_or_v4('v4'); end;
end;

if myenv.verbose;
  fprintf('\n\n\n***********message from gcmfaces_init.m************\n');
  fprintf(' --- initialization of gcmfaces completed correctly \n');
  fprintf(' --- you are all set and may now use the gcmfaces package. \n\n\n');
end;

