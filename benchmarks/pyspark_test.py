from __future__ import print_function

from pyspark.sql import SQLContext
from pyspark.sql import SparkSession
from pyspark.sql.types import *

spark = SparkSession \
    .builder \
    .appName("LatencySummary") \
    .getOrCreate()

sqlCtx = SQLContext(spark)

files = [
    "ps0",
    "ps1",
    "psm",
    "pt0",
    "pt1",
    "ptm",
    "pw0",
    "pw1",
    "pwm",
    "rs0",
    "rs1",
    "rsm",
    "rt0",
    "rt1",
    "rtm",
    "rw0",
    "rw1",
    "rwm"
]

schema = StructType([
    StructField("run", IntegerType(), True),
    StructField("latency", DoubleType(), True),
    StructField("type", StringType(), False)
])

summary = spark.createDataFrame([], schema)

for test in files:
    view = spark.read \
        .option("header", "true") \
        .option("inferSchema", "true") \
        .csv("" + test + ".csv")

    view.createOrReplaceTempView(test)

    temp = sqlCtx.sql(
        "SELECT run, max(ktime_mono_fast) - min(ktime_mono_fast) latency, '" + test +
        "' type FROM ps0 WHERE name in ('irq', 'softirq') AND ktime_mono_fast <> '0' GROUP BY run"
    )

    summary = summary.union(temp)

# summary.createOrReplaceTempView("summary")
# summary = sqlCtx.sql(
#         "SELECT * FROM summary ORDER BY type"
#     )
summary.cache()
# summary.printSchema()
# summary.show()
summary.describe().show()
summary \
    .toPandas() \
    .sort_values(["type", "run"]) \
    .to_csv("summary-spark.csv", index=False)
spark.stop()
