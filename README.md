Purpose of this project is to represent memory efficient processing of GraphML files, 
and the folder-like visual data representation.

The goal was to allow loading GraphML of virtialy infinite size (caped only by the device's disk size).

The graph file is steamed and saved in batches to CoreData.
Altrough initial processing of the file takes some time, the memory usage is mostly constant.
Thanks to proper indexing, reading the data is very fast - almost instant from the user perspective. 
