from pyspark.sql import SQLContext
from pyspark.sql import SparkSession
from pyspark.sql.types import *

spark = SparkSession \
    .builder \
    .appName("LatencySummary") \
    .master("local[*]") \
    .config("spark.sql.execution.arrow.enabled", "true") \
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

summary_opts = [
    # "count",
    "mean",
    "stddev",
    # "min",
    # "25%",
    # "50%",
    # "75%",
    "90%",
    "95%",
    "96%",
    "97%",
    "98%",
    "99%",
    "max"
]

summarySchema = StructType([
    StructField("run", IntegerType(), False)
])

summary = spark.createDataFrame([], summarySchema)

for test in files:
    csv = spark.read \
        .option("header", "true") \
        .option("inferSchema", "true") \
        .csv("consolidated-results/" + test + ".csv")

    view = csv.filter("ktime_mono_fast != '0'")
    view.createOrReplaceTempView(test)

    temp = sqlCtx.sql(
        "SELECT run, int(max(ktime_mono_fast) - min(ktime_mono_fast)) " + test + " FROM " + test +
        " WHERE name in ('irq', 'softirq','tasklet','work') GROUP BY run"
    )

    final = temp.filter(test + " != 0")

    summary = summary.join(final, on=['run'], how='full')

summary.cache()
summary.toPandas().sort_values("run").to_csv("spark-results/merged.csv", index=False, float_format='%.0f')
summary2 = summary.drop("run").summary(summary_opts).toPandas().round(2).T.reset_index()
summary2.cache()
summary2.to_csv("spark-results/summary.csv", header=False, index=False, float_format='%.2f')
summary2.to_latex("spark-results/summary.tex", header=False, index=False, float_format='%.2f')

spark.stop()
