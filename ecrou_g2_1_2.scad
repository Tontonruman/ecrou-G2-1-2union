// Corps creux + siège conique + 12 ergots (PAS DE FILET)
$fn = 220;

L_total = 40;
outer_d_no_lugs = 75;          // Ø sans ergots
outer_d_with_lugs = 79;        // Ø avec ergots
lug_n=12; lug_w=8; lug_radial=(outer_d_with_lugs-outer_d_no_lugs)/2; // =2 mm

// Siège conique
cone_L=7; cone_d1=50; cone_d2=58;

// Alésage arrière (diamètre légèrement > à la zone filetée)
d_after = 66.5;

module body_hollow(){
  difference(){
    // fût extérieur
    color("yellow") cylinder(h=L_total, d=outer_d_no_lugs);
    // perçage + siège + arrière
    union(){
      // siège Ø50->Ø58 sur 7 mm
      color("red") cylinder(h=cone_L, d1=cone_d1, d2=cone_d2);
      // petite transition 1 mm
      translate([0,0,cone_L]) cylinder(h=1, d1=cone_d2, d2=d_after);
      // arrière libre jusqu’à 40 mm
      translate([0,0,33]) cylinder(h=7, d=d_after);
    }
  }
}

module lugs(){
  for(i=[0:lug_n-1]){
    rotate([0,0,360*i/lug_n])
      translate([outer_d_no_lugs/2 + lug_radial/2,0,L_total/2])
        cube([lug_w, lug_radial, L_total-2], center=true);
  }
}

body_hollow();
lugs();
