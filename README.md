Boundary Redis Plugin
---------------------

Collects metrics from an instance of a Redis database.

### Platforms
- Windows
- Linux
- OS X
- SmartOS

### Prerequisites
- node version 0.8.0 or later
- npm version 1.4.21 or later

### Plugin Setup

None

### Plugin Configuration Fields

|Field Name|Description                                            |
|:-------|:------------------------------------------------------|
|Source  |The source to display in the legend for the REDIS data.|
|Port    |The redis port.                                        |
|Host    |The redis hostname.                                    |
|Password|Password to the redis server.                          |

### Metrics Collected
|Metric Name               |Description|
|:-------------------------|:|
|Redis Connected Clients   ||
|Redis Key Hits            ||
|Redis Key Misses          ||
|Redis Keys Expired        ||
|Redis Key Evictions       ||
|Redis Connections Received||
|Redis Commands Processed  ||
|Redis Used Memory         ||

