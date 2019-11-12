import numpy as np
import matplotlib.pyplot as plt


N = 3
zetherMean = (20, 35, 30)
aztecMean = (25, 32, 34)
#menStd = (2, 3, 4, 1, 2)
#womenStd = (3, 5, 2, 3, 3)
ind = np.arange(N)    # the x locations for the groups
width = 0.35       # the width of the bars: can also be len(x) sequence

p1 = plt.bar(ind, zetherMean, width, color='orange') #yerr=menStd
p2 = plt.bar(ind, aztecMean, width, bottom=zetherMean) #yerr=womenStd

plt.ylabel('Time (ms)')
plt.title('# of anonymity set')
plt.xticks(ind, ('', '2', '4', '16'))
plt.yticks(np.arange(0, 81, 10))
plt.xticks(np.arange(-1, 4, 1))
plt.legend((p1[0], p2[0]), ('Anonymous Zether', 'AZTEC'))

plt.show()
