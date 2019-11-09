from datetime import datetime

from pyspark.sql import SQLContext
from pyspark.sql import SparkSession
from pyspark.sql.types import *

start = datetime.now()

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

summary_opts = []

percentils_string = list(map(lambda x: str(x / 10) + "%", range(1001)))

summary_opts += percentils_string[int((len(percentils_string) * (9 / 10))):]

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

summary2 = summary.drop("run").summary(summary_opts).toPandas()
summary2.to_csv("spark-results/summary-percentil.csv", index=False, sep=";")
# summary2.to_latex("spark-results/summary-rpi.tex", index=False)

spark.stop()

print("Total time: " + str(datetime.now() - start))
