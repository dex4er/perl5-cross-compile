#!/usr/bin/perl -w

# Test that we can build modules as miniperl.
# This mostly means no XS modules.

use strict;
use lib 't/lib';

use Config;
use Test::More;

# In a BEGIN block so the END tests aren't registered.
BEGIN {
    plan skip_all => "miniperl test only necessary for the perl core"
      if !$ENV{PERL_CORE};

    plan skip_all => "no toolchain installed when cross-compiling"
      if $ENV{PERL_CORE} && $Config{'usecrosscompile'};

    plan "no_plan";
}

BEGIN {
    ok !$INC{"ExtUtils/MakeMaker.pm"}, "MakeMaker is not yet loaded";
}

# Disable all XS from here on
use MakeMaker::Test::NoXS;

use ExtUtils::MakeMaker;

use MakeMaker::Test::Utils;
use MakeMaker::Test::Setup::BFD;


my $perl     = which_perl();
my $makefile = makefile_name();
my $make     = make_run();


# Setup our test environment
{
    chdir 't';

    perl_lib;

    ok( setup_recurs(), 'setup' );
    END {
        ok( chdir File::Spec->updir );
        ok( teardown_recurs(), 'teardown' );
    }

    ok( chdir('Big-Dummy'), "chdir'd to Big-Dummy" ) ||
      diag("chdir failed: $!");
}


# Run make once
{
    run_ok(qq{$perl Makefile.PL});
    SKIP: {
        skip "make isn't available", 1 if !$make;
        run_ok($make);
    }
}
