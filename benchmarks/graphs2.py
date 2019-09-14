import numpy as np
import pandas as pd
import seaborn

seaborn.set(style='ticks')

df = pd.DataFrame(np.arange(10), columns=['val'])
df['class'] = df['val'].apply(lambda x: 'Odd' if x % 2 else "Even")
seaborn.boxplot(x='class', y='val', data=df, width=0.5)
seaborn.despine(offset=10, trim=True)
