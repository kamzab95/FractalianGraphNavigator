Purpose of this project is to represent memory efficient processing of GraphML files, 
and the folder-like visual data representation.

The goal was to allow loading GraphML of virtialy infinite size (caped only by the device's disk size).

The graph file is steamed and saved in batches to CoreData.
Altrough initial processing of the file takes some time, the memory usage is mostly constant.
Thanks to proper indexing, reading the data is very fast - almost instant from the user perspective. 

## Run the project:

Open `FractalianGraphNavigator/FractalianGraphNavigator.xcworkspace` in Xcode 14.2 or later.


## Usage:
1. Use picker to select graphML file (few preview files are already added to bundle)


![image](https://github.com/kamzab95/FractalianGraphNavigator/assets/16488919/8ec5729b-706c-4a64-ba8a-27189dbd63df)

2. Press "Process"
It loads the graph to CoreData for efficient indexing and to save memory 
The whole graph is never kept in memory, so there is virtualy no limit to its size. Large files just will be processed a bit longer.
The largest graph is "random_graph" and it consists milions of nodes and edges.


3. From "Existing graph" list, select graph that you want to open.


![image](https://github.com/kamzab95/FractalianGraphNavigator/assets/16488919/e6de5c40-5489-4681-8c08-de956e282666)

4. You will see the screen that represents "Folders" of x depth (currently hardoced to be 3 lvl deep). You can tap on any node to open it.


![image](https://github.com/kamzab95/FractalianGraphNavigator/assets/16488919/cc95ce44-9a82-4619-bb52-0980f1f09c95)


Additionaly:
organic_2 graph has data within each node. Those data are also being stored in CoreData. If the node has some data, it will be displayed in Json format.


![image](https://github.com/kamzab95/FractalianGraphNavigator/assets/16488919/03398323-8603-46cc-9869-987329d6990d)










