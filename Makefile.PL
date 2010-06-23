use inc::Module::Install;
name 'Class-Thing';
all_from 'lib/Class/Thing.pm';

requires 'parent';
requires 'Class::Accessor::Lvalue::Fast';
requires 'Class::Data::Inheritable';
requires 'Class::ErrorHandler';

recommends 'YAML::XS';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
