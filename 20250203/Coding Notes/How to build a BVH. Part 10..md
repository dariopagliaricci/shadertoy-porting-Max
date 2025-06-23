
In this third article we discuss how to reduce the time it takes to build a good BVH. This will be an important ingredient for the ultimate goal: building a BVH for a large scale dynamic environment, which is the topic of a later article.

## Preparations

In the [previous article](https://jacco.ompf2.com/2022/04/18/how-to-build-a-bvh-part-2-faster-rays/) the Surface Area Heuristic was introduced to improve the quality of the BVH. Here, a ‘high quality tree’ is one that can be used to quickly find the intersection between a ray and the scene. The SAH works wonders, and when combined with ordered traversal, the naïve BVH from the [first article](https://jacco.ompf2.com/2022/04/13/how-to-build-a-bvh-part-1-basics/) is outperformed by a factor 3.

There is a catch however. Where the basic BVH builder needed mere milliseconds to build the tree, the SAH builder needs multiple seconds – and we’re not exactly using a very complex mesh. The reason is simple: For _N_ polygons, we evaluate _N_split plane candidates on each axis – but split plane evaluation involves visiting all primitives. The algorithmic complexity is thus _O(N²)_ for one split; not great if we hoped to build BVHs for much larger scenes, and also not something we can solve with low-level optimizations or parallel code.

For the new concepts introduced in this article we will need to clean up the `Subdivide` function somewhat. Let’s start with splitting of the code that finds the optimal split plane position and axis to a function:

|   |   |
|---|---|
|1<br><br>2<br><br>3<br><br>4<br><br>5<br><br>6<br><br>7<br><br>8<br><br>9<br><br>10<br><br>11<br><br>12|float FindBestSplitPlane( BVHNode& node, int& axis, float& splitPos )<br><br>{<br><br>    float bestCost = 1e30f;<br><br>    for (int a = 0; a < 3; a++) for (uint i = 0; i < node.triCount; i++)<br><br>    {<br><br>        Tri& triangle = tri[triIdx[node.leftFirst + i]];<br><br>        float candidatePos = triangle.centroid[a];<br><br>        float cost = EvaluateSAH( node, a, candidatePos );<br><br>        if (cost < bestCost) splitPos = candidatePos, axis = a, bestCost = cost;<br><br>    }<br><br>    return bestCost;<br><br>}|

This simplifies the relevant section in `Subdivide` to

|   |   |
|---|---|
|1<br><br>2<br><br>3<br><br>4|// determine split axis using SAH<br><br>    int axis;<br><br>    float splitPos;<br><br>    float splitCost = FindBestSplitPlane( node, axis, splitPos );|

Next, `Subdivide` checks if the best split cost is actually an improvement over not splitting. We can make that a bit more clear using a function that calculates the cost of an unsplit node:

|   |   |
|---|---|
|1<br><br>2<br><br>3<br><br>4<br><br>5<br><br>6|float CalculateNodeCost( BVHNode& node )<br><br>{<br><br>    float3 e = node.aabbMax - node.aabbMin; // extent of the node<br><br>    float surfaceArea = e.x * e.y + e.y * e.z + e.z * e.x;<br><br>    return node.triCount * surfaceArea;<br><br>}|

Back in `Subdivide`, we call `CalculateNodeCost` after finding the best split plane, and terminate if it isn’t worth it:

|   |   |
|---|---|
|1<br><br>2|float nosplitCost = CalculateNodeCost( node );<br><br>    if (splitCost >= nosplitCost) return;|

Now that everything is nice and tidy we can focus on the isolated logic in `FindBestSplitPlane`.

## From _O(N²)_ to _O(N)_

A straightforward way to reduce the time complexity to O(N) is to use the midpoint algorithm. However, we have very good reasons for not using that: the resulting tree is a rather poor one. But what would happen if we did not just consider _one_position, but several, or many? Intuitively, there shouldn’t be too much of a difference between these two situations: 

![](https://jacco.ompf2.com/wp-content/uploads/2022/04/towardsbins-1024x530.jpg)

Left: split plane candidates through the primitive centroids. Right: uniformly spaced split plane candidates.

In fact, if we use a high enough number of uniformly spaced planes, the solution should converge to the same answer as the full SAH sweep. And, once this works, we can start experimenting: At which number of planes do we still get a reasonable tree?

The initial code for this is simple enough:

|   |   |
|---|---|
|1<br><br>2<br><br>3<br><br>4<br><br>5<br><br>6<br><br>7<br><br>8<br><br>9<br><br>10<br><br>11<br><br>12<br><br>13<br><br>14<br><br>15<br><br>16<br><br>17<br><br>18<br><br>19|float FindBestSplitPlane( BVHNode& node, int& axis, float& splitPos )<br><br>{<br><br>    float bestCost = 1e30f;<br><br>    for (int a = 0; a < 3; a++)<br><br>    {<br><br>        float boundsMin = node.aabbMin[a];<br><br>        float boundsMax = node.aabbMax[a];<br><br>        if (boundsMin == boundsMax) continue;<br><br>        float scale = (boundsMax - boundsMin) / 100;<br><br>        for (uint i = 1; i < 100; i++)<br><br>        {<br><br>            float candidatePos = boundsMin + i * scale;<br><br>            float cost = EvaluateSAH( node, a, candidatePos );<br><br>            if (cost < bestCost)<br><br>                splitPos = candidatePos, axis = a, bestCost = cost;<br><br>        }<br><br>    }<br><br>    return bestCost;<br><br>}|

Here, 100 is hardcoded as the number of intervals; these are separated by 99 planes, which will be the split plane candidates. The planes are a fixed distance apart: to prevent a repeated division by 100, this distance is calculated once as _(boundsMax – boundsMin) / 100_.

Running the code gets us our first results. Building the BVH is now considerably faster, because 100 is far smaller than _N_: on my machine it now takes about 350ms. The other result is that the BVH is not bad at all: where the full sweep results in a frame time of 106ms, the 100 planes yield a tree that renders in 109ms; a rather modest reduction in performance considering the much faster build.

It turns out that a smaller number of planes still gets us a pretty decent tree. At only 16 planes, rendering takes 110ms – but the build completes in a mere 60ms. And at just 8 planes, rendering takes 111ms, while the tree now builds in 30ms. Even 4 planes seem reasonable: 113ms for rendering, 15ms for building the tree. Note that this is still far better than the midpoint split.

We can now balance tree quality and build speed. This is very useful, especially once we start rendering animated scenes: a model that occupies just a few pixels and changes every frame justifies a quick and dirty tree, but full-screen static scenery should use a tree that is high quality – no matter the cost. We can control this now, especially when we realize that we left one trick unused: limiting the SAH sweep to the longest axis, like we did with the midpoint split. This comes at a minor degradation of tree quality, but it cuts build time down to 5ms for our scene. 

In short, we have options.

## Tweaking

In the initial code for the uniformly spaced planes I assumed that we should subdivide the full extent of the AABB of a node. This is strictly not necessary. In the SAH sweep, the first split plane candidate is on the first centroid; the last one on the last centroid. A better range of values to cut up is thus the AABB over the centroids of the primitives. It turns out that this matters.

![](https://jacco.ompf2.com/wp-content/uploads/2022/04/cbounds.jpg)

Bounds over the primitives (blue) versus bounds over the primitive centroids (yellow).

The centroid bounds are quickly found using a loop over the primitives:

|   |   |
|---|---|
|1<br><br>2<br><br>3<br><br>4<br><br>5<br><br>6<br><br>7|float boundsMin = 1e30f, boundsMax = -1e30f;<br><br>    for (int i = 0; i < node.triCount; i++)<br><br>    {<br><br>        Tri& triangle = tri[triIdx[node.leftFirst + i]];<br><br>        boundsMin = min( boundsMin, triangle.centroid[a] );<br><br>        boundsMax = max( boundsMax, triangle.centroid[a] );<br><br>    }|

This replaces the two lines that read `boundsMin` and `boundsMax` directly from the node AABB. At 4 and 8 planes per dimension, this slightly improves the resulting tree, at negligible cost.

## Binning

The Unity vehicle mesh consists of about 12k triangles. Using the fixed planes, this now builds in mere milliseconds. But: it turns out that we can do much better than what we have so far.

Let’s have another look at the diagram with the evenly spaced planes:

![](https://jacco.ompf2.com/wp-content/uploads/2022/04/bins-1024x538.jpg)

Here, seven planes separate 8 intervals. Each of the primitive centroids projects to one of these intervals. We can now calculate the _bounds_ of each interval, and the _primitive count_ for each interval. Once we have this data for each interval, we can efficiently determine the union of the bounds of a range of intervals, as well as the sum of the primitive counts of a range of intervals. And this in turn is exactly what we need to evaluate the SAH; this time without visiting every primitive multiple times.

Let’s start with the definition of a _bin_, which will store an AABB and a primitive count:

|   |   |
|---|---|
|1|struct Bin { aabb bounds; int triCount = 0; };|

Next, we populate the bins by visiting the primitives once (per axis):

|   |   |
|---|---|
|1<br><br>2<br><br>3<br><br>4<br><br>5<br><br>6<br><br>7<br><br>8<br><br>9<br><br>10<br><br>11<br><br>12|Bin bin[BINS];<br><br>float scale = BINS / (boundsMax - boundsMin);<br><br>for (uint i = 0; i < node.triCount; i++)<br><br>{<br><br>    Tri& triangle = tri[triIdx[node.leftFirst + i]];<br><br>    int binIdx = min( BINS - 1,<br><br>        (int)((triangle.centroid[a] - boundsMin) * scale) );<br><br>    bin[binIdx].triCount++;<br><br>    bin[binIdx].bounds.grow( triangle.vertex0 );<br><br>    bin[binIdx].bounds.grow( triangle.vertex1 );<br><br>    bin[binIdx].bounds.grow( triangle.vertex2 );<br><br>}|

Here, `BINS` is the number of intervals.

The bin index for a primitive centroid is calculated as:

binIdx=(centroid[a]−boundsMin)∗8/(boundsMax−boundsMin)binIdx=(centroid[a]−boundsMin)∗8/(boundsMax−boundsMin)

To prevent the division per primitive, variable scale stores the non-varying part of this equation.

Once we have determined bounds and primitive counts for the bins, we can use this information to calculate the info we need at each plane. Our final goal is to evaluate the SAH at each plane. For this, we need the following information:

- The number of primitives to the left of the plane
- The number of primitives to the right of the plane
- The bounding box over the primitives to the left of the plane
- The bounding box over the primitives to the right of the plane.

We need this data per plane, so we store it in some arrays:

|   |   |
|---|---|
|1<br><br>2|float leftArea[BINS - 1], rightArea[BINS - 1];<br><br>int leftCount[BINS - 1], rightCount[BINS - 1];|

We can fill these arrays with a sweep over the bins. We will do a sweep from the left to the right to populate the `leftArea` and `leftCount` arrays, and a sweep from the right to the left to populate the `rightArea` and `rightCount`arrays. 

|   |   |
|---|---|
|1<br><br>2<br><br>3<br><br>4<br><br>5<br><br>6<br><br>7<br><br>8<br><br>9<br><br>10<br><br>11<br><br>12<br><br>13|aabb leftBox, rightBox;<br><br>int leftSum = 0, rightSum = 0;<br><br>for (int i = 0; i < BINS - 1; i++)<br><br>{<br><br>    leftSum += bin[i].triCount;<br><br>    leftCount[i] = leftSum;<br><br>    leftBox.grow( bin[i].bounds );<br><br>    leftArea[i] = leftBox.area();<br><br>    rightSum += bin[BINS - 1 - i].triCount;<br><br>    rightCount[BINS - 2 - i] = rightSum;<br><br>    rightBox.grow( bin[BINS - 1 - i].bounds );<br><br>    rightArea[BINS - 2 - i] = rightBox.area();<br><br>}|

Note that the sweep from left to right and from right to left happen simultaneously. Variable `leftBox` starts as an empty AABB. At each bin it is extended with the bounds of that bin. Likewise, `leftSum` (used for the summed triangle count) starts at zero and increases with the counts stored for each bin. The variables for the right side are updated in the same manner.

After the arrays have been filled we can evaluate the SAH for each plane:

|   |   |
|---|---|
|1<br><br>2<br><br>3<br><br>4<br><br>5<br><br>6<br><br>7|scale = (boundsMax - boundsMin) / BINS;<br><br>for (int i = 0; i < BINS - 1; i++)<br><br>{<br><br>    float planeCost = leftCount[i] * leftArea[i] + rightCount[i] * rightArea[i];<br><br>    if (planeCost < bestCost)<br><br>        axis = a, splitPos = boundsMin + scale * (i + 1), bestCost = planeCost;<br><br>}|

Once again, scale is used to prevent the repeated division.

The full Subdivide function is now a somewhat large chunk of code:

|   |   |
|---|---|
|1<br><br>2<br><br>3<br><br>4<br><br>5<br><br>6<br><br>7<br><br>8<br><br>9<br><br>10<br><br>11<br><br>12<br><br>13<br><br>14<br><br>15<br><br>16<br><br>17<br><br>18<br><br>19<br><br>20<br><br>21<br><br>22<br><br>23<br><br>24<br><br>25<br><br>26<br><br>27<br><br>28<br><br>29<br><br>30<br><br>31<br><br>32<br><br>33<br><br>34<br><br>35<br><br>36<br><br>37<br><br>38<br><br>39<br><br>40<br><br>41<br><br>42<br><br>43<br><br>44<br><br>45<br><br>46<br><br>47<br><br>48<br><br>49<br><br>50<br><br>51<br><br>52<br><br>53<br><br>54<br><br>55|float FindBestSplitPlane( BVHNode& node, int& axis, float& splitPos )<br><br>{<br><br>   float bestCost = 1e30f;<br><br>   for (int a = 0; a < 3; a++)<br><br>   {<br><br>      float boundsMin = 1e30f, boundsMax = -1e30f;<br><br>      for (int i = 0; i < node.triCount; i++)<br><br>      {<br><br>         Tri& triangle = tri[triIdx[node.leftFirst + i]];<br><br>         boundsMin = min( boundsMin, triangle.centroid[a] );<br><br>         boundsMax = max( boundsMax, triangle.centroid[a] );<br><br>      }<br><br>      if (boundsMin == boundsMax) continue;<br><br>      // populate the bins<br><br>      Bin bin[BINS];<br><br>      float scale = BINS / (boundsMax - boundsMin);<br><br>      for (uint i = 0; i < node.triCount; i++)<br><br>      {<br><br>         Tri& triangle = tri[triIdx[node.leftFirst + i]];<br><br>         int binIdx = min( BINS - 1,<br><br>            (int)((triangle.centroid[a] - boundsMin) * scale) );<br><br>         bin[binIdx].triCount++;<br><br>         bin[binIdx].bounds.grow( triangle.vertex0 );<br><br>         bin[binIdx].bounds.grow( triangle.vertex1 );<br><br>         bin[binIdx].bounds.grow( triangle.vertex2 );<br><br>      }<br><br>      // gather data for the 7 planes between the 8 bins<br><br>      float leftArea[BINS - 1], rightArea[BINS - 1];<br><br>      int leftCount[BINS - 1], rightCount[BINS - 1];<br><br>      aabb leftBox, rightBox;<br><br>      int leftSum = 0, rightSum = 0;<br><br>      for (int i = 0; i < BINS - 1; i++)<br><br>      {<br><br>         leftSum += bin[i].triCount;<br><br>         leftCount[i] = leftSum;<br><br>         leftBox.grow( bin[i].bounds );<br><br>         leftArea[i] = leftBox.area();<br><br>         rightSum += bin[BINS - 1 - i].triCount;<br><br>         rightCount[BINS - 2 - i] = rightSum;<br><br>         rightBox.grow( bin[BINS - 1 - i].bounds );<br><br>         rightArea[BINS - 2 - i] = rightBox.area();<br><br>      }<br><br>      // calculate SAH cost for the 7 planes<br><br>      scale = (boundsMax - boundsMin) / BINS;<br><br>      for (int i = 0; i < BINS - 1; i++)<br><br>      {<br><br>        float planeCost =<br><br>           leftCount[i] * leftArea[i] + rightCount[i] * rightArea[i];<br><br>        if (planeCost < bestCost)<br><br>           axis = a, splitPos = boundsMin + scale * (i + 1),<br><br>           bestCost = planeCost;<br><br>      }<br><br>   }<br><br>   return bestCost;<br><br>}|

But, it is worth it. Using eight bins the BVH now builds in just 11ms: almost three times faster than before. I did not time the version that considers only the longest axis of the node bounds, but that should take us close to 3ms for this mesh. And that is without any low-level optimizations and SIMD; there is still a lot of room for improvement if we go that route.

## What’s Next

Now that we can build a BVH this rapidly we are ready to consider animated scenes. Before we go there, two more ingredients are needed: refitting and rigid motion for BVHs using ray transforms. Combined with fast rebuilds, these ingredients unlock the full potential of the top-level BVH, which will finally let us ray trace massive scenes with large moving objects in real-time, even on a CPU. But that’s material for another day.

Continue reading in [article 4: rebuilding and refitting](https://jacco.ompf2.com/2022/04/26/how-to-build-a-bvh-part-4-animation/).