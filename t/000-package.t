#! perl

use Test::More;
use Test::Compile;
use Test::Pod;
use Test::Pod::Coverage;

subtest 'compile' => sub {
    all_pm_files_ok();
};

subtest 'pod' => sub { 
    all_pod_files_ok();
};

subtest 'pod_coverage' => sub {
    all_pod_coverage_ok();
};

done_testing;
