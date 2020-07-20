# trees
J routines for manipulating trees in "parent-index" form.
Documentation on these routines: https://code.jsoftware.com/wiki/User:Devon_McCormick/Trees .

# Explanation and Examples
The "parent-index" form to represent a tree is simply an integer vector where each item is the index of its parent but the root is indicated by _1.

For example, here is a simple tree represented by the tree structure "tr0".  The "nms0" vector is an arbitrary list of names for each node in the tree.

   tr0=. _1 0 0 1 2 [ nms0=. 'Root';'Node0';'Node1';'Node00';'Node10'
   tree (}.tr0{nms0),.}.nms0
+---------------------------+
|        ┌─ Node0 ─── Node00|
|─ Root ─┴─ Node1 ─── Node10|
+---------------------------+

The "tree" routine to display this can be found here: https://code.jsoftware.com/wiki/Essays/Tree_Display .

Here is a slightly more complex example representing a directory tree rooted at "C:" with the nodes (sub-directories)
named to indicate their place in the hierarchy.

C: 
|__n0         
|   |_n00    
|   |_n01
|__n1         
    |__n10     
    |   |__n100     
    |__n11     
    |   |__n110     
    |   |__n111     
    |   |__n112     
    |__n12     

To understand the representation of this tree - "trb" below - we line it up here with both the indexes of each item and with names of the corresponding nodes:

NB. Index: 0    1    2    3     4     5     6     7     8      9      10     11
   nmsb=. 'C:';'n0';'n1';'n00';'n01';'n10';'n11';'n12';'n100';'n110';'n111';'n112'
   trb=.  _1    0   0     1     1     2     2     2     5      6      6      6

So, the node named "C:" is the root as indicated by the _1 corresponding to it.  The next two nodes, "n0" and "n1", have as their parents the root's index 0.  Since "n0" is at index 1, its child nodes "n00" and "n01" correspond to the 1s in "trb", and so on for the rest.

We can use the routines found at https://code.jsoftware.com/wiki/Essays/Tree_Display to display the structure of this tree:

   EW=: {: BOXC=: 11{.16}.a.      NB. Line-drawing characters             
   tree (}.trb{nmsb),.}.nmsb                                  
+----------------------------+                                  
|             ┌─ n00         |                                  
|      ┌─ n0 ─┴─ n01         |                                  
|      │      ┌─ n10 ─── n100|                                  
|─ C: ─┤      │       ┌─ n110|                                  
|      └─ n1 ─┼─ n11 ─┼─ n111|                                  
|             │       └─ n112|                                  
|             └─ n12         |                                  
+----------------------------+                                  

## Examples of Using "Prune" and "Graft" to Re-arrange the Nodes of a Tree

To convert initial tree to the following, first split off the "n0" branch:

   'trb0 nms0 trb1 nms1'=. ;0 1 pruneB &.><(nmsb i. <'n0');trb;<nmsb
   trb0                       NB. Tree without pruned branch
_1 0 1 1 1 2 3 3 3
   nms0
+--+--+---+---+---+----+----+----+----+
|C:|n1|n10|n11|n12|n100|n110|n111|n112|
+--+--+---+---+---+----+----+----+----+
   trb1                       NB. Pruned branch
_1 0 0
   nms1
+--+---+---+
|n0|n00|n01|
+--+---+---+
   nms=. nms0,nms1                            NB. All names for new combined tree
   tr=. graftRoot trb0;(nms0 i. <'n100');trb1 NB. Graft pruned branch to node "n100".
   tree (}.tr{nms),.}.nms
+-------------------------------------------+
|                                     ┌─ n00|
|             ┌─ n10 ─── n100 ─── n0 ─┴─ n01|
|             │       ┌─ n110               |
|─ C: ─── n1 ─┼─ n11 ─┼─ n111               |
|             │       └─ n112               |
|             └─ n12                        |
+-------------------------------------------+
