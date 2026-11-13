# G Tasks 1.0
# Cross-platform G CLI application (Windows/Linux)
# Commands:
#   g_tasks add Buy milk
#   g_tasks list
#   g_tasks stats
#   g_tasks clear

fn help() {
    print("G Tasks 1.0\n");
    print("Usage:\n");
    print("  g_tasks add <task>\n");
    print("  g_tasks list\n");
    print("  g_tasks stats\n");
    print("  g_tasks clear\n");
    return 0;
}

fn add_task() {
    var old;
    var f;
    var n;
    var i;
    var s;
    if (argc() < 3) { print("Error: write a task after add.\n"); return 1; }
    old = alloc(65536); n = 0;
    f = open("g_tasks.txt");
    if (f != 0) { n = read(f, old, 65535); close(f); }
    f = create("g_tasks.txt");
    if (f == 0) { print("Error: cannot create g_tasks.txt\n"); return 1; }
    if (n > 0) { write(f, old, n); }
    i = 2;
    while (i < argc()) {
        s = argv(i); write(f, s, strlen(s));
        if (i + 1 < argc()) { write(f, " ", 1); }
        i = i + 1;
    }
    write(f, "\n", 1); close(f);
    print("Added: "); i = 2;
    while (i < argc()) {
        print(argv(i)); if (i + 1 < argc()) { putc(32); } i = i + 1;
    }
    putc(10); return 0;
}

fn list_tasks() {
    var f; var buf; var n; var i; var line; var at_start; var c;
    f = open("g_tasks.txt");
    if (f == 0) { print("No tasks yet.\n"); return 0; }
    buf = alloc(65536); n = read(f, buf, 65535); close(f);
    if (n <= 0) { print("No tasks yet.\n"); return 0; }
    print("G Tasks\n-------\n"); i = 0; line = 1; at_start = 1;
    while (i < n) {
        c = lb(buf + i);
        if (at_start == 1) { printn(line); print(". "); at_start = 0; }
        putc(c);
        if (c == 10) { line = line + 1; at_start = 1; }
        i = i + 1;
    }
    return 0;
}

fn stats() {
    var f; var buf; var n; var i; var count;
    f = open("g_tasks.txt");
    if (f == 0) { print("Tasks: 0\n"); return 0; }
    buf = alloc(65536); n = read(f, buf, 65535); close(f);
    i = 0; count = 0;
    while (i < n) { if (lb(buf + i) == 10) { count = count + 1; } i = i + 1; }
    print("Tasks: "); printn(count); putc(10);
    print("Stored bytes: "); printn(n); putc(10);
    return 0;
}

fn clear_tasks() {
    var f; f = create("g_tasks.txt");
    if (f == 0) { print("Error: cannot clear task file.\n"); return 1; }
    close(f); print("All tasks cleared.\n"); return 0;
}

fn main() {
    if (argc() < 2) { help(); return 0; }
    if (streq(argv(1), "add") == 1) { return add_task(); }
    if (streq(argv(1), "list") == 1) { return list_tasks(); }
    if (streq(argv(1), "stats") == 1) { return stats(); }
    if (streq(argv(1), "clear") == 1) { return clear_tasks(); }
    print("Unknown command: "); print(argv(1)); putc(10); help(); return 1;
}
