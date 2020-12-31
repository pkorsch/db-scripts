--change database
use admin

-- show all granted databases
show dbs
db.adminCommand( { listDatabases: 1 } )

-- database statistics
db.stats()

-- all collection info or specific db.getCollectionInfos( { name: "employees" } )  
use DATABASE_NAME
db.getCollectionInfos();

-- show all db parameters
db.adminCommand( { getParameter : '*' } )

-- get indexes for collection
db.collection.getIndexes()

-- show profiling level
db.getProfilingStatus()

-- show users or specific user ex. db.getUser("arminUser")
show users
db.getUsers()

-- switch logfile
db.adminCommand( { logRotate : 1 } )

-- current operations
db.currentOp()

-- kill operation
db.adminCommand( { "killOp": 1, "op": operation_id } )

-- current replicaset configuration
rs.conf()

-- current status of replicaset
rs.status()

-- replication lag
rs.printSlaveReplicationInfo()

-- shutdown now or with timer
db.shutdownServer()
db.adminCommand({ "shutdown" : 1, timeoutSecs: 60 })
