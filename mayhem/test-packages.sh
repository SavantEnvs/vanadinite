# Shared between mayhem/build.sh (pre-compiles with --no-run) and mayhem/test.sh (runs) so the
# two can never drift. These are the upstream crates whose test suites are HOST-runnable —
# vanadinite is a RISC-V OS: the kernel's own #[cfg(test)] tests (src/kernel/vanadinite) only
# build for riscv64imac-unknown-none-elf and run under QEMU via `cargo xtask test` (a full
# system-emulation boot; not runnable in this image), so they are found-but-skipped.
# Every crate below carries real upstream #[test] assertions.
# Found-but-skipped (and why):
#   - kernel (src/kernel/vanadinite tests.rs, mem/paging/tests.rs): riscv64imac-only, runs
#     under QEMU full-system emulation via `cargo xtask test` — not runnable in this image;
#   - materialize: depends on librust, whose syscall wrappers are riscv inline-asm (a0/t0
#     registers) — does not compile for the host;
#   - endian, netstack: depend on alchemy -> alchemy_derive, whose syn 2 dep is declared
#     without the `full` feature it actually needs (upstream only ever builds it inside the
#     full riscv workspace where feature unification enables it) — does not compile standalone.
SHARED_TEST_PACKAGES=(collections)
USERSPACE_TEST_PACKAGES=(fat32 vidlgen)

# Upstream gitignores Cargo.lock, so a tree reset to the commit has no lockfile for these two
# workspaces and a network-off cargo would re-resolve from the registry cache alone (it picks
# mismatched cached versions, e.g. `failed to select a version for quote`). Restore the lockfiles
# resolved by the online image build; the downloaded crates in $CARGO_HOME match them exactly.
[ -e src/shared/Cargo.lock ]    || cp mayhem/locks/shared.Cargo.lock    src/shared/Cargo.lock
[ -e src/userspace/Cargo.lock ] || cp mayhem/locks/userspace.Cargo.lock src/userspace/Cargo.lock
