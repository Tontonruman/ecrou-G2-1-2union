// Ecrou union femelle G 2-1/2" BSPP (11 TPI) — dimensions extérieures corrigées
// L_total 40 mm, siège Ø50->Ø58 sur 7 mm, 12 ergots
// Extérieur: Ø75 sans ergots, Ø79 avec ergots

// ---------- Paramètres ----------
L_total = 40;
pitch   = 25.4/11;      // 2.3090909 mm

// Filet (mesures utilisateur) + compensations imprimable
d_crest_meas = 65.8;    // diamètre crête interne mesuré
d_root_meas  = 64.6;    // diamètre fond interne mesuré
comp_crest = -0.15;     // à ajuster selon ta machine
comp_root  = +0.10;

d_crest = d_crest_meas + comp_crest;   // 65.65
d_root  = d_root_meas  + comp_root;    // 64.70

L_thread = 24;          // longueur filetée utile
chf = 1;                // chanfrein d'entrée
cone_L = 7;             // profondeur siège
cone_d1 = 50;           // Ø entrée siège
cone_d2 = 58;           // Ø fond siège
bore_after = 50.2;      // passage libre derrière le siège

// Extérieur
outer_d_no_lugs = 75;   // Ø sans ergots
outer_d_with_lugs = 79; // Ø avec ergots
lug_n = 12;
lug_radial = (outer_d_with_lugs - outer_d_no_lugs)/2; // 2 mm de saillie
lug_w = 8;             // largeur développée
lug_h_axial = 3;       // hauteur axiale (dans la direction y du cube)

// Qualité
$fn = 240;

// ---------- Utilitaires ----------
function thread_depth(dc, dr) = (dc - dr)/2;
function r_mean(dc, dr) = dr/2 + thread_depth(dc,dr)/2;

// Taraud “mince” (valleys only) à soustraire
module tap_internal_55(dc, dr, p, L) {
  depth = thread_depth(dc,dr);
  a = 55;
  w = 2*depth / tan(a/2);
  rm = r_mean(dc,dr);
  turns = L/p;

  // solide hélicoïdal étroit
  rotate_extrude(angle=360*turns, convexity=10)
    translate([rm,0,0])
      polygon(points=[
        [-w/2, depth],
        [ 0,   0    ],
        [ w/2, depth]
      ]);
}

// ---------- Modèle principal ----------
module nut_body() {
  // 1) Fût extérieur Ø75 (sans ergots)
  difference() {
    cylinder(h=L_total, d=outer_d_no_lugs);

    // 2) Alésages droits + siège conique + zones libres
    union() {
      // entrée et siège
      cylinder(h=cone_L, d1=cone_d1, d2=cone_d2);
      // chanfrein vers zone filetée
      translate([0,0,cone_L])
        cylinder(h=chf, d1=cone_d2, d2=d_crest+0.6);
      // portion arrière après la zone filetée
      translate([0,0,cone_L+chf+L_thread])
        cylinder(h=L_total-(cone_L+chf+L_thread), d=d_crest+0.6);
    }

    // 3) Filetage interne: soustraction vallée seulement
    translate([0,0,cone_L+chf])
      tap_internal_55(d_crest, d_root, pitch, L_thread);
  }

  // 4) Ergots pour atteindre Ø79
  // rayon base = outer_d_no_lugs/2 ; on ajoute lug_radial en saillie
  for(i=[0:lug_n-1]) {
    rotate([0,0,360*i/lug_n])
      translate([outer_d_no_lugs/2, 0, L_total/2])
        cube([lug_w, 2*lug_radial, L_total-2], center=true);
  }
}

nut_body();
