$fn=100;
difference() {
  color("yellow") cylinder(h=40,d=75);
  color("red")    translate([0,0,0]) cylinder(h=40,d=60);
}
