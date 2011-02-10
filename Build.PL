
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'Module::Build' => '0.3601'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Insert POD for subs from spec',
  'dist_author' => [
    'Steven Haryanto <stevenharyanto@gmail.com>'
  ],
  'dist_name' => 'Pod-Weaver-Plugin-SubSpec',
  'dist_version' => '0.02',
  'license' => 'perl',
  'module_name' => 'Pod::Weaver::Plugin::SubSpec',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'Pod::Weaver' => '0',
    'Sub::Spec::Pod' => '0',
    'perl' => '5.010000'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
