Boundary Redis Plugin
---------------------

Collects metrics from an instance of a Redis database.

### Prerequisites

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |    v    |    v    |  v   |

#### For Boundary Meter V4.0
(to update/download - curl -fsS -d '{"token":"api.<Your API Key Here>"}' -H 'Content-Type: application/json' https://meter.boundary.com/setup_meter > setup_meter.sh && chmod +x setup_meter.sh && ./setup_meter.sh)

|  Runtime | node.js | Python | Java |
|:---------|:-------:|:------:|:----:|
| Required |         |        |      |

#### For Boundary Meter less than V4.0

|  Runtime | node.js | Python | Java |
|:---------|:-------:|:------:|:----:|
| Required |    +    |        |      |

- [How to install node.js?](https://help.boundary.com/hc/articles/202360701)

### Plugin Setup

#### For All Versions

None

#### Plugin Configuration Fields

#### For All Versions

|Field Name  |Description                                            |
|:-----------|:------------------------------------------------------|
|Source      |The source to display in the legend for the REDIS data.|
|Port        |The redis port.                                        |
|Host        |The redis hostname.                                    |
|Password    |Password to the redis server.                          |
|PollInterval|Interval to query the redis server.                    |

### Metrics Collected

#### For All Versions

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
