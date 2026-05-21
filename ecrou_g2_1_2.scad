// Test A: tube percé + siège conique — DOIT ÊTRE CREUX
$fn = 220;

L_total = 40;
outer_d_no_lugs = 75;

cone_L = 7;
cone_d1 = 50;
cone_d2 = 58;
after_thread_start = cone_L + 1;   // +1 mm de transition
after_thread_endZ  = 33;           // zone arrière libre (40 - 7)

difference() {
  cylinder(h=L_total, d=outer_d_no_lugs);

  // Alésage jusqu'au siège (plein creux garanti)
  union() {
    // Siège conique
    translate([0,0,0]) cylinder(h=cone_L, d1=cone_d1, d2=cone_d2);
    // Transition 1 mm
    translate([0,0,cone_L]) cylinder(h=1, d1=cone_d2, d2=66.5);
    // Arrière libre jusqu'à 40 mm
    translate([0,0,after_thread_endZ]) cylinder(h=L_total-after_thread_endZ, d=66.5);
  }
}
