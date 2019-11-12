import matplotlib.pyplot as plt
import numpy as np

zether_2set = [5544, 5725, 5990, 5536, 6456, 5799, 6024, 6130, 5604, 5429, 6242, 6111, 6082, 5839, 6100, 6122, 5503, 6440, 4747, 6072, 6094, 6844, 6017, 4999, 6039, 7065, 4898, 6019, 6239, 6777, 4965, 7149, 4900, 6015, 6048, 7046, 4662, 6327, 7331, 4643, 6792, 6206, 5887, 6034, 5739, 5534, 5586, 7021]
zether_4set = [7920, 6297, 6083, 5342, 6035, 5952, 5603, 5204, 5098, 5992, 6208, 5913, 5674, 6423, 5884, 6075, 6061, 6003, 4502, 5424, 9420, 6715, 6294, 10284, 6152, 5817, 6148, 5946, 5532, 6388, 5872, 5209, 6106, 8203, 5553, 10150, 6293, 5941, 5766]
zether_16set = [7933, 10217, 8068, 7731, 10334, 9188, 9932, 8801, 10841, 10087, 9939, 9910, 9708, 11501, 8051, 10704, 9819, 13509]

#aztec_basic = [711, 709, 737, 738, 721, 824, 711, 725, 737, 748]
aztec_2set = [2653, 2783, 2688, 2615, 2800, 2656, 2830, 2701, 2638, 2686, 2739, 2607, 2616, 2676, 2667, 2751, 2668, 2656, 2762, 2624]
aztec_4set = [2885, 2698, 2665, 2827, 2639, 2814, 2624, 2686, 2980, 2718, 3084, 2727, 2713, 2640, 3169, 2673, 2633, 2657, 2620, 2612]
aztec_16set = [4286, 5132, 6772, 4385, 4357, 4297, 4310, 4262, 5341, 4148, 4321, 4329, 4144, 4131, 4512, 4234, 4367, 4271, 4105, 4291]

## ---- STACKED ----
zether = [zether_2set, zether_4set, zether_16set]
aztec = [aztec_2set, aztec_4set, aztec_16set]

zm = []
zstd = []
for a in zether:
	arr = np.array(a)
	zm.insert(len(zm), np.mean(arr))
	zstd.insert(len(zstd), np.std(arr))

azm = []
azstd = []
for a in aztec:
	arr = np.array(a)
	azm.insert(len(azm), np.mean(arr))
	azstd.insert(len(azstd), np.std(arr))

#print(zm, zstd)
#print(azm, azstd)

## adjust AZTEC results (anonymity set is useful)
for i, v in enumerate(azm):
	if i == 0:
		azm[i] = azm[i]/2
	if i == 1:
		azm[i] = azm[i]/4
	if i == 2:
		azm[i] = azm[i]/16

ind = np.arange(3)
width = 0.35 # the width of the bars: can also be len(x) sequence

p1 = plt.bar(ind, azm, width, color='orange') # yerr=azstd,
p2 = plt.bar(ind, zm, width, bottom=azm) # yerr=zstd, 

plt.ylabel('Time (ms)')
plt.title('# of anonymity set')
plt.xticks(ind, ('', '2', '4', '16'))
plt.yticks(np.arange(0, 11000, 1000))
plt.xticks(np.arange(-1, 4, 1))
plt.legend((p1[0], p2[0]), ('AZTEC', 'Anonymous Zether'), loc=2)

plt.show()

## ---- BOXPLOT ----

# fig = plt.figure()
# #fig.suptitle('Anonymous Zether')
# ax = fig.add_subplot(111)
# ax.set_xlabel('Anonymity set size')
# ax.set_ylabel('Time(ms)')

# #ax.text(1, 10, 'Aztec')
# ax.text(1, 2200, 'AZTEC', fontsize=10)
# ax.text(2, 2200, 'AZTEC', fontsize=10)
# ax.text(3, 3500, 'AZTEC', fontsize=10)

# ax.text(1, 4000, 'AnonZether', fontsize=10)
# ax.text(2, 4000, 'AnonZether', fontsize=10)
# ax.text(3, 7000, 'AnonZether', fontsize=10)

# data_zether = [zether_2set, zether_4set, zether_16set]
# #data_aztec = [aztec_basic]
# data_aztec = [aztec_2set, aztec_4set, aztec_16set]

# plt.boxplot(data_aztec)
# plt.boxplot(data_zether)

# plt.legend()
# plt.show()
