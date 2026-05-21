// Ecrou union femelle G 2-1/2" BSPP (11 TPI)
// Longueur 40 mm, siège Ø50->Ø58 sur 7 mm, 12 ergots
// Version corrigée: alésage + filetage interne OK

// ----- Paramètres -----
L_total = 40;
pitch   = 25.4/11;      // 2.3090909 mm
d_crest = 65.8;         // crête mesurée
d_root  = 64.6;         // fond mesuré
comp_crest = -0.15;     // compensation imprimable
comp_root  = +0.10;
d_crest_model = d_crest + comp_crest;
d_root_model  = d_root  + comp_root;

L_thread = 24;          // longueur filetée utile
chf = 1;                // chanfrein entrée
cone_L = 7;             // profondeur siège
cone_d1 = 50;           // Ø entrée siège
cone_d2 = 58;           // Ø fond siège
bore_after = 50.2;      // passage libre derrière siège

outer_d = 65;           // Ø extérieur (hors ergots)
lug_n = 12; lug_h = 2.8; lug_w = 8;

$fn = 240;

// ---- Profil de filet 55° (interne) ----
module thread55_internal(d_crest, d_root, p, L, z0=0) {
  depth = (d_crest - d_root)/2;     // hauteur de dent
  a = 55;                           // angle total
  w = 2*depth / tan(a/2);           // largeur au radius moyen
  r_mean = d_root/2 + depth/2;      // rayon moyen
  turns = L/p;

  // On crée un “taraud” solide puis on le soustrait
  difference() {
    // cylindre porteur du taraud (grand pour assurer la soustraction)
    translate([0,0,z0])
      cylinder(h=L+2, d=d_crest+4, center=false);

    // enlève l'hélicoïde pour ne garder que le taraud négatif
    translate([0,0,z0])
      rotate_extrude(angle=360*turns, convexity=10)
        translate([r_mean,0,0])
          polygon(points=[
            [-w/2, depth],
            [ 0,   0    ],
            [ w/2, depth]
          ]);
  }
}

// ---- Corps + soustractions ----
module nut() {
  difference() {
    // Fût externe plein
    cylinder(h=L_total, d=outer_d);

    // 1) Alésage libre + siège conique
    union() {
      // alésage jusqu'au début du siège
      cylinder(h=cone_L, d=cone_d1);
      // siège conique Ø50 -> Ø58
      cylinder(h=cone_L, d1=cone_d1, d2=cone_d2);
      // chanfrein d'entrée vers la zone filetée
      translate([0,0,cone_L])
        cylinder(h=chf, d1=cone_d2, d2=d_crest_model+0.6);
      // alésage après le filet (partie arrière)
      translate([0,0,cone_L+chf+L_thread])
        cylinder(h=L_total-(cone_L+chf+L_thread), d=d_crest_model+0.6);
    }

    // 2) Filetage interne (soustraction)
    thread55_internal(d_crest_model, d_root_model, pitch, L_thread, z0=cone_L+chf);
  }

  // 3) Ergots extérieurs
  for(i=[0:lug_n-1]) {
    rotate([0,0,360*i/lug_n])
      translate([outer_d/2,0,L_total/2])
        cube([lug_w,lug_h,L_total-2], center=true);
  }
}

nut();

