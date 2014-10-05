#! perl

use strict;
use warnings;

use Test::More;
use Test::NoWarnings ();
use Test::Exception;

use Params::Check qw(check);

my $template = {};

subtest required => sub {
    my $arg = { foo => 1 };
    $template = { foo => { required => 1 } };
    my $res = check($template, $arg, {});
    is_deeply($res, $arg, "Return value is correct");

    $res = check($template, { foo => undef }, {});
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
    $template = { foo => { defined => 1 } };
    my $res = check($template, $arg, {});
    is_deeply($res, $arg, "Return value is correct");

    throws_ok(
        sub {
            check($template, { foo => undef }, {});
        },
        qr/Key 'foo' must be defined when passed/,
        "Error caught"
    );
};

subtest default => sub {
    my $arg = { foo => 42 };
    $template = { foo => { default => 1337 } };
    my $res = check($template, $arg, {});
    is_deeply($res, $arg, "Return value is correct");

    $res = check($template, {}, {});
    is_deeply($res, { foo => 1337 }, "Return value is correct");
};

subtest depends => sub {
    $template = {
        foo => {
            depends => [qw(foo bar)]
        },
        bar => {
            depends => [qw(foo bar)]
        },
    };

    throws_ok(
        sub {
            check($template, { foo => 42}, {});
        },
        qr/Required option 'bar' is not provided/,
        "Foo depends on bar"
    );
    throws_ok(
        sub {
            check($template, { bar => 42 }, {});
        },
        qr/Required option 'foo' is not provided/,
        "Bar depends on foo"
    );

    my $arg = { foo => 42, bar => 42 };
    my $res = check($template, $arg, {});
    is_deeply($res, $arg, "Depends works");
};

subtest conflicts => sub {
    $template = {
        foo => {
            required  => 1,
            conflicts => [qw(foo bar)],
        },
        bar => {
            required => 1,
            conflicts => [qw(foo bar)],
        },
    };

    my $res = check($template, { bar => 42 }, {});
    is_deeply($res, { bar => 42 }, "Conflicting bar wins from foo");

    $res = check($template, { foo => 42 }, {});
    is_deeply($res, { foo => 42 }, "Conflicting foo wins from bar");

    throws_ok(
        sub {
            check($template, { foo => 42, bar => 42 }, {});
        },
        qr/Conflicting option 'foo'/,
        "Foo conflicts with bar"
    );

    $res = check($template, { foo => 42, baz => 42 }, {allow_unknown => 1});
    is_deeply($res, { foo => 42, baz => 42}, "bar is not required");

};

Test::NoWarnings::had_no_warnings();
done_testing;
