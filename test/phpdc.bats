#!./libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

@test "Invoking dcutil without any arguments return basic message" {
    run dcutil
    assert_success
    assert_line --index 0 --partial "dcutil [ options ] [ parameters ] <target>"
    assert_line --index 2 --partial "https://github.com/faiyaz7283/dcutil"
    assert_line --index 3 --partial "Copyright (c) 2018 Faiyaz Haider under MIT License."
}

@test "Invoking dcutil with -h, --help, --man option flags return DCUTIL Manual message" {
    run dcutil -h
    assert_success
    assert_line --index 0 --partial "General Commands Manual"
    run dcutil --help
    assert_success
    assert_line --index 0 --partial "General Commands Manual"
    run dcutil --man
    assert_success
    assert_line --index 0 --partial "General Commands Manual"
}

@test "Running -r, --remove option flags with dcutil prompts for a selection" {
    run bash -c "yes 2 | dcutil -r"
    assert_success
    assert_line --index 0 --partial "Are you sure you want to remove DCUTIL from this machine ?"
    run bash -c "yes 2 | dcutil --remove"
    assert_success
    assert_line --index 0 --partial "Are you sure you want to remove DCUTIL from this machine ?"
}

@test "Invoking dcutil with -v, --version option flags return DCUTIL version and info" {
    run dcutil -v
    assert_success
    assert_line --index 0 --partial "DCUTIL"
    assert_line --index 1 --partial "Version:"
    assert_line --index 2 --partial "Released:"
    assert_line --index 3 --partial "SHA-1:"
    run dcutil --version
    assert_success
    assert_line --index 0 --partial "DCUTIL"
    assert_line --index 1 --partial "Version:"
    assert_line --index 2 --partial "Released:"
    assert_line --index 3 --partial "SHA-1:"
}

@test "Running -u, --update option flags with dcutil doesn't throw error" {
    run dcutil -u
    assert_success
    run dcutil --update
    assert_success
}