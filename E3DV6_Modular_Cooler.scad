epsilon = 0.01;
epsilon2 = 2 * epsilon;

airhole_in_dia = 3.5;
airhole_out_dia = 5.1;
airhole_angle = 25;
airhole_extend = 0;
airholes_per_90 = 5;
airhole_min_dist = 14;

chamber_thick = 0.8;
chamber_in_height = 5;
chamber_angle = 20;
chamber_back_wall = 31;
chamber_back_wall_cut = 3;
chamber_back_wall_angle = 45;

wall_thick = 0.8;
wall_out_rad = 3;
wall_angle_in = 30;
wall_angle_in2 = 15;

holder_x = -21.5;
holder_y = 36.2;
holder_z = 60;
holder_wall = 0.8;

holder_xw = 15.15;
holder_yw = 20;
holder_zw = 24;
holder_rad = 23;
holder_ry = 2.9;
holder_rz = 11.4;
holder_cut_xw = 2.4;
holder_cut_zw = 11.35;
holder_cut_x = 8.5;
holder_cut_z = 2;
holder_weak_xw = 1;
holder_weak_zw = 10;
holder_weak_x = 1.2+2+0.5;

hole_x = -22.5;
hole_y = -17.3;
hole_z = 34;
hole_d = 2.9;
hole_wall = 1.2;
hole_depth = 5;
hole_punching = 10;
rod_dia = hole_d+2*hole_wall;
x_rod_angle = 45;
y_rod_angle = 20;
rod_length = 20;

harden = 0.8;

// Calc

ah_step = 90 / (airholes_per_90-1);
ah_dome_len=sqrt(pow(airhole_out_dia/2,2)-pow(airhole_in_dia/2,2));
ah_dia_diff = (airhole_out_dia-airhole_in_dia)/2;
ah_hor_len=(ah_dia_diff+airhole_in_dia)/sin(airhole_angle)+ah_dia_diff*cos(airhole_angle);
//echo (ah_hor_len);
ah_len=ah_hor_len*cos(airhole_angle)-ah_dome_len;
ah_circle=ah_hor_len+airhole_min_dist;

ch_rad_height=chamber_in_height+2*chamber_thick-wall_out_rad;
ch_full_width=2*(ah_circle+wall_out_rad);
ch_out_height=chamber_in_height+2*chamber_thick;
ch_cut_start=-ah_circle*sin(ah_step*2);
ch_cut_y=ah_circle-(chamber_back_wall+ch_cut_start)*tan(wall_angle_in2);

hb_cut_bottom=holder_zw-holder_cut_z-holder_cut_zw;
hb_x=holder_x-holder_cut_x;
hb_y=holder_y-holder_yw;
hb_z=holder_z-hb_cut_bottom;

cp_cut_x=chamber_back_wall-ah_circle-chamber_thick;

// Modules

module airhole_in() {
	$fn=32;
	rotate([0,90+airhole_angle,0])
		translate([-airhole_out_dia/2,0,-airhole_extend])
			cylinder(r=airhole_in_dia/2,h=ah_len+airhole_out_dia+airhole_extend);
}

module airholes_in() {
	for (angle = [-90:ah_step:90])
		rotate([0,0,angle])
			translate([-ah_circle,0,0])
				airhole_in();
}

module airhole_out() {
	$fn=32;
	difference () {
		rotate([0,90+airhole_angle,0])
			translate([-airhole_out_dia/2,0,-airhole_extend]) {
				cylinder(r=airhole_out_dia/2,h=ah_len+airhole_extend);
				translate([0,0,ah_len+airhole_extend])
					sphere(r=airhole_out_dia/2);
			}
		translate([ah_hor_len/2-epsilon,0,-airhole_out_dia/2])
			cube([ah_hor_len+epsilon2,airhole_out_dia,airhole_out_dia],center=true);
	}
}

module airholes_out() {
	for (angle = [-90:ah_step:90])
		rotate([0,0,angle])
			translate([-ah_circle,0,0])
				airhole_out();
}

module chamber_out_peri() {
	$fn=32;
	ch_bank_top_x=wall_out_rad*cos(chamber_angle);
	ch_bank_top_y=wall_out_rad*sin(chamber_angle);
	ch_bank_bottom_x=ch_bank_top_x+(chamber_in_height+ch_bank_top_y)*tan(chamber_angle);
	translate([-ah_circle,0,0]) {
		translate([0,ch_rad_height,0])
			circle(wall_out_rad);
		polygon([[-wall_out_rad,0],[ch_bank_bottom_x,0],[ch_bank_top_x,ch_rad_height+ch_bank_top_y],[-wall_out_rad,ch_rad_height]]);
	}
}

module chamber_box_out() {
	$fn=32;
	x_len=(chamber_back_wall+ch_cut_start+wall_out_rad)*cos(wall_angle_in2);
	y_backwall_out=(chamber_back_wall+ch_cut_start)*tan(wall_angle_in2);
	linear_extrude(height=ch_out_height)
		difference() {
			polygon([[0,ah_circle],[ch_cut_start,ah_circle],[-chamber_back_wall,ch_cut_y],
				[-chamber_back_wall,-ch_cut_y],[ch_cut_start,-ah_circle],[0,-ah_circle]]);
			circle(ah_circle);
		}
	linear_extrude(height=ch_rad_height)
		difference() {
			hull() {
				translate([0,ah_circle])
					circle(wall_out_rad);
				translate([0,-ah_circle])
					circle(wall_out_rad);
				translate([ch_cut_start,ah_circle])
					circle(wall_out_rad);
				translate([ch_cut_start,-ah_circle])
					circle(wall_out_rad);
				translate([-chamber_back_wall,ah_circle-y_backwall_out])
					circle(wall_out_rad);
				translate([-chamber_back_wall,-ah_circle+y_backwall_out])
					circle(wall_out_rad);
			}
			circle(ah_circle);
		}
	translate([ch_cut_start,-ah_circle,ch_rad_height]) {
		sphere(r=wall_out_rad);
		rotate([0,90,0])
			linear_extrude(height=-ch_cut_start)
				circle(wall_out_rad);
		rotate([0,90,180-wall_angle_in2])
			linear_extrude(height=x_len)
				circle(wall_out_rad);
	}
	translate([ch_cut_start,ah_circle,ch_rad_height]) {
		sphere(r=wall_out_rad);
		rotate([0,90,0])
			linear_extrude(height=-ch_cut_start)
				circle(wall_out_rad);
		rotate([0,90,180+wall_angle_in2])
			linear_extrude(height=x_len)
				circle(wall_out_rad);
	}
	translate([-chamber_back_wall+wall_out_rad,ah_circle-y_backwall_out,ch_rad_height]) {
		sphere(r=wall_out_rad);
		rotate([0,90,-90])
			linear_extrude(height=(ah_circle-y_backwall_out)*2)
				circle(wall_out_rad);
	}
	translate([-chamber_back_wall+wall_out_rad,-ah_circle+y_backwall_out,ch_rad_height])
		sphere(r=wall_out_rad);
}

module chamber_box_out_cut() {
	difference() {
		chamber_box_out();
		translate([-chamber_back_wall-10,-ch_full_width/2-epsilon,-epsilon])
			cube([10,ch_full_width+epsilon2,ch_out_height+epsilon2]);
		translate([-chamber_back_wall+chamber_back_wall_cut,-ch_full_width/2-epsilon,-epsilon])
			rotate([0,180+chamber_back_wall_angle,0])
				cube([(chamber_back_wall_cut+1)/cos(chamber_back_wall_angle),ch_full_width+epsilon2,(chamber_back_wall_cut+1)*sin(chamber_back_wall_angle)]);
	}
}

module chamber_out() {
	$fn=128;
	intersection() {
		rotate_extrude()
			chamber_out_peri();
		union() {
			translate([-chamber_back_wall,-ch_full_width/2-epsilon,-epsilon])
				cube([chamber_back_wall,ch_full_width+epsilon2,ch_out_height+epsilon2]);
			translate([0,-ah_circle,-epsilon])
				cube([wall_out_rad,2*ah_circle,ch_out_height+epsilon2]);
			translate([0,-ah_circle,0])
				cylinder(r=wall_out_rad+epsilon,h=ch_out_height+epsilon2);
			translate([0,ah_circle,0])
				cylinder(r=wall_out_rad+epsilon,h=ch_out_height+epsilon2);
		}
	}
	chamber_box_out_cut();
}

module chamber_in_peri() {
	$fn=32;
	wall_now=wall_out_rad-chamber_thick;
	wall_bottom=ah_dia_diff*cos(airhole_angle);
	ch_bank_top_x=wall_now*cos(chamber_angle);
	ch_bank_top_y=wall_now*sin(chamber_angle);
	ch_bank_bottom_x=ch_bank_top_x+(chamber_in_height+ch_bank_top_y-wall_bottom)*tan(chamber_angle);
	translate([-ah_circle,0,0]) {
		translate([0,ch_rad_height,0])
			circle(wall_now);
		polygon([[-wall_now,chamber_thick],[0,wall_bottom],[ch_bank_bottom_x,wall_bottom],
			[ch_bank_top_x,ch_rad_height+ch_bank_top_y],[-wall_now,ch_rad_height]]);
	}
}

module chamber_in() {
	$fn=128;
	intersection() {
		rotate_extrude()
			chamber_in_peri();
		union() {
			translate([-chamber_back_wall,-ch_full_width/2,-epsilon])
				cube([chamber_back_wall,ch_full_width,ch_out_height+epsilon2]);
			translate([0,-ah_circle,0])
				cylinder(r=wall_out_rad-chamber_thick+epsilon,h=ch_out_height+epsilon2);
			translate([0,ah_circle,0])
				cylinder(r=wall_out_rad-chamber_thick+epsilon,h=ch_out_height+epsilon2);
		}
	}
}

module chamber_box_in() {
	$fn=32;
	chamber_in_rad_height=ch_rad_height-chamber_thick;
	wall_now=wall_out_rad-chamber_thick;
	x_len=(chamber_back_wall+ch_cut_start+wall_now)*cos(wall_angle_in2);
	y_backwall_out=(chamber_back_wall+ch_cut_start)*tan(wall_angle_in2);
	linear_extrude(height=chamber_in_height)
		difference() {
			polygon([[0,ah_circle],[ch_cut_start,ah_circle],[-chamber_back_wall,ch_cut_y],
				[-chamber_back_wall,-ch_cut_y],[ch_cut_start,-ah_circle],[0,-ah_circle]]);
			circle(ah_circle,$fn=128);
		}
	ah_now=ah_circle;
	linear_extrude(height=chamber_in_rad_height)
		difference() {
			hull() {
				translate([0,ah_now])
					circle(wall_now);
				translate([0,-ah_now])
					circle(wall_now);
				translate([ch_cut_start,ah_now])
					circle(wall_now);
				translate([ch_cut_start,-ah_now])
					circle(wall_now);
				translate([-chamber_back_wall,ah_now-y_backwall_out])
					circle(wall_now);
				translate([-chamber_back_wall,-ah_now+y_backwall_out])
					circle(wall_now);
			}
			circle(ah_now-epsilon,$fn=128);
		}
	translate([ch_cut_start,-ah_circle,chamber_in_rad_height]) {
		sphere(r=wall_now);
		rotate([0,90,0])
			linear_extrude(height=-ch_cut_start)
				circle(wall_now);
		rotate([0,90,180-wall_angle_in2])
			linear_extrude(height=x_len)
				circle(wall_now);
	}
	translate([ch_cut_start,ah_circle,chamber_in_rad_height]) {
		sphere(r=wall_now);
		rotate([0,90,0])
			linear_extrude(height=-ch_cut_start)
				circle(wall_now);
		rotate([0,90,180+wall_angle_in2])
			linear_extrude(height=x_len)
				circle(wall_now);
	}
	translate([-chamber_back_wall+wall_now,ah_circle-y_backwall_out,chamber_in_rad_height]) {
		sphere(r=wall_now);
		rotate([0,90,-90])
			linear_extrude(height=(ah_circle-y_backwall_out)*2)
				circle(wall_now);
	}
	translate([-chamber_back_wall+wall_now,-ah_circle+y_backwall_out,chamber_in_rad_height])
		sphere(r=wall_now);
}

module chamber_box_in_cut() {
	difference() {
		translate([0,0,chamber_thick])
			chamber_box_in();
		translate([-chamber_back_wall-10+chamber_thick,-ch_full_width/2-epsilon,-epsilon])
			cube([10,ch_full_width+epsilon2,ch_out_height+epsilon2]);
		translate([-chamber_back_wall+chamber_back_wall_cut,-ch_full_width/2-epsilon,chamber_thick-epsilon])
			rotate([0,180+chamber_back_wall_angle,0])
				cube([(chamber_back_wall_cut+1)/cos(chamber_back_wall_angle),ch_full_width+epsilon2,(chamber_back_wall_cut+1)*sin(chamber_back_wall_angle)]);
	}
	translate([-chamber_back_wall+chamber_thick,0,ch_rad_height])
		linear_extrude(height=10)
			polygon([[0,ch_cut_y],[cp_cut_x,ch_cut_y],[cp_cut_x,-ch_cut_y],[0,-ch_cut_y]]);
}

module wall_rad(angle) {
	$fn=16;
	wall_x=-ah_circle*cos(angle);
	wall_y=ah_circle*sin(angle);
	angle_in=sign(angle)*wall_angle_in;
	translate([wall_x,wall_y,0]) {
		difference () {
			cylinder(r=wall_out_rad,h=ch_out_height);
			translate([0,0,-epsilon])
				cylinder(r=wall_out_rad-wall_thick,h=ch_out_height+epsilon2);
			rotate([0,0,-angle])
				translate([0,-wall_out_rad-epsilon,-epsilon])
					cube([wall_out_rad+epsilon,2*wall_out_rad+epsilon2,ch_out_height+epsilon2]);
			rotate([0,0,angle_in])
				translate([-wall_out_rad-epsilon,-wall_out_rad-epsilon,-epsilon])
					cube([wall_out_rad+epsilon,2*wall_out_rad+epsilon2,ch_out_height+epsilon2]);
		}
		rotate([0,0,-angle])
			translate([0,(angle>0)?wall_out_rad-wall_thick:-wall_out_rad,0])
				cube([6,wall_thick,ch_out_height]);
		rotate([0,0,angle_in])
			translate([-20,(angle>0)?wall_out_rad-wall_thick:-wall_out_rad,0])
				cube([20,wall_thick,ch_out_height]);
	}
}

module walls() {
	intersection() {
		union() {
			for (angle = [-90+2*ah_step:ah_step:-ah_step])
				wall_rad(angle);
			for (angle = [ah_step:ah_step:90-2*ah_step])
				wall_rad(angle);
		}
		chamber_out();
	}
}

module chamber() {
	difference() {
		union() {
			airholes_out();
			color("Ivory",0.2)
				chamber_out();
		}
		airholes_in();
		color("DarkCyan",0.7)
			chamber_in();
		color("DarkCyan",0.2)
			chamber_box_in_cut();
	}
	walls();
}

module holder_cut(x) {
	translate([x-holder_weak_xw/2,holder_yw-epsilon,holder_zw-holder_weak_zw])
		cube([holder_weak_xw,holder_wall+epsilon2,holder_weak_zw+epsilon]);
}

module holder() {
	h_wall=2*holder_wall;
	translate([hb_x,hb_y,hb_z]) {
		difference() {
			translate([-holder_wall,-holder_wall,0])
				cube([holder_xw+h_wall,holder_yw+h_wall,holder_zw]);
			translate([0,0,-epsilon])
				cube([holder_xw,holder_yw,holder_zw+epsilon2]);
			translate([holder_xw+holder_wall+epsilon,-holder_ry,holder_zw+holder_rz])
				rotate([0,-90,0])
					cylinder(r=holder_rad,h=holder_xw+h_wall+epsilon2,$fn=64);
			translate([holder_cut_x-holder_cut_xw/2,holder_yw-epsilon,hb_cut_bottom])
				cube([holder_cut_xw,holder_wall+epsilon2,holder_cut_zw]);
			//holder_cut(holder_cut_x-holder_weak_x);
			//holder_cut(holder_cut_x+holder_weak_x);
			}
	}
}

module rod_holder() {
	$fn=32;
	hole_r = hole_d/2+hole_wall;
	translate([hole_x,hole_y,hole_z])
		rotate([0,180,0]) {
			difference() {
				union() {
					cylinder(r=hole_r,h=hole_depth);
					translate([0,0,hole_depth])
						sphere(r=hole_r);
					translate([0,0,hole_depth])
						rotate([-x_rod_angle,y_rod_angle,0])
							cylinder(r=rod_dia/2,h=rod_length);
				}
				cylinder(r=hole_d/2,h=hole_depth+hole_punching,$fn=16);
			}
		}
}

module pipe() {
	difference() {
		union() {
			intersection() {
				translate([0,100,0])
					rotate([90,0,0])
						linear_extrude(height=200)
							polygon([[-chamber_back_wall+cp_cut_x+chamber_thick,ch_out_height],[-chamber_back_wall,ch_out_height],
								[hb_x-holder_wall,hb_z],[hb_x+holder_xw+holder_wall,hb_z]]);
				translate([-100,0,0])
					rotate([90,0,90])
						linear_extrude(height=200)
							polygon([[ch_cut_y+chamber_thick,ch_out_height],[-ch_cut_y-chamber_thick,ch_out_height],
								[hb_y-holder_wall,hb_z],[hb_y+holder_yw+holder_wall,hb_z]]);
			}
			rod_holder();
		}
		intersection() {
			translate([0,100,0])
				rotate([90,0,0])
					linear_extrude(height=200)
						polygon([[-chamber_back_wall+cp_cut_x,ch_out_height-epsilon],[-chamber_back_wall+chamber_thick,ch_out_height-epsilon],
							[hb_x,hb_z+epsilon],[hb_x+holder_xw,hb_z+epsilon]]);
			translate([-100,0,0])
				rotate([90,0,90])
					linear_extrude(height=200)
						polygon([[ch_cut_y,ch_out_height-epsilon],[-ch_cut_y,ch_out_height-epsilon],
							[hb_y,hb_z+epsilon],[hb_y+holder_yw,hb_z+epsilon]]);
		}
	}
}

module harden() {
	$fn=16;
	translate([-chamber_back_wall+cp_cut_x+chamber_thick,0,ch_out_height]) {
		translate([0,-ch_cut_y-chamber_thick,0]) {
			rotate([-90,0,0])
				cylinder(r=harden,h=2*ch_cut_y+2*chamber_thick);
			sphere(harden);
			rotate([0,-90,0])
				cylinder(r=harden,h=cp_cut_x+chamber_thick);
		}
		translate([0,ch_cut_y+chamber_thick,0]) {
			sphere(harden);
			rotate([0,-90,0])
				cylinder(r=harden,h=cp_cut_x+chamber_thick);
		}
	}
}

%color ("green",0.3) {
	airholes_in();
}

%color ("yellow",0.1) {
	translate([0,0,-2])
		cylinder(r=airhole_min_dist,h=2,$fn=128);
	translate([holder_x,holder_y,holder_z])
		sphere(r=1);
	translate([hole_x,hole_y,hole_z])
		cylinder(r=hole_d/2,h=5,$fn=16);
}

%color("red",0.1) {
	translate([-chamber_back_wall-1,0,20])
		cube([2,50,40],center=true);
}

color("Lime",0.7)
	chamber();
color("Cyan",0.7)
	holder();
color("Magenta",0.7)
	pipe();

color("Brown",0.7)
	harden();
