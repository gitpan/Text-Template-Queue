use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Text::Template::Queue',
    'VERSION_FROM' => 'Queue.pm', # finds $VERSION
);
