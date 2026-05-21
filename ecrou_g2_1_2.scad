$fn = 120;

L_total = 40;
outer_d_no_lugs = 75;

// Corps creux minimal
difference() {
  color("yellow") cylinder(h=L_total, d=outer_d_no_lugs);
  color("red")    cylinder(h=L_total, d=60);
}

// 12 ergots très visibles (saillie 4 mm, largeur 10 mm)
lug_n = 12;
lug_radial = 4;   // saillie radiale volontairement grande pour le test
lug_w = 10;

for (i = [0:lug_n-1]) {
  rotate([0,0,360*i/lug_n])
    // Placement: milieu de l’épaisseur, à l’extérieur
    translate([outer_d_no_lugs/2 + lug_radial/2, 0, L_total/2])
      color("blue") cube([lug_w, lug_radial, L_total-2], center=true);
}
