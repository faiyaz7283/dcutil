#!./libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

@test "Invoking make returns error" {
    run make
    assert_failure
}
