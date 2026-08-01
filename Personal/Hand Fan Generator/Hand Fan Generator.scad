// Hand Fan Generator
// -----------------------------------------------------------------------------
// Generates the individual blades (plus the pivot peg and its cap) for a folding
// handheld personal fan.  Blades stack on a pivot peg through the Bottom
// Connection Hole and are linked to each other by a Connection Slot Peg that
// rides in the neighbouring blade's Connection Slot, so the fan opens and closes.
//
// Two blade variants alternate through the stack:
//   Blade Section A - Connection Slot Peg sits in the TOP slot, at the right end
//   Blade Section B - Connection Slot Peg sits in the BOTTOM slot, at the right end
// Alternating which slot carries the peg keeps neighbouring pegs from colliding.
//
// Geometry reference: "Hand Fan Sample Blade A/B.stl", "Hand Fan Sample Connector
// Peg.stl" and "Hand Fan Sample Connector Peg Cap.stl" in this folder.
//
// Orientation used throughout: the blade lies flat in XY, extruded along +Z.
//   Y = 0 ............ bottom of the blade (the hand-held end, narrow)
//   Y = Blade_Length . top of the blade (the far end, wide)
//   X ................ blade width, centred on X = 0
// -----------------------------------------------------------------------------

/* [Blade Parameters] */
// Total number of blades that make up the whole fan
Number_Of_Blades = 16;          // [2:1:60]
// Total length of a single fan blade (mm)
Blade_Length = 180;             // [60:1:400]
// Thickness of the fan blade (mm)
Blade_Thickness = 1.3;            // [0.6:0.1:6]
// Width of the top (far) end of the blade (mm)
Top_Blade_Width = 30;           // [8:0.5:120]
// Width of the bottom (hand-held) end of the blade (mm)
Bottom_Blade_Width = 16;        // [8:0.5:120]
// Corner rounding at the top (far) end of the blade (mm)
Top_Corner_Rounding = 1.5;      // [0:0.5:40]
// Corner rounding at the bottom (hand-held) end of the blade (mm)
Bottom_Corner_Rounding = 3;     // [0:0.5:40]

/* [Blade Cutouts] */
// Pattern cut through (or etched into) the body of each blade
Blade_Cutouts = "none";         // [none:None, voronoi:Voronoi, gradient_voronoi:Gradient Voronoi, honeycomb:Honeycomb, variable_honeycomb:Variable Honeycomb, hearts:Hearts, triangular:Triangular, isometric_triangular:Isometric Triangular, delaunay:Delaunay Triangulation, penrose:Penrose Tiling, diamond:Diamond, circular:Circular, staggered_circular:Staggered Circular, rounded_squares:Rounded Squares, slots:Slots, gyroid:Gyroid, wave:Wave, wave_field:Parametric Wave Field, reaction_diffusion:Reaction-Diffusion, leaf_veins:Biomimetic Leaf Veins, islamic:Islamic Geometry, fish_scales:Fish Scales, vertical_text:Vertical Text, horizontal_text:Horizontal Text, svg:SVG Image]
// Font used for the Vertical and Horizontal text cutouts
Blade_Cutout_Text_Font = "Anton";   // [Anton, Bangers, Bebas Neue, Archivo Black, Black Ops One, Fredoka One, Lilita One, Luckiest Guy, Passion One, Bowlby One, Titan One, Alfa Slab One, Ultra, Chango, Paytone One, Russo One, Carter One, Sigmar One, Concert One, Patua One, Staatliches, Righteous, Squada One, Permanent Marker, Bungee, Changa One, Oswald, Montserrat, Arial, Avenir Next Condensed, Georgia, Liberation Sans]
// Font size / cap height for the Vertical and Horizontal text cutouts (mm)
Blade_Cutout_Text_Size = 10;    // [3:0.5:60]
// How deep text and SVG artwork are etched into the blade face (mm)
Blade_Cutout_Text_Depth = 0.4;  // [0.1:0.1:5]
// Colour of the etched text / artwork (shown in preview, for colour-change prints)
Blade_Cutout_Text_Color = "red"; // [white, black, red, orange, yellow, green, blue, purple, pink, gray, silver, gold, brown, cyan, magenta, navy, teal, maroon]
// Text used by the Vertical Text cutout
Blade_Cutout_Vertical_Text = "";
// First line of text used by the Horizontal Text cutout (spread across the blades)
Blade_Cutout_Horizontal_Text_Line_1 = "";
// Optional second line for the Horizontal Text cutout (leave blank for a single line)
Blade_Cutout_Horizontal_Text_Line_2 = "";
// Etched into the underside of the first blade - the face left showing when the
// closed fan is turned over.  Leave blank for none.  Uses the font, size, depth and
// colour set above.
Personalized_Name = "";
// Path to the drawing used by the SVG cutout, e.g. /Users/me/art/crest.svg
// (surrounding ' quotes, as a terminal adds to paths with spaces, are ignored)
Blade_Cutout_SVG_File = "";
// Height of the SVG artwork on the spread fan, measured along the blades (mm)
Blade_Cutout_SVG_Height = 60;   // [5:1:250]
// Width across the spread fan; leave at 0 to take it from the artwork's proportions (mm)
Blade_Cutout_SVG_Width = 0;     // [0:1:400]
// Scales the artwork after it has been fitted to the size above (%)
Blade_Cutout_SVG_Scale = 100;   // [5:1:500]


/* [Rendering] */
// Which part(s) to generate, and in what orientation
Rendering_Mode = "printing";    // [printing:All Blades for Printing, assembly:Assembly View, section_a:Blade Section A, section_b:Blade Section B, hardware:Connector Peg and Cap only]

/* [Hidden] */
//----/* [Top Connection] */
// Vertical gap between the top of the blade and the underside of the peg's flared head (mm)
Connection_Slot_Peg_Tolerance = 0.4;            // [0:0.05:2]

//----/* [Bottom Connection] */
// Diameter of the pivot hole near the bottom of the blade (mm)
Blade_Bottom_Connection_Hole_Diameter = 4;      // [1:0.1:15]
// Distance from the bottom of the blade to the bottom of the pivot hole (mm)
Blade_Bottom_Connection_Hole_Bottom_Margin = 10; // [2:0.5:120]
// Radial gap between the peg shaft and the pivot hole (mm)
Blade_Bottom_Connection_Peg_Tolerance = 0.2;    // [0:0.05:1]
// Gap between the bottom of the peg cap and the top of the blade stack (mm)
Blade_Bottom_Connection_Peg_Cap_Tolerance = 2.5;  // [0:0.1:5]
// Diameter of the peg base disc (mm)
Blade_Bottom_Connection_Peg_Base_Diameter = 8;  // [4:0.5:30]
// Thickness of the peg base disc, below the shaft (mm)
Blade_Bottom_Connection_Peg_Base_Thickness = 2; // [0.6:0.1:10]
// Diameter of the peg cap (mm)
Blade_Bottom_Connection_Peg_Cap_Diameter = 8;   // [4:0.5:30]
// Overall thickness of the peg cap, ignoring the shaft socket (mm)
Blade_Bottom_Connection_Peg_Cap_Thickness = 3;  // [1:0.1:12]
// Tolerance between the peg shaft and the socket in the peg cap (mm)
Peg_Cap_Shaft_Tolerance = 0.2;                 // [0:0.05:1]

// A spare peg and cap are printed alongside the fitted pair, in case the first pair
// seats too loosely or too tightly.  The spare peg is this much longer, the spare
// cap's shaft bore this much tighter, and both are drawn in this colour so they are
// easy to tell apart on the plate.
Spare_Peg_Extra_Length = 1;
Spare_Cap_Tolerance_Reduction = 0.1;
Spare_Hardware_Color = "blue";

// How much of the peg cap's thickness is bored out for the shaft (%).  100 runs the
// shaft clean through, leaving its end flush with the top of the cap; 30 sinks it
// only a third of the way in and leaves the rest of the cap solid.  Clamped to 30-100.
Peg_Cap_Socket_Percent = 80;

// ---- Cutout pattern placement (hidden per spec) ----------------------------
// How far from the top end of the blade the cutout pattern stops
Blade_Cutout_Top_Margin = 25;
// How far from the bottom end of the blade before the cutout pattern may start
Blade_Cutout_Bottom_Margin = 80;
// How close to the blade edges the cutout pattern may run
Blade_Cutout_Side_Margins = 5;
// Minimum material left between neighbouring holes in a cutout pattern
Blade_Cutout_Pattern_Inner_Wall_Thickness = 2;

// ---- Connection slot geometry (hidden per spec) ----------------------------
// Margin between the end of a connector slot and the edge of the blade
Blade_Connection_Slot_Side_Margin = 2;
// Margin between the top end of the blade and the top edge of the top slot
Blade_Connection_Slot_Top_Margin = 6;
// Margin between the bottom of the top slot and the top of the bottom slot
Blade_Connection_Slot_Inner_Margin = 4;
// Total height of an individual connection slot
Blade_Connection_Slot_Height = 6;
// How far the retaining lip reaches into the slot from the top and bottom edges
Blade_Connection_Slot_Lip_Width = 1.6;
// Gap between the slot peg neck and the lip edges it slides between
Blade_Connection_Slot_Peg_Tolerance = 0.5;
// Width of the slot peg itself, measured along the X axis
Blade_Connection_Slot_Peg_Width = 3;

// ---- Shape / pattern tuning ------------------------------------------------
// Thickness (in Z) of the retaining lip, measured up from the blade's bottom face
//Blade_Connection_Slot_Lip_Thickness = min(Blade_Thickness * 0.4, Blade_Thickness - 0.2);
Blade_Connection_Slot_Lip_Thickness = 0.3;
// Height of the slot peg's flared head
Connection_Slot_Peg_Head_Height = Blade_Thickness - Blade_Connection_Slot_Lip_Thickness - Connection_Slot_Peg_Tolerance;
// Nominal cell sizes for the generated patterns
Voronoi_Cell_Size = 6;
Voronoi_Seed = 12;
Honeycomb_Cell_Size = 6;
Hearts_Base_Size = 6;
Hearts_Seed = 7;
// ---- Geometric pattern sizing ----------------------------------------------
// Side length of one triangle in the Triangular grid
Triangular_Cell_Size = 8;
// Rhombus side (= hexagon circumradius) of one isometric cube motif
Isometric_Cell_Size = 8;
// Width of one Diamond cell, and its height as a multiple of that width
Diamond_Cell_Width = 6;
Diamond_Aspect = 1.5;
// Hole diameter for the Circular and Staggered Circular grids
Circular_Hole_Diameter = 4;
Staggered_Circular_Hole_Diameter = 4;
// Side and corner rounding of the Rounded Squares holes
Rounded_Square_Size = 4;
Rounded_Square_Rounding = 0.5;
// Width and length of one Slots hole
Slot_Hole_Width = 3;
Slot_Hole_Length = 8;
// Gyroid unit cell, extra web thickness beyond the minimum wall (0 gives a web of
// exactly one wall thickness), and the width of the slices used to trace contours
Gyroid_Cell_Size = 8;
Gyroid_Threshold = 0;
Gyroid_Strip_Width = 1.2;
// Spacing, height and wavelength of the Wave bands
Wave_Pitch = 4;
Wave_Amplitude = 2.5;
Wave_Wavelength = 26;
// Point radius of the eight-pointed star in the Islamic Geometry lattice
Islamic_Star_Radius = 5;
// Radius of one scale in the Fish Scales pattern
Fish_Scale_Radius = 3;

// ---- Generative pattern sizing ---------------------------------------------
// Delaunay: spacing of the point cloud that gets triangulated, and its seed
Delaunay_Cell_Size = 8;
Delaunay_Seed = 5;
// Gradient Voronoi: cell size at the bottom and top of the band, and its seed
Gradient_Voronoi_Cell_Bottom = 3;
Gradient_Voronoi_Cell_Top = 8;
Gradient_Voronoi_Seed = 3;
// Variable honeycomb: hexagon width at the bottom and top of the band
Variable_Honeycomb_Cell_Bottom = 3;
Variable_Honeycomb_Cell_Top = 8;
// Parametric wave field: band pitch along the blade, the two waves that displace
// every band's centreline, and the slower wave that modulates band thickness
// (as a fraction of the widest the wall thickness allows)
Wave_Field_Pitch = 6;
Wave_Field_Amplitude_1 = 3;
Wave_Field_Lambda_1 = 27;
Wave_Field_Amplitude_2 = 1.6;
Wave_Field_Lambda_2 = 11;
Wave_Field_Thickness_Lambda = 34;
Wave_Field_Thickness_Min = 0.35;
// Reaction-diffusion: a band-limited noise field (a sum of plane waves all at one
// wavelength) thresholded - the standard stand-in for a Turing pattern.  Raise the
// threshold to move from labyrinthine stripes towards isolated spots.
Reaction_Diffusion_Wavelength = 9;
Reaction_Diffusion_Waves = 10;
Reaction_Diffusion_Threshold = -0.2;
Reaction_Diffusion_Seed = 21;
// Grid the reaction-diffusion field is contoured on (smaller = finer, slower), and
// how much its corners are rounded off afterwards
Field_Grid = 1.6;
Field_Smoothing = 0.5;
// Leaf veins: rib widths, spacing up the midrib, and how far each pair reaches up
Leaf_Midrib_Width = 3;
Leaf_Vein_Width = 2.2;
Leaf_Vein_Spacing = 6;
Leaf_Vein_Rise = 1.8;
// Penrose: target edge length of the finished tiling
Penrose_Cell_Size = 4;
// Clipped patterns can leave hair-thin slivers along the edge of the cutout area;
// any hole feature narrower than this is opened away before it is cut.
Cutout_Min_Feature = 1.2;
// Baseline-to-baseline spacing between horizontal text lines, as a multiple of text size
Horizontal_Text_Line_Spacing = 1.35;
// Width of the slices used to bend horizontal text around the fan arc (smaller = smoother, slower)
Horizontal_Text_Strip_Width = 1.5;
// How far back from the blade edge horizontal text stops - keep this small
Horizontal_Text_Edge_Margin = 0.6;
// Bend the SVG artwork around the fan's arc instead of laying it flat.  Flat keeps
// the drawing undistorted; wrapping fills the sector but shears it.
Blade_Cutout_SVG_Wrap = false;
// ---- Assembly-order numbering ----------------------------------------------
// How deep the blade number is etched into the top face
Blade_Number_Etch_Depth = 0.2;
// Cap height of the blade number
Blade_Number_Text_Size = 6;
// Clear space left between the pivot hole and the top of the number
Blade_Number_Hole_Gap = 2;
// Average glyph advance as a fraction of the text size, used to judge whether the
// personalised name has to shrink to fit.  Measured across upper-case names in a
// normal-width face this runs 0.84 to 1.01, so 1.0 sizes typical names accurately
// and errs towards shrinking rather than overflowing.  Drop it towards 0.5 for a
// condensed face like Anton to get larger lettering out of the same space.
Personalized_Name_Advance = 1.0;

// Gap left between blades when laid out for printing
Print_Layout_Gap = 2;
// Bed the printing layout wraps itself to.  Only the width drives the wrapping;
// the depth is used to report whether the result actually fits.
Print_Bed_Width = 250;
Print_Bed_Depth = 250;
// Rows the blades are wrapped into.  0 fills each row to Print_Bed_Width.
Print_Rows = 0;
// A full set of blades is usually deeper than one bed even after wrapping, because
// a row is a whole blade deep.  0 lays the entire set out at once (arrange it in
// the slicer); 1, 2, 3... render just that plate's worth, sized to fit the bed.
Print_Plate = 0;

$fn = 48;
Eps = 0.01;

// -----------------------------------------------------------------------------
// Derived geometry
// -----------------------------------------------------------------------------

Blade_Taper = (Top_Blade_Width - Bottom_Blade_Width) / (2 * Blade_Length);
Blade_Taper_Norm = sqrt(1 + Blade_Taper * Blade_Taper);

// Half width of the blade at a given distance up from the bottom end.
function half_width_at(y) =
    (Bottom_Blade_Width + (Top_Blade_Width - Bottom_Blade_Width) * y / Blade_Length) / 2;

// Pivot hole centre.
Hole_Y = Blade_Bottom_Connection_Hole_Bottom_Margin + Blade_Bottom_Connection_Hole_Diameter / 2;

// Connection slots, measured from the top end of the blade downwards.
Slot_Top_Y1 = Blade_Length - Blade_Connection_Slot_Top_Margin;
Slot_Top_Y0 = Slot_Top_Y1 - Blade_Connection_Slot_Height;
Slot_Bot_Y1 = Slot_Top_Y0 - Blade_Connection_Slot_Inner_Margin;
Slot_Bot_Y0 = Slot_Bot_Y1 - Blade_Connection_Slot_Height;

// Both slots are given the same length, sized from the narrowest point either of
// them reaches, so the side margin is honoured along the whole of both slots and
// the two blade variants travel identically.
Slot_Half_X = max(Blade_Connection_Slot_Peg_Width + 1,
                  half_width_at(Slot_Bot_Y0) - Blade_Connection_Slot_Side_Margin);

// Clear opening between the two lips of a slot, and the peg that slides through it.
Slot_Lip_Gap = Blade_Connection_Slot_Height - 2 * Blade_Connection_Slot_Lip_Width;
Slot_Peg_Neck_Length = max(0.4, Slot_Lip_Gap - Blade_Connection_Slot_Peg_Tolerance);
Slot_Peg_Head_Length = max(Slot_Peg_Neck_Length + 0.4, Blade_Connection_Slot_Height - 1);
// The neck has to clear the full thickness of the blade above it, plus the tolerance,
// before the head is allowed to flare out.
//Slot_Peg_Neck_Height = Blade_Thickness + Connection_Slot_Peg_Tolerance;
Slot_Peg_Neck_Height = Blade_Connection_Slot_Lip_Thickness + Connection_Slot_Peg_Tolerance;
// Flare height, floored so a large Connection_Slot_Peg_Tolerance on a thin blade
// cannot drive it to zero (or negative) and invert the head.
Slot_Peg_Head_Height = max(0.2, Connection_Slot_Peg_Head_Height);
// How far the neck runs up into the head so the two weld into one solid.  Kept well
// inside the flare, so it never breaks the surface.
Peg_Head_Overlap = min(0.05, Slot_Peg_Neck_Height / 2, Slot_Peg_Head_Height / 2);

// How far one blade slides relative to the next: the peg starts hard against one
// end of the neighbour's slot and finishes hard against the other.
Slot_Travel = 2 * Slot_Half_X - Blade_Connection_Slot_Peg_Width;

// Lever arm from the pivot to the slot that carries each variant's peg.
Slot_Top_Radius = (Slot_Top_Y0 + Slot_Top_Y1) / 2 - Hole_Y;
Slot_Bot_Radius = (Slot_Bot_Y0 + Slot_Bot_Y1) / 2 - Hole_Y;

// Angle opened up between blade i and blade i+1 when that pair is fully extended.
function step_angle(i) =
    let (r = (i % 2 == 0) ? Slot_Top_Radius : Slot_Bot_Radius)
    (r <= 0) ? 0 : 2 * asin(min(1, Slot_Travel / (2 * r)));

// Blade 0 sits at the left of the fan; each following blade swings to the right.
function cum_angle(i) = (i <= 0) ? 0 : cum_angle(i - 1) - step_angle(i - 1);
Fan_Angle_Offset = (cum_angle(0) + cum_angle(Number_Of_Blades - 1)) / 2;
function blade_angle(i) = cum_angle(i) - Fan_Angle_Offset;

// Cutout band, in blade Y coordinates.
Cut_Y0 = Blade_Cutout_Bottom_Margin;
Cut_Y1 = Blade_Length - Blade_Cutout_Top_Margin;
Cut_Y_Mid = (Cut_Y0 + Cut_Y1) / 2;
Cut_Half_X_Max = half_width_at(Cut_Y1) - Blade_Cutout_Side_Margins;

// Text - vertical or horizontal - is given the clear stretch of blade between the
// pivot hole and the lower connection slot, and is centred in it.  That is more
// room than the tiled patterns get, and on a default blade it works out to very
// nearly the middle of the blade.
Text_Y0    = Hole_Y + Blade_Bottom_Connection_Hole_Diameter / 2
             + Blade_Cutout_Pattern_Inner_Wall_Thickness;
Text_Y1    = Slot_Bot_Y0 - Blade_Cutout_Pattern_Inner_Wall_Thickness;
Text_Y_Mid = (Text_Y0 + Text_Y1) / 2;

// Horizontal text is laid out on arcs concentric with the pivot, so that same band
// expressed as radii from the pivot.
Text_Band_R0 = Text_Y0 - Hole_Y;
Text_Band_R1 = Text_Y1 - Hole_Y;
Text_Band_Rc = (Text_Band_R0 + Text_Band_R1) / 2;
Has_Text_Line_2 = len(Blade_Cutout_Horizontal_Text_Line_2) > 0;
Text_Line_Spacing = Blade_Cutout_Text_Size * Horizontal_Text_Line_Spacing;
// One line: centred in the band.  Two lines: the pair is centred in the band.
Text_Line_1_Radius = Has_Text_Line_2 ? Text_Band_Rc + Text_Line_Spacing / 2 : Text_Band_Rc;
Text_Line_2_Radius = Text_Band_Rc - Text_Line_Spacing / 2;
// Angular half-window each blade needs to see of the fan-wide text, measured at
// the tightest radius any line sits at.
Text_Min_Radius = Has_Text_Line_2 ? Text_Line_2_Radius : Text_Line_1_Radius;
Fan_Text_Window = atan(half_width_at(Hole_Y + Text_Min_Radius) / max(5, Text_Min_Radius)) + 5;

Text_Depth = min(Blade_Cutout_Text_Depth, Blade_Thickness - 0.2);

// The assembly-order number sits in the clear handle area between the bottom of
// the pivot hole and the bottom end of the blade.
Blade_Number_Depth = min(Blade_Number_Etch_Depth, Blade_Thickness - 0.2);
Blade_Number_Y = Hole_Y - Blade_Bottom_Connection_Hole_Diameter / 2
                 - Blade_Number_Hole_Gap - Blade_Number_Text_Size / 2;

// SVG artwork is centred on the same band the horizontal text uses - midway between
// the pivot hole and the lower connection slot - and spans the fan from there.
SVG_Radius     = Text_Band_Rc;
SVG_Scale      = Blade_Cutout_SVG_Scale / 100;
// Half the artwork's finished height.  It has to follow the scale as well as the
// nominal height, because in wrap mode this is the window each strip is cut from -
// leave it at the unscaled height and an enlarged drawing gets its top and bottom
// sliced off.
SVG_R_Half     = max(2, Blade_Cutout_SVG_Height * SVG_Scale / 2);
SVG_R_Min      = max(5, SVG_Radius - SVG_R_Half);
Fan_SVG_Window = atan(half_width_at(Hole_Y + SVG_R_Min) / SVG_R_Min) + 5;
Fan_Total_Span = blade_angle(0) - blade_angle(Number_Of_Blades - 1);
SVG_Span_Half  = SVG_Radius * (Fan_Total_Span / 2 + Fan_SVG_Window) * PI / 180;

// Etched, not cut through - the same treatment as the text overlays.
Is_Text_Cutout = (Blade_Cutouts == "vertical_text" || Blade_Cutouts == "horizontal_text"
                  || Blade_Cutouts == "svg");
// Everything that is not text and not "none" is a pattern cut clean through.
Is_Hole_Cutout = !(Is_Text_Cutout || Blade_Cutouts == "none");

// ---- Personalised name ------------------------------------------------------
// Etched into the underside of the first blade.  A pattern that cuts clean through
// would leave the name riddled with holes, so when one is selected the name keeps to
// the clear handle below it - between the top of the pivot hole and the foot of the
// pattern.  With nothing cutting through it gets the run of the blade instead.
//
// Either way the span starts above the pivot hole and, on a solid blade, stops below
// the lower connection slot: those are cut clean through as well, so a name taken
// literally to the blade's ends would be chopped up by them at full length.
Has_Personalized_Name = len(Personalized_Name) > 0;
PName_Y0 = Hole_Y + Blade_Bottom_Connection_Hole_Diameter / 2;
PName_Y1 = Is_Hole_Cutout ? Cut_Y0 : Slot_Bot_Y0;
PName_Y_Mid   = (PName_Y0 + PName_Y1) / 2;
PName_Avail_L = max(1, PName_Y1 - PName_Y0);
// Across the blade the text is limited by how wide the blade is where the name sits,
// less the usual side margins.
PName_Avail_W = max(1, 2 * (half_width_at(PName_Y_Mid) / Blade_Taper_Norm
                            - Blade_Cutout_Side_Margins));
// OpenSCAD exposes no text metrics, so the run length is estimated from an average
// advance per character.  The estimate only ever drives shrinking - a name that
// already fits is left at the size set above - and the region clip catches whatever
// the estimate gets wrong.
PName_Est_L = max(0.1, len(Personalized_Name) * Blade_Cutout_Text_Size
                       * Personalized_Name_Advance);
PName_Size = min(Blade_Cutout_Text_Size,
                 Blade_Cutout_Text_Size * PName_Avail_L / PName_Est_L,
                 PName_Avail_W);
// The assembly number is recessed into the opposite face of this same blade.  On a
// thin blade two full-depth recesses would meet in the middle, so the name's depth is
// held back far enough to always leave material between them.
PName_Depth = min(Text_Depth, Blade_Thickness - Blade_Number_Depth - 0.2);

// -----------------------------------------------------------------------------
// Blade outline
// -----------------------------------------------------------------------------

// Rounded trapezoid.  Each corner circle is placed so it is exactly tangent to
// both edges it touches, which matters because the sides are not vertical.
module blade_outline_2d() {
    // Clamped so an over-large rounding cannot eat past the blade's own half width
    // or a quarter of its length and invert the outline.  The lower bound matters
    // too: circle(r = 0) is empty, which would collapse the hull and take the whole
    // blade with it, so a rounding of zero becomes a corner too small to print.
    rb = max(0.01, min(Bottom_Corner_Rounding, Bottom_Blade_Width / 2 - 0.1, Blade_Length / 4));
    rt = max(0.01, min(Top_Corner_Rounding,    Top_Blade_Width / 2 - 0.1,    Blade_Length / 4));
    bx = rb * (Blade_Taper_Norm - Blade_Taper) - Bottom_Blade_Width / 2;
    tx = rt * (Blade_Taper_Norm + Blade_Taper) - Top_Blade_Width / 2;
    hull() {
        translate([ bx, rb]) circle(r = rb);
        translate([-bx, rb]) circle(r = rb);
        translate([ tx, Blade_Length - rt]) circle(r = rt);
        translate([-tx, Blade_Length - rt]) circle(r = rt);
    }
}

// -----------------------------------------------------------------------------
// Connection slots and the slot peg
// -----------------------------------------------------------------------------

// The slot is a through cutout whose opening is narrowed, over the bottom
// Blade_Connection_Slot_Lip_Thickness of the blade, by a lip on its top and
// bottom edge.  The neighbouring blade's peg neck slides through that gap while
// its flared head, sitting above the blade, stops it lifting back out.
module slot_cut_3d(y0, y1) {
    lw = min(Blade_Connection_Slot_Lip_Width, (y1 - y0) / 2 - 0.2);
    lt = Blade_Connection_Slot_Lip_Thickness;
    translate([-Slot_Half_X, y0, lt])
        cube([2 * Slot_Half_X, y1 - y0, Blade_Thickness - lt + Eps]);
    translate([-Slot_Half_X, y0 + lw, -Eps])
        cube([2 * Slot_Half_X, (y1 - y0) - 2 * lw, lt + Eps]);
}

// Trapezoidal peg filling the right-hand end of one slot and reaching up above
// the blade so it can capture the next blade in the stack.
module slot_peg_3d(y0, y1) {
    pw = Blade_Connection_Slot_Peg_Width;
    x0 = Slot_Half_X - pw;
    yc = (y0 + y1) / 2;
    nl = Slot_Peg_Neck_Length;
    hl = Slot_Peg_Head_Length;
    // Root: plugs the end of this blade's own slot and ties the peg to the blade.
    translate([x0, y0, 0]) cube([pw, y1 - y0, Blade_Thickness]);
    // Neck: narrow enough to pass between the lips of the neighbouring slot.  It is
    // run a hair past its nominal top so that it interpenetrates the head instead of
    // meeting it on a shared plane - butting the two flush leaves coincident faces,
    // which read as a seam and leave the union relying on the mesh engine to weld
    // them.  The extension is swallowed by the widening flare, so no outside surface
    // moves and the head's underside stays exactly one tolerance clear of the lip.
    translate([x0, yc - nl / 2, Blade_Thickness])
        cube([pw, nl, Slot_Peg_Neck_Height + Peg_Head_Overlap]);
    // Head: flares out to (slot height - 1) so it cannot drop back through a lip.
    hull() {
        translate([x0, yc - nl / 2, Blade_Thickness + Slot_Peg_Neck_Height])
            cube([pw, nl, Eps]);
        translate([x0, yc - hl / 2,
                   Blade_Thickness + Slot_Peg_Neck_Height + Slot_Peg_Head_Height - Eps])
            cube([pw, hl, Eps]);
    }
}

// -----------------------------------------------------------------------------
// Cutout patterns
// -----------------------------------------------------------------------------

// Area a pattern is allowed to occupy: the blade inset by the side margins,
// clipped to the cutout band, with the slots and the pivot hole kept clear.
module cut_region_2d() {
    w = Blade_Cutout_Pattern_Inner_Wall_Thickness;
    difference() {
        intersection() {
            offset(r = -Blade_Cutout_Side_Margins) blade_outline_2d();
            translate([-Blade_Length, Cut_Y0]) square([2 * Blade_Length, Cut_Y1 - Cut_Y0]);
        }
        // The default cutout band reaches up into the bottom slot, so both slots
        // (and the pivot hole) are explicitly fenced off with a wall's clearance.
        translate([-Slot_Half_X - w, Slot_Bot_Y0 - w])
            square([2 * (Slot_Half_X + w), Blade_Connection_Slot_Height + 2 * w]);
        translate([-Slot_Half_X - w, Slot_Top_Y0 - w])
            square([2 * (Slot_Half_X + w), Blade_Connection_Slot_Height + 2 * w]);
        translate([0, Hole_Y])
            circle(d = Blade_Bottom_Connection_Hole_Diameter + 2 * w);
    }
}

// ---- Honeycomb --------------------------------------------------------------
// Hexagonal cells on a tiling grid; each hole is shrunk from its cell so exactly
// Blade_Cutout_Pattern_Inner_Wall_Thickness of material is left between holes.
module honeycomb_2d() {
    w  = Blade_Cutout_Pattern_Inner_Wall_Thickness;
    rc = Honeycomb_Cell_Size / sqrt(3);            // cell circumradius
    rh = max(0.5, rc - w / sqrt(3));               // hole circumradius
    px = 1.5 * rc;                                 // column pitch
    py = sqrt(3) * rc;                             // row pitch
    nx = ceil((Cut_Half_X_Max + rc) / px) + 1;
    ny = ceil((Cut_Y1 - Cut_Y0) / py / 2) + 2;
    for (i = [-nx : nx], j = [-ny : ny])
        translate([i * px, Cut_Y_Mid + j * py + (i % 2 == 0 ? 0 : py / 2)])
            circle(r = rh, $fn = 6);
}

// ---- Voronoi ----------------------------------------------------------------
// Sites are a jittered grid (deterministic via rands()'s seed), which keeps the
// cells reasonably even so no wall ends up thinner than the wall thickness.
Vor_Pad   = Voronoi_Cell_Size;
Vor_X0    = -Cut_Half_X_Max - Vor_Pad;
Vor_X1    =  Cut_Half_X_Max + Vor_Pad;
Vor_Y0    = Cut_Y0 - Vor_Pad;
Vor_Y1    = Cut_Y1 + Vor_Pad;
Vor_NX    = max(2, round((Vor_X1 - Vor_X0) / Voronoi_Cell_Size));
Vor_NY    = max(2, round((Vor_Y1 - Vor_Y0) / Voronoi_Cell_Size));
Vor_SX    = (Vor_X1 - Vor_X0) / Vor_NX;
Vor_SY    = (Vor_Y1 - Vor_Y0) / Vor_NY;
Vor_N     = Vor_NX * Vor_NY;
Vor_Jit   = rands(-0.34, 0.34, Vor_N * 2, Voronoi_Seed);
Vor_Sites = [ for (j = [0 : Vor_NY - 1]) for (i = [0 : Vor_NX - 1])
                let (k = j * Vor_NX + i)
                [ Vor_X0 + (i + 0.5) * Vor_SX + Vor_Jit[2 * k]     * Vor_SX,
                  Vor_Y0 + (j + 0.5) * Vor_SY + Vor_Jit[2 * k + 1] * Vor_SY ] ];
Vor_Big   = Blade_Length + Top_Blade_Width;
Vor_Reach = 2.3 * max(Vor_SX, Vor_SY);

// Only genuinely nearby sites can contribute an edge to a cell, so the half-plane
// intersection is kept to a handful of neighbours instead of every other site.
function vor_neighbours(k) =
    [ for (j = [0 : Vor_N - 1])
        if (j != k && norm(Vor_Sites[j] - Vor_Sites[k]) < Vor_Reach) j ];

// Half plane on pi's side of the perpendicular bisector of pi-pj.
module vor_halfplane(pi, pj) {
    d = pj - pi;
    translate((pi + pj) / 2)
        rotate(atan2(d[1], d[0]))
            translate([-2 * Vor_Big, -Vor_Big])
                square([2 * Vor_Big, 2 * Vor_Big]);
}

module voronoi_2d() {
    w = Blade_Cutout_Pattern_Inner_Wall_Thickness;
    for (k = [0 : Vor_N - 1]) {
        nb = vor_neighbours(k);
        if (len(nb) > 0)
            offset(r = -w / 2)
                intersection() {
                    translate(Vor_Sites[k]) square(2 * Vor_Big, center = true);
                    intersection_for (j = nb) vor_halfplane(Vor_Sites[k], Vor_Sites[j]);
                }
    }
}

// The same cell construction, but driven by any site list.  Voronoi cells share
// their edges, so insetting every cell by half a wall leaves exactly one wall
// between neighbours however the sites are distributed.
function site_neighbours(sites, k, reach) =
    [ for (j = [0 : len(sites) - 1])
        if (j != k && norm(sites[j] - sites[k]) < reach) j ];

module voronoi_from_sites(sites, reach) {
    for (k = [0 : len(sites) - 1]) {
        nb = site_neighbours(sites, k, reach);
        if (len(nb) > 0)
            offset(r = -Pat_Wall / 2)
                intersection() {
                    translate(sites[k]) square(2 * Vor_Big, center = true);
                    intersection_for (j = nb) vor_halfplane(sites[k], sites[j]);
                }
    }
}

// Deterministic pseudo-random in [0,1) from two integers - lets the site builders
// jitter without having to thread an index into a single rands() array.
function hash2(a, b) = let (v = sin(a * 127.1 + b * 311.7) * 43758.5453) v - floor(v);

// ---- Triangle inset ---------------------------------------------------------
// Scaling a triangle about its incentre moves every edge in by the same amount, so
// this is the triangle equivalent of offset(r = -d) but without the offset cost.
function tri_incentre(A, B, C) =
    let (a = norm(C - B), b = norm(A - C), c = norm(B - A))
    (a * A + b * B + c * C) / (a + b + c);

function tri_inradius(A, B, C) =
    let (a = norm(C - B), b = norm(A - C), c = norm(B - A), s = (a + b + c) / 2,
         area = abs((B[0] - A[0]) * (C[1] - A[1]) - (C[0] - A[0]) * (B[1] - A[1])) / 2)
    (s <= 0) ? 0 : area / s;

module tri_inset(A, B, C, d) {
    r = tri_inradius(A, B, C);
    if (r > d + 0.05) {
        I = tri_incentre(A, B, C);
        k = (r - d) / r;
        polygon([I + k * (A - I), I + k * (B - I), I + k * (C - I)]);
    }
}

// ---- Hearts -----------------------------------------------------------------
// Unit heart: a 45-degree diamond with a circle capping each of its upper edges.
// Drawn centred on its own bounding box so it can be rotated in place.
module heart_2d(w) {
    a = w / 1.7071;                 // diamond side length for an overall width w
    h = 1.5607 * a;                 // resulting overall height
    translate([0, -h / 2])
        union() {
            rotate(45) square(a);
            translate([ 0.3536 * a, 1.0607 * a]) circle(r = a / 2);
            translate([-0.3536 * a, 1.0607 * a]) circle(r = a / 2);
        }
}

Heart_Max      = Hearts_Base_Size + 2;
Heart_Diameter = 1.06 * Heart_Max;              // bounding circle of the largest heart
Heart_Pitch    = Heart_Diameter + Blade_Cutout_Pattern_Inner_Wall_Thickness;
Heart_Rows     = max(1, floor((Cut_Y1 - Cut_Y0) / Heart_Pitch));
Heart_Max_Cols = max(1, floor((2 * Cut_Half_X_Max - Heart_Diameter) / Heart_Pitch) + 1);
Heart_Count    = Heart_Rows * Heart_Max_Cols;
Heart_Rand     = rands(0, 1, Heart_Count * 2, Hearts_Seed);

// Distance from a point to an axis-aligned rectangle (0 if the point is inside).
function rect_distance(x, y, x0, y0, x1, y1) =
    norm([max(x0 - x, 0, x - x1), max(y0 - y, 0, y - y1)]);

// Unlike the tiled patterns, a heart clipped by the edge of the cutout area stops
// looking like a heart, so hearts are placed only where a whole one fits.  The
// blade narrows towards the bottom of the band, so this thins the field out by
// itself instead of leaving fragments behind.
function heart_fits(x, y, r) =
    let (w = Blade_Cutout_Pattern_Inner_Wall_Thickness)
    y - r >= Cut_Y0
    && y + r <= Cut_Y1
    && (half_width_at(y) - abs(x)) / Blade_Taper_Norm >= r + Blade_Cutout_Side_Margins
    && rect_distance(x, y, -Slot_Half_X - w, Slot_Bot_Y0 - w,
                     Slot_Half_X + w, Slot_Bot_Y1 + w) >= r
    && rect_distance(x, y, -Slot_Half_X - w, Slot_Top_Y0 - w,
                     Slot_Half_X + w, Slot_Top_Y1 + w) >= r
    && norm([x, y - Hole_Y]) >= r + Blade_Bottom_Connection_Hole_Diameter / 2 + w;

// Each row is filled with as many hearts as the blade is wide enough to take at
// that height, so the field stays dense at the top and tapers to a single column
// down near the handle.
module hearts_2d() {
    for (j = [0 : Heart_Rows - 1]) {
        cy     = Cut_Y0 + (Cut_Y1 - Cut_Y0) * (j + 0.5) / Heart_Rows;
        usable = 2 * (half_width_at(cy) / Blade_Taper_Norm - Blade_Cutout_Side_Margins);
        ncols  = max(1, floor((usable - Heart_Diameter) / Heart_Pitch) + 1);
        for (i = [0 : ncols - 1]) {
            k  = (j * Heart_Max_Cols + i) % Heart_Count;
            // Sizes stay within 2mm of one another; each heart gets its own in-plane angle.
            sz = Hearts_Base_Size + 2 * Heart_Rand[2 * k];
            an = 360 * Heart_Rand[2 * k + 1];
            cx = (i - (ncols - 1) / 2) * Heart_Pitch;
            if (heart_fits(cx, cy, 0.53 * sz))
                translate([cx, cy]) rotate(an) heart_2d(sz);
        }
    }
}

// ---- Geometric tilings ------------------------------------------------------
// All of these lay a repeating hole out around the middle of the cutout band and
// let cut_region_2d() clip whatever runs past the margins.  Each sizes its hole
// from the cell pitch minus Blade_Cutout_Pattern_Inner_Wall_Thickness, so the
// material left between neighbouring holes is the wall thickness by construction.

// How many cells to step either side of the band centre to cover it.
function pat_nx(px) = ceil(Cut_Half_X_Max / px) + 2;
function pat_ny(py) = ceil((Cut_Y1 - Cut_Y0) / (2 * py)) + 2;

Pat_Wall = Blade_Cutout_Pattern_Inner_Wall_Thickness;

// ---- Triangular -------------------------------------------------------------
// Alternating up/down equilateral triangles.  Shrinking a triangle of side s to
// side s - wall*sqrt(3) pulls every edge in by wall/2, so any two neighbours end
// up exactly one wall apart.
module tri_hole(a, up) {
    base = a * sqrt(3) / 6;        // centroid to base
    apex = a * sqrt(3) / 3;        // centroid to apex
    if (up) polygon([[-a / 2, -base], [a / 2, -base], [0,  apex]]);
    else    polygon([[-a / 2,  base], [a / 2,  base], [0, -apex]]);
}

module triangular_2d() {
    s  = Triangular_Cell_Size;
    h  = s * sqrt(3) / 2;
    a  = max(1, s - Pat_Wall * sqrt(3));
    nx = pat_nx(s);
    ny = pat_ny(h);
    for (i = [-nx : nx], j = [-ny : ny]) {
        y0 = Cut_Y_Mid + j * h;
        translate([(i + 0.5) * s, y0 + h / 3])     tri_hole(a, true);
        translate([(i + 1.0) * s, y0 + 2 * h / 3]) tri_hole(a, false);
    }
}

// ---- Isometric triangular ---------------------------------------------------
// The rhombille (tumbling-blocks) tessellation.  Splitting a hexagon of side s
// into the three quads (centre, V0, V1, V2), (centre, V2, V3, V4) and (centre, V4,
// V5, V0) gives three 60/120 rhombi meeting at 120 degrees - each a pair of the
// underlying lattice triangles - so every hexagon reads as an isometric cube.  The
// three rhombus orientations sit 60 degrees apart, which is what carries the
// isometric look.
//
// A rhombus of side s has half-diagonals s*sqrt(3)/2 and s/2 and an inradius of
// s*sqrt(3)/4, so scaling both half-diagonals by 1 - 2*wall/(s*sqrt(3)) pulls every
// edge in by half a wall and neighbours end up exactly one wall apart.
module isometric_triangular_2d() {
    s  = Isometric_Cell_Size;
    k  = max(0.1, 1 - 2 * Pat_Wall / (s * sqrt(3)));
    L  = s * sqrt(3) / 2 * k;      // long half-diagonal, after inset
    S  = s / 2 * k;                // short half-diagonal, after inset
    px = 1.5 * s;                  // hexagon lattice: pointy along X
    py = s * sqrt(3);
    nx = pat_nx(px);
    ny = pat_ny(py);
    for (i = [-nx : nx], j = [-ny : ny]) {
        cx = i * px;
        cy = Cut_Y_Mid + j * py + (i % 2 == 0 ? 0 : py / 2);
        for (r = [0 : 2]) {
            a = 120 * r;
            // Rhombus r's centre is the midpoint of the hexagon centre and V(60*(2r+1)).
            ox = s * 0.25 * cos(a) - s * (sqrt(3) / 4) * sin(a);
            oy = s * 0.25 * sin(a) + s * (sqrt(3) / 4) * cos(a);
            translate([cx + ox, cy + oy])
                rotate(a - 30)                       // long diagonal of rhombus 0 lies at -30
                    polygon([[L, 0], [0, S], [-L, 0], [0, -S]]);
        }
    }
}

// ---- Diamond ----------------------------------------------------------------
// A rhombic lattice.  Scaling a rhombus about its centre by 1 - (wall/2)/inradius
// insets every edge by wall/2.
module diamond_hole(a, b) { polygon([[a, 0], [0, b], [-a, 0], [0, -b]]); }

module diamond_2d() {
    a   = Diamond_Cell_Width / 2;
    b   = a * Diamond_Aspect;
    inr = a * b / sqrt(a * a + b * b);
    k   = max(0.15, 1 - (Pat_Wall / 2) / inr);
    nx  = pat_nx(2 * a);
    ny  = pat_ny(2 * b);
    for (i = [-nx : nx], j = [-ny : ny]) {
        translate([i * 2 * a,     Cut_Y_Mid + j * 2 * b])     diamond_hole(k * a, k * b);
        translate([i * 2 * a + a, Cut_Y_Mid + j * 2 * b + b]) diamond_hole(k * a, k * b);
    }
}

// ---- Circular / Staggered Circular ------------------------------------------
module circular_2d() {
    d  = Circular_Hole_Diameter;
    p  = d + Pat_Wall;
    nx = pat_nx(p);
    ny = pat_ny(p);
    for (i = [-nx : nx], j = [-ny : ny])
        translate([i * p, Cut_Y_Mid + j * p]) circle(d = d);
}

// Rows offset by half a pitch, with the row spacing set so a hole is the same
// distance from its diagonal neighbours as from the ones beside it.
module staggered_circular_2d() {
    d  = Staggered_Circular_Hole_Diameter;
    p  = d + Pat_Wall;
    ph = p * sqrt(3) / 2;
    nx = pat_nx(p);
    ny = pat_ny(ph);
    for (i = [-nx : nx], j = [-ny : ny])
        translate([i * p + (j % 2 == 0 ? 0 : p / 2), Cut_Y_Mid + j * ph]) circle(d = d);
}

// ---- Rounded squares --------------------------------------------------------
module rounded_squares_2d() {
    s  = Rounded_Square_Size;
    r  = min(Rounded_Square_Rounding, s / 2 - 0.1);
    p  = s + Pat_Wall;
    nx = pat_nx(p);
    ny = pat_ny(p);
    for (i = [-nx : nx], j = [-ny : ny])
        translate([i * p, Cut_Y_Mid + j * p])
            offset(r = r) square(s - 2 * r, center = true);
}

// ---- Slots ------------------------------------------------------------------
// Stadium-ended slots running along the blade, brick-bonded so no two columns
// line their ends up.
module slot_hole(sw, sl) {
    o = max(0, (sl - sw) / 2);
    hull() {
        translate([0,  o]) circle(d = sw);
        translate([0, -o]) circle(d = sw);
    }
}

module slots_2d() {
    sw = Slot_Hole_Width;
    sl = max(Slot_Hole_Length, Slot_Hole_Width);
    px = sw + Pat_Wall;
    py = sl + Pat_Wall;
    nx = pat_nx(px);
    ny = pat_ny(py);
    for (i = [-nx : nx], j = [-ny : ny])
        translate([i * px, Cut_Y_Mid + j * py + (i % 2 == 0 ? 0 : py / 2)])
            slot_hole(sw, sl);
}

// ---- Gyroid -----------------------------------------------------------------
// A true slice through the gyroid surface, sin(X)cos(Y) + sin(Y)cos(Z) +
// sin(Z)cos(X) = 0, taken at Z = 45 degrees.  Material is kept where the surface
// function is near zero (|g| <= threshold), which is a band following the level
// set, so the web is always connected; everything else is cut away.
//
// Collecting the Y terms turns g into R*cos(Y - phi) + C*cos(X), which inverts
// exactly - no marching squares needed.  For each thin slice of X the two hole
// bands are solved for directly and drawn as a trapezoid, so the contour comes
// out smooth rather than stepped.
Gyroid_C = 0.70710678;   // cos(45) = sin(45)

function gy_R(X)      = sqrt(sin(X) * sin(X) + Gyroid_C * Gyroid_C);
function gy_phi(X)    = atan2(Gyroid_C, sin(X));
// Half-width (in degrees of Y) of the g > +t band, and of the g < -t band.
function gy_hi_h(X, t) = let (u = (t - Gyroid_C * cos(X)) / gy_R(X))
                         (u >= 1) ? 0 : (u <= -1 ? 180 : acos(u));
function gy_lo_h(X, t) = let (v = (-t - Gyroid_C * cos(X)) / gy_R(X))
                         (v <= -1) ? 0 : (v >= 1 ? 180 : 180 - acos(v));

// One trapezoid of a hole band between two neighbouring X slices.
module gy_quad(xa, xb, ca, cb, ha, hb) {
    if (ha + hb > 0)
        polygon([[xa, ca - ha], [xb, cb - hb], [xb, cb + hb], [xa, ca + ha]]);
}

// One of the two hole families: hi = where g > +threshold, lo = where g < -threshold.
module gyroid_bands(hi) {
    S  = Gyroid_Cell_Size;
    t  = Gyroid_Threshold;
    x0 = -Cut_Half_X_Max - 2;
    x1 =  Cut_Half_X_Max + 2;
    n  = max(2, ceil((x1 - x0) / Gyroid_Strip_Width));
    k0 = floor((Cut_Y0 - S - Cut_Y_Mid) / S);
    k1 = ceil ((Cut_Y1 + S - Cut_Y_Mid) / S);
    for (i = [0 : n - 1]) {
        xa = x0 + (x1 - x0) * i / n;
        xb = x0 + (x1 - x0) * (i + 1) / n;
        Xa = 360 * xa / S;
        Xb = 360 * xb / S;
        // The lo band sits half a period away from the hi band.
        ca = (gy_phi(Xa) + (hi ? 0 : 180)) / 360 * S;
        cb = (gy_phi(Xb) + (hi ? 0 : 180)) / 360 * S;
        ha = (hi ? gy_hi_h(Xa, t) : gy_lo_h(Xa, t)) / 360 * S;
        hb = (hi ? gy_hi_h(Xb, t) : gy_lo_h(Xb, t)) / 360 * S;
        for (k = [k0 : k1]) {
            base = Cut_Y_Mid + k * S;
            gy_quad(xa, xb, base + ca, base + cb, ha, hb);
        }
    }
}

// At the default threshold of 0 the two families tile the plane, meeting exactly on
// the gyroid's zero level set.  Pulling each one back by half a wall - separately,
// so the gap between them survives the union - leaves a web of precisely one wall
// thickness following the surface.  Raising the threshold thickens it from there.
module gyroid_2d() {
    union() {
        offset(r = -Pat_Wall / 2) gyroid_bands(true);
        offset(r = -Pat_Wall / 2) gyroid_bands(false);
    }
}

// ---- Wave -------------------------------------------------------------------
// Sinusoidal bands running across the blade, stacked up its length.
module wave_band(yc, t) {
    n  = 48;
    x0 = -Cut_Half_X_Max - 2;
    x1 =  Cut_Half_X_Max + 2;
    polygon(concat(
        [ for (i = [0 : n])
            let (x = x0 + (x1 - x0) * i / n)
            [x, yc + Wave_Amplitude * sin(360 * x / Wave_Wavelength) + t / 2] ],
        [ for (i = [n : -1 : 0])
            let (x = x0 + (x1 - x0) * i / n)
            [x, yc + Wave_Amplitude * sin(360 * x / Wave_Wavelength) - t / 2] ]));
}

module wave_2d() {
    t  = max(0.5, Wave_Pitch - Pat_Wall);
    ny = pat_ny(Wave_Pitch);
    for (j = [-ny : ny]) wave_band(Cut_Y_Mid + j * Wave_Pitch, t);
}

// ---- Islamic geometry -------------------------------------------------------
// The khatam lattice: an eight-pointed star (two squares at 45 degrees to each
// other) on a square grid, with a small diamond dropped into each gap between
// four stars.
module star8(R) {
    a = R * sqrt(2);
    union() {
        square(a, center = true);
        rotate(45) square(a, center = true);
    }
}

module islamic_2d() {
    R  = Islamic_Star_Radius;
    p  = 2 * R + Pat_Wall;
    // What is left in the gap once the four surrounding stars keep their wall.
    dh = p / sqrt(2) - R - Pat_Wall;
    nx = pat_nx(p);
    ny = pat_ny(p);
    for (i = [-nx : nx], j = [-ny : ny]) {
        translate([i * p, Cut_Y_Mid + j * p]) star8(R);
        if (dh > 0.6)
            translate([(i + 0.5) * p, Cut_Y_Mid + (j + 0.5) * p])
                diamond_hole(dh, dh);
    }
}

// ---- Fish scales ------------------------------------------------------------
// Rows of domes, each row shifted half a pitch so the scales interlock.
module fish_scale(r) {
    intersection() {
        circle(r = r);
        translate([-r, 0]) square([2 * r, r]);
    }
}

module fish_scales_2d() {
    r  = Fish_Scale_Radius;
    px = 2 * r + Pat_Wall;
    py = r + Pat_Wall;
    nx = pat_nx(px);
    ny = pat_ny(py);
    for (i = [-nx : nx], j = [-ny : ny])
        translate([i * px + (j % 2 == 0 ? 0 : px / 2), Cut_Y_Mid + j * py])
            fish_scale(r);
}

// ---- Delaunay triangulation -------------------------------------------------
// The Delaunay triangulation of a jittered grid is that grid's quads, each split
// along whichever diagonal satisfies the empty-circumcircle test - so the in-circle
// determinant on each quad gives a genuine Delaunay mesh without a full solver.
Del_Pad = Delaunay_Cell_Size;
Del_X0  = -Cut_Half_X_Max - Del_Pad;
Del_X1  =  Cut_Half_X_Max + Del_Pad;
Del_Y0  = Cut_Y0 - Del_Pad;
Del_Y1  = Cut_Y1 + Del_Pad;
Del_NX  = max(2, round((Del_X1 - Del_X0) / Delaunay_Cell_Size));
Del_NY  = max(2, round((Del_Y1 - Del_Y0) / Delaunay_Cell_Size));
Del_SX  = (Del_X1 - Del_X0) / Del_NX;
Del_SY  = (Del_Y1 - Del_Y0) / Del_NY;
Del_Jit = rands(-0.3, 0.3, (Del_NX + 1) * (Del_NY + 1) * 2, Delaunay_Seed);

function del_pt(i, j) =
    let (k = j * (Del_NX + 1) + i)
    [ Del_X0 + i * Del_SX + Del_Jit[2 * k]     * Del_SX,
      Del_Y0 + j * Del_SY + Del_Jit[2 * k + 1] * Del_SY ];

// Is D strictly inside the circumcircle of the counter-clockwise triangle ABC?
function in_circle(A, B, C, D) =
    let (ax = A[0] - D[0], ay = A[1] - D[1],
         bx = B[0] - D[0], by = B[1] - D[1],
         cx = C[0] - D[0], cy = C[1] - D[1])
    (ax * ax + ay * ay) * (bx * cy - cx * by)
  - (bx * bx + by * by) * (ax * cy - cx * ay)
  + (cx * cx + cy * cy) * (ax * by - bx * ay) > 0;

module delaunay_2d() {
    d = Pat_Wall / 2;
    for (j = [0 : Del_NY - 1], i = [0 : Del_NX - 1]) {
        P00 = del_pt(i, j);      P10 = del_pt(i + 1, j);
        P11 = del_pt(i + 1, j + 1); P01 = del_pt(i, j + 1);
        if (in_circle(P00, P10, P11, P01)) {
            tri_inset(P00, P10, P01, d);
            tri_inset(P10, P11, P01, d);
        } else {
            tri_inset(P00, P10, P11, d);
            tri_inset(P00, P11, P01, d);
        }
    }
}

// ---- Gradient Voronoi -------------------------------------------------------
// Same Voronoi construction, but the sites thin out towards the top of the band, so
// the cells grow along the blade.
function gv_cell(y) =
    let (u = max(0, min(1, (y - Cut_Y0) / max(1, Cut_Y1 - Cut_Y0))))
    Gradient_Voronoi_Cell_Bottom
  + (Gradient_Voronoi_Cell_Top - Gradient_Voronoi_Cell_Bottom) * u;

// Row positions accumulate the local cell size, so spacing tracks the gradient.
function gv_rows(y) = (y > Vor_Y1) ? [] : concat([y], gv_rows(y + gv_cell(y)));
GV_Rows = gv_rows(Vor_Y0);

GV_Sites = [ for (r = [0 : len(GV_Rows) - 1])
               let (y = GV_Rows[r], c = gv_cell(y),
                    n = max(2, ceil((Vor_X1 - Vor_X0) / c)))
               for (i = [0 : n])
                 [ Vor_X0 + i * (Vor_X1 - Vor_X0) / n
                         + (hash2(r + 1, i + 1) - 0.5) * 0.55 * c,
                   y + (hash2(i + 7, r + 3) - 0.5) * 0.55 * c ] ];

module gradient_voronoi_2d() {
    voronoi_from_sites(GV_Sites, 2.4 * max(Gradient_Voronoi_Cell_Bottom,
                                           Gradient_Voronoi_Cell_Top));
}

// ---- Variable honeycomb -----------------------------------------------------
// The Voronoi diagram of a hexagonal lattice is a honeycomb, so scaling the lattice
// along the blade gives hexagons that grow with it while still tiling exactly.
function vh_cell(y) =
    let (u = max(0, min(1, (y - Cut_Y0) / max(1, Cut_Y1 - Cut_Y0))))
    Variable_Honeycomb_Cell_Bottom
  + (Variable_Honeycomb_Cell_Top - Variable_Honeycomb_Cell_Bottom) * u;

function vh_rows(y) = (y > Vor_Y1) ? [] : concat([y], vh_rows(y + vh_cell(y) * sqrt(3) / 2));
VH_Rows = vh_rows(Vor_Y0);

VH_Sites = [ for (r = [0 : len(VH_Rows) - 1])
               let (y = VH_Rows[r], c = vh_cell(y),
                    n = max(2, ceil((Vor_X1 - Vor_X0) / c)))
               for (i = [0 : n])
                 [ Vor_X0 + (i + (r % 2 == 0 ? 0 : 0.5)) * (Vor_X1 - Vor_X0) / n, y ] ];

module variable_honeycomb_2d() {
    voronoi_from_sites(VH_Sites, 2.4 * max(Variable_Honeycomb_Cell_Bottom,
                                           Variable_Honeycomb_Cell_Top));
}

// ---- Penrose (aperiodic) tiling ---------------------------------------------
// Robinson-triangle deflation.  Ten thin triangles arranged round a point make the
// starting decagon; each subdivision step replaces every triangle with smaller ones
// in the golden ratio, and the limit is the aperiodic P3 tiling.
PHI = (1 + sqrt(5)) / 2;
Pen_Radius = 1.15 * norm([Cut_Half_X_Max + 4, (Cut_Y1 - Cut_Y0) / 2 + 4]);
// A starting thin triangle is R, R, 2*R*sin(18) - and it is that short base, not the
// legs, that ends up setting the cell size, so the depth is chosen against it.
Pen_Levels = max(1, round(ln(2 * sin(18) * Pen_Radius / max(1, Penrose_Cell_Size)) / ln(PHI)));

Pen_Init = [ for (i = [0 : 9])
               let (a1 = (2 * i - 1) * 18, a2 = (2 * i + 1) * 18,
                    B = Pen_Radius * [cos(a1), sin(a1)],
                    C = Pen_Radius * [cos(a2), sin(a2)])
               (i % 2 == 0) ? [0, [0, 0], C, B] : [0, [0, 0], B, C] ];

function pen_children(t) =
    let (ty = t[0], A = t[1], B = t[2], C = t[3])
    (ty == 0)
      ? let (P = A + (B - A) / PHI) [ [0, C, P, B], [1, P, C, A] ]
      : let (Q = B + (A - B) / PHI, R = B + (C - B) / PHI)
        [ [1, R, C, A], [1, Q, R, B], [0, R, Q, A] ];

function pen_sub(ts)      = [ for (t = ts) each pen_children(t) ];
function pen_build(ts, n) = (n <= 0) ? ts : pen_build(pen_sub(ts), n - 1);

// Thrown away before any geometry is built, so the off-blade majority costs nothing.
function pen_keep(t) =
    let (xs = [t[1][0], t[2][0], t[3][0]], ys = [t[1][1], t[2][1], t[3][1]],
         y0 = Cut_Y0 - Cut_Y_Mid - 3, y1 = Cut_Y1 - Cut_Y_Mid + 3)
    max(xs) > -Cut_Half_X_Max - 3 && min(xs) < Cut_Half_X_Max + 3
    && max(ys) > y0 && min(ys) < y1;

module penrose_2d() {
    d = Pat_Wall / 2;
    translate([0, Cut_Y_Mid])
        for (t = pen_build(Pen_Init, Pen_Levels))
            if (pen_keep(t)) tri_inset(t[1], t[2], t[3], d);
}

// ---- Scalar field patterns --------------------------------------------------
// Both the wave field and the reaction-diffusion pattern are "cut where f(x,y) is
// above a threshold".  Rather than contour them, each thin column of X is scanned
// in Y and the runs that are above the threshold become rectangles; the union welds
// the columns back together.  Eroding the result by half a wall afterwards both
// smooths the column steps and guarantees the wall thickness - a level set can pinch
// to nothing at a saddle, and eroding the holes reopens exactly one wall there.
RD_Rand = rands(0, 1, Reaction_Diffusion_Waves * 2, Reaction_Diffusion_Seed);

function rd_sum(x, y, k) =
    (k >= Reaction_Diffusion_Waves) ? 0
    : let (th = 180 * RD_Rand[2 * k], ph = 360 * RD_Rand[2 * k + 1])
      cos(360 * (x * cos(th) + y * sin(th)) / Reaction_Diffusion_Wavelength + ph)
      + rd_sum(x, y, k + 1);

function wave_field_sum(x, y, k) =
    (k >= len(Wave_Field_Angles)) ? 0
    : let (th = Wave_Field_Angles[k], lam = Wave_Field_Lambdas[k])
      sin(360 * (x * cos(th) + y * sin(th)) / lam)
      + wave_field_sum(x, y, k + 1);

// kind 0 = parametric wave field, 1 = reaction-diffusion
function field_f(kind, x, y) =
    (kind == 0) ? wave_field_sum(x, y, 0) : rd_sum(x, y, 0);

// Where the field crosses the threshold along an edge, found by linear interpolation.
function seg_pt(P, vp, Q, vq) = P + (Q - P) * (vp / (vp - vq));

// The part of triangle ABC where the field is at or above the threshold.  Splitting
// each grid cell into two triangles keeps this to eight cases and gives a properly
// interpolated contour - sampling column by column instead would step by a whole
// grid row wherever the contour runs steep.
function tri_above_pts(A, va, B, vb, C, vc) =
    let (a = va >= 0, b = vb >= 0, c = vc >= 0)
      (a && b && c)    ? [A, B, C]
    : (!a && !b && !c) ? []
    : (a && b && !c)   ? [A, B, seg_pt(B, vb, C, vc), seg_pt(A, va, C, vc)]
    : (a && !b && c)   ? [A, seg_pt(A, va, B, vb), seg_pt(C, vc, B, vb), C]
    : (!a && b && c)   ? [seg_pt(A, va, B, vb), B, C, seg_pt(A, va, C, vc)]
    : (a && !b && !c)  ? [A, seg_pt(A, va, B, vb), seg_pt(A, va, C, vc)]
    : (!a && b && !c)  ? [seg_pt(B, vb, A, va), B, seg_pt(B, vb, C, vc)]
    :                    [seg_pt(C, vc, A, va), seg_pt(C, vc, B, vb), C];

module tri_above(A, va, B, vb, C, vc) {
    p = tri_above_pts(A, va, B, vb, C, vc);
    if (len(p) >= 3) polygon(p);
}

module field_fill_2d(kind, thr) {
    x0 = -Cut_Half_X_Max - 2;  x1 = Cut_Half_X_Max + 2;
    y0 = Cut_Y0 - 2;           y1 = Cut_Y1 + 2;
    nx = max(2, ceil((x1 - x0) / Field_Grid));
    ny = max(2, ceil((y1 - y0) / Field_Grid));
    dx = (x1 - x0) / nx;
    dy = (y1 - y0) / ny;
    g  = [ for (j = [0 : ny]) [ for (i = [0 : nx])
             field_f(kind, x0 + i * dx, y0 + j * dy) - thr ] ];
    for (j = [0 : ny - 1], i = [0 : nx - 1]) {
        P00 = [x0 + i * dx,       y0 + j * dy];
        P10 = [x0 + (i + 1) * dx, y0 + j * dy];
        P11 = [x0 + (i + 1) * dx, y0 + (j + 1) * dy];
        P01 = [x0 + i * dx,       y0 + (j + 1) * dy];
        tri_above(P00, g[j][i],     P10, g[j][i + 1],     P11, g[j + 1][i + 1]);
        tri_above(P00, g[j][i],     P11, g[j + 1][i + 1], P01, g[j + 1][i]);
    }
}

// Eroding by (half a wall + s) and then dilating by s nets out to exactly half a
// wall - so the wall guarantee is unchanged - while the dilation rounds off the
// column steps that plain erosion would have preserved.
module field_shape_2d(kind, thr) {
    s = Field_Smoothing;
    offset(r = s)
        offset(r = -(Pat_Wall / 2 + s))
            field_fill_2d(kind, thr);
}

module reaction_diffusion_2d() { field_shape_2d(1, Reaction_Diffusion_Threshold); }

// ---- Parametric wave field --------------------------------------------------
// Bands whose centreline is displaced by two superimposed travelling waves, so the
// beat between them makes the run of the field drift and never quite repeat, and
// whose thickness is modulated by a third, slower wave.
//
// Every band shares one displacement function, so they are exact translates of one
// another: the gap between neighbours is pitch - thickness at every x, which is why
// capping the thickness at (pitch - wall) guarantees the wall outright rather than
// leaving it to a later erosion.
function wf_offset(x) =
    Wave_Field_Amplitude_1 * sin(360 * x / Wave_Field_Lambda_1)
  + Wave_Field_Amplitude_2 * sin(360 * x / Wave_Field_Lambda_2 + 55);

function wf_thickness(x) =
    let (tmax = max(0.6, Wave_Field_Pitch - Pat_Wall))
    tmax * (Wave_Field_Thickness_Min
            + (1 - Wave_Field_Thickness_Min)
              * (0.5 + 0.5 * sin(360 * x / Wave_Field_Thickness_Lambda + 20)));

module wave_field_band(yc) {
    n  = 72;
    x0 = -Cut_Half_X_Max - 2;
    x1 =  Cut_Half_X_Max + 2;
    polygon(concat(
        [ for (i = [0 : n]) let (x = x0 + (x1 - x0) * i / n)
            [x, yc + wf_offset(x) + wf_thickness(x) / 2] ],
        [ for (i = [n : -1 : 0]) let (x = x0 + (x1 - x0) * i / n)
            [x, yc + wf_offset(x) - wf_thickness(x) / 2] ]));
}

module wave_field_2d() {
    ny = pat_ny(Wave_Field_Pitch);
    for (j = [-ny : ny]) wave_field_band(Cut_Y_Mid + j * Wave_Field_Pitch);
}

// ---- Biomimetic leaf veins --------------------------------------------------
// Here the pattern is the material rather than the holes: a midrib with secondary
// veins arching off it, everything else cut away.  Stroke widths are the wall
// thickness, so the ribs are the walls.
module stroke(p0, p1, w) {
    hull() {
        translate(p0) circle(d = w);
        translate(p1) circle(d = w);
    }
}

// Quadratic Bezier, stroked as a chain of capsules so the vein arcs like a real one.
module vein(p0, p1, p2, w, n = 7) {
    pts = [ for (i = [0 : n])
              let (u = i / n)
              (1 - u) * (1 - u) * p0 + 2 * (1 - u) * u * p1 + u * u * p2 ];
    for (i = [0 : n - 1]) stroke(pts[i], pts[i + 1], w);
}

module leaf_veins_solid() {
    stroke([0, Cut_Y0 - 4], [0, Cut_Y1 + 4], Leaf_Midrib_Width);
    n  = max(1, floor((Cut_Y1 - Cut_Y0) / Leaf_Vein_Spacing));
    dy = Leaf_Vein_Spacing * Leaf_Vein_Rise;
    xe = Cut_Half_X_Max + 4;
    for (k = [0 : n], sgn = [-1, 1]) {
        y = Cut_Y0 + (k + 0.15) * Leaf_Vein_Spacing;
        vein([0, y],
             [sgn * xe * 0.62, y + dy * 0.18],
             [sgn * xe,        y + dy], Leaf_Vein_Width);
    }
}

module leaf_veins_2d() {
    difference() {
        cut_region_2d();
        leaf_veins_solid();
    }
}

// ---- Vertical text ----------------------------------------------------------
// Runs up the text band, held off the blade edges by the usual side margins.
module vtext_region_2d() {
    intersection() {
        offset(r = -Blade_Cutout_Side_Margins) blade_outline_2d();
        translate([-Blade_Length, Text_Y0])
            square([2 * Blade_Length, max(0.1, Text_Y1 - Text_Y0)]);
    }
}

module vertical_text_2d() {
    translate([0, Text_Y_Mid])
        rotate(90)
            text(Blade_Cutout_Vertical_Text,
                 size = Blade_Cutout_Text_Size,
                 font = Blade_Cutout_Text_Font,
                 halign = "center", valign = "center", $fn = 24);
}

// ---- Personalised name ------------------------------------------------------
// Etched into the underside of the first blade, running along it like the vertical
// text.  Mirrored in X because it is cut into the bottom face: seen from underneath
// the X axis reads backwards, so the drawing has to be flipped for the name to come
// out the right way round when the fan is turned over.
module personalized_name_2d() {
    mirror([1, 0, 0])
        translate([0, PName_Y_Mid])
            rotate(90)
                text(Personalized_Name,
                     size = PName_Size,
                     font = Blade_Cutout_Text_Font,
                     halign = "center", valign = "center", $fn = 24);
}

module pname_region_2d() {
    intersection() {
        offset(r = -Blade_Cutout_Side_Margins) blade_outline_2d();
        translate([-Blade_Length, PName_Y0])
            square([2 * Blade_Length, max(0.1, PName_Y1 - PName_Y0)]);
    }
}

module personalized_name_cut_2d() {
    intersection() { pname_region_2d(); personalized_name_2d(); }
}

// ---- Horizontal text --------------------------------------------------------
// The text belongs to the *fan*, not to any one blade: it is laid out once, in
// the fan's own frame (pivot at the origin, blades radiating upwards), and each
// blade then cuts whatever part of it happens to fall on that blade.  Reassembled,
// the pieces line up into one line of text.  Where two blades overlap, both carry
// the same fragment, so whichever one ends up on top still reads correctly.
//
// The line is bent around an arc concentric with the pivot by slicing the flat
// text into narrow vertical strips and swinging each strip to its own angle.
// This needs no font metrics, so it works with any font.
// Bends whatever it is given around an arc of the given radius, by slicing it into
// narrow vertical strips and swinging each strip to its own angle.  `span_half`
// bounds how far out the artwork can reach, `half_height` how tall it is; only the
// strips falling inside [a_lo, a_hi] are emitted, which is what keeps each blade
// from having to slice the whole fan's worth of artwork.
module arc_bend_2d(radius, a_lo, a_hi, span_half, half_height) {
    if (radius > 1) {
        // A strip at flat x sits at fan angle -x/radius, so the wanted angle
        // window maps back to this range of x.
        xlo = max(-span_half, -radius * a_hi * PI / 180);
        xhi = min( span_half, -radius * a_lo * PI / 180);
        n   = floor((xhi - xlo) / Horizontal_Text_Strip_Width) + 1;
        if (xhi > xlo) {
            w = (xhi - xlo) / n;
            // Neighbouring strips splay apart at the outer edge of the artwork, so
            // each strip is widened slightly to keep the seams closed.
            ww = w * (1 + 1.5 * half_height / radius);
            for (k = [0 : n - 1]) {
                xc = xlo + (k + 0.5) * w;
                rotate(-xc / radius * 180 / PI)
                    translate([0, radius])
                        intersection() {
                            translate([-xc, 0]) children();
                            translate([-ww / 2, -half_height])
                                square([ww, 2 * half_height]);
                        }
            }
        }
    }
}

module arc_line_2d(txt, radius, a_lo, a_hi) {
    if (len(txt) > 0)
        arc_bend_2d(radius, a_lo, a_hi,
                    len(txt) * Blade_Cutout_Text_Size / 2,   // generous width bound
                    2 * Blade_Cutout_Text_Size)
            text(txt,
                 size = Blade_Cutout_Text_Size,
                 font = Blade_Cutout_Text_Font,
                 halign = "center", valign = "center", $fn = 24);
}

// ---- SVG artwork ------------------------------------------------------------
// The same trick as the horizontal text, applied to an imported drawing: the art is
// laid out once in the fan's frame and each blade keeps whatever part of it lands on
// that blade.  Where blades overlap both carry the same fragment, so whichever ends
// up on top still shows the right piece and the picture reassembles when the fan is
// spread.  resize() scales the imported drawing by its own ink bounds, so a zero
// width or height is filled in from the artwork's aspect ratio.
// Dragging a file into a terminal, or copying its path on a system where the path
// contains spaces, hands back something like '/Users/me/My Drive/art.svg' - quotes
// and all.  Those are part of the shell's quoting, not the filename, so any at
// either end are stripped before the path is used.
function svg_first_kept(s, i) = (i < len(s) && s[i] == "'") ? svg_first_kept(s, i + 1) : i;
function svg_last_kept(s, i)  = (i >= 0    && s[i] == "'") ? svg_last_kept(s, i - 1)  : i;

// Halving rather than walking character by character, so even a long path only
// recurses a handful of levels deep.
function svg_substr(s, a, b) =
      (a > b)  ? ""
    : (a == b) ? s[a]
    : let (m = floor((a + b) / 2)) str(svg_substr(s, a, m), svg_substr(s, m + 1, b));

function strip_quotes(s) =
    let (a = svg_first_kept(s, 0), b = svg_last_kept(s, len(s) - 1))
    (a > b) ? "" : svg_substr(s, a, b);

SVG_File = strip_quotes(Blade_Cutout_SVG_File);

module svg_art_2d() {
    if (len(SVG_File) > 0)
        scale(SVG_Scale)
            resize([Blade_Cutout_SVG_Width, Blade_Cutout_SVG_Height], auto = true)
                import(file = SVG_File, center = true);
}

// The fan-wide artwork, in the fan's own frame with the pivot at the origin.
//
// By default the drawing is laid flat, so it reads undistorted once the fan is
// spread - the blades simply take their share of it.  Wrapping instead bends it
// around the arc the way the horizontal text is bent, which fills the sector corner
// to corner but shears the artwork, since the outer edge has to stretch further than
// the inner one.  Worth it for a border or a repeating motif, not for a logo.
module svg_fan_2d(i) {
    a = blade_angle(i);
    if (Blade_Cutout_SVG_Wrap)
        arc_bend_2d(SVG_Radius, a - Fan_SVG_Window, a + Fan_SVG_Window,
                    SVG_Span_Half, SVG_R_Half)
            svg_art_2d();
    else
        translate([0, SVG_Radius]) svg_art_2d();
}

// That artwork expressed in blade i's own coordinates.
module svg_blade_2d(i) {
    translate([0, Hole_Y])
        rotate(-blade_angle(i))
            svg_fan_2d(i);
}

// Horizontal text has to run all the way out to the blade edges.  Once the fan is
// extended each blade is covered by the next one except for a narrow strip along
// its edge, and that strip is the only part anybody ever reads - a side margin
// here would blank out precisely the text that shows.
module htext_region_2d() {
    w = Blade_Cutout_Pattern_Inner_Wall_Thickness;
    difference() {
        offset(r = -Horizontal_Text_Edge_Margin) blade_outline_2d();
        translate([-Slot_Half_X - w, Slot_Bot_Y0 - w])
            square([2 * (Slot_Half_X + w), Blade_Connection_Slot_Height + 2 * w]);
        translate([-Slot_Half_X - w, Slot_Top_Y0 - w])
            square([2 * (Slot_Half_X + w), Blade_Connection_Slot_Height + 2 * w]);
        translate([0, Hole_Y])
            circle(d = Blade_Bottom_Connection_Hole_Diameter + 2 * w);
    }
}

// The fan-wide text, restricted to the angular slice blade i can actually see.
module fan_text_2d(i) {
    a = blade_angle(i);
    arc_line_2d(Blade_Cutout_Horizontal_Text_Line_1, Text_Line_1_Radius,
                a - Fan_Text_Window, a + Fan_Text_Window);
    if (Has_Text_Line_2)
        arc_line_2d(Blade_Cutout_Horizontal_Text_Line_2, Text_Line_2_Radius,
                    a - Fan_Text_Window, a + Fan_Text_Window);
}

// Horizontal text expressed in blade i's own coordinates.
module horizontal_text_2d(i) {
    translate([0, Hole_Y])
        rotate(-blade_angle(i))
            fan_text_2d(i);
}

// ---- Dispatch ---------------------------------------------------------------

// Patterns cut clean through the blade.  The opening (erode then dilate) drops
// any sliver the cutout area's edge has pared down below Cutout_Min_Feature.
module through_cutout_2d() {
    offset(r = Cutout_Min_Feature / 2)
        offset(r = -Cutout_Min_Feature / 2)
            intersection() {
                cut_region_2d();
                if (Blade_Cutouts == "voronoi")                 voronoi_2d();
                else if (Blade_Cutouts == "honeycomb")          honeycomb_2d();
                else if (Blade_Cutouts == "hearts")             hearts_2d();
                else if (Blade_Cutouts == "triangular")         triangular_2d();
                else if (Blade_Cutouts == "isometric_triangular") isometric_triangular_2d();
                else if (Blade_Cutouts == "diamond")            diamond_2d();
                else if (Blade_Cutouts == "circular")           circular_2d();
                else if (Blade_Cutouts == "staggered_circular") staggered_circular_2d();
                else if (Blade_Cutouts == "rounded_squares")    rounded_squares_2d();
                else if (Blade_Cutouts == "slots")              slots_2d();
                else if (Blade_Cutouts == "gyroid")             gyroid_2d();
                else if (Blade_Cutouts == "wave")               wave_2d();
                else if (Blade_Cutouts == "islamic")            islamic_2d();
                else if (Blade_Cutouts == "fish_scales")        fish_scales_2d();
                else if (Blade_Cutouts == "delaunay")           delaunay_2d();
                else if (Blade_Cutouts == "gradient_voronoi")   gradient_voronoi_2d();
                else if (Blade_Cutouts == "variable_honeycomb") variable_honeycomb_2d();
                else if (Blade_Cutouts == "penrose")            penrose_2d();
                else if (Blade_Cutouts == "wave_field")         wave_field_2d();
                else if (Blade_Cutouts == "reaction_diffusion") reaction_diffusion_2d();
                else if (Blade_Cutouts == "leaf_veins")         leaf_veins_2d();
            }
}

// Etched, not cut through.  The fan-wide overlays - horizontal text and SVG art -
// are skipped when a single blade is rendered on its own, because they only mean
// anything across the whole set.  Both run out to the blade edges for the same
// reason the text does: the edge strip is the only part left showing once the fan
// is spread.
module etched_art_2d(i, with_fan_text, is_final = false) {
    // Vertical text goes on the last blade only.  That is the one that ends up on
    // top of the closed stack, so it is the only blade whose face is on show -
    // repeating the text on all of them would just hide it nineteen times over.
    // A blade rendered on its own still gets it, so the wording and size can be
    // checked without switching to a whole-fan view.
    if (Blade_Cutouts == "vertical_text" && (is_final || !with_fan_text))
        intersection() { vtext_region_2d(); vertical_text_2d(); }
    else if (Blade_Cutouts == "horizontal_text" && with_fan_text)
        intersection() { htext_region_2d(); horizontal_text_2d(i); }
    else if (Blade_Cutouts == "svg" && with_fan_text)
        intersection() { htext_region_2d(); svg_blade_2d(i); }
}

// -----------------------------------------------------------------------------
// Blade
// -----------------------------------------------------------------------------

// The blade's place in the stack, etched into the top face just under the pivot
// hole so the set can be assembled in the right order.  Numbering is 1-based, so
// blade i is stamped i + 1.
module blade_number_2d(i) {
    translate([0, Blade_Number_Y])
        text(str(i + 1),
             size = Blade_Number_Text_Size,
             font = Blade_Cutout_Text_Font,
             halign = "center", valign = "center", $fn = 24);
}

// i selects the variant: even = Blade Section A (peg in the top slot),
// odd = Blade Section B (peg in the bottom slot).  i also fixes where this blade
// sits in the fan, which is what the horizontal text needs.
//
// is_final marks the last blade of the set.  It ends up on top of the assembled
// stack, so it is the one blade whose handle stays in view - it gets no number.
// It also has nothing above it to link to, so it carries no connection slot peg.
module blade_body(i, with_fan_text = true, is_final = false) {
    difference() {
        linear_extrude(height = Blade_Thickness) blade_outline_2d();

        translate([0, Hole_Y, -Eps])
            cylinder(d = Blade_Bottom_Connection_Hole_Diameter, h = Blade_Thickness + 2 * Eps);

        slot_cut_3d(Slot_Top_Y0, Slot_Top_Y1);
        slot_cut_3d(Slot_Bot_Y0, Slot_Bot_Y1);

        if (Is_Hole_Cutout)
            translate([0, 0, -Eps])
                linear_extrude(height = Blade_Thickness + 2 * Eps) through_cutout_2d();

        if (Is_Text_Cutout)
            translate([0, 0, Blade_Thickness - Text_Depth])
                linear_extrude(height = Text_Depth + Eps) etched_art_2d(i, with_fan_text, is_final);

        if (!is_final)
            translate([0, 0, Blade_Thickness - Blade_Number_Depth])
                linear_extrude(height = Blade_Number_Depth + Eps) blade_number_2d(i);

        // Cut upward from below, so this one lands on the underside.
        if (Has_Personalized_Name && i == 0)
            translate([0, 0, -Eps])
                linear_extrude(height = PName_Depth + Eps) personalized_name_cut_2d();
    }
}

module blade(i, with_fan_text = true, is_final = false) {
    is_a = (i % 2 == 0);
    union() {
        blade_body(i, with_fan_text, is_final);
        if (!is_final) {
            if (is_a) slot_peg_3d(Slot_Top_Y0, Slot_Top_Y1);
            else      slot_peg_3d(Slot_Bot_Y0, Slot_Bot_Y1);
        }
    }
    // The lettering is a real recess, Blade_Cutout_Text_Depth deep, cut into the top
    // face by blade_body().  In preview only, that recess is filled with a solid in
    // Blade_Cutout_Text_Color so the text reads on screen and the chosen colour is
    // visible.  $preview is false for F6 and for every export, so what you render,
    // slice and print is the engraving itself - never a filled-in inlay.
    if (Is_Text_Cutout && $preview)
        color(Blade_Cutout_Text_Color)
            translate([0, 0, Blade_Thickness - Text_Depth])
                linear_extrude(height = Text_Depth) etched_art_2d(i, with_fan_text, is_final);

    if (Has_Personalized_Name && i == 0 && $preview)
        color(Blade_Cutout_Text_Color)
            linear_extrude(height = PName_Depth) personalized_name_cut_2d();
}

// -----------------------------------------------------------------------------
// Pivot peg and cap
// -----------------------------------------------------------------------------

Peg_Shaft_Diameter = max(0.8, Blade_Bottom_Connection_Hole_Diameter
                              - 2 * Blade_Bottom_Connection_Peg_Tolerance);
// How far the shaft can enter the cap: a share of the cap's own thickness, so the
// socket keeps its proportions whatever the cap is sized to.
Peg_Cap_Socket_Depth = Blade_Bottom_Connection_Peg_Cap_Thickness
                       * max(30, min(100, Peg_Cap_Socket_Percent)) / 100;
// The shaft only has to clear the blade stack, cross the tolerance gap the cap
// floats on, and fill the cap's socket - no more.  Anything longer bottoms out
// against the end of the socket and holds the cap off the stack.
Peg_Shaft_Length   = Blade_Thickness * Number_Of_Blades
                     + Blade_Bottom_Connection_Peg_Cap_Tolerance
                     + Peg_Cap_Socket_Depth;

// extra_length lets the spare peg be run longer than the fitted one.
module connector_peg(extra_length = 0) {
    union() {
        cylinder(d = Blade_Bottom_Connection_Peg_Base_Diameter,
                 h = Blade_Bottom_Connection_Peg_Base_Thickness);
        translate([0, 0, Blade_Bottom_Connection_Peg_Base_Thickness - Eps])
            cylinder(d = Peg_Shaft_Diameter, h = Peg_Shaft_Length + extra_length + Eps);
    }
}

// Modelled as it sits when assembled, socket facing down over the shaft.
// shaft_tolerance lets the spare cap be bored tighter than the fitted one.
module connector_peg_cap(shaft_tolerance = Peg_Cap_Shaft_Tolerance) {
    difference() {
        cylinder(d = Blade_Bottom_Connection_Peg_Cap_Diameter,
                 h = Blade_Bottom_Connection_Peg_Cap_Thickness);
        translate([0, 0, -Eps])
            cylinder(d = Peg_Shaft_Diameter + max(0, shaft_tolerance),
                     h = Peg_Cap_Socket_Depth + Eps);
    }
}

// The cap turned over for printing.  Left the way it is assembled, the socket opens
// downward and its ceiling has to bridge the full shaft bore; inverted, the ceiling
// becomes the first layer, the bore is an open-topped well needing no support, and
// the cap's visible outer face is the one laid against the build plate.
module connector_peg_cap_printed(shaft_tolerance = Peg_Cap_Shaft_Tolerance) {
    translate([0, 0, Blade_Bottom_Connection_Peg_Cap_Thickness])
        rotate([180, 0, 0])
            connector_peg_cap(shaft_tolerance);
}

// The whole pivot kit on the bed: the fitted peg and cap in the front row, and
// behind them a spare pair - a longer peg and a tighter-bored cap, in blue - so a
// slacker or tighter fit is already printed if the first pair does not seat well.
// The peg stands on its base disc, the caps are inverted, everything sits at z = 0.
//
// Laid out two by two rather than in a line so the set still fits inside a single
// blade slot on the print plate, which is only one blade pitch wide.
module connector_hardware_view() {
    d  = max(Blade_Bottom_Connection_Peg_Base_Diameter,
             Blade_Bottom_Connection_Peg_Cap_Diameter);
    dx = (d + Print_Layout_Gap) / 2;
    dy = (d + Print_Layout_Gap) / 2;
    spare_tol = max(0, Peg_Cap_Shaft_Tolerance - Spare_Cap_Tolerance_Reduction);

    translate([-dx,  dy, 0]) connector_peg();
    translate([ dx,  dy, 0]) connector_peg_cap_printed();

    color(Spare_Hardware_Color) {
        translate([-dx, -dy, 0]) connector_peg(Spare_Peg_Extra_Length);
        translate([ dx, -dy, 0]) connector_peg_cap_printed(spare_tol);
    }
}

// -----------------------------------------------------------------------------
// Rendering modes
// -----------------------------------------------------------------------------

// Alternate blades are turned 180 degrees in the plane so the wide end of one sits
// beside the narrow end of the next; a row of tapered blades then nests into far
// less bed width.  Average width is exactly the pitch that nesting allows.
Print_Pitch = (Top_Blade_Width + Bottom_Blade_Width) / 2 + Print_Layout_Gap;

// The peg and its cap are small enough to share one slot at the end of the run,
// so the layout is simply Number_Of_Blades + 1 slots wrapped into rows.
Print_Slots = Number_Of_Blades + 1;
// A row of n slots is (n-1) pitches across plus one full-width blade at the end.
Print_Slots_Per_Row_Max = max(1, floor((Print_Bed_Width - Top_Blade_Width) / Print_Pitch) + 1);
// The bed width decides how many rows are needed; the slots are then levelled across
// them rather than each row being filled to capacity, which would leave a stub of a
// final row.  Splitting the remainder one slot at a time - the first few rows taking
// one extra - is what makes 41 slots come out 9/8/8/8/8 rather than 9/9/9/9/5; a
// single shared row length cannot express that.
//
// Levelling never widens the plate: with the row count taken as ceil(slots / max),
// the longest levelled row, ceil(slots / rows), is always back within that maximum.
Print_Rows_Wanted = (Print_Rows > 0)
                    ? max(1, Print_Rows)
                    : max(1, ceil(Print_Slots / Print_Slots_Per_Row_Max));
// Never more rows than slots, so no row can come out empty.
Print_Row_Count = max(1, min(Print_Rows_Wanted, Print_Slots));
Print_Row_Base  = floor(Print_Slots / Print_Row_Count);
Print_Row_Extra = Print_Slots - Print_Row_Base * Print_Row_Count;   // rows taking one more
Print_Row_Pitch = Blade_Length + Print_Layout_Gap;

function print_row_slots(r) = Print_Row_Base + ((r < Print_Row_Extra) ? 1 : 0);
function print_row_start(r) = r * Print_Row_Base + min(r, Print_Row_Extra);

// A row is a whole blade deep, so the bed depth caps how many rows share a plate.
Print_Rows_Per_Plate = max(1, floor((Print_Bed_Depth + Print_Layout_Gap) / Print_Row_Pitch));
Print_Plate_Count   = ceil(Print_Row_Count / Print_Rows_Per_Plate);
Print_Row_First = (Print_Plate > 0)
                  ? (min(Print_Plate, Print_Plate_Count) - 1) * Print_Rows_Per_Plate : 0;
Print_Row_Last  = (Print_Plate > 0)
                  ? min(Print_Row_Count, Print_Row_First + Print_Rows_Per_Plate) - 1
                  : Print_Row_Count - 1;

Print_Plate_Rows  = Print_Row_Last - Print_Row_First + 1;
Print_Plate_Width = (print_row_slots(Print_Row_First) - 1) * Print_Pitch + Top_Blade_Width;
Print_Plate_Depth = Print_Plate_Rows * Blade_Length
                    + (Print_Plate_Rows - 1) * Print_Layout_Gap;

module all_blades_for_printing() {
    for (r = [Print_Row_First : Print_Row_Last]) {
        cnt = print_row_slots(r);
        for (c = [0 : cnt - 1]) {
            s = print_row_start(r) + c;
            translate([(c - (cnt - 1) / 2) * Print_Pitch,
                       (r - Print_Row_First) * Print_Row_Pitch, 0])
                if (s < Number_Of_Blades)
                    translate([0, Blade_Length / 2, 0])
                        rotate([0, 0, (s % 2 == 0) ? 0 : 180])
                            translate([0, -Blade_Length / 2, 0])
                                blade(s, is_final = (s == Number_Of_Blades - 1));
                else
                    // Last slot: the pivot kit - fitted peg and cap, plus the blue
                    // spare pair - two by two so it fits inside one blade pitch.
                    translate([0, Blade_Length / 2, 0]) connector_hardware_view();
        }
    }
}

module assembly_view() {
    for (i = [0 : Number_Of_Blades - 1])
        translate([0, 0, i * Blade_Thickness])
            translate([0, Hole_Y, 0])
                rotate([0, 0, blade_angle(i)])
                    translate([0, -Hole_Y, 0])
                        blade(i, is_final = (i == Number_Of_Blades - 1));

    translate([0, Hole_Y, -Blade_Bottom_Connection_Peg_Base_Thickness])
        connector_peg();
    // connector_peg_cap() is already modelled the way it sits here - socket facing
    // down over the shaft - so it just gets lifted to float one cap tolerance above
    // the stack.  Turning it over would point the socket at the sky and bury the
    // shaft in the solid end of the cap.
    translate([0, Hole_Y,
               Number_Of_Blades * Blade_Thickness + Blade_Bottom_Connection_Peg_Cap_Tolerance])
        connector_peg_cap();
}

if (Rendering_Mode == "printing") {
    all_blades_for_printing();
    echo(str("Print layout: ",
             (Print_Plate > 0) ? str("plate ", min(Print_Plate, Print_Plate_Count),
                                     " of ", Print_Plate_Count, ", ")
                               : str("whole set (", Print_Plate_Count, " plate(s) needed), "),
             Print_Plate_Rows, " row(s), ",
             Print_Plate_Width, " x ", Print_Plate_Depth, " mm - ",
             (Print_Plate_Width > Print_Bed_Width)
                 ? str("TOO WIDE for the ", Print_Bed_Width, " x ", Print_Bed_Depth,
                       " mm bed; raise Print_Rows, or set it back to 0 to wrap automatically.")
             : (Print_Plate_Depth > Print_Bed_Depth)
                 ? str("TOO DEEP for the ", Print_Bed_Width, " x ", Print_Bed_Depth,
                       " mm bed; set Print_Plate to 1..", Print_Plate_Count,
                       " to render one bed-sized batch at a time.")
                 : str("fits the ", Print_Bed_Width, " x ", Print_Bed_Depth, " mm bed.")));
}
else if (Rendering_Mode == "section_a")  blade(0, with_fan_text = false);
else if (Rendering_Mode == "section_b")  blade(1, with_fan_text = false);
else if (Rendering_Mode == "assembly")   assembly_view();
else if (Rendering_Mode == "hardware")   connector_hardware_view();
