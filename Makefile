all: png

png: plot/internet-access.png

plot/internet-access.png:
	Rscript -e "targets::tar_make()"

clean:
	rm plot/internet-access.png

cleanall: clean
	rm -rf _targets
