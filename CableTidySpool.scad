// Height
H = 20; // [10:200]

// Width
W = 25; // [10:200]

// Length
L = 70; // [50:200]

// Cable Diameter (30 = 3mm)
C = 30; // [10:5:60]

// Rim Height
R = 2; // [5]


/* [Hidden] */
rim_angle = 50;
lip = 0.964; // straight part of the rim
th=1.67;


c = C/10; // to have mm

module sidecut() {
    polygon([
    [R+th+R, -H/2],
    [R, -H/2],
    [R, -H/2 + lip],
    [0, -H/2 + lip + R * tan(rim_angle)],
    [0,  H/2 - lip - R * tan(rim_angle)],
    [R,  H/2 - lip],
    [R,  H/2],
    [R+th+R, H/2],
    ]);
}

module base_silu() {
    
    translate([W/2-R-th,0])
    difference() {
        sidecut();
        translate([th, 0])
        sidecut();
    }
}

module struct_fin() {
    translate([W/2-R-th,0])
    rotate([90,0,0])
    linear_extrude(th, center = true)
    difference() {
        polygon([
            [ R, -H/2],
            [ 0, -H/2],
            [-R, -H/2 + R ],
            [-R,  H/2 - R ],
            [ 0,  H/2],
            [ R, H/2],
        ]);
        sidecut();
    }
}

module half_spool() {
    rotate([90,0,0])
    linear_extrude(L - W, center = true)
    base_silu();

    translate([0, L/2 - W/2, 0])
    rotate_extrude(angle=180, $fn=180)
    base_silu();
    
    struct_fin();
}    

module cable_half_slot() {
    chamf = 0.6;
    cable_hole = (c+th) / sin(45);    
    offset = R - 0.5;
    
    rotate(90)
    polygon([
        [0,0],
        [c/2 + chamf, 0],
        [c/2, -chamf],
        [c/2, -offset],
        [cable_hole/2, -offset - (cable_hole - c) / 2 / tan(50)],
        // tan(25) thing has no good reason to exist
        [cable_hole/2, -offset - (cable_hole - c) / 2 / tan(50) - (c+0.2) * tan(25)],
        [2, -offset - (cable_hole - c/2 - 2) / tan(50) - (c+0.2) * tan(25)],
        [0, -offset - (cable_hole - c/2 - 2) / tan(50) - (c+0.2) * tan(25) ],
    ]);
}

module cable_slot() {
    union() {
        mirror([0,1])
        cable_half_slot();
        cable_half_slot();
    }
}

module solid_spool() {
    rotate(180)
    half_spool();
    half_spool();
}



module cable_cutter() {
    translate([0, (L - W) / 4, H/2])
    rotate([0, 90, 0])
    linear_extrude(W*2, center=true, convexity = 4)
    cable_slot();
}






color("gray")
difference() {
    solid_spool();
    cable_cutter();
    mirror([0, 1, 0]) cable_cutter();
    mirror([0, 0, 1]) cable_cutter();
    rotate([180, 0, 0]) cable_cutter();
}
