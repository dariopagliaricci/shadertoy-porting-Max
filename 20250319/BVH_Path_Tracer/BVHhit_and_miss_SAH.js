autowhatch = 1;
inlets = 1;
outlets = 2;

BVH = [];
nodesUsed = 1;
centroid = [];
triIdx = [];

//utilities
var x = 0; var y = 1; var z = 2;

var aabbMin = 0; 
var aabbMax = 1; 
var leftNode = 2; 
var firstTriIdx = 3; 
var triCount = 4;
var parent = 5;
var hit = 6;
var miss = 7;
var left_right = 8;

var left = 0;
var right = 1;

var last_split = 0;

function prepareTriStruct(mIn)
{
	var numTri 	= mIn.dim / 3;
	centroid 	= new Array(numTri);
	triIdx 		= new Array(numTri);

	for(var i = 0; i < numTri; i++){
		centroid[i] = new Array(3);
		var v0 = i*3;
		var v1 = v0+1;
		var v2 = v0+2;
		centroid[i][x] = (mIn.getcell(v0)[x] + mIn.getcell(v1)[x] + mIn.getcell(v2)[x]) * 0.3333333333333;
		centroid[i][y] = (mIn.getcell(v0)[y] + mIn.getcell(v1)[y] + mIn.getcell(v2)[y]) * 0.3333333333333;
		centroid[i][z] = (mIn.getcell(v0)[z] + mIn.getcell(v1)[z] + mIn.getcell(v2)[z]) * 0.3333333333333;
		triIdx[i] = i;
	}
}

function prepareBVHStruct()
{
	BVH = new Array(triIdx.length*2 - 1); //initialize an empty AABB structure
	for(k = 0; k < BVH.length; k++){
		BVH[k] = new Array(9);
		BVH[k][0] = new Array(3);
		BVH[k][1] = new Array(3);
	}
}

function getMin(a, b){	return a < b ? a : b; }
function getMax(a, b){	return a > b ? a : b; }

function UpdateNodeBounds(nodeIdx)
{
	BVH[nodeIdx][aabbMin] = [ 10000000000,  10000000000,  10000000000];
	BVH[nodeIdx][aabbMax] = [-10000000000, -10000000000, -10000000000];
	var first = BVH[nodeIdx][firstTriIdx];
	for(var i = 0; i < BVH[nodeIdx][triCount]; i++)
	{
		var id0 = triIdx[first + i];
		id0 *= 3;
		var id1 = id0 + 1;
		var id2 = id0 + 2;
		BVH[nodeIdx][aabbMin][x] = getMin(BVH[nodeIdx][aabbMin][x], mIn.getcell(id0)[x]);
		BVH[nodeIdx][aabbMin][y] = getMin(BVH[nodeIdx][aabbMin][y], mIn.getcell(id0)[y]);
		BVH[nodeIdx][aabbMin][z] = getMin(BVH[nodeIdx][aabbMin][z], mIn.getcell(id0)[z]);
		BVH[nodeIdx][aabbMin][x] = getMin(BVH[nodeIdx][aabbMin][x], mIn.getcell(id1)[x]);
		BVH[nodeIdx][aabbMin][y] = getMin(BVH[nodeIdx][aabbMin][y], mIn.getcell(id1)[y]);
		BVH[nodeIdx][aabbMin][z] = getMin(BVH[nodeIdx][aabbMin][z], mIn.getcell(id1)[z]);
		BVH[nodeIdx][aabbMin][x] = getMin(BVH[nodeIdx][aabbMin][x], mIn.getcell(id2)[x]);
		BVH[nodeIdx][aabbMin][y] = getMin(BVH[nodeIdx][aabbMin][y], mIn.getcell(id2)[y]);
		BVH[nodeIdx][aabbMin][z] = getMin(BVH[nodeIdx][aabbMin][z], mIn.getcell(id2)[z]);

		BVH[nodeIdx][aabbMax][x] = getMax(BVH[nodeIdx][aabbMax][x], mIn.getcell(id0)[x]);
		BVH[nodeIdx][aabbMax][y] = getMax(BVH[nodeIdx][aabbMax][y], mIn.getcell(id0)[y]);
		BVH[nodeIdx][aabbMax][z] = getMax(BVH[nodeIdx][aabbMax][z], mIn.getcell(id0)[z]);
		BVH[nodeIdx][aabbMax][x] = getMax(BVH[nodeIdx][aabbMax][x], mIn.getcell(id1)[x]);
		BVH[nodeIdx][aabbMax][y] = getMax(BVH[nodeIdx][aabbMax][y], mIn.getcell(id1)[y]);
		BVH[nodeIdx][aabbMax][z] = getMax(BVH[nodeIdx][aabbMax][z], mIn.getcell(id1)[z]);
		BVH[nodeIdx][aabbMax][x] = getMax(BVH[nodeIdx][aabbMax][x], mIn.getcell(id2)[x]);
		BVH[nodeIdx][aabbMax][y] = getMax(BVH[nodeIdx][aabbMax][y], mIn.getcell(id2)[y]);
		BVH[nodeIdx][aabbMax][z] = getMax(BVH[nodeIdx][aabbMax][z], mIn.getcell(id2)[z]);
	}
}

function swap(i, j)
{
	var temp = triIdx[i];
	triIdx[i] = triIdx[j];
	triIdx[j] = temp;
}

function EvaluateSAH( nodeIdx, axis, candidatePos )
{
    // determine triangle counts and bounds for this split candidate
    var leftBox = new Array(2);
    var rightBox = new Array(2);

    var bmin = 0; var bmax = 1;

    leftBox[bmin] = new Array(3); leftBox[bmax] = new Array(3);
    rightBox[bmin] = new Array(3); rightBox[bmax] = new Array(3);

    leftBox[bmin] 	= [100000000, 100000000, 100000000];
    rightBox[bmin] 	= [100000000, 100000000, 100000000];
    leftBox[bmax] 	= [-100000000, -100000000, -100000000];
    rightBox[bmax] 	= [-100000000, -100000000, -100000000];;

    var leftCount = 0; var rightCount = 0;
    var first = BVH[nodeIdx][firstTriIdx];
    for( var i = 0; i < BVH[nodeIdx][triCount]; i++ )
    {
    	var triangle = triIdx[first + i];
        if (centroid[triangle][axis] < candidatePos)
        {
            leftCount++;
            leftBox[bmin][x] = getMin(leftBox[bmin][x], centroid[triangle][x]);
            leftBox[bmin][y] = getMin(leftBox[bmin][y], centroid[triangle][y]);
            leftBox[bmin][z] = getMin(leftBox[bmin][z], centroid[triangle][z]);
            leftBox[bmax][x] = getMax(leftBox[bmax][x], centroid[triangle][x]);
			leftBox[bmax][y] = getMax(leftBox[bmax][y], centroid[triangle][y]);
			leftBox[bmax][z] = getMax(leftBox[bmax][z], centroid[triangle][z]);
        }
        else
        {
            rightCount++;
            rightBox[bmin][x] = getMin(rightBox[bmin][x], centroid[triangle][x]);
            rightBox[bmin][y] = getMin(rightBox[bmin][y], centroid[triangle][y]);
            rightBox[bmin][z] = getMin(rightBox[bmin][z], centroid[triangle][z]);
            rightBox[bmax][x] = getMax(rightBox[bmax][x], centroid[triangle][x]);
			rightBox[bmax][y] = getMax(rightBox[bmax][y], centroid[triangle][y]);
			rightBox[bmax][z] = getMax(rightBox[bmax][z], centroid[triangle][z]);
        }
    }

    //compute left area
    var lefte = [	leftBox[bmax][x] - leftBox[bmin][x],
    			 	leftBox[bmax][y] - leftBox[bmin][y],
    			 	leftBox[bmax][z] - leftBox[bmin][z]
    			];	//left box extent

    var righte = [	rightBox[bmax][x] - rightBox[bmin][x],
    			 	rightBox[bmax][y] - rightBox[bmin][y],
    			 	rightBox[bmax][z] - rightBox[bmin][z]
    			];	//right box extent

    var lefta 	= lefte[x]*lefte[y] 	+ lefte[y]*lefte[z] 	+ lefte[z]*lefte[x]; //left box area
    var righta	= righte[x]*righte[y] 	+ righte[y]*righte[z] 	+ righte[z]*righte[x]; //left box area

    var cost = leftCount * lefta + rightCount * righta;
    return cost > 0 ? cost : 100000000000;
}


function FindBestSplitPlane(nodeIdx, subdivision)
{
	var bestAxis = -1;
	var bestPos = 0;
	var bestCost = 1000000000;
    for (var a = x; a <= z; a++){
        var boundsMin = BVH[nodeIdx][aabbMin][a];
        var boundsMax = BVH[nodeIdx][aabbMax][a];
        if (boundsMin == boundsMax) continue;
        var scale = (boundsMax - boundsMin) / subdivision;
        for (var i = 1; i < subdivision; i++){
            var candidatePos = boundsMin + i * scale;
            var cost = EvaluateSAH( nodeIdx, a, candidatePos );
            if (cost < bestCost){
                bestPos = candidatePos;
                bestAxis = a; 
                bestCost = cost;
            }
        }
  
    }
    return [bestAxis, bestPos, bestCost];
}

function CalculateNodeCost(nodeIdx)
{
	var extent = new Array(3);
	extent[x] = BVH[nodeIdx][aabbMax][x] - BVH[nodeIdx][aabbMin][x];
	extent[y] = BVH[nodeIdx][aabbMax][y] - BVH[nodeIdx][aabbMin][y];
	extent[z] = BVH[nodeIdx][aabbMax][z] - BVH[nodeIdx][aabbMin][z];
	var parentarea = extent[x]*extent[y] + extent[y]*extent[z] + extent[z]*extent[x];
	return BVH[nodeIdx][triCount]*parentarea;
}

function Subdivide(nodeIdx)
{
	//**************************************************************//
	// HIT AND MISS LINKS: 											//
	// - Hit Links													//
	//		Always the next node in the array						//
	// - Miss Links 												//
	//		Internal, left: sibling node 							//
	//		internal, right: parent's sibling node(until it exists) //
	//		Leaf: same as hit links									//
	//**************************************************************//

	if(BVH[nodeIdx][triCount] <= 2){ //it's a leaf
		//and if's a left node
		if(BVH[nodeIdx][left_right] == left){
			BVH[nodeIdx][miss] = nodeIdx + 1;	
			BVH[nodeIdx][hit] = BVH[nodeIdx][miss];
			return;		
		} 

		//but if it's a right node, climb up the tree
 		else {
 			var thisNode = BVH[nodeIdx][parent];
 			while(BVH[thisNode][left_right] == right){
 				if(thisNode == 0){
 					BVH[nodeIdx][miss] = -1; //terminate
 					post(nodeIdx, "which is", BVH[nodeIdx][left_right], "terminated from leaf", "\n");
 					break;
 				}
 				thisNode = BVH[thisNode][parent];
 			}
			if(BVH[nodeIdx][miss] != -1) BVH[nodeIdx][miss] = thisNode + 1;
			BVH[nodeIdx][hit] = BVH[nodeIdx][miss];
			return;
		}
	} 

	var isLeaf = false;

	//var axis; var splitPos; 
	var subdivision = 30;
	var bestSplit = FindBestSplitPlane(nodeIdx, subdivision);
	var axis = bestSplit[0];
	var splitPos = bestSplit[1];
	var splitCost = bestSplit[2];

    var nosplitCost = CalculateNodeCost(nodeIdx);

	if(splitCost >= nosplitCost){ //return if the cost is worse
		//and if's a left node
		if(BVH[nodeIdx][left_right] == left){
			BVH[nodeIdx][miss] = nodeIdx + 1;	
			BVH[nodeIdx][hit] = BVH[nodeIdx][miss];
			return;		
		} 

		//but if it's a right node, climb up the tree
 		else {
 			var thisNode = BVH[nodeIdx][parent];
 			while(BVH[thisNode][left_right] == right){
 				if(thisNode == 0){
 					BVH[nodeIdx][miss] = -1; //terminate
 					post(nodeIdx, "which is", BVH[nodeIdx][left_right], "terminated from leaf", "\n");
 					break;
 				}
 				thisNode = BVH[thisNode][parent];
 			}
			if(BVH[nodeIdx][miss] != -1) BVH[nodeIdx][miss] = thisNode + 1;
			BVH[nodeIdx][hit] = BVH[nodeIdx][miss];
			return;
		}		
	}

	//in-place partition
	var i = BVH[nodeIdx][firstTriIdx];
	var j = i + BVH[nodeIdx][triCount] - 1;
	while(i <= j)
	{
		if(centroid[triIdx[i]][axis] < splitPos) i++
		else swap(i, j--);
	}

	// abort split if one of the sides is empty
	var leftCount = i - BVH[nodeIdx][firstTriIdx];
	if(leftCount == 0 || leftCount == BVH[nodeIdx][triCount]) isLeaf = true;

	//if this node is a leaf...
	if(isLeaf){
		//and if's a left node
		if(BVH[nodeIdx][left_right] == left){
			BVH[nodeIdx][miss] = nodeIdx + 1;	
			BVH[nodeIdx][hit] = BVH[nodeIdx][miss];
			return;		
		} 

		//but if it's a right node, climb up the tree
 		else {
 			var thisNode = BVH[nodeIdx][parent];
 			while(BVH[thisNode][left_right] == right){
 				if(thisNode == 0){
 					BVH[nodeIdx][miss] = -1; //terminate
 					post(nodeIdx, "which is", BVH[nodeIdx][left_right], "terminated from leaf", "\n");
 					break;
 				}
 				thisNode = BVH[thisNode][parent];
 			}
			if(BVH[nodeIdx][miss] != -1) BVH[nodeIdx][miss] = thisNode + 1;
			BVH[nodeIdx][hit] = BVH[nodeIdx][miss];
			return;
		}
	}

	//if it's not a leaf, continue and create two children
	var leftChildIdx = nodesUsed++;
	var rightChildIdx = nodesUsed++;

	BVH[leftChildIdx][firstTriIdx] = BVH[nodeIdx][firstTriIdx];
	BVH[leftChildIdx][triCount] = leftCount;
	BVH[leftChildIdx][parent] = nodeIdx;
	BVH[leftChildIdx][left_right] = left;
	BVH[rightChildIdx][firstTriIdx] = i;
	BVH[rightChildIdx][triCount] = BVH[nodeIdx][triCount] - leftCount;
	BVH[rightChildIdx][parent] = nodeIdx;
	BVH[rightChildIdx][left_right] = right;
	BVH[nodeIdx][leftNode] = leftChildIdx;
	BVH[nodeIdx][triCount] = 0;

	//internal node
	BVH[nodeIdx][hit] = leftChildIdx;

	//if this is a left child
	if(BVH[nodeIdx][left_right] == left) BVH[nodeIdx][miss] = nodeIdx + 1;

	//if this is a right child
	else {
		//and it's not the root
		if(nodeIdx == 0) BVH[nodeIdx][miss] = -1;
		else {
			var thisNode = BVH[nodeIdx][parent];
		 	while(BVH[thisNode][left_right] == right){
		 		if(thisNode == 0){
		 			BVH[nodeIdx][miss] = -1;
		 			post("terminated from node", "\n");
		 			break;
		 		}
		 		thisNode = BVH[thisNode][parent];
		 	}	
		 	if(BVH[nodeIdx][miss] != -1) BVH[nodeIdx][miss] = thisNode + 1;				
		}
	}

	UpdateNodeBounds(leftChildIdx);
	UpdateNodeBounds(rightChildIdx);
	Subdivide(leftChildIdx);	
	Subdivide(rightChildIdx);	
}

function jit_matrix(inName)
{
	mIn = JitterMatrix(inName);

	prepareTriStruct(mIn);
	prepareBVHStruct();

	var rootNodeIdx = 0;
	nodesUsed = 1;

	BVH[rootNodeIdx][firstTriIdx] = 0;
	BVH[rootNodeIdx][triCount] = triIdx.length;
	BVH[rootNodeIdx][parent] = 0;
	BVH[rootNodeIdx][left_right] = right;
	//BVH[rootNodeIdx][hit] = 1;
	//BVH[rootNodeIdx][miss] = -1;
	//BVH[rootNodeIdx][depth] = 0;

	UpdateNodeBounds(rootNodeIdx);
	Subdivide(rootNodeIdx, left);

	post("-------BVH-READY-------", "\n");
	post("nodes used: ", nodesUsed, "\n");
	post("BVH length: ", BVH.length, "\n");
	post("tri list length: ", triIdx.length, "\n");

	var testCount = 0;
	var mOut = new JitterMatrix(3, "float32", nodesUsed*24);
	for(var i = 0; i < nodesUsed; i++){
		var v = i*24;
		var min = BVH[i][aabbMin];
		var max = BVH[i][aabbMax];
		mOut.setcell(v+0 , "val", min); mOut.setcell(v+1 , "val", min[x], min[y], max[z]);
		mOut.setcell(v+2 , "val", min); mOut.setcell(v+3 , "val", min[x], max[y], min[z]);
		mOut.setcell(v+4 , "val", min); mOut.setcell(v+5 , "val", max[x], min[y], min[z]);
		mOut.setcell(v+6 , "val", max); mOut.setcell(v+7 , "val", max[x], max[y], min[z]);
		mOut.setcell(v+8 , "val", max); mOut.setcell(v+9 , "val", max[x], min[y], max[z]);
		mOut.setcell(v+10, "val", max); mOut.setcell(v+11, "val", min[x], max[y], max[z]);
		mOut.setcell(v+12, "val", min[x], max[y], max[z]); mOut.setcell(v+13, "val", min[x], min[y], max[z]);
		mOut.setcell(v+14, "val", min[x], max[y], max[z]); mOut.setcell(v+15, "val", min[x], max[y], min[z]);
		mOut.setcell(v+16, "val", max[x], min[y], min[z]); mOut.setcell(v+17, "val", max[x], min[y], max[z]);
		mOut.setcell(v+18, "val", max[x], min[y], min[z]); mOut.setcell(v+19, "val", max[x], max[y], min[z]);
		mOut.setcell(v+20, "val", max[x], max[y], min[z]); mOut.setcell(v+21, "val", min[x], max[y], min[z]);
		mOut.setcell(v+22, "val", max[x], min[y], max[z]); mOut.setcell(v+23, "val", min[x], min[y], max[z]);
		testCount = getMax(testCount, BVH[i][triCount]);
		//post("max tri count: ",testCount, "\n");
	}
	outlet(0, "jit_matrix", mOut.name);
	post("max tri count: ", testCount, "\n");

	//prova del nove
	var current = 0;
	var counter = 0;
	var numTriFound = 0;
	for(var t = 0; t < triIdx.length*3; t++){
		numTriFound += BVH[current][triCount];
		current = BVH[current][hit];
		counter++;
		if(current == -1){
			post("uscita!!!", "\n");
			break;	
		} 
	}
	post("nodes vidited: ",counter, "\n");
	post("numbers of triangles found: ",counter, "\n");

}

function level(sel)//to test the integrity of the funcion
{
	var mOut = new JitterMatrix(3, "float32", 24);

	var v = 0;//i*24;
	var min = BVH[sel][aabbMin];
	var max = BVH[sel][aabbMax];
	mOut.setcell(v+0 , "val", min); mOut.setcell(v+1 , "val", min[x], min[y], max[z]);
	mOut.setcell(v+2 , "val", min); mOut.setcell(v+3 , "val", min[x], max[y], min[z]);
	mOut.setcell(v+4 , "val", min); mOut.setcell(v+5 , "val", max[x], min[y], min[z]);
	mOut.setcell(v+6 , "val", max); mOut.setcell(v+7 , "val", max[x], max[y], min[z]);
	mOut.setcell(v+8 , "val", max); mOut.setcell(v+9 , "val", max[x], min[y], max[z]);
	mOut.setcell(v+10, "val", max); mOut.setcell(v+11, "val", min[x], max[y], max[z]);
	mOut.setcell(v+12, "val", min[x], max[y], max[z]); mOut.setcell(v+13, "val", min[x], min[y], max[z]);
	mOut.setcell(v+14, "val", min[x], max[y], max[z]); mOut.setcell(v+15, "val", min[x], max[y], min[z]);
	mOut.setcell(v+16, "val", max[x], min[y], min[z]); mOut.setcell(v+17, "val", max[x], min[y], max[z]);
	mOut.setcell(v+18, "val", max[x], min[y], min[z]); mOut.setcell(v+19, "val", max[x], max[y], min[z]);
	mOut.setcell(v+20, "val", max[x], max[y], min[z]); mOut.setcell(v+21, "val", min[x], max[y], min[z]);
	mOut.setcell(v+22, "val", max[x], min[y], max[z]); mOut.setcell(v+23, "val", min[x], min[y], max[z]);

	outlet(0, "jit_matrix", mOut.name);

	if(BVH[sel][triCount] > 0){
		post("-----------LEAF-----------", "\n");
		post("triCount", BVH[sel][triCount], "\n");
		post("hit", BVH[sel][hit], "\n");
		post("miss", BVH[sel][miss], "\n");	
		//post("depth", BVH[sel][depth], "\n");
		var mTest = new JitterMatrix(3, "float32", BVH[sel][triCount]*3);
		for(v = 0; v < BVH[sel][triCount]; v++){
			var index = BVH[sel][firstTriIdx] + v;
			var k0 = triIdx[index]*3;
			var k1 = k0 + 1;
			var k2 = k0 + 2;
			mTest.setcell(v*3 + 0, "val", mIn.getcell(k0).slice(0, 3));
			mTest.setcell(v*3 + 1, "val", mIn.getcell(k1).slice(0, 3));
			mTest.setcell(v*3 + 2, "val", mIn.getcell(k2).slice(0, 3));
			post("P0: ", mIn.getcell(k0).slice(0, 3), "\n");
			post("P1: ", mIn.getcell(k1).slice(0, 3), "\n");
			post("P2: ", mIn.getcell(k2).slice(0, 3), "\n");
		}	
		outlet(1, "jit_matrix", mTest.name);
	} else {
		post("--------INNER-BOX---------", "\n");
		post("bb index", sel, "\n");
		//post("parent", BVH[sel][parent], "\n");
		//post("splitDim", BVH[sel][splitDim], "\n");
		//post("sibling", BVH[sel][sibling], "\n");
		post("leftChild", BVH[sel][leftNode], "\n");
		post("rightChild", BVH[sel][leftNode] + 1, "\n");
		post("hit", BVH[sel][hit], "\n");
		post("miss", BVH[sel][miss], "\n");	
		//post("depth", BVH[sel][depth], "\n");
		var mTest = new JitterMatrix(3, "float32", 1);
		mTest.setall(0.);
		outlet(1, "jit_matrix", mTest.name);
	}
}