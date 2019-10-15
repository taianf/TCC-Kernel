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

summarySchema = StructType([
    StructField("run", IntegerType(), False),
    StructField("latency", IntegerType(), False),
    StructField("type", StringType(), False)
])

summary = spark.createDataFrame([], summarySchema)

for test in files:
    csv = spark.read \
        .option("header", "true") \
        .option("inferSchema", "true") \
        .csv("" + test + ".csv")

    view = csv.filter("ktime_mono_fast != '0'")
    view.createOrReplaceTempView(test)

    temp = sqlCtx.sql(
        "SELECT run, int(max(ktime_mono_fast) - min(ktime_mono_fast)) latency, '" + test +
        "' type FROM " + test + " WHERE name in ('irq', 'softirq','tasklet','work') GROUP BY run"
    )

    final = temp.filter("latency != 0")

    final.cache()
    final.describe().toPandas().to_csv("spark-" + test + "-describe.csv", index=False)
    final.toPandas().sort_values("run").to_csv("spark-" + test + "-summary.csv", index=False)

    summary = summary.union(final)

summary.cache()
summary.describe().toPandas().to_csv("spark-summary-describe.csv", index=False)
summary.toPandas().sort_values(["type", "run"]).to_csv("spark-summary.csv", index=False)

spark.stop()
