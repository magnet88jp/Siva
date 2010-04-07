use inc::Module::Install;

name 'Siva';
all_from 'lib/Siva.pm';

requires Catalyst => '5.64';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
