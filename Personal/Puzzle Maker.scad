STL_File = "puzzle_image_sample.stl";
STL_xshift = 0;
STL_yshift = 0;
STL_zshift = 0;

/* [Puzzle Parameters] */
Preview_Cutter = true;
//X dimension of cutted model in mm 
x=150;
//Y dimension of cutted model in mm 
y=200;
//Z dimension of cutted model in mm
z=15;

//Thickness of frame
frame_thickness = 2;

// Range of average piece size in mm
min_piecesize = 15;
max_piecesize = 30;

// Space between pieces in mm
bezwidth=0.12;

if(Preview_Cutter){
  color("blue") puzzleCutter();
} 

// // // // // // // // // // // // // // ////
// Do not change anything beyond this point //
// // // // // // // // // // // // // // ////

STL_xpos = x/2+STL_xshift+frame_thickness;
STL_ypos = y/2+STL_yshift+frame_thickness;
STL_zpos = 0+STL_zshift;

difference(){
  translate([ STL_xpos, STL_ypos, STL_zpos ])
    import(STL_File);
  puzzleCutter();
}

module puzzleCutter(){
  rest = [for (var_p = [min_piecesize:max_piecesize]) 
        min( (x%var_p)/var_p , 1 - (x%var_p)/var_p) + 
        min( (y%var_p)/var_p , 1 - (y%var_p)/var_p)
      ];

  piece_sizes = [for (var_p = [min_piecesize:max_piecesize]) 
          var_p
        ];
  x_pieces_count = [for (var_p = [min_piecesize:max_piecesize]) 
          round(x/var_p)
        ];
  y_pieces_count = [for (var_p = [min_piecesize:max_piecesize]) 
          round(y/var_p)
        ]; 

  function index_min(l) = search(min(l), l)[0];

  // Average piece size in mm
  piecesize=piece_sizes[index_min(rest)]; 
  // How many rows of pieces
  rows=max(2, y_pieces_count[index_min(rest)]); 
  // How many columns of pieces
  columns=max(2,x_pieces_count[index_min(rest)]); 
  // Piece thickness in mm
  thickness=1; 

  //Print info
  echo(str("--Info--"));
  echo(str("# rows = ", rows));
  echo(str("# columns = ", columns));
  echo(str("piecesize = ", piecesize));

  /* [Hidden] */
  // Determine puzzle width
  cubex=piecesize*columns;
  // Determine puzzle height
  cubey=piecesize*rows;
  // Make sure cuts all the way through puzzle
  bezheight=thickness+1;
  // Resolution, higher=better quality,more time to render
  bezsteps=20;

  // These variable control the nub of the piece
  // beza is the start and end point of the nub
  bezaw=0.28*piecesize;
  bezah=0.0*piecesize;

  // --- GEOMETRIE FIX GEGEN ÜBERSCHNEIDUNGEN ---
  // bezb is the narrow part of the nub
  bezbw=0.69*piecesize; 
  bezbh=0.08*piecesize;
  // bezc is the wide part of the nub
  bezcw=0.15*piecesize; 
  bezch=0.12*piecesize;
  // --------------------------------------------

  // bezd is the top of the nub
  bezdw=0*piecesize;
  bezdh=0.54*piecesize;

  // These variable control the legs of the piece
  bezlegax=0*piecesize;
  bezlegay=0*piecesize;
  bezlegbx=0.1*piecesize;
  bezlegby=-0.04*piecesize;
  bezlegcx=0.2*piecesize;
  bezlegcy=-0.04*piecesize;
  bezlegdx=0.24*piecesize;
  bezlegdy=0*piecesize;
  bezlegex=0.28*piecesize;
  bezlegey=0*piecesize;

  // variables that control how much variation is in the pieces
  // --- FIX: Weniger Zufall ---
  stdev=0.003*piecesize; 
  mean=1;

  // creating a normal distribution for nub variability
  function sd(stdev,mean)=(rands(-1,1,1)[0]+rands(-1,1,1)[0]+rands(-1,1,1)[0])*stdev+mean;

  // module to creat nub
  module nub(xpos,ypos,piecesizex,piecesizey,bezwidth,bezheight,bezsteps,bezaw,
      bezah,bezbw,bezbh,bezcw,bezch,bezdw,bezdh,signx,signy,flipx,flipy) {
    BezWall( [
      [xpos+flipx*bezaw, (ypos+flipy*bezah)], // A-L
      [xpos+sd(stdev,mean)*flipx*bezbw, (ypos+sd(stdev,mean)*flipy*bezbh)], // B-L
      [xpos+sd(stdev,mean)*flipx*bezcw, (ypos+sd(stdev,mean)*flipy*bezch)], // C-L
      [xpos+sd(stdev,mean)*flipx*bezdw, (ypos+sd(stdev,mean)*flipy*bezdh)], // D-L
      [xpos+piecesizex+sd(stdev,mean)*flipx*(signx*bezdw), ypos+piecesizey+sd(stdev,mean)*flipy*(signy*bezdh)], // D-R
      [xpos+piecesizex+sd(stdev,mean)*flipx*(signx*bezcw), ypos+piecesizey+sd(stdev,mean)*flipy*(signy*bezch)], // C-R
      [xpos+piecesizex+sd(stdev,mean)*flipx*(signx*bezbw), ypos+piecesizey+sd(stdev,mean)*flipy*(signy*bezbh)], // B-R
      [xpos+piecesizex+flipx*(signx*bezaw), ypos+piecesizey+flipy*(signy*bezah)], // A-R
    ] , width = bezwidth, height = bezheight, steps = bezsteps, centered = true );
  }

  // module to create nub legs
  module legs(xpos,ypos,piecesizex,piecesizey,bezwidth,bezheight,bezsteps,
      bezlegax,bezlegbx,bezlegcx,bezlegdx,bezlegex,bezlegay,bezlegby,bezlegcy,
      bezlegdy,bezlegey,left,right,flipx,flipy) {
    BezWall( [
      [xpos+piecesizex+flipx*(left*bezlegax), ypos+piecesizey+flipy*(right*bezlegay)], // 
      [xpos+piecesizex+sd(stdev,mean)*flipx*(left*bezlegbx), ypos+piecesizey+sd(stdev,mean)*flipy*(right*bezlegby)], // 
      [xpos+piecesizex+sd(stdev,mean)*flipx*(left*bezlegcx), ypos+piecesizey+sd(stdev,mean)*flipy*(right*bezlegcy)], // 
      [xpos+piecesizex+flipx*(left*bezlegdx), ypos+piecesizey+flipy*(right*bezlegdy)], // 
      [xpos+piecesizex+flipx*(left*bezlegex), ypos+piecesizey+flipy*(right*bezlegey)], // 
    ] , width = bezwidth, height = bezheight, steps = bezsteps, centered = true );
    // this cylinder is added to help make a smooth connection between legs and nub
    translate([xpos+bezlegex,ypos+bezlegey,0]) cylinder(r=bezwidth/2, 
      h=bezheight);
  }

  module cutter(){
    for (xpos=[0:piecesize:cubex-piecesize], 
      ypos = [piecesize:piecesize:cubey-piecesize])
    {
        flipy = rands(-1,1,1)[0]>0 ? 1 : -1;
        
        nub(xpos,ypos,piecesize,0,bezwidth,bezheight,bezsteps,bezaw,bezah,bezbw,
            bezbh,bezcw,bezch,bezdw,bezdh,-1,1,1,flipy);

        legs(xpos,ypos,0,0,bezwidth,bezheight,bezsteps,bezlegax,bezlegbx,bezlegcx,
            bezlegdx,bezlegex,bezlegay,bezlegby,bezlegcy,bezlegdy,bezlegey,1,1,1,flipy);
    
        legs(xpos,ypos,piecesize,0,bezwidth,bezheight,bezsteps,bezlegex,bezlegdx,
            bezlegcx,bezlegbx,bezlegax,bezlegey,bezlegdy,bezlegcy,bezlegby,
            bezlegay,-1,1,1,flipy);
    }
    
    for (xpos = [piecesize:piecesize:cubex-piecesize], 
          ypos = [0:piecesize:cubey-piecesize])
    {
        flipx = rands(-1,1,1)[0]>0 ? 1 : -1;
        
        nub(xpos,ypos,0,piecesize,bezwidth,bezheight,bezsteps,bezah,bezaw,bezbh,
            bezbw,bezch,bezcw,bezdh,bezdw,1,-1,flipx,1);
    
        legs(xpos,ypos,0,0,bezwidth,bezheight,bezsteps,bezlegay,bezlegby,bezlegcy,
            bezlegdy,bezlegey,bezlegax,bezlegbx,bezlegcx,bezlegdx,bezlegex,1,1,flipx,1);
    
        legs(xpos,ypos,0,piecesize,bezwidth,bezheight,bezsteps,bezlegay,bezlegby,
            bezlegcy,bezlegdy,bezlegey,bezlegax,bezlegbx,bezlegcx,bezlegdx,
            bezlegex,1,-1,flipx,1);
    }
  }

  module frame() {
      outer_box = [x + 2 * frame_thickness, y + 2 * frame_thickness, z];
      puzzle_box = [x, y, z];
      
      difference() {
          cube(outer_box);
          translate([frame_thickness, frame_thickness, 0])
          cube(puzzle_box);
      }
  }

  // RENDERING
  frame();
  resize([x+2,y+2,z+2])
  cutter();
}




// ***************************************************
// LIBRARY
// ***************************************************

module BezWall( 
  ctlPts, 
  width = 1, 
  height = 1, 
  steps = 16,
  widthCtls = [], 
  heightCtls = [], 
  centered = false, 
  showCtlR = 1
) {
  hodoPts = hodograph(ctlPts);
  if (showCtlR > 0) {
    for (pt = ctlPts) {
      % translate([pt[0], pt[1], 0]) circle(showCtlR);
    }
  }
  
  // FIX für MakerWorld/Polyhedron: faces statt triangles
  tri_idx = [ [0,2,1], [0,3,2], [0,4,5], [0,1,4], [0,6,3], [0,5,6], [4,6,5], [4,7,6], [1,2,7], [1,7,4], [2,3,6], [2,6,7], ];
  
  // FIX FÜR MAKERWORLD:
  // Wir zählen vorwärts [1 : steps-1]. 
  // MakerWorld mag [High : Low] (Rückwärts) oft nicht ohne expliziten Step.
  for(step = [1 : steps-1])
  {
      t1 = step/(steps-1);
      t0 = (step-1)/(steps-1);
    
      hgt0 = len(heightCtls) > 0 ? BezI(t0, heightCtls) : height;
      hgt1 = len(heightCtls) > 0 ? BezI(t1, heightCtls) : height;
      wid0 = len(widthCtls) > 0 ? BezI(t0, widthCtls) : width;
      wid1 = len(widthCtls) > 0 ? BezI(t1, widthCtls) : width;
   
      if (centered) {
          p0 = PerpAlongBez(t0, ctlPts, dist = -wid0/2, hodograph = hodoPts);
          p1 = PerpAlongBez(t0, ctlPts, dist = wid0/2, hodograph = hodoPts);
          p4 = PerpAlongBez(t1, ctlPts, dist = wid1/2, hodograph = hodoPts);
          p5 = PerpAlongBez(t1, ctlPts, dist = -wid1/2, hodograph = hodoPts);
        
          if (hgt0 == 0 && hgt1 == 0 ) {
            polygon([ p5, p0, p1, p4 ]);
          } else if (hgt0 == hgt1) {
            linear_extrude(height = hgt0, convexity = 2) polygon([ p5, p0, p1, p4 ]);
          } else {
            polyhedron(
              points =[
                [p0[0],p0[1],0], // 0
                [p1[0],p1[1],0], // 1
                [p1[0],p1[1],hgt0], // 2
                [p0[0],p0[1],hgt0], // 3
                [p4[0],p4[1],0], // 4
                [p5[0],p5[1],0], // 5
                [p5[0],p5[1],hgt1], // 6
                [p4[0],p4[1],hgt1], // 7
              ],
              faces = tri_idx,
              convexity = 2
            );
          }
      } else {
          p0 = PointAlongBez(t0, ctlPts);
          p1 = PerpAlongBez(t0, ctlPts, dist = wid0, hodograph = hodoPts);
          p4 = PerpAlongBez(t1, ctlPts, dist = wid1, hodograph = hodoPts);
          p5 = PointAlongBez(t1, ctlPts);
        
          if (hgt0 == 0 && hgt1 == 0 ) {
            polygon([ p5, p0, p1, p4 ]);
          } else if (hgt0 == hgt1) {
            linear_extrude(height = hgt0, convexity = 2) polygon([ p5, p0, p1, p4 ]);
          } else {
            polyhedron(
              points =[
                [p0[0],p0[1],0], // 0
                [p1[0],p1[1],0], // 1
                [p1[0],p1[1],hgt0], // 2
                [p0[0],p0[1],hgt0], // 3
                [p4[0],p4[1],0], // 4
                [p5[0],p5[1],0], // 5
                [p5[0],p5[1],hgt1], // 6
                [p4[0],p4[1],hgt1], // 7
              ],
              faces = tri_idx,
              convexity = 2
            );
          }
      } 
  }
}

function PointAlongBez(t, ctlPts) = 
  len(ctlPts) == 1 ? PointAlongBez1(t, ctlPts) : 
  len(ctlPts) == 2 ? PointAlongBez2(t, ctlPts) : 
  len(ctlPts) == 3 ? PointAlongBez3(t, ctlPts) : 
  len(ctlPts) == 4 ? PointAlongBez4(t, ctlPts) : 
  len(ctlPts) == 5 ? PointAlongBez5(t, ctlPts) : 
  len(ctlPts) == 6 ? PointAlongBez6(t, ctlPts) : 
  len(ctlPts) == 7 ? PointAlongBez7(t, ctlPts) : 
  len(ctlPts) == 8 ? PointAlongBez8(t, ctlPts) :
  [];

function BezI(t, ctls) = 
  len(ctls) == 1 ? BezI1(t, ctls) : 
  len(ctls) == 2 ? BezI2(t, ctls) : 
  len(ctls) == 3 ? BezI3(t, ctls) : 
  len(ctls) == 4 ? BezI4(t, ctls) : 
  len(ctls) == 5 ? BezI5(t, ctls) : 
  len(ctls) == 6 ? BezI6(t, ctls) : 
  len(ctls) == 7 ? BezI7(t, ctls) : 
  len(ctls) == 8 ? BezI8(t, ctls) :
  [];

function PointAlongBez1(t, ctlPts) = [ 
  BezI1(t, [ctlPts[0][0]]), 
  BezI1(t, [ctlPts[0][1]]) 
];
function PointAlongBez2(t, ctlPts) = [ 
  BezI2(t, [ctlPts[0][0], ctlPts[1][0]]), 
  BezI2(t, [ctlPts[0][1], ctlPts[1][1]]) 
];
function PointAlongBez3(t, ctlPts) = [ 
  BezI3(t, [ctlPts[0][0], ctlPts[1][0], ctlPts[2][0]]), 
  BezI3(t, [ctlPts[0][1], ctlPts[1][1], ctlPts[2][1]]) 
];
function PointAlongBez4(t, ctlPts) = [ 
  BezI4(t, [ctlPts[0][0], ctlPts[1][0], ctlPts[2][0], ctlPts[3][0]]), 
  BezI4(t, [ctlPts[0][1], ctlPts[1][1], ctlPts[2][1], ctlPts[3][1]]) 
];
function PointAlongBez5(t, ctlPts) = [ 
  BezI5(t, [ctlPts[0][0], ctlPts[1][0], ctlPts[2][0], ctlPts[3][0], ctlPts[4][0]]), 
  BezI5(t, [ctlPts[0][1], ctlPts[1][1], ctlPts[2][1], ctlPts[3][1], ctlPts[4][1]]) 
];
function PointAlongBez6(t, ctlPts) = [ 
  BezI6(t, [ctlPts[0][0], ctlPts[1][0], ctlPts[2][0], ctlPts[3][0], ctlPts[4][0], ctlPts[5][0]]), 
  BezI6(t, [ctlPts[0][1], ctlPts[1][1], ctlPts[2][1], ctlPts[3][1], ctlPts[4][1], ctlPts[5][1]]) 
];
function PointAlongBez7(t, ctlPts) = [ 
  BezI7(t, [ctlPts[0][0], ctlPts[1][0], ctlPts[2][0], ctlPts[3][0], ctlPts[4][0], ctlPts[5][0], ctlPts[6][0]]), 
  BezI7(t, [ctlPts[0][1], ctlPts[1][1], ctlPts[2][1], ctlPts[3][1], ctlPts[4][1], ctlPts[5][1], ctlPts[6][1]]) 
];
function PointAlongBez8(t, ctlPts) = [ 
  BezI8(t, [ctlPts[0][0], ctlPts[1][0], ctlPts[2][0], ctlPts[3][0], ctlPts[4][0], ctlPts[5][0], ctlPts[6][0], ctlPts[7][0]]), 
  BezI8(t, [ctlPts[0][1], ctlPts[1][1], ctlPts[2][1], ctlPts[3][1], ctlPts[4][1], ctlPts[5][1], ctlPts[6][1], ctlPts[7][1]]) 
];

function PerpAlongBez(t, ctlPts, dist = 1, hodograph = []) = 
  len(ctlPts) == 2 ? PerpAlongBez2(t, ctlPts, dist, hodograph) : 
  len(ctlPts) == 3 ? PerpAlongBez3(t, ctlPts, dist, hodograph) : 
  len(ctlPts) == 4 ? PerpAlongBez4(t, ctlPts, dist, hodograph) : 
  len(ctlPts) == 5 ? PerpAlongBez5(t, ctlPts, dist, hodograph) : 
  len(ctlPts) == 6 ? PerpAlongBez6(t, ctlPts, dist, hodograph) : 
  len(ctlPts) == 7 ? PerpAlongBez7(t, ctlPts, dist, hodograph) : 
  len(ctlPts) == 8 ? PerpAlongBez8(t, ctlPts, dist, hodograph) :
  [];

function PerpAlongBez2(t, ctlPts, dist = 1, hodograph = []) = 
  pSum( 
    PointAlongBez2(t, ctlPts), 
    rot90cw( 
      normalize( 
        PointAlongBez1( t, (len(hodograph) > 1) ? hodograph : hodograph(ctlPts) ),
        dist 
      ) 
    )
  );

function PerpAlongBez3(t, ctlPts, dist = 1, hodograph = []) = 
  pSum( 
    PointAlongBez3(t, ctlPts), 
    rot90cw( 
      normalize( 
        PointAlongBez2( t, (len(hodograph) > 1) ? hodograph : hodograph(ctlPts) ),
        dist 
      ) 
    )
  );

function PerpAlongBez4(t, ctlPts, dist = 1, hodograph = []) = 
  pSum( 
    PointAlongBez4(t, ctlPts), 
    rot90cw( 
      normalize( 
        PointAlongBez3( t, (len(hodograph) > 1) ? hodograph : hodograph(ctlPts) ),
        dist 
      ) 
    )
  );

function PerpAlongBez5(t, ctlPts, dist = 1, hodograph = []) = 
  pSum( 
    PointAlongBez5(t, ctlPts), 
    rot90cw( 
      normalize( 
        PointAlongBez4( t, (len(hodograph) > 1) ? hodograph : hodograph(ctlPts) ),
        dist 
      ) 
    )
  );

function PerpAlongBez6(t, ctlPts, dist = 1, hodograph = []) = 
  pSum( 
    PointAlongBez6(t, ctlPts), 
    rot90cw( 
      normalize( 
        PointAlongBez5( t, (len(hodograph) > 1) ? hodograph : hodograph(ctlPts) ),
        dist 
      ) 
    )
  );

function PerpAlongBez7(t, ctlPts, dist = 1, hodograph = []) = 
  pSum( 
    PointAlongBez7(t, ctlPts), 
    rot90cw( 
      normalize( 
        PointAlongBez6( t, (len(hodograph) > 1) ? hodograph : hodograph(ctlPts) ),
        dist 
      ) 
    )
  );

function PerpAlongBez8(t, ctlPts, dist = 1, hodograph = []) = 
  pSum( 
    PointAlongBez8(t, ctlPts), 
    rot90cw( 
      normalize( 
        PointAlongBez7( t, (len(hodograph) > 1) ? hodograph : hodograph(ctlPts) ),
        dist 
      ) 
    )
  );


function hodograph(p) = 
  len(p) == 2 ? 
    [ pDiff(p[1], p[0]) ] :  
  len(p) == 3 ? 
    [ pDiff(p[1], p[0]), pDiff(p[2], p[1]) ] :  
  len(p) == 4 ? 
    [ pDiff(p[1], p[0]), pDiff(p[2], p[1]), pDiff(p[3], p[2]) ] :  
  len(p) == 5 ? 
    [ pDiff(p[1], p[0]), pDiff(p[2], p[1]), pDiff(p[3], p[2]), pDiff(p[4], p[3]) ] :  
  len(p) == 6 ? 
    [ pDiff(p[1], p[0]), pDiff(p[2], p[1]), pDiff(p[3], p[2]), pDiff(p[4], p[3]), pDiff(p[5], p[4]) ] :  
  len(p) == 7 ? 
    [ pDiff(p[1], p[0]), pDiff(p[2], p[1]), pDiff(p[3], p[2]), pDiff(p[4], p[3]), pDiff(p[5], p[4]), pDiff(p[6], p[5]) ] :  
  len(p) == 8 ? 
    [ pDiff(p[1], p[0]), pDiff(p[2], p[1]), pDiff(p[3], p[2]), pDiff(p[4], p[3]), pDiff(p[5], p[4]), pDiff(p[6], p[5]), pDiff(p[7], p[6]) ] : 
  [];

function BezI1(t, ctls) =
  (ctls[0])
  ;

function BezI2(t, ctls) =
  ((1-t) * ctls[0]) +
  (t * ctls[1])
  ;

function BezI3(t, ctls) =
  (pow(1-t, 2) * ctls[0]) +
  (2 * t * (1-t) * ctls[1]) +
  (pow(t, 2) * ctls[2])
  ;

function BezI4(t, ctls) =
  (pow(1-t, 3) * ctls[0]) +
  (3 * t * pow(1-t, 2) * ctls[1]) +
  (3 * pow(t, 2) * (1-t) * ctls[2]) +
  (pow(t, 3) * ctls[3])
  ;

function BezI5(t, ctls) =
  (pow(1-t, 4) * ctls[0]) +
  (4 * t * pow(1-t, 3) * ctls[1]) +
  (6 * pow(t, 2) * pow(1-t, 2) * ctls[2]) +
  (4 * pow(t, 3) * (1-t) * ctls[3]) +
  (pow(t, 4) * ctls[4])
  ;

function BezI6(t, ctls) =
  (pow(1-t, 5) * ctls[0]) +
  (5 * t * pow(1-t, 4) * ctls[1]) +
  (10 * pow(t, 2) * pow(1-t, 3) * ctls[2]) +
  (10 * pow(t, 3) * pow(1-t, 2) * ctls[3]) +
  (5 * pow(t, 4) * (1-t) * ctls[4]) +
  (pow(t, 5) * ctls[5])
  ;

function BezI7(t, ctls) =
  (pow(1-t, 6) * ctls[0]) +
  (6 * t * pow(1-t, 5) * ctls[1]) +
  (15 * pow(t, 2) * pow(1-t, 4) * ctls[2]) +
  (20 * pow(t, 3) * pow(1-t, 3) * ctls[3]) +
  (15 * pow(t, 4) * pow(1-t, 2) * ctls[4]) +
  (6 * pow(t, 5) * (1-t) * ctls[5]) +
  (pow(t, 6) * ctls[6])
  ;

function BezI8(t, ctls) =
  (pow(1-t, 7) * ctls[0]) +
  (7 * t * pow(1-t, 6) * ctls[1]) +
  (21 * pow(t, 2) * pow(1-t, 5) * ctls[2]) +
  (35 * pow(t, 3) * pow(1-t, 4) * ctls[3]) +
  (35 * pow(t, 4) * pow(1-t, 3) * ctls[4]) +
  (21 * pow(t, 5) * pow(1-t, 2) * ctls[5]) +
  (7 * pow(t, 6) * (1-t) * ctls[6]) +
  (pow(t, 7) * ctls[7])
  ;

function x(p) = p[0];
function y(p) = p[1];
function dx(p1, p2) = x(p1) - x(p2);
function dy(p1, p2) = y(p1) - y(p2);
function sx(p1, p2) = x(p1) + x(p2);
function sy(p1, p2) = y(p1) + y(p2);

function dist(p1, p2 = [0,0]) = sqrt( pow( dx(p1,p2), 2) + pow( dy(p1,p2), 2) );
function normalize(p, n = 1) = pScale( p, n / dist( p ) );

function pSum(p1, p2) = [sx(p1, p2), sy(p1, p2)];
function pDiff(p1, p2) = [dx(p1, p2), dy(p1, p2)];
function pScale(p, v) = [x(p)*v, y(p)*v];

function rot90cw(p) = [y(p), -x(p)];
function rot90ccw(p) = [-y(p), x(p)];
function rot(p, a) = [
  x(p) * cos(a) - y(p) * sin(a),
  x(p) * sin(a) - y(p) * cos(a),
];
function rotAbout(p1, p2, a) = pSum(rot(pDiff(p1, p2), a), p2); // rotate p1 about p2