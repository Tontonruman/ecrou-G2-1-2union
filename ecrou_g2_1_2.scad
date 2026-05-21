// Ecrou union femelle G 2-1/2" BSPP (11 TPI) — version manifold
// Extérieur: Ø75 sans ergots, Ø79 avec ergots
// Intérieur: siège Ø50->Ø58 sur 7 mm, filetage interne (valley-only)
// Longueur totale: 40 mm, 12 ergots

// ----------------- Paramètres -----------------
L_total = 40;
pitch   = 25.4/11;          // 2.3090909 mm

// Filet (mesures + compensations imprimables)
d_crest = 65.8 - 0.15;      // 65.65
d_root  = 64.6 + 0.10;      // 64.70

L_thread = 24;
chf = 1;
cone_L = 7;
cone_d1 = 50;
cone_d2 = 58;
bore_after = 50.2;

outer_d_no_lugs  = 75;      // sans ergots
outer_d_with_lugs= 79;      // avec ergots

lug_n = 12;
lug_radial = (outer_d_with_lugs - outer_d_no_lugs)/2; // 2 mm
lug_w = 8;
lug_ax = 3;

// Marges anti-non-manifold
eps = 0.12;                 // petit jeu radial
zeps = 0.15;                // petit jeu axial

$fn = 260;

// ----------------- Utilitaires -----------------
function t_depth(dc, dr) = (dc - dr)/2;
function r_mean(dc, dr) = dr/2 + t_depth(dc,dr)/2;

// Filetage interne: tore hélicoïdal étroit à soustraire
module valley_55(dc, dr, p, L) {
  depth = t_depth(dc,dr);
  a = 55;
  w = 2*depth / tan(a/2);
  rm = r_mean(dc,dr);

  // Section triangulaire très fine (valley-only)
  module section() {
    polygon(points=[
      [-w/2, depth],
      [ 0,   0    ],
      [ w/2, depth]
    ]);
  }

  turns = L/p;
  // Légère dilatation radiale pour garantir la soustraction
  scale([ (rm+eps)/rm, (rm+eps)/rm, 1 ])
    rotate_extrude(angle=360*turns, convexity=12)
      translate([rm,0,0]) section();
}

// ----------------- Modèle -----------------
module nut() {
  difference() {
    // Fût extérieur (sans ergots)
    cylinder(h=L_total, d=outer_d_no_lugs, center=false);

    // Alésage + siège + arrière, avec marges pour éviter coplanarité
    union() {
      // siège conique (légère extension axiale)
      translate([0,0,-zeps])
        cylinder(h=cone_L+zeps, d1=cone_d1, d2=cone_d2);

      // chanfrein d'entrée
      translate([0,0,cone_L])
        cylinder(h=chf+zeps, d1=cone_d2, d2=d_crest+0.6);

      // portion arrière après filet
      translate([0,0,cone_L+chf+L_thread])
        cylinder(h=L_total-(cone_L+chf+L_thread)+zeps, d=d_crest+0.6);

      // alésage libre derrière siège (sécurité)
      cylinder(h=cone_L, d=cone_d1+eps);
    }

    // Filetage interne: soustraction des vallées uniquement
    translate([0,0,cone_L+chf - zeps])
      valley_55(d_crest, d_root, pitch, L_thread + 2*zeps);
  }

  // Ergots extérieurs jusqu’à Ø79
  for(i=[0:lug_n-1]) {
    rotate([0,0,360*i/lug_n])
      translate([outer_d_no_lugs/2 + lug_radial/2, 0, L_total/2])
        cube([lug_w, lug_radial, L_total-2], center=true);
  }
}

nut();
