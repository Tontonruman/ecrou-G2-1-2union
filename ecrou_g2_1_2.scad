// Ecrou union femelle G 2-1/2" BSPP (11 TPI)
// Longueur 40 mm, siège conique Ø50->Ø58 sur 7 mm, 12 ergots
// Auteur: Tontonruman + paramètres fournis
// Licence: CC BY-SA 4.0

// ----- Paramètres -----
L_total = 40;           // longueur totale
pitch   = 25.4/11;      // 2.3090909 mm
d_crest = 65.8;         // diamètre crête mesuré
d_root  = 64.6;         // diamètre fond mesuré
comp_crest = -0.15;     // compensation imprimable crêtes
comp_root  = +0.10;     // compensation imprimable fonds
d_crest_model = d_crest + comp_crest;
d_root_model  = d_root  + comp_root;

L_thread = 24;          // longueur filetée utile
chf = 1;                // chanfrein d'entrée 1x45°
cone_L = 7;             // profondeur du siège
cone_d1 = 50;           // Ø entrée siège
cone_d2 = 58;           // Ø fond siège
bore_after = 50.2;      // passage libre derrière le siège

outer_d = 65;           // Ø extérieur cylindre de base (hors ergots)
lug_n = 12;             // nombre d'ergots
lug_h = 2.8;            // hauteur des ergots
lug_w = 8;              // largeur en développement
r_internal = 0.8;       // rayons internes généraux

$fn = 240;

// ----- Modules -----
module nut_body() {
  difference() {
    // fût externe
    cylinder(h=L_total, d=outer_d);

    // alésage libre jusqu'au siège
    cylinder(h=cone_L, d=cone_d1);

    // siège conique Ø50 -> Ø58 sur 7 mm
    cylinder(h=cone_L, d1=cone_d1, d2=cone_d2);

    // chanfrein d'entrée entre siège et début filet
    translate([0,0,cone_L])
      cylinder(h=chf, d1=cone_d2, d2=d_crest_model+0.6);

    // alésage derrière le filet (surplus léger)
    translate([0,0,cone_L+chf+L_thread])
      cylinder(h=L_total-(cone_L+chf+L_thread), d=d_crest_model+0.6);

    // filetage interne hélicoïdal 55° (approx)
    thread_internal(d_crest_model, d_root_model, pitch, L_thread, z0=cone_L+chf);
  }

  // ergots extérieurs
  for(i=[0:lug_n-1]) {
    rotate([0,0,360*i/lug_n])
      translate([outer_d/2,0,L_total/2])
        minkowski() {
          cube([lug_w,lug_h,L_total-2], center=true);
          sphere(r=0.6, $fn=36);
        }
  }
}

// Filetage interne approximé 55°
module thread_internal(d_crest, d_root, p, L, z0=0) {
  // profondeur moitié (crête->fond)
  depth = (d_crest - d_root)/2;
  a = 55; // angle total
  // largeur du triangle à la base (au diamètre moyen)
  w = 2*depth / tan(a/2);
  r_mean = d_root/2 + depth/2;
  turns = L/p;

  // profil triangulaire simple (arrondis laissés à l'impression)
  translate([0,0,z0])
    rotate_extrude(angle=360*turns, convexity=10)
      translate([r_mean,0,0])
        polygon(points=[
          [-w/2, depth],
          [ 0,   0    ],
          [ w/2, depth]
        ]);
}

// ----- Build -----
nut_body();
