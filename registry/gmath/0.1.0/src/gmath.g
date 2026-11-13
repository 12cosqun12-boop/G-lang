fn gmath_abs(n) { if (n < 0) { return 0 - n; } return n; }
fn gmath_min(a, b) { if (a < b) { return a; } return b; }
fn gmath_max(a, b) { if (a > b) { return a; } return b; }
fn gmath_clamp(n, lo, hi) { if (n < lo) { return lo; } if (n > hi) { return hi; } return n; }
fn gmath_pow(base, exp) { var out; out = 1; while (exp > 0) { out = out * base; exp = exp - 1; } return out; }
fn gmath_gcd(a, b) { var t; a = gmath_abs(a); b = gmath_abs(b); while (b != 0) { t = a % b; a = b; b = t; } return a; }