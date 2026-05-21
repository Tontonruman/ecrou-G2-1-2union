// Ecrou union femelle G 2-1/2" BSPP (11 TPI)
// Méthode robuste: taraud hélicoïdal solide soustrait
$fn = 220;

// --------- Paramètres extérieurs ---------
L_total = 40;
outer_d_no_lugs  = 75;
outer_d_with_lugs= 79;
lug_n=12; lug_w=8;
lug_radial = (outer_d_with_lugs-outer_d_no_lugs)/2; // 2 mm

// --------- Paramètres internes ---------
cone_L = 7; cone_d1 = 50; cone_d2 = 58;
L_thread = 24; chf = 1;
pitch = 25.4/11;                  // 2.309 mm, 11 TPI
d_crest = 65.8 - 0.15;            // 65.65 (crêtes internes visées)
d_root  = 64.6 + 0.10;            // 64.70 (fonds internes visés)

// Marges anti-coplanarité
eps = 0.2; zeps = 0.2;

// --------- Taraud hélicoïdal (solide) ---------
// On construit une "vis" interne (profil 55°) puis on la soustrait.
module tap_solid_55(d_crest, d_root, pitch, L) {
  depth = (d_crest - d_root)/2;
  a = 55;
  w = 2*depth / tan(a/2);

  // Profil triangulaire AU RAYON MOYEN, extrudé en helice
  r_mean = d_root/2 + depth/2;

  // Section triangulaire ÉPAISSIE radialement pour bien mordre
  module section() {
    // on fait un trapèze pour être sûr d’enlever de la matière
    polygon(points=[
      [-w/2, -eps],            // pointe vers l'axe
      [ 0,    depth+eps],
      [ w/2, -eps]
    ]);
  }

  turns = L/pitch;

  // On produit un solide hélicoïdal
  rotate_extrude(angle=360*turns, convexity=12)
    translate([r_mean,0,0]) section();
}

// --------- Corps creux + siège ---------
module body_hollow() {
  difference() {
    // Fût extérieur Ø75
    cylinder(h=L_total, d=outer_d_no_lugs);

    // Alésages + siège (avec marges)
    union() {
      // Siège conique
      translate([0,0,-zeps])
        cylinder(h=cone_L+zeps, d1=cone_d1, d2=cone_d2);
      // Transition vers zone filetée
      translate([0,0,cone_L])
        cylinder(h=chf+zeps, d1=cone_d2, d2=d_crest+0.8);
      // Arrière libre
      translate([0,0,cone_L+chf+L_thread])
        cylinder(h=L_total-(cone_L+chf+L_thread)+zeps, d=d_crest+0.8);
    }

    // Taraud hélicoïdal solide — SOUSTRACTION
    translate([0,0,cone_L+chf - zeps])
      tap_solid_55(d_crest, d_root, pitch, L_thread+2*zeps);
  }
}

// --------- Ergots ---------
module lugs(){
  for(i=[0:lug_n-1]){
    rotate([0,0,360*i/lug_n])
      translate([outer_d_no_lugs/2 + lug_radial/2, 0, L_total/2])
        cube([lug_w, lug_radial, L_total-2], center=true);
  }
}

// --------- Assemblage ---------
body_hollow();
lugs();
