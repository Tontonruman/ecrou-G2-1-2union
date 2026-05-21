// Ecrou union femelle G 2-1/2" BSPP (11 TPI) — version stable
// Longueur 40 mm, siège Ø50->Ø58 sur 7 mm, 12 ergots
// Conserve la paroi verticale, crée un filetage interne exploitable

// ---------- Paramètres ----------
L_total = 40;
pitch   = 25.4/11;      // 2.3090909 mm

// Mesures utilisateur
d_crest_meas = 65.8;    // crête interne mesurée
d_root_meas  = 64.6;    // fond interne mesuré

// Compensations impression (à ajuster à ta machine)
comp_crest = -0.15;     // réduit légèrement le diamètre de crête
comp_root  = +0.10;     // ouvre légèrement le fond

d_crest = d_crest_meas + comp_crest;
d_root  = d_root_meas  + comp_root;

L_thread = 24;          // longueur filetée utile
chf = 1;                // chanfrein entrée
cone_L = 7;             // profondeur siège
cone_d1 = 50;           // Ø entrée siège
cone_d2 = 58;           // Ø fond siège
bore_after = 50.2;      // passage libre derrière le siège

// Extérieur
outer_d = 66;           // Ø extérieur de base (donne >4.5 mm de paroi mini)
lug_n = 12; lug_h = 2.8; lug_w = 8;

$fn = 220;

// ---------- Aides ----------
function thread_depth(dcrest, droot) = (dcrest - droot)/2; // hauteur de dent
function r_mean(dcrest, droot) = droot/2 + thread_depth(dcrest,droot)/2;

// Taraud “mince” (uniquement la vallée), à soustraire du fût
module tap_internal_55(dcrest, droot, p, L) {
  depth = thread_depth(dcrest,droot);
  a = 55;
  w = 2*depth / tan(a/2);
  rm = r_mean(dcrest,droot);
  turns = L/p;

  // on fabrique un solide hélicoïdal étroit, limité radialement
  rotate_extrude(angle=360*turns, convexity=10)
    translate([rm,0,0])
      polygon(points=[
        [-w/2, depth],   // flanc gauche
        [ 0,    0   ],   // sommet (vers le centre)
        [ w/2, depth]    // flanc droit
      ]);
}

// ---------- Modèle ----------
module nut() {
  // 1) Fût externe plein (paroi assurée)
  difference() {
    cylinder(h=L_total, d=outer_d);

    // 2) Alésages internes (NE PAS retirer la paroi du filet)
    union() {
      // jusqu'au début du siège
      cylinder(h=cone_L, d=cone_d1);
      // siège conique
      cylinder(h=cone_L, d1=cone_d1, d2=cone_d2);
      // chanfrein d'entrée vers la zone filetée
      translate([0,0,cone_L])
        cylinder(h=chf, d1=cone_d2, d2=d_crest+0.4);
      // portion arrière après le filet
      translate([0,0,cone_L+chf+L_thread])
        cylinder(h=L_total-(cone_L+chf+L_thread), d=d_crest+0.4);
    }

    // 3) Filetage interne: on ne retire QUE la vallée du filet
    translate([0,0,cone_L+chf])
      tap_internal_55(d_crest, d_root, pitch, L_thread);
  }

  // 4) Ergots extérieurs
  for(i=[0:lug_n-1]) {
    rotate([0,0,360*i/lug_n])
      translate([outer_d/2,0,L_total/2])
        cube([lug_w,lug_h,L_total-2], center=true);
  }

  // 5) Petit chanfrein extérieur d’entrée (confort)
  difference() {
    // rien à soustraire, juste un visuel: si besoin, commente cette section
  }
}

nut();


