// Ecrou union femelle G 2-1/2" BSPP (11 TPI)
// Extérieur: Ø75 sans ergots, Ø79 avec ergots — Longueur 40 mm — 12 ergots
// Intérieur: siège Ø50->Ø58 sur 7 mm + filetage interne (valley-only)
// Version stable/manifold

$fn = 260;

// ----- Paramètres généraux -----
L_total = 40;

// Extérieur
outer_d_no_lugs  = 75;    // sans ergots
outer_d_with_lugs= 79;    // avec ergots
lug_n = 12;
lug_w = 8;
lug_radial = (outer_d_with_lugs - outer_d_no_lugs)/2; // 2 mm

// Siège et zones internes
cone_L = 7;
cone_d1 = 50;
cone_d2 = 58;

// Filet BSPP G 2-1/2" (11 TPI, profil 55°)
pitch   = 25.4/11;        // 2.309 mm
L_thread= 24;
chf     = 1;

// Cotes internes mesurées + petites compensations imprimables
d_crest = 65.8 - 0.15;    // 65.65 mm (crêtes internes)
d_root  = 64.6 + 0.10;    // 64.70 mm (fonds internes)

// Marges anti-non-manifold
eps  = 0.15;              // jeu radial pour la soustraction
zeps = 0.20;              // jeu axial pour éviter les coplanarités

// ----- Fonctions utilitaires -----
function tdepth(dc,dr) = (dc - dr)/2;
function rmean(dc,dr)  = dr/2 + tdepth(dc,dr)/2;

// Hélicoïde triangulaire 55° (vallée du filet) à soustraire
module valley55(dc, dr, p, L) {
  depth = tdepth(dc,dr);
  a = 55;
  w = 2*depth / tan(a/2);
  rm = rmean(dc,dr);
  turns = L / p;

  // Solide hélicoïdal fin (valley); léger surdimensionnement radial
  rotate_extrude(angle = 360*turns, convexity=12)
    translate([rm + eps, 0, 0])
      polygon(points=[
        [-w/2, depth],
        [ 0,   0    ],
        [ w/2, depth]
      ]);
}

// Corps creux + siège + filet
module body_with_thread() {
  difference() {
    // Fût extérieur Ø75
    cylinder(h=L_total, d=outer_d_no_lugs);

    // Alésages droits + siège (avec petites marges)
    union() {
      // Siège conique (prolongé d'un poil vers -Z)
      translate([0,0,-zeps])
        cylinder(h=cone_L + zeps, d1=cone_d1, d2=cone_d2);
      // Transition vers la zone filetée
      translate([0,0,cone_L])
        cylinder(h=chf + zeps, d1=cone_d2, d2=d_crest + 0.8);
      // Arrière libre après le filet
      translate([0,0,cone_L + chf + L_thread])
        cylinder(h=L_total - (cone_L + chf + L_thread) + zeps, d=d_crest + 0.8);
    }

    // Filetage interne: on enlève uniquement la "vallée"
    translate([0,0,cone_L + chf - zeps])
      valley55(d_crest, d_root, pitch, L_thread + 2*zeps);
  }
}

// Ergots extérieurs jusqu’à Ø79
module lugs() {
  for (i = [0:lug_n-1]) {
    rotate([0,0,360*i/lug_n])
      translate([outer_d_no_lugs/2 + lug_radial/2, 0, L_total/2])
        cube([lug_w, lug_radial, L_total-2], center=true);
  }
}

// Assemblage
body_with_thread();
lugs();
