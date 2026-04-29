// Text-Flip 3D Model
// View at 45 degrees to read Word 1, or at -45 degrees to read Word 2
// https://www.thingiverse.com/thing:2809071

include <BOSL2/std.scad>

/* [Text Options] */
word_1 = "MOM";                      // Word visible at 45 degree angle
word_2 = "DAD";                      // Word visible at -45 degree angle
font_name = "Montagu Slab:Bold";     // Font name
font_size = 20;                      // Font size in mm
letter_spacing = 20;                 // Space between letters in mm
letter_rotation = 45;                    // Rotation angle for letters in degrees

/* [Base Options] */
// Thickness of the base in mm
base_thickness = 3;      
// Padding around the text on the base
base_padding = 10;
// Radius for rounded ends (pill shape)
corner_radius = 10;  




/* [Hidden] */
// Calculate text dimensions for layout
text_height = font_size * 0.7;  // Approximate height of text
char_width = font_size * 0.6;   // Approximate width per character
$fn = 106;

// Calculate total width needed for word_1 (longer word)
word_1_upper = upcase(word_1);
echo("Word 1: ", word_1_upper);
word_2_upper = upcase(word_2);
echo("Word 2: ", word_2_upper);
word_1_length = len(word_1_upper);
word_2_length = len(word_2_upper);
max_chars = max(word_1_length, word_2_length);
total_text_width = (max_chars - 1) * letter_spacing + max_chars * char_width;

//Base Dimensions
base_width = total_text_width + (base_padding * 2);
base_length = text_height + (base_padding * 2);
base_height = base_thickness;





// ============ MAIN MODEL ============

// Create the base
pill_base();

// Create intersected letter pairs
intersected_words();

// Module to create rounded rectangle (pill shape) base
module pill_base() {
    // Create a pill-shaped base with rounded ends
    // hull() {
    //     // Left rounded end
    //     translate([-(base_width/2 - corner_radius), 0, 0])
    //         cylinder(h = base_height, r = corner_radius, $fn = 32);
        
    //     // Right rounded end
    //     translate([(base_width/2 - corner_radius), 0, 0])
    //         cylinder(h = base_height, r = corner_radius, $fn = 32);
    // }
    echo ("Base dimensions: ", base_width, " x ", base_length, " x ", base_height);
    cuboid([base_width, base_length, base_height], rounding=corner_radius, edges="Z");
    
}

// Module to create intersected letter pairs from both words
module intersected_words() {
    start_x = -(total_text_width / 2) + char_width / 2;
    
    for (i = [0 : max_chars - 1]) {
        x_pos = start_x + i * (char_width + letter_spacing);
        
        // Get letters from each word, or empty string if word is shorter
        letter_1 = (i < word_1_length) ? word_1_upper[i] : "";
        letter_2 = (i < word_2_length) ? word_2_upper[i] : "";
        
        // Only create intersection if both letters exist
        if (letter_1 != "" && letter_2 != "") {
            intersection() {
            // union(){
                rotated_letter(letter_1, x_pos, letter_rotation);
                rotated_letter(letter_2, x_pos, -letter_rotation);
            }
        }
    }
}

// Module to create individual letter with rotation around its own Z-axis
module rotated_letter(letter, position, rotation) {
    translate([position, 0, font_size / 2])
        rotate([90, 0, rotation])
            translate([0, 0, base_height/2])
                linear_extrude(height = font_size, center = true)
                    text(letter, font = font_name, size = font_size, halign = "center", valign = "center");
}

// Module to create a word with proper letter spacing and rotation
module spaced_word(word, rotation) {
    word_length = len(word);
    start_x = -(total_text_width / 2) + char_width / 2;
    
    for (i = [0 : word_length - 1]) {
        letter = word[i];
        x_pos = start_x + i * (char_width + letter_spacing);
        rotate([0, 0, 0]){
            rotated_letter(letter, x_pos, rotation);
        }
    }
}

// Module for word at 45 degree angle
module word_at_45() {
    spaced_word(word_1_upper, 45);
}

// Module for word at -45 degree angle
module word_at_neg45() {
    spaced_word(word_2_upper, -45);
}