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
    StructField("run", IntegerType(), False)
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
        "SELECT run, int(max(ktime_mono_fast) - min(ktime_mono_fast)) " + test +
        " FROM " + test + " WHERE name in ('irq', 'softirq','tasklet','work') GROUP BY run"
    )

    final = temp.filter(test + " != 0")
    final.cache()
    final.describe().toPandas().to_csv("spark-" + test + "-describe.csv", index=False)
    final.toPandas().sort_values(test).to_csv("spark-" + test + "-summary.csv", index=False)
    plot = final.toPandas().plot(x="run", y=test, kind='scatter')
    fig = plot.get_figure()
    fig.savefig(test + ".png")

    summary = summary.join(final, on=['run'], how='full')

summary.cache()
summary.describe().toPandas().to_csv("spark-summary-describe.csv", index=False)
summary.toPandas().sort_values("run").to_csv("spark-summary.csv", index=False)

spark.stop()
