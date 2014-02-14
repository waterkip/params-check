#! perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::NoWarnings ();

use Params::Check qw(allow);

use constant FALSE => sub {0};
use constant TRUE  => sub {1};

ok(allow(42, qr/^\d+$/), "Allow based on regex");
ok(allow($0, $0),        "Allow based on string");
ok(allow(42, [0, 42]), "Allow based on list");
ok(allow(42, [50, sub {1}]), "Allow based on list containing sub");
ok(allow(42, TRUE), "Allow based on constant sub");
ok(!allow($0, qr/^\d+$/), "Disallowing based on regex");
ok(!allow(42, $0),        "Disallowing based on string");
ok(!allow(42, [0, $0]), "Disallowing based on list");
ok(!allow(42, [50, sub {0}]), "Disallowing based on list containing sub");
ok(!allow(42, FALSE), "Disallowing based on constant sub");

# check that allow short circuits where required
subtest 'short_circuit' => sub {
    my $sub_called;
    allow(1, [1, sub {$sub_called++}]);
    ok(!$sub_called, "Allow short-circuits properly");
};

# check if the subs for allow get what you expect
subtest 'coderef_gets_correct_values' => sub {
    for my $thing (1, 'foo', [1]) {
        allow(
            $thing,
            sub {
                is_deeply(+shift, $thing, "Allow coderef gets proper args");
            },
        );
    }
};

Test::NoWarnings::had_no_warnings();
done_testing;
