# Graph Maker: user guide

Graph Maker is a mobile app for drawing weighted graphs with your finger and analysing them. A graph is made of **nodes** (circles) and **edges** (lines or arrows between nodes). Every edge has a **weight** (a number). Edges can be **directed** (one-way arrow) or **non-directed** (works both ways, no arrow).

The app has four screens: the **Graph screen** (home, where you draw), the **Adjacency Matrix screen**, the **Hungarian Assignment screen** and the **AI Assistant** (this chat).

## Graph screen: drawing and editing

### Create a node
Tap an empty spot on the canvas. New nodes are named automatically: A, B, C ... Z, then AA, AB and so on. A node cannot be created too close to another node; the app shows "Can't create a node that close to another".

### Rename or recolor a node
Tap a node. The "Edit node" window has two tabs: **Name** (type a new name) and **Color** (pick a color). Press **Save** to apply or **Cancel** to discard.

### Move a node
Press and hold a node for about half a second (the phone gives a small vibration), then drag it and release. A node cannot be dropped too close to another node; the app shows "Can't move a node that close to another" and the node stays where it was.

### Create an edge
Press a node, drag to another node and release on it. A "Set weight" window opens:
- Choose **Directed** (one-way arrow, the default) or **Non-directed** (no arrow, works both ways).
- Type the weight. Decimals and negative numbers are accepted (for example 6.54). If the text is not a valid number, nothing happens and the window stays open.
- Press **Save** to create the edge or **Cancel** to abort.

To create a self-loop (an edge from a node to itself), drag from a node and release on the same node. The loop is drawn as a small ring next to the node.

Rules about edges:
- Only one edge is allowed for the same source and target. If it already exists, the app says "An edge already exists between these nodes".
- If a non-directed edge already exists between two nodes, you cannot add another edge between them in the opposite direction.
- If a directed edge already exists in the opposite direction and you create a non-directed edge, the old one is replaced by the single non-directed edge.
- An edge weight cannot be edited afterwards. To change it, delete the edge and create it again.

### Delete a node or an edge
Double-tap a node to delete it. All edges connected to that node are deleted too. Double-tap an edge to delete only that edge.

### Undo
The undo arrow in the top bar reverses the last change (up to 20 steps). It is greyed out when there is nothing to undo. Some actions, such as editing a node or replacing an opposite edge, may need more than one press to fully undo.

### Clear graph
The sweep-bin icon in the top bar removes every node and edge. It can be undone with the undo arrow.

### Save a graph
The save icon in the top bar asks for a name and stores the graph on the phone. If a saved graph with that name already exists, the app asks "Replace existing save?".

### Open a graph
The folder icon in the top bar lists your saved graphs. Tap a name to load it (this replaces the graph on screen and can be undone). Tap the trash icon next to a name to delete that saved graph permanently. Deleting a saved graph does not change the graph currently on screen.

## How the graph is drawn
- The number next to an edge is its weight.
- An arrowhead means the edge is directed. No arrowhead means it is non-directed.
- Edge colors: **orange** for edges pointing to the right, **cyan** for edges pointing to the left, **purple** for self-loops, **green** for edges in the Hungarian solution. While you drag to create an edge, a blue line follows your finger.
- If two edges connect the same pair of nodes in opposite directions, they are drawn side by side so they do not overlap.

## Adjacency Matrix screen
Open it with the round **M[x]** button at the bottom right of the Graph screen. It shows the graph as a table:
- **Rows** are the source nodes (where edges start). **Columns** are the target nodes (where edges end).
- Each cell holds the weight of the edge from the row node to the column node. **0 means there is no edge.**
- Rows for nodes with no outgoing edges and columns for nodes with no incoming edges are hidden, so the table is not always square.
- The **Attributes leaving** column is the sum of the weights of each row. **Grade** (right column) is the number of edges leaving that node.
- The bottom rows show **Attributes arriving** (sum of each column) and **Grade** (number of edges arriving at that node).
- A non-directed edge counts in both directions.
- The table scrolls in both directions. With no nodes it shows "No nodes yet".
- Press the **M[x]** button again, or use the back arrow, to return to the Graph screen.

## Hungarian Assignment screen
Open it with the round **flag** button above the M[x] button on the Graph screen. The Hungarian algorithm solves the assignment problem: it picks a set of edges so that every source node is used at most once and every target node is used at most once, with the best possible total weight.

How to use it:
1. The screen opens with a **copy** of your graph. The copy cannot be edited, and your real graph is never changed from this screen.
2. A window asks for the goal: **Minimize** (smallest total weight) or **Maximize** (largest total weight).
3. The edges that belong to the best assignment are drawn in **green**.
4. Use the back arrow to return to the Graph screen. To try the other goal, open the screen again.

Good to know:
- Only real edges can be selected. Edges with weight 0 or a negative weight are ignored by this algorithm.
- If no assignment exists, the app shows "No assignment found in this graph".
- It works best on graphs where some nodes only have outgoing edges (workers) and others only have incoming edges (jobs), but it also works on general graphs.

## AI Assistant (chat)
Open it with the chat-bubble icon in the top bar of the Graph screen. You can ask how to use any feature of the app, or ask about the graph currently on screen (nodes, edges, weights). It needs an internet connection. The conversation is not saved: closing the chat screen clears it.

About the graph information the assistant receives: it gets a list of node names and a list of edges. Edges refer to nodes by internal ids (n0, n1, n2 ...), which are given in the order the nodes were created. If nodes were deleted or renamed, the link between an id and a name may be uncertain. In that case say so instead of guessing.

## Not available yet
- Editing an existing edge weight (delete and recreate the edge instead).
- Multiple edges with the same source and target.
- Algorithms other than the Hungarian assignment.
