fn gargs_count() { if (argc() <= 1) { return 0; } return argc() - 1; }
fn gargs_has(flag) { var i; i = 1; while (i < argc()) { if (streq(argv(i), flag) == 1) { return 1; } i = i + 1; } return 0; }
fn gargs_value(flag) { var i; i = 1; while (i + 1 < argc()) { if (streq(argv(i), flag) == 1) { return argv(i + 1); } i = i + 1; } return 0; }