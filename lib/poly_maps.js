// http://econym.googlepages.com/inside.htm
// === A method for testing if a point is inside a polygon
// === Returns true if poly contains point
// === Algorithm shamelessly stolen from http://alienryderflex.com/polygon/
GPolygon.prototype.Contains = function(point) {
  var j=0;
  var oddNodes = false;
  var x = point.lng();
  var y = point.lat();
  for (var i=0; i < this.getVertexCount(); i++) {
    j++;
    if (j == this.getVertexCount()) {j = 0;}
    if (((this.getVertex(i).lat() < y) && (this.getVertex(j).lat() >= y))
    || ((this.getVertex(j).lat() < y) && (this.getVertex(i).lat() >= y))) {
      if ( this.getVertex(i).lng() + (y - this.getVertex(i).lat())
      /  (this.getVertex(j).lat()-this.getVertex(i).lat())
      *  (this.getVertex(j).lng() - this.getVertex(i).lng())<x ) {
        oddNodes = !oddNodes
      }
    }
  }
  return oddNodes;
}
// === A method which returns the length of a path in metres ===
GPolygon.prototype.Distance = function() {
  var dist = 0;
  for (var i=1; i < this.getVertexCount(); i++) {
    dist += this.getVertex(i).distanceFrom(this.getVertex(i-1));
  }
  return dist;
}
GPolygon.Shape = function(point,r1,r2,r3,r4,rotation,vertexCount,  strokeColour,strokeWeight,Strokepacity,fillColour,fillOpacity,opts,tilt) {
  var rot = -rotation*Math.PI/180;
  var points = [];
  var latConv = point.distanceFrom(new GLatLng(point.lat()+0.1,point.lng()))*10;
  var lngConv = point.distanceFrom(new GLatLng(point.lat(),point.lng()+0.1))*10;
  var step = (360/vertexCount)||10;
  
  var flop = -1;
  if (tilt) {
    var I1=180/vertexCount;
  } else {
    var  I1=0;
  }
  for(var i=I1; i<=360.001+I1; i+=step) {
    var r1a = flop?r1:r3;
    var r2a = flop?r2:r4;
    flop = -1-flop;
    var y = r1a * Math.cos(i * Math.PI/180);
    var x = r2a * Math.sin(i * Math.PI/180);
    var lng = (x*Math.cos(rot)-y*Math.sin(rot))/lngConv;
    var lat = (y*Math.cos(rot)+x*Math.sin(rot))/latConv;

    points.push(new GLatLng(point.lat()+lat,point.lng()+lng));
  }
  return (new GPolygon(points,strokeColour,strokeWeight,Strokepacity,fillColour,fillOpacity,opts))
}

GPolygon.Circle = function(point,radius,strokeColour,strokeWeight,Strokepacity,fillColour,fillOpacity,opts) {
  return GPolygon.Shape(point,radius,radius,radius,radius,0,100,strokeColour,strokeWeight,Strokepacity,fillColour,fillOpacity,opts)
}
GPolygon.Ellipse = function(point,r1,r2,rotation,strokeColour,strokeWeight,Strokepacity,fillColour,fillOpacity,opts) {
  rotation = rotation||0;
  return GPolygon.Shape(point,r1,r2,r1,r2,rotation,100,strokeColour,strokeWeight,Strokepacity,fillColour,fillOpacity,opts)
}



// Copyright 2001, softSurfer (www.softsurfer.com)
// This code may be freely used and modified for any purpose
// providing that this copyright notice is included with it.
// SoftSurfer makes no warranty for this code, and cannot be held
// liable for any real or imagined damage resulting from its use.
// Users of this code must verify correctness for their application.
// http://geometryalgorithms.com/Archive/algorithm_0109/algorithm_0109.htm

// Assume that a class is already given for the object:
//    Point with coordinates {float x, y;}
//===================================================================


// isLeft(): tests if a point is Left|On|Right of an infinite line.
//    Input:  three points P0, P1, and P2
//    Return: >0 for P2 left of the line through P0 and P1
//            =0 for P2 on the line
//            <0 for P2 right of the line
//    See: the January 2001 Algorithm on Area of Triangles
function isLeft( P0, P1, P2 )
{
    return (P1.x - P0.x)*(P2.y - P0.y) - (P2.x - P0.x)*(P1.y - P0.y);
}
//===================================================================
 

// chainHull_2D(): Andrew's monotone chain 2D convex hull algorithm
//     Input:  P[] = an array of 2D points 
//                   presorted by increasing x- and y-coordinates
//             n = the number of points in P[]
//     Output: H[] = an array of the convex hull vertices (max is n)
//     Return: the number of points in H[]
function chainHull_2D( P, n, H )
{
    // the output array H[] will be used as the stack
    var    bot=0, top=(-1);  // indices for bottom and top of the stack
    var    i;                // array scan index

    // Get the indices of points with min x-coord and min|max y-coord
    var minmin = 0, minmax;
    var xmin = P[0].x;
    for (i=1; i<n; i++)
        if (P[i].x != xmin) break;
    minmax = i-1;
    if (minmax == n-1) {       // degenerate case: all x-coords == xmin
        H[++top] = P[minmin];
        if (P[minmax].y != P[minmin].y) // a nontrivial segment
            H[++top] = P[minmax];
        H[++top] = P[minmin];           // add polygon endpoint
        return top+1;
    }

    // Get the indices of points with max x-coord and min|max y-coord
    var maxmin, maxmax = n-1;
    var xmax = P[n-1].x;
    for (i=n-2; i>=0; i--)
        if (P[i].x != xmax) break;
    maxmin = i+1;

    // Compute the lower hull on the stack H
    H[++top] = P[minmin];      // push minmin point onto stack
    i = minmax;

    while (++i <= maxmin)
    {
        // the lower line joins P[minmin] with P[maxmin]
        if (isLeft( P[minmin], P[maxmin], P[i]) >= 0 && i < maxmin)
            continue;          // ignore P[i] above or on the lower line

        while (top > 0)        // there are at least 2 points on the stack
        {
            // test if P[i] is left of the line at the stack top
            if (isLeft( H[top-1], H[top], P[i]) > 0)
                break;         // P[i] is a new hull vertex
            else
                top--;         // pop top point off stack
        }
        H[++top] = P[i];       // push P[i] onto stack
    }
    // Next, compute the upper hull on the stack H above the bottom hull
    if (maxmax != maxmin)      // if distinct xmax points
        H[++top] = P[maxmax];  // push maxmax point onto stack
    bot = top;                 // the bottom point of the upper hull stack
    i = maxmin;
    while (--i >= minmax)
    {
        // the upper line joins P[maxmax] with P[minmax]
        if (isLeft( P[maxmax], P[minmax], P[i]) >= 0 && i > minmax)
            continue;          // ignore P[i] below or on the upper line

        while (top > bot)    // at least 2 points on the upper stack
        {
            // test if P[i] is left of the line at the stack top
            if (isLeft( H[top-1], H[top], P[i]) > 0)
                break;         // P[i] is a new hull vertex
            else
                top--;         // pop top point off stack
        }
        H[++top] = P[i];       // push P[i] onto stack
    }

    if (minmax != minmin)
        H[++top] = P[minmin];  // push joining endpoint onto stack
    return top+1;
}

function sortPointX(a,b) { return a.x - b.x; }
function sortPointY(a,b) { return a.y - b.y; }

function DrawHull(map, points, color) {
  var hullPoints = []
  chainHull_2D( points, points.length, hullPoints );
  var polyline = new GPolygon(hullPoints, color, 2, 0.5, color);
	return polyline;
}

function calculateConvexHull(map, points, color) {
  points.sort(sortPointY);
  points.sort(sortPointX);
  return DrawHull(map, points, color);
}

var mouseover_cursor = function() { this.style.cursor='pointer'; }
