loop = $preview ? pow(0.5*(cos($t*360)+1),2) : 1;

$fn = $preview ? 60 : 600;

c_w = 5.9/2;
cb_h = 14.1;
bh = cb_h/4*2;

module round_in(r=1) {
    offset(r=-r) offset(delta=r) children();
}

module round_out(r=1) {
    offset(r=r) offset(r=-r/2) children();
}

// r - radius (outer)
// h - height
// th - thickness (towards inside)
module capsule(r, h, th=0.1) {
    rotate_extrude() {
        union() {
            polygon(points=[[r-th,r],[r,r],[r,h],[r-th,h]]);
            intersection(){
                translate([0,r,0]) difference() {
                    circle(r);
                    circle(r-th);
                }
                square(r);
            }
        }
    }
}

// r - radius
// h - depth of hole
// hr - hole raius
// t - thickness of bottom layer
module base(r, h, hr, t, cap_width = 3, detail = 0.4) {
    rotate_extrude() {
        polygon(points=[[1,0],[r,0],[r,h+t-cap_width+detail],[r-detail,h+t-cap_width+detail],[r-cap_width,h+t],[hr,h+t],[hr,t+detail],[hr-detail,t],[1,t]]);
    }
}

// r - radius
// h - depth of hole
// hr - hole raius
// t - thickness of bottom layer
module base2(r, h, hr, t, cap_width = 3, detail = 0.4) {
    rotate_extrude() {
        polygon(points=[
            [1,0],
            [r,0],
            [r,t+detail],
            [r-detail,t+detail],
            [r-cap_width-detail,t+detail+cap_width],
            [hr+3*detail,t+detail+cap_width],
            [hr+2*detail,t+2*detail+cap_width],
            [hr+2*detail,t+h-detail],
            [hr+detail,t+h],
            [hr+detail,t+h],
            [hr,t+h],
            [hr,t+detail],
            [hr-detail,t],
            [1,t]]);
    }
}

module funnel(r, cap_width = 3, detail = 0.4) {
    rotate_extrude() {
        polygon(points=[
            [r-cap_width,bh],
            [r-detail,bh-cap_width+detail],
            [r,bh-cap_width+detail],
            [r,cb_h+1+r-c_w-max(2,detail)],
            [r-max(2,detail),cb_h+1+r-c_w-max(2,detail)],
            [c_w-0.6-detail,cb_h+1],
            [c_w-0.6-detail,cb_h-2],
            [c_w-0.6,cb_h-2],
            [c_w-0.6,cb_h+0.1-detail],
            [c_w-0.6+detail,cb_h+0.1],
            [r-cap_width-1,cb_h+0.1],
            [r-cap_width,cb_h+0.1-1]]);
    }
}

// r - radius
// ch - height of capsule
// cr - radius of capsule (inner)
module funnel2(r, ch, cr, cap_width = 3, detail = 0.4) {
    rotate_extrude() {
        polygon(points=[
            [r-detail-cap_width,detail+cap_width],
            [r-detail,detail],
            [r,detail],
            [r,ch+detail],
            // top flat part (for printing)
            [r,        ch+detail+detail+(r-(cr-detail))-2],
            // funnel part
            [r-2,      ch+detail+detail+r-(cr-detail)-2],
            [cr-detail,ch+detail+detail],
            // part that goes into the capsule
            [cr-detail,ch+detail-5],
            [cr,ch+detail-5],
            [cr,ch+detail-detail],
            [cr+detail,ch+detail],
            [r-detail-cap_width-detail,detail+ch],
            [r-detail-cap_width,detail+ch-detail]]);
    }
}

//let( w = 26/2, bt = 0.4, cap_width = 3, detail = 0.4 )
//translate([0,0,0]) difference() {
//    union() {
//        base(w, bh, c_w, bt, cap_width, detail);
//        if ($preview) translate ([0,0,bt+loop*20]) rotate([0]) color([1,0,0,1,min(0.7+loop*0.4,1)]) {
//            funnel(w, cap_width, detail);
//        }
//        translate([30,0,cb_h+1+w-c_w-2]) rotate([180]) {
//            funnel(w, cap_width, detail);
//        }
//        translate([0,0,bt-0.1+loop*10]) {
//            color([1,1,1,0.7]) {
//                if ($preview) capsule(5.56/2,cb_h,0.13);
//            }
//        }
//    }
//    if ($preview) rotate(-80) translate([0,0,-1]) cube([w,w,2*cb_h+20*loop]);
//    translate([0,-w/2,bh+bt-0.2]) linear_extrude(0.3, center=false)
//         round_out(0.1) round_in(0.1) text("3", font = "DejaVu Sans Mono", size = 3, halign = "center", valign = "center");
//}

// cr - capsule base radius
// ch - capsule base height
// ct - capsule base thickness
module mk(label, cr, ch, ct) let(r = 26/2, hr = ceil(cr*10.4)/10, fr=floor((cr-ct)*9.6)/10, bh=ch/4*2, bt=0.4, cap_width = 3, detail = 0.4) {
    difference() {
        union() {
            difference() {
                base2(r, ch/4*2, hr, 0.4, cap_width, detail);
                translate([0,-hr-detail-(r-hr-detail-cap_width)/2,bt+detail+cap_width-0.2])
                    linear_extrude(0.3, center=false)
                    round_out(0.1) round_in(0.1)
                    text(label, font = "DejaVu Sans Mono", size = 2, halign = "center", valign = "center");
            }
            if ($preview)
                color([1,0,0])
                translate([0,0,bt+loop*2*ch])
                funnel2(r, ch, fr, cap_width, detail);
            else
                translate([-30,0,ch+detail+detail+r-(cr-detail)-2+detail]) rotate([180])
                    funnel2(r, ch, fr, cap_width, detail);
            if ($preview)
                translate([0,0,bt-0.9*(cr-cr*cos(asin(1/cr)))+loop*1*ch])
                color([1,1,1,0.7])
                capsule(cr,ch,ct);
        }
        if ($preview) rotate(-80) translate([0,0,-1]) cube([r,r,2*ch+loop*2*ch]);
    }
}

dist = 40;
// 000
translate([0,1*dist,0]) mk("000", 9.55/2, 22.20+0.51, 0.110+0.03);
// 00
translate([0,2*dist,0]) mk("00",  8.18/2, 20.22+0.51, 0.107+0.03);
// 0
translate([0,3*dist,0]) mk("0",   7.34/2, 18.44+0.51, 0.104+0.03);
// 1
translate([0,4*dist,0]) mk("1",   6.63/2, 16.61+0.51, 0.102+0.03);
// 2
translate([0,5*dist,0]) mk("2",   6.07/2, 15.27+0.51, 0.099+0.03);
// 3
translate([0,6*dist,0]) mk("3",   5.56/2, 13.59+0.51, 0.098+0.03);
// 4
translate([0,7*dist,0]) mk("4",   5.05/2, 12.19+0.51, 0.091+0.03);
// 5
translate([0,8*dist,0]) mk("5",   4.68/2,  9.32+0.51, 0.086+0.03);
