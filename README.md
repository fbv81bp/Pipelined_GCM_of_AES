# Pipelined GCM module for AES-GCM

In this repository i publish my research and results to create a 10 to 40Gb/s fast AES-GCM module's Galois multiplication based hash. It turns out it is possible even in a Xilinx Artix 7 device with heavy pipelining. This pipelining unfortunatly means that the core has to be initialized with the H constant's multiples and so many of them as many pipeline stages there are. This is a bit of a burden, because it will only worth it if very large amounts of data are processed with the same H, otherwise the initialisation will take the bulk of time.
