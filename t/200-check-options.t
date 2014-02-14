#! perl

use strict;
use warnings;

use Test::More;
use Test::NoWarnings ();
use Test::Exception;

use Params::Check qw(check);

my $tmpl = {foo => {default => 1}};

subtest 'failure is an option' => sub { 
    throws_ok(
        sub {
            check(undef, undef, undef);
        },
        qr/check\(\) expects two arguments/,
        "Input incorrect: template"
    );
    throws_ok(
        sub {
            check({}, undef);
        },
        qr/check\(\) expects two arguments/,
        "Input incorrect: params"
    );
    throws_ok(
        sub {
            check({}, {}, [qw(incorrect)]);
        },
        qr/check\(\) invalid type for options or verbose/,
        "Input incorrect: verbose/options"
    );
    throws_ok(
        sub {
            check([],{}, {});
        },
        qr/check\(\) expects two arguments/,
        "Input incorrect: template not hashref"
    );
    throws_ok(
        sub {
            check({}, [], [qw(incorrect)]);
        },
        qr/check\(\) expects two arguments/,
        "Input incorrect: params not hashref"
    );
};

subtest 'emtpty_args' => sub {
    my $args = check($tmpl, {}, {});
    is($args->{foo}, 1, "got default value");
};

subtest 'alternate_value' => sub {
    my $try = {foo => 2};
    my $args = check($tmpl, $try, {});
    is_deeply($args, $try, "Found provided value in rv");
};

subtest 'strip_leading_dashes' => sub {
    my $try = {-foo => 2};
    my $get = {foo  => 2};

    my $args = check($tmpl, $try, { strip_leading_dashes => 1 });
    is_deeply($args, $get, "   found provided value in rv");
};

subtest 'allow_unknowns' => sub {
    my $try = {foo => 42};
    throws_ok(
        sub {
            check({}, $try, {});
        },
        qr/^Key 'foo' is not a valid key/,
        "Unknows are not allowed"
    );

    my $rv = check({}, $try, {allow_unknown => 1});
    is_deeply($rv, $try, "check call() with unknown args allowed");
};

subtest 'case_preserving_off' => sub {
    my $try = {FOO => 2};
    throws_ok(
        sub {
            check($tmpl, $try, {});
        },
        qr/^Key 'FOO' is not a valid key/,
        "FOO is not allowed when preserving case"
    );

    my $args = check($tmpl, $try, {preserve_case => 0});
    is_deeply($args, {foo => 2}, "found provided value in rv");
};

# Test with store..
subtest 'store' => sub {
    my $try = { foo => 2 };
    my $store;
    my $tmpl = { foo => { store => \$store } };
    my $args = check($tmpl, $try, {});
    is_deeply($args, $try, "found provided value in rv");
    is($store, $try->{foo}, "Store works");

    $args = check($tmpl, $try, {no_duplicates => 1});
    ok(!exists $args->{foo}, "Not found in rv");
    is($store, $try->{foo}, "Store works");

    throws_ok(
        sub {
            check({foo => {store => $store}}, {}, {});
        },
        qr/Store variable for 'foo' is not a reference!/,
        "Store wants an ref"
    );
};

#subtest 'strict_type' => sub {
#    fail("Not tested");
#};
#
#subtest 'allow_only_defined' => sub {
#    fail("Not tested");
#};
#
#subtest 'sanity_check_template' => sub {
#    fail("Not tested");
#};
#
#subtest 'caller_depth' => sub {
#    fail("Not tested");
#};

Test::NoWarnings::had_no_warnings();
done_testing;
