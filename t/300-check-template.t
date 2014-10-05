#! perl

use strict;
use warnings;

use Test::More;
use Test::NoWarnings ();
use Test::Exception;

use Params::Check qw(check);

my $template = { };

subtest required => sub {
    my $arg = { foo => 1 };
    $template = { foo => {required => 1}};
    my $res = check($template, $arg, {});
    is_deeply($res, $arg, "Return value is correct");

    $res = check($template, {foo => undef}, {});
    is_deeply($res, { foo => undef }, "Return value is correct");

    throws_ok(
        sub {
            check($template, {}, {});
        },
        qr/Required option 'foo' is not provided/,
        "Error caught"
    );
};

subtest defined => sub {
    my $arg = { foo => 1 };
    $template = { foo => {defined => 1}};
    my $res = check($template, $arg, {});
    is_deeply($res, $arg, "Return value is correct");

    throws_ok(
        sub {
            check($template, {foo => undef}, {});
        },
        qr/Key 'foo' must be defined when passed/,
        "Error caught"
    );
};

subtest default => sub {
    my $arg = { foo => 42 };
    $template = { foo => {default => 1337}};
    my $res = check($template, $arg, {});
    is_deeply($res, $arg, "Return value is correct");

    $res = check($template, {}, {});
    is_deeply($res, { foo => 1337 }, "Return value is correct");
};

subtest depends => sub {
    my $arg = { foo => 42 };
    $template = { foo => { default => 1337, depends => [ qw(foo bar) ] }, bar => { required => 0 }, };

    throws_ok(
        sub {
            check($template, $arg, {});
        },
        qr/Required option 'bar' is not provided/,
        "Foo depends on bar"
    );
    #is_deeply($res, $arg, "Return value is correct");
};

#subtest conflicts => sub {
#    fail("Not tested");
#};
#
#

Test::NoWarnings::had_no_warnings();
done_testing;
