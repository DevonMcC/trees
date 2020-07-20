NB.* tree.ijs: tree-handling functions.

overview=. 0 : 0
The tree is a vector of integers where each element is the index of the parent node but with _1 for the root''s parent. This is handy for modeling directory trees and it works well for that.

Say we have a directory tree like this:

C:
|__n0
|   |_n00
|   |_n01
|
|__n1
    |__n10
    |   |__n100
    |__n11
    |   |__n110
    |   |__n111
    |   |__n112
    |__n12

We typically separate the tree structure from the corresponding vector of nodes which, in this case, are the directory or file names.
For example, we can translate the above tree as follows using breadth-first ordering:
[Index:     0    1     2     3      4       5      6      7       8       9       10       11]
   nmsb=. 'C:';'n0';'n1';'n00';'n01';'n10';'n11';'n12';'n100';'n110';'n111';'n112'
   trb=.  _1     0     0     1      1       2      2      2       5       6        6       6

We can also translate it using depth-first ordering:
[Index:     0     1    2       3     4      5      6        7      8        9       10       11]
   nmsd=. 'C:';'n0';'n00';'n01';'n1';'n10';'n100';'n11';'n110';'n111';'n112';'n12'
   trd=.  _1     0     1      1       0     4      5        4      7        7       7       4

Whichever we choose is not functionally significant: all the following code works the same on either version. This representation of trees is good for looking up an item and locating its parent, or joining sub-trees into a larger tree. By "good", we mean simple to code and fast-running.
)

whChild=: [: I. [ e. ]        NB.* whChild: where are children of x in tree y
whRoot=: [:I. _1=]            NB.* whRoot: where roots are in tree y
nextLevel=: [ whChild ]       NB.* nextLevel: indexes of descendents of x in tree y
whParent=: _1-.~]{[           NB.* whParent: index of parent; _1 means no parent.
whLeaves=: [: I. [: -. ] e.~ [: i.#     NB.* whLeaves: indexes into tree of leaf nodes.

NB.* countLevels: return vec of # levels below each node given tree y.
countLevels=: 3 : 0
   ix=. _1-.~whLeaves y [ numLevels=. 0$~#y [ ctr=. 0
   while. 0<#ix do.
       numLevels=. (ctr) ix}numLevels
       ix=. _1-.~~.ix{y [ ctr=. >:ctr
   end.       
   numLevels
 )
 
NB.* graftRoot: join one tree to another by grafting root onto an arbitrary node.
graftRoot=: 3 : 0
   'ot jn nt'=. y        NB. old tree;join-node;new tree
   ot,(_1=nt)}(nt+#ot),:jn
)

NB.* verifyTree: check that tree has >:1 root, no cycles, no unreachable nodes:
NB. 0 for bad node, 1 for good one.
verifyTree=: 3 : 0
   cc=. 0$~#y                 NB. Cycle counter
   nli=. whRoot y             NB. Next level indexes: start at root(s)
   cc=. (1+nli{cc) nli}cc     NB. Count # visits to node
   while. (0<#nli) *. 1=>./cc do.
       nli=. y nextLevel nli
       cc=. (1+nli{cc) nli}cc NB. Count # visits to node
   end.
  cc *. -.(_1=y) *. 1<+/_1= y    NB. Dis-allow forests
NB.EG (1 0;0 0;1 0 0) -: verifyTree &.> _1 1; 0 1; _1 2 1  NB. bad ones
NB.EG (1 1 1;1 1 1 1) -: verifyTree &.> _1 0 1; _1 0 _1 2  NB. good ones
NB.EG (0 0;0 1 0 1) -: verifyTree &.> _1 _1; _1 0 _1 2     NB. bad ones, multi-root
)

explainVerification=. 0 : 0
The "EG" comments at the end give examples of use and the results expected: each phrase should return a single "1" indicating the results match the outputs. The three initial bad trees fail verification (indicated by zeros corresponding to bad nodes) because the first one is cyclical because it has a node that is its own parent, the second one is cyclical and has no root, and the third has a cycle between 1 and 2.

Notice that we choose to treat multi-rooted trees as invalid only with the final condition. This is an arbitrary choice. Similarly, our exclusion of cycles is arbitrary as well. We could just as well allow forests or cycles if we wanted to generalize beyond trees to graphs of some kind.  However, this "parent index" scheme would allow for only a limited subset of graphs, so is not a good choice to represent more general graphs.
)

NB. pruneI: index representation
pruneI=: 3 : 0
   1 pruneI y       NB. 0: return tree pruned of branch; 1: return branch
:
   'br tree nodes'=. y
   whi=. gatherSubIxs br;tree
   if. x do. newNodes=. whi{nodes [ newTree=. (_1) 0}whi i. whi{tree
   else. newNodes=. rmix{nodes [ newTree=. rmix{tree-+/whi</tree [ rmix=. <^:3]whi end.
   newTree;<newNodes
)

NB.* gatherSubIxs: gather indexes of all sub-trees from a certain point all the way down.
gatherSubIxs=: 3 : 0
   len=. #br=. ,br [ 'br tree'=. y
   while. len~:#br=. ~.br,(i.#tree)#~tree e. br do. len=. #br end.
   br
)

NB. pruneB: Boolean representation
pruneB=: 3 : 0
   1 pruneB y       NB. 0: return tree pruned of branch; 1: return branch
:
   'br tree nodes'=. y
   whb=. gatherSubBools br;tree
   if. x do. newNodes=. whb#nodes [ newTree=. (_1) 0}(I. whb) i. whb#tree
   else. newNodes=. nodes#~-.whb [ newTree=. (-.whb)#tree-+/"1 tree>:/I. whb end.
   newTree;<newNodes
)

NB.* gatherSubBools: build Boolean showing where sub-branches are all the way down.
gatherSubBools=: 3 : 0
   br=. ,br [ 'br tree'=. y
   svWhb=. whb=. (1) br}0$~#tree     NB. Where is start of branch to prune?
   while. -.svWhb-:whb=. whb+.tree e. whb#i.#tree do. svWhb=. whb end.
   whb
)

NB.* pruneB_testcases_: test cases for "pruneB"
pruneB_testcases_=: 3 : 0
   nmsb=. 'C:';'n0';'n1';'n00';'n01';'n10';'n11';'n12';'n100';'n110';'n111';'n112'
   trb=.  _1     0     0     1      1       2      2      2       5       6        6       6
NB. prune at root node, returning pruned branch (=original tree)   
   assert. (trb;<nmsb) -: 1 pruneB 0;trb;<nmsb
NB. prune at root node, returning remaining tree -> nothing left
   assert. (a:,a:) -: 0 pruneB 0;trb;<nmsb  
   assert. (_1 0 0;<'n0';'n00';'n01') -: pruneB 1;trb;<nmsb
   assert. (_1 0;<'n10';'n100') -: pruneB 5;trb;<nmsb
   assert. ((,_1);<,<'n112') -: pruneB _1;trb;<nmsb
   assert. ((}:trb);<}:nmsb) -: 0 pruneB _1;trb;<nmsb
   assert. (_1 0 0 0 1 2 2 2;<'n1';'n10';'n11';'n12';'n100';'n110';'n111';'n112') -: 1 pruneB 2;trb;<nmsb
)
