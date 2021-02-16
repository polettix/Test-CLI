requires 'perl', '5.024000';
requires 'Command::Template';
requires 'Test2::Suite', '0.000139';

on test => sub {
   requires 'Path::Tiny',      '0.084';
   requires 'Test::Exception';
};

on develop => sub {
   requires 'Path::Tiny',          '0.084';
   requires 'Template::Perlish',   '1.52';
   requires 'Test::Pod::Coverage', '1.04';
   requires 'Test::Pod',           '1.51';
};
