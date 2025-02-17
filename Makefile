all: png

png: plot/internet-access.png

plot/internet-access.png:
	Rscript internet-access.r
