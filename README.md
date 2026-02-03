# ksqlDB Workshop — Getting Started with Streaming SQL

### Overview
ksqlDB is a database for building stream processing applications on top of Apache Kafka. It is **distributed**, **scalable**, **reliable**, and **real-time**. ksqlDB combines the power of real-time stream processing with the approachable feel of a relational database through a familiar, lightweight SQL syntax.
<p align="center">
  <img src="Image/ksqldb-kafka-db.png" width="600"/>
</p>

### How ksqlDB work with Kafka
ksqlDB separates its distributed compute layer from its distributed storage layer, for which it uses Apache Kafka.
<p align="center">
  <img src="Image/ksqldb-kafka.png" width="400"/>
  <img src="Image/ksql.svg" width="400"/>
</p>

ksqlDB allows us to read, filter, transform, or otherwise process streams and tables of events, which are backed by Kafka topics. We can also join streams and/or tables to meet the needs of our application. And we can do all of this using familiar SQL syntax.

### Basic standing concept on ksqlDB
#### Stream and Table
**Stream** is a partitioned, immutable, append-only collection that represents a series of historical facts. Once a row is inserted into a stream, it can never change. New rows can be appended at the end of the stream, but existing rows can never be updated or deleted.

**Table** table is a mutable, partitioned collection that models change over time. In contrast with a stream, which represents a historical sequence of events, a table represents what is true as of “now”. 

<p align="center">
  <img src="Image/Stream-GIF.gif" width="500"/>
</p>

#### Materialized views (Stateful)
You can use ksqlDB to build a materialized view of state on a specific server by using RocksDB, driven by the events in an Apache Kafka topic. This is done using SQL aggregation functions, such as COUNT and SUM .
