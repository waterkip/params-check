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

subtest 'allow_only_defined' => sub {
    my $try = { foo => 2 };
    my $store;
    my $tmpl = { foo => { default => 1 }};
    my $args = check($tmpl, $try, {only_allow_defined => 1});
    is_deeply($args, $try, "Correct return value");

    throws_ok(
        sub {
            check($tmpl, { foo => undef }, {only_allow_defined => 1});
        },
        qr/Key 'foo' must be defined when passed/,
    );
};

# TODO: This will be { foo => { isa => 'Int' }} in the future
subtest 'strict_type' => sub {
    my $try = { foo => 2 };
    my $tmpl = { foo => { default => 1 }};
    my $args = check($tmpl, $try, {strict_type => 1});
    is_deeply($args, $try, "Correct return value");

    $try  = {foo => undef};
    $args = check($tmpl, $try, {strict_type => 1});
    is_deeply($args, $try, "Correct return value");

    throws_ok(
        sub {
            check($tmpl, {foo => []}, {strict_type => 1});
        },
        qr/Key 'foo' needs to be of type 'SCALAR'/,
        "Not a strict type"
    );


};

subtest 'caller_depth' => sub {
    sub wrapper {check(@_)}
    sub inner   {wrapper(@_)}
    sub outer   {inner(@_)}

    my $tmpl = {dummy => {required => 1}};

    throws_ok(
        sub {
            outer($tmpl, {}, {caller_depth => 0});
        },
        qr/for main::wrapper by main::inner/,
        "wrong caller without caller_depth"
    );

    throws_ok(
        sub {
            outer($tmpl, {}, {caller_depth => 1});
        },
        qr/for main::inner by main::outer/,
        "right caller without caller_depth"
    );
};

# This is on by default, checks store refs and unknown keys in the template
subtest 'sanity_check_template' => sub {
    ok("Always on");
};



Test::NoWarnings::had_no_warnings();
done_testing;
