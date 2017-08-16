import numpy as np
import pickle
import matplotlib.pyplot as plt
import pandas as pd

# traceFile = 'C:\\users\\mallison\\documents\\github\\rsa_api_sandbox' \
#            '\\classifier\\traces.csv'
# traceFile = 'traces.csv'
# with open(traceFile, 'rb') as f:
#     df = pd.read_csv(f)
#     traces = df.as_matrix()

# featuresFile  = 'C:\\users\\mallison\\documents\\github\\rsa_api_sandbox' \
#            '\\classifier\\ism_features.csv'
featuresFile = 'ism_features.csv'
with open(featuresFile, 'rb') as f:
    data = pd.read_csv(f)
    colIndexer = ['TP{}'.format(i) for i in range(801)]
    print(colIndexer)
    traces = data.as_matrix(columns=colIndexer)
N, D = data.shape
print('N: {} D: {}'.format(N, D))

Y = np.zeros(N)

for i in range(N):
    plt.plot(traces[i], color='y')
    plt.show()
    sClass = 91
    while sClass < -1 or sClass > 2:
        try:
            sClass = int(input('{}: 0 = 802.11b/g, 1 = 802.11n '
                               '2 = Bluetooth, -1 = error> '.format(i)))
        except ValueError:
            pass
    Y[i] = sClass

Ydf = pd.DataFrame(Y)
data['class'] = Ydf

fileName = 'dataset.csv'
f = open(fileName)

try:
    oldData = pd.read_csv(fileName)
    result = pd.concat([oldData, data])
    result.to_csv(fileName, index=False)
except pd.errors.EmptyDataError:
    print('Empty file.')
    data.to_csv(fileName, index=False)

f.close()
