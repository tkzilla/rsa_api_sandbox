import matplotlib.pyplot as plt
import numpy as np

# open file with read permissions
with open('iq_stream_test.siq', 'rb') as f:
    # if siq file, skip header
    if f.name[-1] == 'q':
        f.seek(1024)
    # read in data as int16
    d = np.frombuffer(f.read(), dtype=np.int16)
# separate i and q from interleaved data
i = d[0:-1:2]
q = d[1:-1:2]

# plot the first 10k samples
plt.plot(i[:10000])
plt.plot(q[:10000])
plt.show()
