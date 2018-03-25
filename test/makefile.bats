#!./libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

@test "Invoking make without arguments return commands list" {
    run make
    assert_success
    assert_line --index 0 --partial "All available commands (targets)."
}
