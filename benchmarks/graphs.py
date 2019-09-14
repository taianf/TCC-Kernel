import matplotlib.pyplot as plt
import pandas
import seaborn

# seaborn.set(style='whitegrid')

data = pandas.read_csv('summary.csv', sep=';')

seaborn.boxplot(x='type', y='latency', data=data, width=0.5)
# seaborn.despine(offset=10, trim=True)

# type_data = data.groupby('type')
# type_data.boxplot(column=['latency'])

plt.grid(True)
plt.show()
